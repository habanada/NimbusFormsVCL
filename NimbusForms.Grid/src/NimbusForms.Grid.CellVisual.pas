unit NimbusForms.Grid.CellVisual;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.VisualImage,
  NimbusForms.Grid.VisualAction;

type
  TThemedGridVisualContentAlignment = (Near, Center, Far);

  TThemedGridVisualImagePlacement = (Left, Right, Top, Bottom, LeftAndRight);

  TThemedGridVisualTextTrimming = (None, Character, Word, EllipsisCharacter, EllipsisWord);

  TThemedGridCellVisual = class
  private
    FText: string;
    FToolTip: string;
    FTag: TValue;
    FImages: TObjectList<TThemedVisualImage>;
    FImageSizes: TList<Integer>;
    FActions: TThemedGridVisualActionCollection;
    FImageSize: Integer;
    FImageSpacing: Integer;
    FTextSpacing: Integer;
    FPadding: Integer;
    FEnabled: Boolean;
    FImagePlacement: TThemedGridVisualImagePlacement;
    FContentAlignment: TThemedGridVisualContentAlignment;
    FTextTrimming: TThemedGridVisualTextTrimming;
    FForeColor: TThemeColor;
    FHasForeColor: Boolean;
    FCurrentColor: TThemeColor;
    FHasCurrentColor: Boolean;
    FActionsApplied: Boolean;
    function GetHasText: Boolean;
    function GetHasImages: Boolean;
    procedure SetForeColor(const AValue: TThemeColor);
    procedure SetCurrentColor(const AValue: TThemeColor);
    procedure ResetDefaults;
    function CreateImageFromAction(const AAction: TThemedGridVisualAction): TThemedVisualImage;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddImage(const AImage: TThemedVisualImage): Integer; overload;
    function AddImage(const AKey: string; const AGraphic: TGraphic): Integer; overload;
    function AddSvgFile(const AKey, AFileName: string): Integer;
    function AddSvgText(const AKey, ASvgText: string): Integer;
    function AddImageFile(const AKey, AFileName: string): Integer;
    function AddImageListKey(const AKey, AImageListKey: string): Integer;
    procedure SetImageSize(const AImageIndex, ASize: Integer);
    function GetImageSize(const AImageIndex: Integer): Integer;
    procedure EnsureActionImages;
    function Clone: TThemedGridCellVisual;
    procedure ClearForeColor;
    procedure ClearCurrentColor;
    class function FromText(const AText: string): TThemedGridCellVisual; static;
    class function FromImageAndText(const AImage: TThemedVisualImage; const AText: string): TThemedGridCellVisual; static;
    property Text: string read FText write FText;
    property ToolTip: string read FToolTip write FToolTip;
    property Tag: TValue read FTag write FTag;
    property Images: TObjectList<TThemedVisualImage> read FImages;
    property ImageSizes: TList<Integer> read FImageSizes;
    property Actions: TThemedGridVisualActionCollection read FActions;
    property ImageSize: Integer read FImageSize write FImageSize;
    property ImageSpacing: Integer read FImageSpacing write FImageSpacing;
    property TextSpacing: Integer read FTextSpacing write FTextSpacing;
    property Padding: Integer read FPadding write FPadding;
    property Enabled: Boolean read FEnabled write FEnabled;
    property ImagePlacement: TThemedGridVisualImagePlacement read FImagePlacement write FImagePlacement;
    property ContentAlignment: TThemedGridVisualContentAlignment read FContentAlignment write FContentAlignment;
    property TextTrimming: TThemedGridVisualTextTrimming read FTextTrimming write FTextTrimming;
    property ForeColor: TThemeColor read FForeColor write SetForeColor;
    property HasForeColor: Boolean read FHasForeColor;
    property CurrentColor: TThemeColor read FCurrentColor write SetCurrentColor;
    property HasCurrentColor: Boolean read FHasCurrentColor;
    property HasText: Boolean read GetHasText;
    property HasImages: Boolean read GetHasImages;
  end;

  TThemedGridVisualHitInfo = class
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FVisualIndex: Integer;
    FBounds: TRect;
    FImage: TThemedVisualImage;
    FVisual: TThemedGridCellVisual;
    FAction: TThemedGridVisualAction;
    FActionKey: string;
    FTag: TValue;
    FToolTip: string;
    FIsGroupHeader: Boolean;
    FIsDetail: Boolean;
  public
    constructor Create;
    function Contains(const ALocation: TPoint): Boolean;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property VisualIndex: Integer read FVisualIndex write FVisualIndex;
    property Bounds: TRect read FBounds write FBounds;
    property Image: TThemedVisualImage read FImage write FImage;
    property Visual: TThemedGridCellVisual read FVisual write FVisual;
    property Action: TThemedGridVisualAction read FAction write FAction;
    property ActionKey: string read FActionKey write FActionKey;
    property Tag: TValue read FTag write FTag;
    property ToolTip: string read FToolTip write FToolTip;
    property IsGroupHeader: Boolean read FIsGroupHeader write FIsGroupHeader;
    property IsDetail: Boolean read FIsDetail write FIsDetail;
  end;

  TThemedGridVisualHitInfoList = class
  private
    FItems: TObjectList<TThemedGridVisualHitInfo>;
    FVisuals: TObjectList<TThemedGridCellVisual>;
    function GetCount: Integer;
    function GetItem(const AIndex: Integer): TThemedGridVisualHitInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(const AInfo: TThemedGridVisualHitInfo): Integer;
    function AdoptVisual(const AVisual: TThemedGridCellVisual): TThemedGridCellVisual;
    function HitTest(const ALocation: TPoint): TThemedGridVisualHitInfo;
    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: TThemedGridVisualHitInfo read GetItem; default;
  end;

implementation

constructor TThemedGridCellVisual.Create;
begin
  inherited Create;
  FImages := TObjectList<TThemedVisualImage>.Create(True);
  FImageSizes := TList<Integer>.Create;
  FActions := TThemedGridVisualActionCollection.Create;
  ResetDefaults;
end;

destructor TThemedGridCellVisual.Destroy;
begin
  FActions.Free;
  FImageSizes.Free;
  FImages.Free;
  inherited Destroy;
end;

procedure TThemedGridCellVisual.ResetDefaults;
begin
  FText := '';
  FToolTip := '';
  FTag := TValue.Empty;
  FImageSize := 16;
  FImageSpacing := 4;
  FTextSpacing := 6;
  FPadding := 4;
  FEnabled := True;
  FImagePlacement := TThemedGridVisualImagePlacement.Left;
  FContentAlignment := TThemedGridVisualContentAlignment.Near;
  FTextTrimming := TThemedGridVisualTextTrimming.EllipsisCharacter;
  FForeColor := 0;
  FHasForeColor := False;
  FCurrentColor := 0;
  FHasCurrentColor := False;
  FActionsApplied := False;
end;

procedure TThemedGridCellVisual.Clear;
begin
  ResetDefaults;
  FImages.Clear;
  FImageSizes.Clear;
  FActions.Clear;
end;

function TThemedGridCellVisual.GetHasText: Boolean;
begin
  Result := FText <> '';
end;

function TThemedGridCellVisual.GetHasImages: Boolean;
begin
  Result := (FImages.Count > 0) or (FActions.Count > 0);
end;

procedure TThemedGridCellVisual.SetForeColor(const AValue: TThemeColor);
begin
  FForeColor := AValue;
  FHasForeColor := True;
end;

procedure TThemedGridCellVisual.SetCurrentColor(const AValue: TThemeColor);
begin
  FCurrentColor := AValue;
  FHasCurrentColor := True;
end;

procedure TThemedGridCellVisual.ClearForeColor;
begin
  FForeColor := 0;
  FHasForeColor := False;
end;

procedure TThemedGridCellVisual.ClearCurrentColor;
begin
  FCurrentColor := 0;
  FHasCurrentColor := False;
end;

function TThemedGridCellVisual.AddImage(const AImage: TThemedVisualImage): Integer;
begin
  Result := -1;
  if AImage = nil then
    Exit;
  if not AImage.HasImage then
  begin
    AImage.Free;
    Exit;
  end;
  FImages.Add(AImage);
  FImageSizes.Add(0);
  Result := FImages.Count - 1;
end;

function TThemedGridCellVisual.AddImage(const AKey: string; const AGraphic: TGraphic): Integer;
begin
  Result := AddImage(TThemedVisualImage.FromImage(AKey, AGraphic));
end;

function TThemedGridCellVisual.AddSvgFile(const AKey, AFileName: string): Integer;
begin
  Result := AddImage(TThemedVisualImage.FromSvgFile(AKey, AFileName));
end;

function TThemedGridCellVisual.AddSvgText(const AKey, ASvgText: string): Integer;
begin
  Result := AddImage(TThemedVisualImage.FromSvgText(AKey, ASvgText));
end;

function TThemedGridCellVisual.AddImageFile(const AKey, AFileName: string): Integer;
begin
  Result := AddImage(TThemedVisualImage.FromImageFile(AKey, AFileName));
end;

function TThemedGridCellVisual.AddImageListKey(const AKey, AImageListKey: string): Integer;
begin
  Result := AddImage(TThemedVisualImage.FromImageListKey(AKey, AImageListKey));
end;

procedure TThemedGridCellVisual.SetImageSize(const AImageIndex, ASize: Integer);
begin
  if AImageIndex < 0 then
    Exit;
  while FImageSizes.Count <= AImageIndex do
    FImageSizes.Add(0);
  if ASize < 0 then
    FImageSizes[AImageIndex] := 0
  else
    FImageSizes[AImageIndex] := ASize;
end;

function TThemedGridCellVisual.GetImageSize(const AImageIndex: Integer): Integer;
begin
  if (AImageIndex < 0) or (AImageIndex >= FImageSizes.Count) then
    Result := 0
  else
    Result := FImageSizes[AImageIndex];
end;

function TThemedGridCellVisual.CreateImageFromAction(const AAction: TThemedGridVisualAction): TThemedVisualImage;
begin
  Result := nil;
  if AAction = nil then
    Exit;
  if AAction.SvgFile <> '' then
    Exit(TThemedVisualImage.FromSvgFile(AAction.Key, AAction.SvgFile));
  if AAction.ImageFile <> '' then
    Exit(TThemedVisualImage.FromImageFile(AAction.Key, AAction.ImageFile));
  if AAction.Image <> nil then
    Exit(TThemedVisualImage.FromImage(AAction.Key, AAction.Image));
  if AAction.ImageListKey <> '' then
    Exit(TThemedVisualImage.FromImageListKey(AAction.Key, AAction.ImageListKey));
end;

procedure TThemedGridCellVisual.EnsureActionImages;
var
  I, LIndex: Integer;
  LAction: TThemedGridVisualAction;
  LImage: TThemedVisualImage;
begin
  if FActionsApplied then
    Exit;
  FActionsApplied := True;
  for I := 0 to FActions.Count - 1 do
  begin
    LAction := FActions[I];
    if (LAction = nil) or (not LAction.Visible) or (not LAction.HasImage) then
      Continue;
    LImage := CreateImageFromAction(LAction);
    if LImage = nil then
      Continue;
    LImage.Clickable := LAction.Clickable;
    LImage.ToolTip := LAction.ToolTip;
    LImage.ActionIndex := I;
    if LAction.HasForeColor then
      LImage.CurrentColor := LAction.ForeColor;
    LIndex := AddImage(LImage);
    if LIndex >= 0 then
      SetImageSize(LIndex, LAction.ImageSize);
  end;
end;

function TThemedGridCellVisual.Clone: TThemedGridCellVisual;
var
  LImage: TThemedVisualImage;
  LSize: Integer;
  LAction: TThemedGridVisualAction;
begin
  Result := TThemedGridCellVisual.Create;
  Result.FText := FText;
  Result.FToolTip := FToolTip;
  Result.FTag := FTag;
  Result.FImageSize := FImageSize;
  Result.FImageSpacing := FImageSpacing;
  Result.FTextSpacing := FTextSpacing;
  Result.FPadding := FPadding;
  Result.FEnabled := FEnabled;
  Result.FImagePlacement := FImagePlacement;
  Result.FContentAlignment := FContentAlignment;
  Result.FTextTrimming := FTextTrimming;
  Result.FForeColor := FForeColor;
  Result.FHasForeColor := FHasForeColor;
  Result.FCurrentColor := FCurrentColor;
  Result.FHasCurrentColor := FHasCurrentColor;
  Result.FActionsApplied := FActionsApplied;
  for LImage in FImages do
    Result.FImages.Add(LImage.Clone);
  for LSize in FImageSizes do
    Result.FImageSizes.Add(LSize);
  for LAction in FActions do
    Result.FActions.Add(LAction.Clone);
end;

class function TThemedGridCellVisual.FromText(const AText: string): TThemedGridCellVisual;
begin
  Result := TThemedGridCellVisual.Create;
  Result.Text := AText;
end;

class function TThemedGridCellVisual.FromImageAndText(const AImage: TThemedVisualImage;
  const AText: string): TThemedGridCellVisual;
begin
  Result := TThemedGridCellVisual.Create;
  Result.Text := AText;
  Result.AddImage(AImage);
end;

constructor TThemedGridVisualHitInfo.Create;
begin
  inherited Create;
  FRowIndex := -1;
  FColumnIndex := -1;
  FVisualIndex := -1;
  FBounds := TRect.Empty;
end;

function TThemedGridVisualHitInfo.Contains(const ALocation: TPoint): Boolean;
begin
  Result := FBounds.Contains(ALocation);
end;

constructor TThemedGridVisualHitInfoList.Create;
begin
  inherited Create;
  FItems := TObjectList<TThemedGridVisualHitInfo>.Create(True);
  FVisuals := TObjectList<TThemedGridCellVisual>.Create(True);
end;

destructor TThemedGridVisualHitInfoList.Destroy;
begin
  FItems.Free;
  FVisuals.Free;
  inherited Destroy;
end;

procedure TThemedGridVisualHitInfoList.Clear;
begin
  FItems.Clear;
  FVisuals.Clear;
end;

function TThemedGridVisualHitInfoList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TThemedGridVisualHitInfoList.GetItem(const AIndex: Integer): TThemedGridVisualHitInfo;
begin
  Result := FItems[AIndex];
end;

function TThemedGridVisualHitInfoList.Add(const AInfo: TThemedGridVisualHitInfo): Integer;
begin
  Result := FItems.Add(AInfo);
end;

function TThemedGridVisualHitInfoList.AdoptVisual(const AVisual: TThemedGridCellVisual): TThemedGridCellVisual;
begin
  FVisuals.Add(AVisual);
  Result := AVisual;
end;

function TThemedGridVisualHitInfoList.HitTest(const ALocation: TPoint): TThemedGridVisualHitInfo;
var
  I: Integer;
begin
  Result := nil;
  for I := FItems.Count - 1 downto 0 do
    if FItems[I].Contains(ALocation) then
      Exit(FItems[I]);
end;

end.

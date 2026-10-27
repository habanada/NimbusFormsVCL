unit NimbusForms.Grid.CellVisualRenderer;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Math,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ImgList,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.VisualImage,
  NimbusForms.Grid.VisualImageRenderer,
  NimbusForms.Grid.VisualAction,
  NimbusForms.Grid.CellVisual;

type
  TThemedGridCellVisualRenderer = class
  private
    FImageRenderer: TThemedVisualImageRenderer;
    FDefaultPadding: Integer;
    FDefaultImageSize: Integer;
    FDefaultImageSpacing: Integer;
    FDefaultTextSpacing: Integer;
    function GetUseBitmapCache: Boolean;
    procedure SetUseBitmapCache(const AValue: Boolean);
    class function CreateImageSizes(const AVisual: TThemedGridCellVisual; const ADefaultSize: Integer): TArray<Integer>; static;
    class function GetImageSize(const ASizes: TArray<Integer>; const AIndex: Integer): Integer; static;
    class function GetImagesWidth(const ASizes: TArray<Integer>; const AStart, ACount, ASpacing: Integer): Integer; static;
    class function GetMaxImageSize(const ASizes: TArray<Integer>): Integer; static;
    class function AlignX(const ABounds: TRect; const AWidth: Integer;
      const AAlignment: TThemedGridVisualContentAlignment): Integer; static;
    class function AlignY(const ABounds: TRect; const AHeight: Integer;
      const AAlignment: TThemedGridVisualContentAlignment): Integer; static;
    class procedure ResolveLayout(const AContentBounds: TRect; const AVisual: TThemedGridCellVisual;
      const ASizes: TArray<Integer>; const AImageSpacing, ATextSpacing: Integer; const ATextSize: TSize;
      const AImageBounds: TList<TRect>; out ATextBounds: TRect); static;
    class procedure ResolveImageOnlyLayout(const AContentBounds: TRect; const AVisual: TThemedGridCellVisual;
      const ASizes: TArray<Integer>; const AImageSpacing: Integer; const AImageBounds: TList<TRect>); static;
    class procedure ResolveHorizontalLayout(const AContentBounds: TRect; const AVisual: TThemedGridCellVisual;
      const ASizes: TArray<Integer>; const AImageSpacing, ATextSpacing: Integer; const ATextSize: TSize;
      const AImageBounds: TList<TRect>; out ATextBounds: TRect); static;
    class procedure ResolveVerticalLayout(const AContentBounds: TRect; const AVisual: TThemedGridCellVisual;
      const ASizes: TArray<Integer>; const AImageSpacing, ATextSpacing: Integer; const ATextSize: TSize;
      const AImageBounds: TList<TRect>; out ATextBounds: TRect); static;
    class function TrimmingOf(const ATrimming: TThemedGridVisualTextTrimming): TStringTrimming; static;
    class function WithOpacity(const AColor: TThemeColor; const AOpacity: Double): TThemeColor; static;
    class procedure DrawVisualText(const AContext: TThemedGridRenderContext; const ABounds: TRect;
      const AText: string; const AColor: TThemeColor; const ATrimming: TThemedGridVisualTextTrimming); static;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw(const AContext: TThemedGridRenderContext; const ABounds: TRect;
      const AVisual: TThemedGridCellVisual; const AForeColor: TThemeColor; const AEnabled: Boolean;
      const AImageList: TCustomImageList; const ARowIndex, AColumnIndex: Integer;
      const AHitInfos: TThemedGridVisualHitInfoList);
    procedure ClearCache;
    procedure ClearBitmapCache;
    property DefaultPadding: Integer read FDefaultPadding write FDefaultPadding;
    property DefaultImageSize: Integer read FDefaultImageSize write FDefaultImageSize;
    property DefaultImageSpacing: Integer read FDefaultImageSpacing write FDefaultImageSpacing;
    property DefaultTextSpacing: Integer read FDefaultTextSpacing write FDefaultTextSpacing;
    property UseBitmapCache: Boolean read GetUseBitmapCache write SetUseBitmapCache;
    property ImageRenderer: TThemedVisualImageRenderer read FImageRenderer;
  end;

implementation

uses
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText;

const
  CDisabledOpacity = 0.45;

constructor TThemedGridCellVisualRenderer.Create;
begin
  inherited Create;
  FImageRenderer := TThemedVisualImageRenderer.Create;
  FDefaultPadding := 4;
  FDefaultImageSize := 16;
  FDefaultImageSpacing := 4;
  FDefaultTextSpacing := 6;
end;

destructor TThemedGridCellVisualRenderer.Destroy;
begin
  FImageRenderer.Free;
  inherited Destroy;
end;

function TThemedGridCellVisualRenderer.GetUseBitmapCache: Boolean;
begin
  Result := FImageRenderer.UseBitmapCache;
end;

procedure TThemedGridCellVisualRenderer.SetUseBitmapCache(const AValue: Boolean);
begin
  FImageRenderer.UseBitmapCache := AValue;
end;

procedure TThemedGridCellVisualRenderer.ClearCache;
begin
  FImageRenderer.ClearCache;
end;

procedure TThemedGridCellVisualRenderer.ClearBitmapCache;
begin
  FImageRenderer.ClearBitmapCache;
end;

class function TThemedGridCellVisualRenderer.CreateImageSizes(const AVisual: TThemedGridCellVisual;
  const ADefaultSize: Integer): TArray<Integer>;
var
  I, LSize: Integer;
begin
  SetLength(Result, 0);
  if AVisual = nil then
    Exit;
  SetLength(Result, AVisual.Images.Count);
  for I := 0 to AVisual.Images.Count - 1 do
  begin
    LSize := AVisual.GetImageSize(I);
    if LSize <= 0 then
      LSize := ADefaultSize;
    if LSize <= 0 then
      LSize := 1;
    Result[I] := LSize;
  end;
end;

class function TThemedGridCellVisualRenderer.GetImageSize(const ASizes: TArray<Integer>; const AIndex: Integer): Integer;
begin
  if (AIndex < 0) or (AIndex >= Length(ASizes)) then
    Exit(1);
  Result := ASizes[AIndex];
  if Result <= 0 then
    Result := 1;
end;

class function TThemedGridCellVisualRenderer.GetImagesWidth(const ASizes: TArray<Integer>;
  const AStart, ACount, ASpacing: Integer): Integer;
var
  I, LEnd: Integer;
begin
  Result := 0;
  if (Length(ASizes) = 0) or (ACount <= 0) then
    Exit;
  LEnd := Min(Length(ASizes), AStart + ACount);
  for I := AStart to LEnd - 1 do
  begin
    if I > AStart then
      Inc(Result, ASpacing);
    Inc(Result, GetImageSize(ASizes, I));
  end;
end;

class function TThemedGridCellVisualRenderer.GetMaxImageSize(const ASizes: TArray<Integer>): Integer;
var
  I, LSize: Integer;
begin
  Result := 1;
  for I := 0 to High(ASizes) do
  begin
    LSize := GetImageSize(ASizes, I);
    if LSize > Result then
      Result := LSize;
  end;
end;

class function TThemedGridCellVisualRenderer.AlignX(const ABounds: TRect; const AWidth: Integer;
  const AAlignment: TThemedGridVisualContentAlignment): Integer;
begin
  case AAlignment of
    TThemedGridVisualContentAlignment.Center:
      Result := ABounds.Left + (ABounds.Width - AWidth) div 2;
    TThemedGridVisualContentAlignment.Far:
      Result := ABounds.Right - AWidth;
  else
    Result := ABounds.Left;
  end;
end;

class function TThemedGridCellVisualRenderer.AlignY(const ABounds: TRect; const AHeight: Integer;
  const AAlignment: TThemedGridVisualContentAlignment): Integer;
begin
  case AAlignment of
    TThemedGridVisualContentAlignment.Center:
      Result := ABounds.Top + (ABounds.Height - AHeight) div 2;
    TThemedGridVisualContentAlignment.Far:
      Result := ABounds.Bottom - AHeight;
  else
    Result := ABounds.Top;
  end;
end;

class procedure TThemedGridCellVisualRenderer.ResolveLayout(const AContentBounds: TRect;
  const AVisual: TThemedGridCellVisual; const ASizes: TArray<Integer>; const AImageSpacing, ATextSpacing: Integer;
  const ATextSize: TSize; const AImageBounds: TList<TRect>; out ATextBounds: TRect);
var
  LHasImages, LHasText: Boolean;
  LTextWidth: Integer;
  LX: Integer;
begin
  ATextBounds := TRect.Empty;
  AImageBounds.Clear;
  LHasImages := AVisual.Images.Count > 0;
  LHasText := (AVisual.Text <> '') and (ATextSize.cx > 0) and (ATextSize.cy > 0);
  if (not LHasImages) and (not LHasText) then
    Exit;
  if not LHasImages then
  begin
    LTextWidth := Min(AContentBounds.Width, ATextSize.cx);
    LX := AlignX(AContentBounds, LTextWidth, AVisual.ContentAlignment);
    ATextBounds := Rect(LX, AContentBounds.Top, LX + LTextWidth, AContentBounds.Bottom);
    Exit;
  end;
  if not LHasText then
  begin
    ResolveImageOnlyLayout(AContentBounds, AVisual, ASizes, AImageSpacing, AImageBounds);
    Exit;
  end;
  if AVisual.ImagePlacement in [TThemedGridVisualImagePlacement.Top, TThemedGridVisualImagePlacement.Bottom] then
  begin
    ResolveVerticalLayout(AContentBounds, AVisual, ASizes, AImageSpacing, ATextSpacing, ATextSize, AImageBounds,
      ATextBounds);
    Exit;
  end;
  ResolveHorizontalLayout(AContentBounds, AVisual, ASizes, AImageSpacing, ATextSpacing, ATextSize, AImageBounds,
    ATextBounds);
end;

class procedure TThemedGridCellVisualRenderer.ResolveImageOnlyLayout(const AContentBounds: TRect;
  const AVisual: TThemedGridCellVisual; const ASizes: TArray<Integer>; const AImageSpacing: Integer;
  const AImageBounds: TList<TRect>);
var
  I, LCount, LTotal, LX, LSize, LY: Integer;
begin
  LCount := AVisual.Images.Count;
  LTotal := GetImagesWidth(ASizes, 0, LCount, AImageSpacing);
  LX := AlignX(AContentBounds, LTotal, AVisual.ContentAlignment);
  for I := 0 to LCount - 1 do
  begin
    LSize := GetImageSize(ASizes, I);
    LY := AContentBounds.Top + (AContentBounds.Height - LSize) div 2;
    AImageBounds.Add(Rect(LX, LY, LX + LSize, LY + LSize));
    Inc(LX, LSize + AImageSpacing);
  end;
end;

class procedure TThemedGridCellVisualRenderer.ResolveHorizontalLayout(const AContentBounds: TRect;
  const AVisual: TThemedGridCellVisual; const ASizes: TArray<Integer>; const AImageSpacing, ATextSpacing: Integer;
  const ATextSize: TSize; const AImageBounds: TList<TRect>; out ATextBounds: TRect);
var
  LCount, LLeftCount, LRightCount, LLeftWidth, LRightWidth, LTotal, LX, I, LSize, LY: Integer;
  LTextLeft, LTextRight, LRightStart, LRightReserve, LLeftReserve: Integer;
  LVisualIndex: Integer;
begin
  ATextBounds := TRect.Empty;
  LCount := AVisual.Images.Count;
  LLeftCount := LCount;
  LRightCount := 0;
  if AVisual.ImagePlacement = TThemedGridVisualImagePlacement.Right then
  begin
    LLeftCount := 0;
    LRightCount := LCount;
  end
  else if AVisual.ImagePlacement = TThemedGridVisualImagePlacement.LeftAndRight then
  begin
    LLeftCount := (LCount + 1) div 2;
    LRightCount := LCount - LLeftCount;
  end;
  if LLeftCount > 0 then
    LLeftWidth := GetImagesWidth(ASizes, 0, LLeftCount, AImageSpacing)
  else
    LLeftWidth := 0;
  if LRightCount > 0 then
    LRightWidth := GetImagesWidth(ASizes, LLeftCount, LRightCount, AImageSpacing)
  else
    LRightWidth := 0;
  LTotal := LLeftWidth + LRightWidth + ATextSize.cx;
  if LLeftWidth > 0 then
    Inc(LTotal, ATextSpacing);
  if LRightWidth > 0 then
    Inc(LTotal, ATextSpacing);
  LTotal := Min(LTotal, AContentBounds.Width);
  LX := AlignX(AContentBounds, LTotal, AVisual.ContentAlignment);
  for I := 0 to LLeftCount - 1 do
  begin
    LSize := GetImageSize(ASizes, I);
    LY := AContentBounds.Top + (AContentBounds.Height - LSize) div 2;
    AImageBounds.Add(Rect(LX, LY, LX + LSize, LY + LSize));
    Inc(LX, LSize + AImageSpacing);
  end;
  if LLeftCount > 0 then
    Inc(LX, ATextSpacing - AImageSpacing);
  LTextLeft := LX;
  if LRightWidth > 0 then
    LRightReserve := LRightWidth + ATextSpacing
  else
    LRightReserve := 0;
  if LLeftWidth > 0 then
    LLeftReserve := ATextSpacing
  else
    LLeftReserve := 0;
  LTextRight := AContentBounds.Right - LRightReserve;
  if AVisual.ContentAlignment in [TThemedGridVisualContentAlignment.Center, TThemedGridVisualContentAlignment.Far] then
    LTextRight := Min(AContentBounds.Right - LRightReserve,
      LTextLeft + Max(0, LTotal - LLeftWidth - LRightWidth - LLeftReserve - LRightReserve));
  LTextRight := Max(LTextLeft, LTextRight);
  ATextBounds := Rect(LTextLeft, AContentBounds.Top, LTextRight, AContentBounds.Bottom);
  LRightStart := ATextBounds.Right + ATextSpacing;
  for I := 0 to LRightCount - 1 do
  begin
    LVisualIndex := LLeftCount + I;
    LSize := GetImageSize(ASizes, LVisualIndex);
    LY := AContentBounds.Top + (AContentBounds.Height - LSize) div 2;
    while AImageBounds.Count < LVisualIndex do
      AImageBounds.Add(TRect.Empty);
    AImageBounds.Add(Rect(LRightStart, LY, LRightStart + LSize, LY + LSize));
    Inc(LRightStart, LSize + AImageSpacing);
  end;
end;

class procedure TThemedGridCellVisualRenderer.ResolveVerticalLayout(const AContentBounds: TRect;
  const AVisual: TThemedGridCellVisual; const ASizes: TArray<Integer>; const AImageSpacing, ATextSpacing: Integer;
  const ATextSize: TSize; const AImageBounds: TList<TRect>; out ATextBounds: TRect);
var
  LCount, LImagesWidth, LMaxHeight, LTotalHeight, LY, LImageX, LX, I, LSize, LImageY, LTextHeight: Integer;
begin
  ATextBounds := TRect.Empty;
  LCount := AVisual.Images.Count;
  LImagesWidth := GetImagesWidth(ASizes, 0, LCount, AImageSpacing);
  LMaxHeight := GetMaxImageSize(ASizes);
  LTotalHeight := LMaxHeight + ATextSpacing + ATextSize.cy;
  LY := AlignY(AContentBounds, LTotalHeight, AVisual.ContentAlignment);
  LImageX := AContentBounds.Left + (AContentBounds.Width - LImagesWidth) div 2;
  if AVisual.ImagePlacement = TThemedGridVisualImagePlacement.Top then
  begin
    LX := LImageX;
    for I := 0 to LCount - 1 do
    begin
      LSize := GetImageSize(ASizes, I);
      LImageY := LY + (LMaxHeight - LSize) div 2;
      AImageBounds.Add(Rect(LX, LImageY, LX + LSize, LImageY + LSize));
      Inc(LX, LSize + AImageSpacing);
    end;
    ATextBounds := Rect(AContentBounds.Left, LY + LMaxHeight + ATextSpacing, AContentBounds.Right,
      LY + LMaxHeight + ATextSpacing + Max(0, AContentBounds.Bottom - LY - LMaxHeight - ATextSpacing));
    Exit;
  end;
  LTextHeight := Min(ATextSize.cy, AContentBounds.Height);
  ATextBounds := Rect(AContentBounds.Left, LY, AContentBounds.Right, LY + LTextHeight);
  LImageY := ATextBounds.Bottom + ATextSpacing;
  LX := LImageX;
  for I := 0 to LCount - 1 do
  begin
    LSize := GetImageSize(ASizes, I);
    AImageBounds.Add(Rect(LX, LImageY + (LMaxHeight - LSize) div 2, LX + LSize,
      LImageY + (LMaxHeight - LSize) div 2 + LSize));
    Inc(LX, LSize + AImageSpacing);
  end;
end;

class function TThemedGridCellVisualRenderer.TrimmingOf(const ATrimming: TThemedGridVisualTextTrimming): TStringTrimming;
begin
  case ATrimming of
    TThemedGridVisualTextTrimming.Character:
      Result := StringTrimmingCharacter;
    TThemedGridVisualTextTrimming.Word:
      Result := StringTrimmingWord;
    TThemedGridVisualTextTrimming.EllipsisWord:
      Result := StringTrimmingEllipsisWord;
    TThemedGridVisualTextTrimming.EllipsisCharacter:
      Result := StringTrimmingEllipsisCharacter;
  else
    Result := StringTrimmingNone;
  end;
end;

class function TThemedGridCellVisualRenderer.WithOpacity(const AColor: TThemeColor; const AOpacity: Double): TThemeColor;
begin
  Result := ThemeColor(Byte(Round(ThemeColorAlpha(AColor) * AOpacity)), ThemeColorRed(AColor),
    ThemeColorGreen(AColor), ThemeColorBlue(AColor));
end;

class procedure TThemedGridCellVisualRenderer.DrawVisualText(const AContext: TThemedGridRenderContext;
  const ABounds: TRect; const AText: string; const AColor: TThemeColor;
  const ATrimming: TThemedGridVisualTextTrimming);
var
  LFont: TGPFont;
  LFormat: TGPStringFormat;
  LLayout: TGPRectF;
begin
  if (AText = '') or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  LFont := TThemedGridGdiText.CreateFont(AContext, AContext.Font);
  LFormat := TGPStringFormat.Create;
  try
    LFormat.SetAlignment(StringAlignmentNear);
    LFormat.SetLineAlignment(StringAlignmentCenter);
    LFormat.SetFormatFlags(StringFormatFlagsNoWrap);
    LFormat.SetTrimming(TrimmingOf(ATrimming));
    LLayout := MakeRect(Single(ABounds.Left), Single(ABounds.Top), Single(ABounds.Width), Single(ABounds.Height));
    AContext.Graphics.DrawString(PChar(AText), Length(AText), LFont, LLayout, LFormat,
      TThemedGridGdiCache.Brush(AColor));
  finally
    LFormat.Free;
    LFont.Free;
  end;
end;

procedure TThemedGridCellVisualRenderer.Draw(const AContext: TThemedGridRenderContext; const ABounds: TRect;
  const AVisual: TThemedGridCellVisual; const AForeColor: TThemeColor; const AEnabled: Boolean;
  const AImageList: TCustomImageList; const ARowIndex, AColumnIndex: Integer;
  const AHitInfos: TThemedGridVisualHitInfoList);
var
  LState: GraphicsState;
  LPadding, LImageSize, LImageSpacing, LTextSpacing, I, LActionIndex: Integer;
  LContentBounds, LTextBounds, LImageRect: TRect;
  LResolvedFore, LCurrentColor: TThemeColor;
  LSizes: TArray<Integer>;
  LTextSize: TSize;
  LImageBounds: TList<TRect>;
  LImage: TThemedVisualImage;
  LAction: TThemedGridVisualAction;
  LImageEnabled: Boolean;
  LClone: TThemedGridCellVisual;
  LInfo: TThemedGridVisualHitInfo;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (AVisual = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  AVisual.EnsureActionImages;
  LState := AContext.Graphics.Save;
  LImageBounds := TList<TRect>.Create;
  try
    AContext.Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    AContext.Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    AContext.Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    AContext.Graphics.SetCompositingQuality(CompositingQualityHighQuality);
    AContext.Graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    if AVisual.Padding >= 0 then
      LPadding := AVisual.Padding
    else
      LPadding := FDefaultPadding;
    LContentBounds := ABounds;
    LContentBounds.Inflate(-LPadding, -LPadding);
    if (LContentBounds.Width <= 0) or (LContentBounds.Height <= 0) then
      Exit;
    if AVisual.HasForeColor then
      LResolvedFore := AVisual.ForeColor
    else
      LResolvedFore := AForeColor;
    if AVisual.HasCurrentColor then
      LCurrentColor := AVisual.CurrentColor
    else
      LCurrentColor := LResolvedFore;
    if AVisual.ImageSize > 0 then
      LImageSize := AVisual.ImageSize
    else
      LImageSize := FDefaultImageSize;
    if AVisual.ImageSpacing >= 0 then
      LImageSpacing := AVisual.ImageSpacing
    else
      LImageSpacing := FDefaultImageSpacing;
    if AVisual.TextSpacing >= 0 then
      LTextSpacing := AVisual.TextSpacing
    else
      LTextSpacing := FDefaultTextSpacing;
    if LImageSize <= 0 then
      LImageSize := Min(LContentBounds.Width, LContentBounds.Height);
    LSizes := CreateImageSizes(AVisual, LImageSize);
    if AVisual.Text <> '' then
      LTextSize := TThemedGridGdiText.MeasureText(AContext, AVisual.Text, AContext.Font)
    else
      LTextSize := TSize.Create(0, 0);
    ResolveLayout(LContentBounds, AVisual, LSizes, LImageSpacing, LTextSpacing, LTextSize, LImageBounds,
      LTextBounds);
    LClone := nil;
    for I := 0 to LImageBounds.Count - 1 do
    begin
      if I >= AVisual.Images.Count then
        Break;
      LImageRect := LImageBounds[I];
      if (LImageRect.Width <= 0) or (LImageRect.Height <= 0) then
        Continue;
      LImage := AVisual.Images[I];
      LAction := nil;
      LActionIndex := LImage.ActionIndex;
      if (LActionIndex >= 0) and (LActionIndex < AVisual.Actions.Count) then
        LAction := AVisual.Actions[LActionIndex];
      LImageEnabled := AEnabled and AVisual.Enabled;
      if LAction <> nil then
        LImageEnabled := LImageEnabled and LAction.Enabled;
      FImageRenderer.DrawImage(AContext.Graphics, LImageRect, LImage, LCurrentColor, LImageEnabled, AImageList);
      if (AHitInfos <> nil) and LImage.Clickable then
      begin
        if LClone = nil then
          LClone := AHitInfos.AdoptVisual(AVisual.Clone);
        LInfo := TThemedGridVisualHitInfo.Create;
        LInfo.RowIndex := ARowIndex;
        LInfo.ColumnIndex := AColumnIndex;
        LInfo.VisualIndex := I;
        LInfo.Bounds := LImageRect;
        LInfo.Visual := LClone;
        LInfo.Image := LClone.Images[I];
        if LAction <> nil then
        begin
          LInfo.Action := LClone.Actions[LActionIndex];
          LInfo.ActionKey := LAction.Key;
          LInfo.Tag := LAction.Tag;
        end
        else
          LInfo.Tag := LImage.Tag;
        if LImage.ToolTip <> '' then
          LInfo.ToolTip := LImage.ToolTip
        else
          LInfo.ToolTip := AVisual.ToolTip;
        AHitInfos.Add(LInfo);
      end;
    end;
    if (AVisual.Text <> '') and (LTextBounds.Width > 0) and (LTextBounds.Height > 0) then
    begin
      if AEnabled and AVisual.Enabled then
        DrawVisualText(AContext, LTextBounds, AVisual.Text, LResolvedFore, AVisual.TextTrimming)
      else
        DrawVisualText(AContext, LTextBounds, AVisual.Text, WithOpacity(LResolvedFore, CDisabledOpacity),
          AVisual.TextTrimming);
    end;
  finally
    LImageBounds.Free;
    AContext.Graphics.Restore(LState);
  end;
end;

end.

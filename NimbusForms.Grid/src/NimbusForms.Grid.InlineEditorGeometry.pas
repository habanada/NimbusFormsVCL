unit NimbusForms.Grid.InlineEditorGeometry;

interface

uses
  System.Types,
  System.Math,
  NimbusForms.Grid.Column;

type
  TThemedGridInlineEditorGeometry = class
  public
    const
      DefaultCheckBoxSize = 14;
      CheckBoxHitPadding = 3;
      ToggleMinimumWidth = 28;
      ToggleMaximumWidth = 44;
      ToggleMinimumHeight = 14;
      ToggleMaximumHeight = 20;
      BarHorizontalPadding = 6;
      BarVerticalPadding = 5;
      SliderHorizontalPadding = 8;
      SliderTrackHeight = 6;
      SliderMinimumThumbSize = 10;
      SliderMaximumThumbSize = 16;
      RatingItemSpacing = 3;
      RatingMinimumItemSize = 9;
      RatingMaximumItemSize = 16;
      RatingHorizontalPadding = 4;
      RatingDefaultMaximum = 5;
      RatingMinimumMaximum = 1;
      RatingMaximumMaximum = 20;
      ColorSwatchWidth = 32;
      ColorSwatchHorizontalPadding = 7;
      ColorSwatchVerticalPadding = 5;
      ColorSwatchTextGap = 6;
      ColorSwatchHitPadding = 2;
      DetailExpanderSize = 11;
      DetailExpanderLeftPadding = 4;
      DetailExpanderHitPadding = 3;
    class function GetCheckBoxBounds(const ACellBounds: TRect; const ACheckBoxSize: Integer): TRect; static;
    class function HitTestCheckBox(const ACellBounds: TRect; const ACheckBoxSize: Integer; const ALocation: TPoint): Boolean; static;
    class function GetColorSwatchBounds(const ACellBounds: TRect; const ASwatchWidth, AHorizontalPadding, AVerticalPadding: Integer): TRect; static;
    class function HitTestColorSwatch(const ACellBounds: TRect; const ASwatchWidth, AHorizontalPadding, AVerticalPadding: Integer; const ALocation: TPoint): Boolean; static;
    class function GetDetailExpanderBounds(const ARowHeaderBounds: TRect): TRect; static;
    class function HitTestDetailExpander(const ARowHeaderBounds: TRect; const ALocation: TPoint): Boolean; static;
    class function HitTestToggle(const ACellBounds: TRect; const ALocation: TPoint): Boolean; static;
    class function HitTestRating(const ACellBounds: TRect; const AMaximum: Integer; const ALocation: TPoint): Boolean; static;
    class function HitTestSlider(const ACellBounds: TRect; const ALocation: TPoint): Boolean; static;
    class function GetToggleBounds(const ACellBounds: TRect): TRect; static;
    class function GetBarBounds(const ACellBounds: TRect): TRect; static;
    class function GetSliderTrackBounds(const ACellBounds: TRect): TRect; static;
    class function GetSliderThumbSize(const ACellBounds: TRect): Integer; static;
    class function GetSliderThumbBounds(const ACellBounds: TRect; const ANormalizedValue: Extended): TRect; static;
    class function GetSliderRatioFromPoint(const ACellBounds: TRect; const ALocation: TPoint): Extended; static;
    class function ResolveRatingMaximum(const AColumn: TThemedGridColumn): Integer; static;
    class function GetRatingItemSize(const ACellBounds: TRect): Integer; static;
    class function GetRatingBounds(const ACellBounds: TRect; const AMaximum: Integer): TRect; static;
    class function GetRatingItemBounds(const ACellBounds: TRect; const AMaximum, AIndex: Integer): TRect; static;
    class function GetRatingValueFromPoint(const ACellBounds: TRect; const AMaximum: Integer; const ALocation: TPoint): Integer; static;
  end;

implementation

function RoundAwayFromZero(const AValue: Extended): Int64;
begin
  if AValue >= 0 then
    Result := Trunc(AValue + 0.5)
  else
    Result := Trunc(AValue - 0.5);
end;

function InflatedRect(const ARect: TRect; const ADX, ADY: Integer): TRect;
begin
  Result := ARect;
  Result.Inflate(ADX, ADY);
end;

class function TThemedGridInlineEditorGeometry.GetCheckBoxBounds(const ACellBounds: TRect; const ACheckBoxSize: Integer): TRect;
var
  LSize: Integer;
begin
  LSize := ACheckBoxSize;
  if LSize <= 0 then
    LSize := DefaultCheckBoxSize;
  if LSize > ACellBounds.Height - 2 then
    LSize := Max(8, ACellBounds.Height - 2);
  Result := TRect.Create(
    ACellBounds.Left + (ACellBounds.Width - LSize) div 2,
    ACellBounds.Top + (ACellBounds.Height - LSize) div 2,
    ACellBounds.Left + (ACellBounds.Width - LSize) div 2 + LSize,
    ACellBounds.Top + (ACellBounds.Height - LSize) div 2 + LSize);
end;

class function TThemedGridInlineEditorGeometry.HitTestCheckBox(const ACellBounds: TRect; const ACheckBoxSize: Integer; const ALocation: TPoint): Boolean;
begin
  Result := InflatedRect(GetCheckBoxBounds(ACellBounds, ACheckBoxSize), CheckBoxHitPadding, CheckBoxHitPadding).Contains(ALocation);
end;

class function TThemedGridInlineEditorGeometry.GetColorSwatchBounds(const ACellBounds: TRect; const ASwatchWidth, AHorizontalPadding, AVerticalPadding: Integer): TRect;
var
  LSwatchWidth, LHPad, LVPad, LHeight, LWidth, LAvailable: Integer;
begin
  LSwatchWidth := ASwatchWidth;
  if LSwatchWidth <= 0 then
    LSwatchWidth := ColorSwatchWidth;
  LHPad := AHorizontalPadding;
  if LHPad < 0 then
    LHPad := ColorSwatchHorizontalPadding;
  LVPad := AVerticalPadding;
  if LVPad < 0 then
    LVPad := ColorSwatchVerticalPadding;
  LHeight := ACellBounds.Height - (LVPad * 2);
  if LHeight < 1 then
    LHeight := Max(1, ACellBounds.Height - 2);
  LWidth := LSwatchWidth;
  LAvailable := ACellBounds.Width - (LHPad * 2);
  if LAvailable < 1 then
    LAvailable := Max(1, ACellBounds.Width - 2);
  if LWidth > LAvailable then
    LWidth := LAvailable;
  if LWidth < 1 then
    Exit(TRect.Empty);
  Result := TRect.Create(
    ACellBounds.Left + LHPad,
    ACellBounds.Top + (ACellBounds.Height - LHeight) div 2,
    ACellBounds.Left + LHPad + LWidth,
    ACellBounds.Top + (ACellBounds.Height - LHeight) div 2 + LHeight);
end;

class function TThemedGridInlineEditorGeometry.HitTestColorSwatch(const ACellBounds: TRect; const ASwatchWidth, AHorizontalPadding, AVerticalPadding: Integer; const ALocation: TPoint): Boolean;
var
  LBounds: TRect;
begin
  LBounds := GetColorSwatchBounds(ACellBounds, ASwatchWidth, AHorizontalPadding, AVerticalPadding);
  if LBounds.IsEmpty then
    Exit(False);
  Result := InflatedRect(LBounds, ColorSwatchHitPadding, ColorSwatchHitPadding).Contains(ALocation);
end;

class function TThemedGridInlineEditorGeometry.GetDetailExpanderBounds(const ARowHeaderBounds: TRect): TRect;
var
  LSize: Integer;
begin
  LSize := DetailExpanderSize;
  if LSize > ARowHeaderBounds.Height - 4 then
    LSize := Max(7, ARowHeaderBounds.Height - 4);
  if LSize > ARowHeaderBounds.Width - DetailExpanderLeftPadding * 2 then
    LSize := Max(7, ARowHeaderBounds.Width - DetailExpanderLeftPadding * 2);
  if LSize <= 0 then
    Exit(TRect.Empty);
  Result := TRect.Create(
    ARowHeaderBounds.Left + DetailExpanderLeftPadding,
    ARowHeaderBounds.Top + (ARowHeaderBounds.Height - LSize) div 2,
    ARowHeaderBounds.Left + DetailExpanderLeftPadding + LSize,
    ARowHeaderBounds.Top + (ARowHeaderBounds.Height - LSize) div 2 + LSize);
end;

class function TThemedGridInlineEditorGeometry.HitTestDetailExpander(const ARowHeaderBounds: TRect; const ALocation: TPoint): Boolean;
var
  LBounds: TRect;
begin
  LBounds := GetDetailExpanderBounds(ARowHeaderBounds);
  if LBounds.IsEmpty then
    Exit(False);
  Result := InflatedRect(LBounds, DetailExpanderHitPadding, DetailExpanderHitPadding).Contains(ALocation);
end;

class function TThemedGridInlineEditorGeometry.HitTestToggle(const ACellBounds: TRect; const ALocation: TPoint): Boolean;
begin
  Result := InflatedRect(GetToggleBounds(ACellBounds), CheckBoxHitPadding, CheckBoxHitPadding).Contains(ALocation);
end;

class function TThemedGridInlineEditorGeometry.HitTestRating(const ACellBounds: TRect; const AMaximum: Integer; const ALocation: TPoint): Boolean;
var
  LBounds, LHit: TRect;
begin
  LBounds := GetRatingBounds(ACellBounds, AMaximum);
  if LBounds.IsEmpty then
    Exit(False);
  LHit := InflatedRect(LBounds, CheckBoxHitPadding, CheckBoxHitPadding);
  LHit := TRect.Create(LHit.Left, ACellBounds.Top, LHit.Right, ACellBounds.Bottom);
  Result := LHit.Contains(ALocation);
end;

class function TThemedGridInlineEditorGeometry.HitTestSlider(const ACellBounds: TRect; const ALocation: TPoint): Boolean;
var
  LTrack, LHit: TRect;
  LThumbSize: Integer;
begin
  LTrack := GetSliderTrackBounds(ACellBounds);
  if LTrack.Width <= 0 then
    Exit(False);
  LThumbSize := GetSliderThumbSize(ACellBounds);
  LHit := TRect.Create(LTrack.Left - LThumbSize, ACellBounds.Top, LTrack.Right + LThumbSize, ACellBounds.Bottom);
  Result := LHit.Contains(ALocation);
end;

class function TThemedGridInlineEditorGeometry.GetToggleBounds(const ACellBounds: TRect): TRect;
var
  LWidth, LHeight: Integer;
begin
  LWidth := Min(ToggleMaximumWidth, Max(ToggleMinimumWidth, ACellBounds.Width - 12));
  LHeight := Min(ToggleMaximumHeight, Max(ToggleMinimumHeight, ACellBounds.Height - 8));
  Result := TRect.Create(
    ACellBounds.Left + (ACellBounds.Width - LWidth) div 2,
    ACellBounds.Top + (ACellBounds.Height - LHeight) div 2,
    ACellBounds.Left + (ACellBounds.Width - LWidth) div 2 + LWidth,
    ACellBounds.Top + (ACellBounds.Height - LHeight) div 2 + LHeight);
end;

class function TThemedGridInlineEditorGeometry.GetBarBounds(const ACellBounds: TRect): TRect;
begin
  Result := TRect.Create(
    ACellBounds.Left + BarHorizontalPadding,
    ACellBounds.Top + BarVerticalPadding,
    ACellBounds.Right - BarHorizontalPadding,
    ACellBounds.Bottom - BarVerticalPadding);
end;

class function TThemedGridInlineEditorGeometry.GetSliderTrackBounds(const ACellBounds: TRect): TRect;
var
  LCenterY: Integer;
begin
  LCenterY := ACellBounds.Top + ACellBounds.Height div 2;
  Result := TRect.Create(
    ACellBounds.Left + SliderHorizontalPadding,
    LCenterY - SliderTrackHeight div 2,
    ACellBounds.Right - SliderHorizontalPadding,
    LCenterY + SliderTrackHeight - SliderTrackHeight div 2);
end;

class function TThemedGridInlineEditorGeometry.GetSliderThumbSize(const ACellBounds: TRect): Integer;
var
  LSize: Integer;
begin
  LSize := ACellBounds.Height - 8;
  if LSize < SliderMinimumThumbSize then
    LSize := SliderMinimumThumbSize;
  if LSize > SliderMaximumThumbSize then
    LSize := SliderMaximumThumbSize;
  Result := LSize;
end;

class function TThemedGridInlineEditorGeometry.GetSliderThumbBounds(const ACellBounds: TRect; const ANormalizedValue: Extended): TRect;
var
  LTrack: TRect;
  LThumbSize, LUsableWidth, LOffset, LCenterY: Integer;
  LValue: Extended;
begin
  LTrack := GetSliderTrackBounds(ACellBounds);
  LThumbSize := GetSliderThumbSize(ACellBounds);
  LUsableWidth := LTrack.Width - LThumbSize;
  if LUsableWidth < 0 then
    LUsableWidth := 0;
  LValue := ANormalizedValue;
  if LValue < 0 then
    LValue := 0;
  if LValue > 1 then
    LValue := 1;
  LOffset := Integer(RoundAwayFromZero(LUsableWidth * LValue));
  LCenterY := ACellBounds.Top + ACellBounds.Height div 2;
  Result := TRect.Create(LTrack.Left + LOffset, LCenterY - LThumbSize div 2,
    LTrack.Left + LOffset + LThumbSize, LCenterY - LThumbSize div 2 + LThumbSize);
end;

class function TThemedGridInlineEditorGeometry.GetSliderRatioFromPoint(const ACellBounds: TRect; const ALocation: TPoint): Extended;
var
  LTrack: TRect;
  LThumbSize, LUsableWidth, LOffset: Integer;
begin
  LTrack := GetSliderTrackBounds(ACellBounds);
  LThumbSize := GetSliderThumbSize(ACellBounds);
  LUsableWidth := LTrack.Width - LThumbSize;
  if LUsableWidth <= 0 then
    Exit(0);
  LOffset := ALocation.X - (LTrack.Left + LThumbSize div 2);
  if LOffset <= 0 then
    Exit(0);
  if LOffset >= LUsableWidth then
    Exit(1);
  Result := LOffset / LUsableWidth;
end;

class function TThemedGridInlineEditorGeometry.ResolveRatingMaximum(const AColumn: TThemedGridColumn): Integer;
var
  LMaximum: Integer;
begin
  LMaximum := RatingDefaultMaximum;
  if (AColumn <> nil) and (AColumn.EditorOptions <> nil) and AColumn.EditorOptions.HasMaximum then
    LMaximum := Integer(RoundAwayFromZero(AColumn.EditorOptions.Maximum));
  if LMaximum < RatingMinimumMaximum then
    LMaximum := RatingMinimumMaximum;
  if LMaximum > RatingMaximumMaximum then
    LMaximum := RatingMaximumMaximum;
  Result := LMaximum;
end;

class function TThemedGridInlineEditorGeometry.GetRatingItemSize(const ACellBounds: TRect): Integer;
var
  LSize: Integer;
begin
  LSize := ACellBounds.Height - 10;
  if LSize < RatingMinimumItemSize then
    LSize := RatingMinimumItemSize;
  if LSize > RatingMaximumItemSize then
    LSize := RatingMaximumItemSize;
  Result := LSize;
end;

class function TThemedGridInlineEditorGeometry.GetRatingBounds(const ACellBounds: TRect; const AMaximum: Integer): TRect;
var
  LMaximum, LItemSize, LTotalWidth, LLeft, LTop: Integer;
begin
  LMaximum := AMaximum;
  if LMaximum < RatingMinimumMaximum then
    LMaximum := RatingMinimumMaximum;
  LItemSize := GetRatingItemSize(ACellBounds);
  LTotalWidth := LMaximum * LItemSize + (LMaximum - 1) * RatingItemSpacing;
  LLeft := ACellBounds.Left + Max(RatingHorizontalPadding, (ACellBounds.Width - LTotalWidth) div 2);
  LTop := ACellBounds.Top + (ACellBounds.Height - LItemSize) div 2;
  Result := TRect.Create(LLeft, LTop, LLeft + LTotalWidth, LTop + LItemSize);
end;

class function TThemedGridInlineEditorGeometry.GetRatingItemBounds(const ACellBounds: TRect; const AMaximum, AIndex: Integer): TRect;
var
  LRatingBounds: TRect;
  LItemSize: Integer;
begin
  LRatingBounds := GetRatingBounds(ACellBounds, AMaximum);
  LItemSize := GetRatingItemSize(ACellBounds);
  Result := TRect.Create(
    LRatingBounds.Left + AIndex * (LItemSize + RatingItemSpacing),
    LRatingBounds.Top,
    LRatingBounds.Left + AIndex * (LItemSize + RatingItemSpacing) + LItemSize,
    LRatingBounds.Top + LItemSize);
end;

class function TThemedGridInlineEditorGeometry.GetRatingValueFromPoint(const ACellBounds: TRect; const AMaximum: Integer; const ALocation: TPoint): Integer;
var
  LMaximum, LItemSize, I, LItemRight: Integer;
  LRatingBounds: TRect;
begin
  LMaximum := AMaximum;
  if LMaximum < RatingMinimumMaximum then
    LMaximum := RatingMinimumMaximum;
  LRatingBounds := GetRatingBounds(ACellBounds, LMaximum);
  if ALocation.X < LRatingBounds.Left then
    Exit(0);
  if ALocation.X > LRatingBounds.Right then
    Exit(LMaximum);
  LItemSize := GetRatingItemSize(ACellBounds);
  for I := 0 to LMaximum - 1 do
  begin
    LItemRight := LRatingBounds.Left + I * (LItemSize + RatingItemSpacing) + LItemSize;
    if ALocation.X <= LItemRight + RatingItemSpacing then
      Exit(I + 1);
  end;
  Result := LMaximum;
end;

end.

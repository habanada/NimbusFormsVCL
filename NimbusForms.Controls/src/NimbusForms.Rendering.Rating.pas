{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Rating;

interface

uses
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedRatingRenderContext = record
    Bounds: TRect;
    Font: TFont;
    Palette: TThemePalette;
    Enabled: Boolean;
    Focused: Boolean;
    ReadOnly: Boolean;
    IsHovered: Boolean;
    ShowValueText: Boolean;
    ShowOutline: Boolean;
    Maximum: Integer;
    RatingValue: Double;
    HoverValue: Double;
    RatingShape: TRatingShape;
    ItemSize: Integer;
    ItemSpacing: Integer;
    TextSpacing: Integer;
    HoverOutlineWidth: Single;
    ValueText: string;
    ForeColor: TColor;
    ActiveColor: TColor;
    InactiveColor: TColor;
    HoverColor: TColor;
    OutlineColor: TColor;
    ActiveImage: Vcl.Graphics.TBitmap;
    InactiveImage: Vcl.Graphics.TBitmap;
    HoverImage: Vcl.Graphics.TBitmap;
  end;

  TThemedRatingRenderer = class
  public
    class function CalculateItemsWidth(const AMaximum, AItemSize, ASpacing: Integer): Integer; static;
    class function CalculateItemRect(const ABounds: TRect; const AIndex, AItemSize, ASpacing: Integer): TRect; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedRatingRenderContext); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

const
  RatingCircleSegments = 48;
  RatingHeartSegments = 24;

function ResolveCustomColor(const AColor: TColor; const AFallback: TThemeColor): TThemeColor;
begin
  if AColor = Vcl.Graphics.clNone then
    Result := AFallback
  else
    Result := ColorToThemeColor(AColor);
end;

function DefaultActiveColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then
    Result := NimbusAccentColor(APalette)
  else
    Result := ThemeColor(255, 255, 215, 0);
end;

function DefaultHoverColor(const APalette: TThemePalette; const AActiveColor: TThemeColor): TThemeColor;
begin
  if (APalette <> nil) and (ThemeColorAlpha(APalette.FocusBorderColor) <> 0) then
    Result := APalette.FocusBorderColor
  else
    Result := NimbusBlendColor(AActiveColor, ThemeColor(255, 255, 255, 255), 89);
end;

function CubicValue(const AStart, AControl1, AControl2, AEnd, AT: Double): Double;
var
  LInverse, LInverse2, LT2: Double;
begin
  LInverse := 1 - AT;
  LInverse2 := LInverse * LInverse;
  LT2 := AT * AT;
  Result := LInverse2 * LInverse * AStart + 3 * LInverse2 * AT * AControl1 +
    3 * LInverse * LT2 * AControl2 + LT2 * AT * AEnd;
end;

function BuildStarPoints(const ARect: TRect; var APoints: TNimbusPointBuffer): Integer;
var
  I: Integer;
  LCenterX, LCenterY, LOuterX, LOuterY, LInnerX, LInnerY, LRadiusX, LRadiusY, LAngle: Double;
begin
  Result := 10;
  LOuterX := ARect.Width / 2;
  LOuterY := ARect.Height / 2;
  LCenterX := ARect.Left + LOuterX;
  LCenterY := ARect.Top + LOuterY;
  LInnerX := LOuterX * 0.382;
  LInnerY := LOuterY * 0.382;
  LAngle := -Pi / 2;
  for I := 0 to Result - 1 do
  begin
    if Odd(I) then
    begin
      LRadiusX := LInnerX;
      LRadiusY := LInnerY;
    end
    else
    begin
      LRadiusX := LOuterX;
      LRadiusY := LOuterY;
    end;
    APoints[I] := Point(Round(LCenterX + Cos(LAngle) * LRadiusX), Round(LCenterY + Sin(LAngle) * LRadiusY));
    LAngle := LAngle + Pi / 5;
  end;
end;

function BuildHeartPoints(const ARect: TRect; var APoints: TNimbusPointBuffer): Integer;
var
  I, LIndex: Integer;
  LT, LX, LY, LW, LH: Double;
begin
  LX := ARect.Left;
  LY := ARect.Top;
  LW := ARect.Width;
  LH := ARect.Height;
  LIndex := 0;
  for I := 0 to RatingHeartSegments do
  begin
    LT := I / RatingHeartSegments;
    APoints[LIndex] := Point(
      Round(CubicValue(LX + LW / 2, LX - LW * 0.1, LX + LW * 0.1, LX + LW / 2, LT)),
      Round(CubicValue(LY + LH * 0.9, LY + LH * 0.45, LY, LY + LH * 0.28, LT)));
    Inc(LIndex);
  end;
  for I := 1 to RatingHeartSegments do
  begin
    LT := I / RatingHeartSegments;
    APoints[LIndex] := Point(
      Round(CubicValue(LX + LW / 2, LX + LW * 0.9, LX + LW * 1.1, LX + LW / 2, LT)),
      Round(CubicValue(LY + LH * 0.28, LY, LY + LH * 0.45, LY + LH * 0.9, LT)));
    Inc(LIndex);
  end;
  Result := LIndex;
end;

function BuildCirclePoints(const ARect: TRect; var APoints: TNimbusPointBuffer): Integer;
var
  I: Integer;
  LCenterX, LCenterY, LRadiusX, LRadiusY, LAngle: Double;
begin
  Result := RatingCircleSegments;
  LRadiusX := ARect.Width / 2;
  LRadiusY := ARect.Height / 2;
  LCenterX := ARect.Left + LRadiusX;
  LCenterY := ARect.Top + LRadiusY;
  for I := 0 to Result - 1 do
  begin
    LAngle := -Pi / 2 + 2 * Pi * I / Result;
    APoints[I] := Point(Round(LCenterX + Cos(LAngle) * LRadiusX), Round(LCenterY + Sin(LAngle) * LRadiusY));
  end;
end;

function BuildShapePoints(const AShape: TRatingShape; const ARect: TRect; var APoints: TNimbusPointBuffer): Integer;
begin
  case AShape of
    rsHeart: Result := BuildHeartPoints(ARect, APoints);
    rsCircle: Result := BuildCirclePoints(ARect, APoints);
    rsSquare:
      begin
        APoints[0] := Point(ARect.Left, ARect.Top);
        APoints[1] := Point(ARect.Right, ARect.Top);
        APoints[2] := Point(ARect.Right, ARect.Bottom);
        APoints[3] := Point(ARect.Left, ARect.Bottom);
        Result := 4;
      end;
    rsDiamond:
      begin
        APoints[0] := Point(ARect.Left + ARect.Width div 2, ARect.Top);
        APoints[1] := Point(ARect.Right, ARect.Top + ARect.Height div 2);
        APoints[2] := Point(ARect.Left + ARect.Width div 2, ARect.Bottom);
        APoints[3] := Point(ARect.Left, ARect.Top + ARect.Height div 2);
        Result := 4;
      end;
  else
    Result := BuildStarPoints(ARect, APoints);
  end;
end;

function VerticalIntersection(const AStart, AEnd: TPoint; const AX: Integer): TPoint;
var
  LFactor: Double;
begin
  Result.X := AX;
  if AEnd.X = AStart.X then
  begin
    Result.Y := AEnd.Y;
    Exit;
  end;
  LFactor := (AX - AStart.X) / (AEnd.X - AStart.X);
  Result.Y := Round(AStart.Y + (AEnd.Y - AStart.Y) * LFactor);
end;

function ClipPolygonLeft(const AInput: TNimbusPointBuffer; const ACount, AX: Integer; var AOutput: TNimbusPointBuffer): Integer;
var
  I: Integer;
  LPrevious, LCurrent: TPoint;
  LPreviousInside, LCurrentInside: Boolean;
begin
  Result := 0;
  if ACount < 3 then
    Exit;
  LPrevious := AInput[ACount - 1];
  LPreviousInside := LPrevious.X >= AX;
  for I := 0 to ACount - 1 do
  begin
    LCurrent := AInput[I];
    LCurrentInside := LCurrent.X >= AX;
    if LCurrentInside <> LPreviousInside then
    begin
      AOutput[Result] := VerticalIntersection(LPrevious, LCurrent, AX);
      Inc(Result);
    end;
    if LCurrentInside then
    begin
      AOutput[Result] := LCurrent;
      Inc(Result);
    end;
    LPrevious := LCurrent;
    LPreviousInside := LCurrentInside;
  end;
end;

function ClipPolygonRight(const AInput: TNimbusPointBuffer; const ACount, AX: Integer; var AOutput: TNimbusPointBuffer): Integer;
var
  I: Integer;
  LPrevious, LCurrent: TPoint;
  LPreviousInside, LCurrentInside: Boolean;
begin
  Result := 0;
  if ACount < 3 then
    Exit;
  LPrevious := AInput[ACount - 1];
  LPreviousInside := LPrevious.X <= AX;
  for I := 0 to ACount - 1 do
  begin
    LCurrent := AInput[I];
    LCurrentInside := LCurrent.X <= AX;
    if LCurrentInside <> LPreviousInside then
    begin
      AOutput[Result] := VerticalIntersection(LPrevious, LCurrent, AX);
      Inc(Result);
    end;
    if LCurrentInside then
    begin
      AOutput[Result] := LCurrent;
      Inc(Result);
    end;
    LPrevious := LCurrent;
    LPreviousInside := LCurrentInside;
  end;
end;

function ClipPolygonRange(const AInput: TNimbusPointBuffer; const ACount, ALeft, ARight: Integer; var AOutput: TNimbusPointBuffer): Integer;
var
  LTemp: TNimbusPointBuffer;
  LCount: Integer;
begin
  Result := 0;
  if (ACount < 3) or (ARight <= ALeft) then
    Exit;
  LCount := ClipPolygonLeft(AInput, ACount, ALeft, LTemp);
  if LCount < 3 then
    Exit;
  Result := ClipPolygonRight(LTemp, LCount, ARight, AOutput);
end;

procedure DrawBitmapRange(const ACanvas: INimbusRenderCanvas; const ABitmap: Vcl.Graphics.TBitmap;
  const ARect: TRect; const AStartFill, AEndFill: Double);
var
  LStartFill, LEndFill: Double;
  LDestRect, LSourceRect: TRect;
  LDestLeft, LDestRight, LSourceLeft, LSourceRight: Integer;
begin
  if (ACanvas = nil) or (ABitmap = nil) or ABitmap.Empty then
    Exit;
  LStartFill := EnsureRange(AStartFill, 0.0, 1.0);
  LEndFill := EnsureRange(AEndFill, 0.0, 1.0);
  if LEndFill <= LStartFill then
    Exit;
  LDestLeft := ARect.Left + Integer(Floor(ARect.Width * LStartFill));
  LDestRight := ARect.Left + Integer(Ceil(ARect.Width * LEndFill));
  LSourceLeft := Integer(Floor(ABitmap.Width * LStartFill));
  LSourceRight := Integer(Ceil(ABitmap.Width * LEndFill));
  if LDestRight <= LDestLeft then LDestRight := LDestLeft + 1;
  if LSourceRight <= LSourceLeft then LSourceRight := LSourceLeft + 1;
  if LDestRight > ARect.Right then LDestRight := ARect.Right;
  if LSourceRight > ABitmap.Width then LSourceRight := ABitmap.Width;
  LDestRect := Rect(LDestLeft, ARect.Top, LDestRight, ARect.Bottom);
  LSourceRect := Rect(LSourceLeft, 0, LSourceRight, ABitmap.Height);
  ACanvas.DrawBitmapPart(ABitmap, LDestRect, LSourceRect);
end;

procedure DrawShapeRange(const ACanvas: INimbusRenderCanvas; const APoints: TNimbusPointBuffer;
  const APointCount: Integer; const ARect: TRect; const AStartFill, AEndFill: Double; const AColor: TThemeColor);
var
  LClipped: TNimbusPointBuffer;
  LLeft, LRight, LCount: Integer;
begin
  LLeft := ARect.Left + Integer(Floor(ARect.Width * EnsureRange(AStartFill, 0.0, 1.0)));
  LRight := ARect.Left + Integer(Ceil(ARect.Width * EnsureRange(AEndFill, 0.0, 1.0)));
  if LRight <= LLeft then
    Exit;
  LCount := ClipPolygonRange(APoints, APointCount, LLeft, LRight, LClipped);
  if LCount >= 3 then
    ACanvas.FillPolygon(AColor, @LClipped, LCount);
end;

class function TThemedRatingRenderer.CalculateItemsWidth(const AMaximum, AItemSize, ASpacing: Integer): Integer;
begin
  if AMaximum <= 0 then
    Exit(0);
  Result := AMaximum * AItemSize + (AMaximum - 1) * ASpacing;
end;

class function TThemedRatingRenderer.CalculateItemRect(const ABounds: TRect; const AIndex, AItemSize, ASpacing: Integer): TRect;
var
  LX, LY: Integer;
begin
  LX := ABounds.Left + AIndex * (AItemSize + ASpacing);
  LY := ABounds.Top + (ABounds.Height - AItemSize) div 2;
  Result := Rect(LX, LY, LX + AItemSize, LY + AItemSize);
end;

class procedure TThemedRatingRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedRatingRenderContext);
var
  I, LPointCount, LItemsWidth: Integer;
  LRect, LTextRect: TRect;
  LPoints: TNimbusPointBuffer;
  LSelectedFill, LHoverFill: Double;
  LActiveColor, LInactiveColor, LHoverColor, LOutlineColor, LTextColor: TThemeColor;
  LShowHoverPreview: Boolean;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;

  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  LActiveColor := ResolveCustomColor(AContext.ActiveColor, DefaultActiveColor(AContext.Palette));
  LInactiveColor := ResolveCustomColor(AContext.InactiveColor, NimbusControlBorderColor(AContext.Palette));
  LHoverColor := ResolveCustomColor(AContext.HoverColor, DefaultHoverColor(AContext.Palette, LActiveColor));
  LOutlineColor := ResolveCustomColor(AContext.OutlineColor, NimbusControlBorderColor(AContext.Palette));
  if AContext.Palette <> nil then LTextColor := NimbusControlForeColor(AContext.Palette) else LTextColor := ColorToThemeColor(AContext.ForeColor);

  if not AContext.Enabled then
  begin
    LActiveColor := NimbusDisabledForeColor(AContext.Palette);
    if AContext.Palette <> nil then LInactiveColor := NimbusDisabledBackColor(AContext.Palette) else LInactiveColor := ColorToThemeColor(clBtnHighlight);
    LHoverColor := LInactiveColor;
    LOutlineColor := LActiveColor;
    LTextColor := LActiveColor;
  end;

  LShowHoverPreview := AContext.IsHovered and not AContext.ReadOnly and AContext.Enabled and (AContext.HoverValue > 0);

  for I := 0 to AContext.Maximum - 1 do
  begin
    LRect := CalculateItemRect(AContext.Bounds, I, AContext.ItemSize, AContext.ItemSpacing);
    if (AContext.InactiveImage <> nil) and not AContext.InactiveImage.Empty then
      ACanvas.DrawBitmap(AContext.InactiveImage, LRect)
    else
    begin
      LPointCount := BuildShapePoints(AContext.RatingShape, LRect, LPoints);
      ACanvas.FillPolygon(LInactiveColor, @LPoints, LPointCount);
    end;
  end;

  for I := 0 to AContext.Maximum - 1 do
  begin
    LSelectedFill := EnsureRange(AContext.RatingValue - I, 0.0, 1.0);
    if LSelectedFill <= 0 then Continue;
    LRect := CalculateItemRect(AContext.Bounds, I, AContext.ItemSize, AContext.ItemSpacing);
    if (AContext.ActiveImage <> nil) and not AContext.ActiveImage.Empty then
      DrawBitmapRange(ACanvas, AContext.ActiveImage, LRect, 0, LSelectedFill)
    else
    begin
      LPointCount := BuildShapePoints(AContext.RatingShape, LRect, LPoints);
      DrawShapeRange(ACanvas, LPoints, LPointCount, LRect, 0, LSelectedFill, LActiveColor);
    end;
  end;

  if AContext.ShowOutline then
    for I := 0 to AContext.Maximum - 1 do
    begin
      LRect := CalculateItemRect(AContext.Bounds, I, AContext.ItemSize, AContext.ItemSpacing);
      LPointCount := BuildShapePoints(AContext.RatingShape, LRect, LPoints);
      ACanvas.DrawPolygon(LOutlineColor, @LPoints, LPointCount, 1.0);
    end;

  if LShowHoverPreview then
    for I := 0 to AContext.Maximum - 1 do
    begin
      LHoverFill := EnsureRange(AContext.HoverValue - I, 0.0, 1.0);
      if LHoverFill <= 0 then Continue;
      LSelectedFill := EnsureRange(AContext.RatingValue - I, 0.0, 1.0);
      LRect := CalculateItemRect(AContext.Bounds, I, AContext.ItemSize, AContext.ItemSpacing);
      if LHoverFill > LSelectedFill then
      begin
        if (AContext.HoverImage <> nil) and not AContext.HoverImage.Empty then
          DrawBitmapRange(ACanvas, AContext.HoverImage, LRect, LSelectedFill, LHoverFill)
        else
        begin
          LPointCount := BuildShapePoints(AContext.RatingShape, LRect, LPoints);
          DrawShapeRange(ACanvas, LPoints, LPointCount, LRect, LSelectedFill, LHoverFill, NimbusColorWithAlpha(LHoverColor, 112));
        end;
      end;
      LPointCount := BuildShapePoints(AContext.RatingShape, LRect, LPoints);
      ACanvas.DrawPolygon(LHoverColor, @LPoints, LPointCount, AContext.HoverOutlineWidth);
    end;

  if AContext.ShowValueText and (AContext.ValueText <> '') then
  begin
    LItemsWidth := CalculateItemsWidth(AContext.Maximum, AContext.ItemSize, AContext.ItemSpacing);
    LTextRect := Rect(AContext.Bounds.Left + LItemsWidth + AContext.TextSpacing, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
    if not NimbusRectIsEmpty(LTextRect) then ACanvas.DrawText(AContext.ValueText, AContext.Font, LTextColor, LTextRect, [ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  end;

  if AContext.Focused and AContext.Enabled then ACanvas.DrawDashedRectangle(NimbusFocusBorderColor(AContext.Palette), AContext.Bounds);
end;

end.

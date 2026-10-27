{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ScrollBar;

interface

uses
  System.Types,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TNimbusScrollBarOrientation = (nsboHorizontal, nsboVertical);
  TNimbusScrollBarPart = (nsbpNone, nsbpDecreaseButton, nsbpIncreaseButton, nsbpThumb, nsbpTrackBefore, nsbpTrackAfter);

  TNimbusScrollBarRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    Orientation: TNimbusScrollBarOrientation;
    Minimum: Integer;
    Maximum: Integer;
    Value: Integer;
    LargeChange: Integer;
    ButtonSize: Integer;
    MinimumThumbSize: Integer;
    ArrowMinorSize: Integer;
    ArrowMajorSize: Integer;
    Enabled: Boolean;
    HoverDecrease: Boolean;
    HoverIncrease: Boolean;
    HoverThumb: Boolean;
    PressedDecrease: Boolean;
    PressedIncrease: Boolean;
    PressedThumb: Boolean;
  end;

  TNimbusScrollBarLayout = record
    DecreaseButtonRect: TRect;
    IncreaseButtonRect: TRect;
    TrackRect: TRect;
    ThumbRect: TRect;
  end;

  TThemedScrollBarRenderer = class
  private
    class function ClampValue(const AValue, AMinimum, AMaximum: Integer): Integer; static;
    class procedure DrawButton(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const ABackColor, ABorderColor, AArrowColor: TThemeColor; const AOrientation: TNimbusScrollBarOrientation; const ADecrease: Boolean; const AMinorSize, AMajorSize: Integer); static;
  public
    class function EffectiveMaximum(const AMinimum, AMaximum, ALargeChange: Integer): Integer; static;
    class procedure CalculateLayout(const AContext: TNimbusScrollBarRenderContext; out ALayout: TNimbusScrollBarLayout); static;
    class function HitTest(const AContext: TNimbusScrollBarRenderContext; const APoint: TPoint): TNimbusScrollBarPart; static;
    class function ValueFromThumbPosition(const AContext: TNimbusScrollBarRenderContext; const AThumbPosition: Integer): Integer; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  NimbusForms.Rendering.Types;

class function TThemedScrollBarRenderer.ClampValue(const AValue, AMinimum, AMaximum: Integer): Integer;
begin
  Result := AValue;
  if Result < AMinimum then Result := AMinimum;
  if Result > AMaximum then Result := AMaximum;
end;

class function TThemedScrollBarRenderer.EffectiveMaximum(const AMinimum, AMaximum, ALargeChange: Integer): Integer;
var
  LValue: Int64;
begin
  LValue := Int64(AMaximum) - Int64(ALargeChange) + 1;
  if LValue < AMinimum then LValue := AMinimum;
  if LValue > High(Integer) then LValue := High(Integer);
  Result := Integer(LValue);
end;

class procedure TThemedScrollBarRenderer.CalculateLayout(const AContext: TNimbusScrollBarRenderContext; out ALayout: TNimbusScrollBarLayout);
var
  LButtonSize, LTrackLength, LThumbLength, LMovable, LOffset, LMaxValue: Integer;
  LRange: Int64;
  LRatio: Double;
begin
  ALayout.DecreaseButtonRect := Rect(0, 0, 0, 0);
  ALayout.IncreaseButtonRect := Rect(0, 0, 0, 0);
  ALayout.TrackRect := Rect(0, 0, 0, 0);
  ALayout.ThumbRect := Rect(0, 0, 0, 0);
  if NimbusRectIsEmpty(AContext.Bounds) then Exit;

  if AContext.Orientation = nsboHorizontal then
  begin
    LButtonSize := AContext.ButtonSize;
    if LButtonSize < 0 then LButtonSize := 0;
    if LButtonSize > AContext.Bounds.Width div 2 then LButtonSize := AContext.Bounds.Width div 2;
    ALayout.DecreaseButtonRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Left + LButtonSize, AContext.Bounds.Bottom);
    ALayout.IncreaseButtonRect := Rect(AContext.Bounds.Right - LButtonSize, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
    ALayout.TrackRect := Rect(ALayout.DecreaseButtonRect.Right, AContext.Bounds.Top, ALayout.IncreaseButtonRect.Left, AContext.Bounds.Bottom);
    LTrackLength := ALayout.TrackRect.Width;
  end
  else
  begin
    LButtonSize := AContext.ButtonSize;
    if LButtonSize < 0 then LButtonSize := 0;
    if LButtonSize > AContext.Bounds.Height div 2 then LButtonSize := AContext.Bounds.Height div 2;
    ALayout.DecreaseButtonRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Top + LButtonSize);
    ALayout.IncreaseButtonRect := Rect(AContext.Bounds.Left, AContext.Bounds.Bottom - LButtonSize, AContext.Bounds.Right, AContext.Bounds.Bottom);
    ALayout.TrackRect := Rect(AContext.Bounds.Left, ALayout.DecreaseButtonRect.Bottom, AContext.Bounds.Right, ALayout.IncreaseButtonRect.Top);
    LTrackLength := ALayout.TrackRect.Height;
  end;

  if LTrackLength <= 0 then Exit;
  LMaxValue := EffectiveMaximum(AContext.Minimum, AContext.Maximum, AContext.LargeChange);
  if LMaxValue <= AContext.Minimum then
  begin
    ALayout.ThumbRect := ALayout.TrackRect;
    Exit;
  end;

  LRange := Int64(AContext.Maximum) - Int64(AContext.Minimum) + Int64(AContext.LargeChange);
  if LRange <= 0 then
    LThumbLength := LTrackLength
  else
    LThumbLength := Integer(Round(LTrackLength * (AContext.LargeChange / LRange)));
  if LThumbLength < AContext.MinimumThumbSize then LThumbLength := AContext.MinimumThumbSize;
  if LThumbLength > LTrackLength then LThumbLength := LTrackLength;

  LMovable := LTrackLength - LThumbLength;
  if LMovable <= 0 then
    LOffset := 0
  else
  begin
    LRatio := (Int64(ClampValue(AContext.Value, AContext.Minimum, LMaxValue)) - Int64(AContext.Minimum)) / (Int64(LMaxValue) - Int64(AContext.Minimum));
    LOffset := Integer(Round(LRatio * LMovable));
  end;

  if AContext.Orientation = nsboHorizontal then
    ALayout.ThumbRect := Rect(ALayout.TrackRect.Left + LOffset, ALayout.TrackRect.Top, ALayout.TrackRect.Left + LOffset + LThumbLength, ALayout.TrackRect.Bottom)
  else
    ALayout.ThumbRect := Rect(ALayout.TrackRect.Left, ALayout.TrackRect.Top + LOffset, ALayout.TrackRect.Right, ALayout.TrackRect.Top + LOffset + LThumbLength);
end;

class function TThemedScrollBarRenderer.HitTest(const AContext: TNimbusScrollBarRenderContext; const APoint: TPoint): TNimbusScrollBarPart;
var
  LLayout: TNimbusScrollBarLayout;
begin
  CalculateLayout(AContext, LLayout);
  if PtInRect(LLayout.DecreaseButtonRect, APoint) then Exit(nsbpDecreaseButton);
  if PtInRect(LLayout.IncreaseButtonRect, APoint) then Exit(nsbpIncreaseButton);
  if PtInRect(LLayout.ThumbRect, APoint) then Exit(nsbpThumb);
  if PtInRect(LLayout.TrackRect, APoint) then
  begin
    if AContext.Orientation = nsboHorizontal then
    begin
      if APoint.X < LLayout.ThumbRect.Left then Exit(nsbpTrackBefore);
      if APoint.X >= LLayout.ThumbRect.Right then Exit(nsbpTrackAfter);
    end
    else
    begin
      if APoint.Y < LLayout.ThumbRect.Top then Exit(nsbpTrackBefore);
      if APoint.Y >= LLayout.ThumbRect.Bottom then Exit(nsbpTrackAfter);
    end;
  end;
  Result := nsbpNone;
end;

class function TThemedScrollBarRenderer.ValueFromThumbPosition(const AContext: TNimbusScrollBarRenderContext; const AThumbPosition: Integer): Integer;
var
  LLayout: TNimbusScrollBarLayout;
  LTrackStart, LTrackLength, LThumbLength, LMovable, LPosition, LMaxValue: Integer;
  LRatio: Double;
begin
  CalculateLayout(AContext, LLayout);
  LMaxValue := EffectiveMaximum(AContext.Minimum, AContext.Maximum, AContext.LargeChange);
  if AContext.Orientation = nsboHorizontal then
  begin
    LTrackStart := LLayout.TrackRect.Left;
    LTrackLength := LLayout.TrackRect.Width;
    LThumbLength := LLayout.ThumbRect.Width;
  end
  else
  begin
    LTrackStart := LLayout.TrackRect.Top;
    LTrackLength := LLayout.TrackRect.Height;
    LThumbLength := LLayout.ThumbRect.Height;
  end;
  LMovable := LTrackLength - LThumbLength;
  if (LMovable <= 0) or (LMaxValue <= AContext.Minimum) then Exit(AContext.Minimum);
  LPosition := AThumbPosition;
  if LPosition < LTrackStart then LPosition := LTrackStart;
  if LPosition > LTrackStart + LMovable then LPosition := LTrackStart + LMovable;
  LRatio := (LPosition - LTrackStart) / LMovable;
  Result := ClampValue(Integer(Round(Int64(AContext.Minimum) + (Int64(LMaxValue) - Int64(AContext.Minimum)) * LRatio)), AContext.Minimum, LMaxValue);
end;

class procedure TThemedScrollBarRenderer.DrawButton(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const ABackColor, ABorderColor, AArrowColor: TThemeColor; const AOrientation: TNimbusScrollBarOrientation; const ADecrease: Boolean; const AMinorSize, AMajorSize: Integer);
var
  LCX, LCY: Integer;
  LP1, LP2, LP3: TPoint;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  ACanvas.FillRectangle(ABackColor, ARect);
  ACanvas.DrawRectangle(ABorderColor, ARect, 1.0);
  LCX := ARect.Left + ARect.Width div 2;
  LCY := ARect.Top + ARect.Height div 2;
  if AOrientation = nsboHorizontal then
  begin
    if ADecrease then
    begin
      LP1 := Point(LCX + AMinorSize, LCY - AMajorSize);
      LP2 := Point(LCX + AMinorSize, LCY + AMajorSize);
      LP3 := Point(LCX - AMinorSize, LCY);
    end
    else
    begin
      LP1 := Point(LCX - AMinorSize, LCY - AMajorSize);
      LP2 := Point(LCX - AMinorSize, LCY + AMajorSize);
      LP3 := Point(LCX + AMinorSize, LCY);
    end;
  end
  else
  begin
    if ADecrease then
    begin
      LP1 := Point(LCX - AMajorSize, LCY + AMinorSize);
      LP2 := Point(LCX + AMajorSize, LCY + AMinorSize);
      LP3 := Point(LCX, LCY - AMinorSize);
    end
    else
    begin
      LP1 := Point(LCX - AMajorSize, LCY - AMinorSize);
      LP2 := Point(LCX + AMajorSize, LCY - AMinorSize);
      LP3 := Point(LCX, LCY + AMinorSize);
    end;
  end;
  ACanvas.FillTriangle(AArrowColor, LP1, LP2, LP3);
end;

class procedure TThemedScrollBarRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext);
var
  LLayout: TNimbusScrollBarLayout;
  LTrackColor, LBorderColor, LButtonColor, LHoverColor, LPressedColor, LThumbColor, LArrowColor: TThemeColor;
  LDecreaseColor, LIncreaseColor, LCurrentThumbColor: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  LTrackColor := NimbusControlBackColor(AContext.Palette);
  LBorderColor := NimbusControlBorderColor(AContext.Palette);
  LButtonColor := NimbusInputBackColor(AContext.Palette);
  LHoverColor := NimbusHoverBackColor(AContext.Palette);
  LPressedColor := NimbusPressedBackColor(AContext.Palette);
  LThumbColor := NimbusMenuSelectedBackColor(AContext.Palette);
  LArrowColor := NimbusControlForeColor(AContext.Palette);
  if not AContext.Enabled then
  begin
    LTrackColor := NimbusDisabledBackColor(AContext.Palette);
    LButtonColor := NimbusDisabledBackColor(AContext.Palette);
    LThumbColor := NimbusDisabledForeColor(AContext.Palette);
    LArrowColor := NimbusDisabledForeColor(AContext.Palette);
  end;
  ACanvas.FillRectangle(LTrackColor, AContext.Bounds);
  CalculateLayout(AContext, LLayout);
  LDecreaseColor := LButtonColor;
  LIncreaseColor := LButtonColor;
  LCurrentThumbColor := LThumbColor;
  if AContext.Enabled then
  begin
    if AContext.PressedDecrease then LDecreaseColor := LPressedColor else if AContext.HoverDecrease then LDecreaseColor := LHoverColor;
    if AContext.PressedIncrease then LIncreaseColor := LPressedColor else if AContext.HoverIncrease then LIncreaseColor := LHoverColor;
    if AContext.PressedThumb then LCurrentThumbColor := LPressedColor else if AContext.HoverThumb then LCurrentThumbColor := LHoverColor;
  end;
  DrawButton(ACanvas, LLayout.DecreaseButtonRect, LDecreaseColor, LBorderColor, LArrowColor, AContext.Orientation, True, AContext.ArrowMinorSize, AContext.ArrowMajorSize);
  DrawButton(ACanvas, LLayout.IncreaseButtonRect, LIncreaseColor, LBorderColor, LArrowColor, AContext.Orientation, False, AContext.ArrowMinorSize, AContext.ArrowMajorSize);
  if not NimbusRectIsEmpty(LLayout.ThumbRect) then
  begin
    ACanvas.FillRectangle(LCurrentThumbColor, LLayout.ThumbRect);
    ACanvas.DrawRectangle(LBorderColor, LLayout.ThumbRect, 1.0);
  end;
  ACanvas.DrawRectangle(LBorderColor, AContext.Bounds, 1.0);
end;

end.

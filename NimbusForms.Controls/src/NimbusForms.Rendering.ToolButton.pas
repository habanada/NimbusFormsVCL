{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ToolButton;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedToolButtonRenderContext = record
    Bounds: TRect;
    MainBounds: TRect;
    DropDownBounds: TRect;
    ContentBounds: TRect;
    ImageBounds: TRect;
    TextBounds: TRect;
    Caption: string;
    Font: TFont;
    Palette: TThemePalette;
    IconHandle: HICON;
    ButtonStyle: TThemedToolButtonStyle;
    HighlightStyle: TThemedToolButtonHighlightStyle;
    ImagePlacement: TThemedToolButtonImagePlacement;
    DropDownMode: TThemedToolButtonDropDownMode;
    TextAlign: TThemedContentAlignment;
    ImageAlign: TThemedContentAlignment;
    PaddingLeft: Integer;
    PaddingTop: Integer;
    PaddingRight: Integer;
    PaddingBottom: Integer;
    TextOffset: TPoint;
    ImageOffset: TPoint;
    ImageSize: Integer;
    ImageTextSpacing: Integer;
    CornerRadius: Integer;
    SplitButtonWidth: Integer;
    PPI: Integer;
    CurrentColor: TThemeColor;
    Enabled: Boolean;
    Hot: Boolean;
    Pressed: Boolean;
    DropDownHot: Boolean;
    DropDownPressed: Boolean;
    Checkable: Boolean;
    Checked: Boolean;
    Focused: Boolean;
    ShowFocusRectangle: Boolean;
    Multiline: Boolean;
    AutoEllipsis: Boolean;
    UseThemeAccent: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedToolButtonRenderer = class sealed
  private
    class function Scale(const AContext: TThemedToolButtonRenderContext; const AValue: Integer): Integer; static;
    class function AlignX(const ABounds: TRect; const AWidth: Integer; const AAlignment: TThemedContentAlignment): Integer; static;
    class function AlignY(const ABounds: TRect; const AHeight: Integer; const AAlignment: TThemedContentAlignment): Integer; static;
    class function AlignRect(const ABounds: TRect; const ASize: TSize; const AAlignment: TThemedContentAlignment): TRect; static;
    class function TextFlags(const AContext: TThemedToolButtonRenderContext): TNimbusTextFlags; static;
    class function MeasureText(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext; const AMaxWidth: Integer): TSize; static;
    class function EffectivePlacement(const AContext: TThemedToolButtonRenderContext): TThemedToolButtonImagePlacement; static;
    class procedure ResolveContentLayout(const ACanvas: INimbusRenderCanvas; var AContext: TThemedToolButtonRenderContext); static;
    class procedure ResolveColors(const AContext: TThemedToolButtonRenderContext; out AFill, ABorder, AFore: TThemeColor); static;
    class function ResolveHotBorderColor(const AContext: TThemedToolButtonRenderContext): TThemeColor; static;
    class function ResolveCheckedFillColor(const AContext: TThemedToolButtonRenderContext; const ABaseFill: TThemeColor; const AHot: Boolean): TThemeColor; static;
    class procedure DrawBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext); static;
    class procedure DrawContent(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext); static;
    class procedure DrawDropDown(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext); static;
    class procedure DrawFocus(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext); static;
  public
    class procedure CalculateLayout(const ACanvas: INimbusRenderCanvas; var AContext: TThemedToolButtonRenderContext); static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; var AContext: TThemedToolButtonRenderContext); static;
  end;

implementation

uses
  System.Math;

class function TThemedToolButtonRenderer.Scale(const AContext: TThemedToolButtonRenderContext; const AValue: Integer): Integer;
begin
  Result := NimbusScaleValue(AValue, AContext.PPI);
end;

class function TThemedToolButtonRenderer.AlignX(const ABounds: TRect; const AWidth: Integer; const AAlignment: TThemedContentAlignment): Integer;
begin
  case AAlignment of
    tcaTopCenter, tcaMiddleCenter, tcaBottomCenter: Result := ABounds.Left + (ABounds.Width - AWidth) div 2;
    tcaTopRight, tcaMiddleRight, tcaBottomRight: Result := ABounds.Right - AWidth;
  else
    Result := ABounds.Left;
  end;
end;

class function TThemedToolButtonRenderer.AlignY(const ABounds: TRect; const AHeight: Integer; const AAlignment: TThemedContentAlignment): Integer;
begin
  case AAlignment of
    tcaMiddleLeft, tcaMiddleCenter, tcaMiddleRight: Result := ABounds.Top + (ABounds.Height - AHeight) div 2;
    tcaBottomLeft, tcaBottomCenter, tcaBottomRight: Result := ABounds.Bottom - AHeight;
  else
    Result := ABounds.Top;
  end;
end;

class function TThemedToolButtonRenderer.AlignRect(const ABounds: TRect; const ASize: TSize; const AAlignment: TThemedContentAlignment): TRect;
var
  X, Y: Integer;
begin
  X := AlignX(ABounds, ASize.cx, AAlignment);
  Y := AlignY(ABounds, ASize.cy, AAlignment);
  Result := Rect(X, Y, X + ASize.cx, Y + ASize.cy);
end;

class function TThemedToolButtonRenderer.TextFlags(const AContext: TThemedToolButtonRenderContext): TNimbusTextFlags;
begin
  Result := [ntfNoPrefix];
  if AContext.Multiline then Include(Result, ntfWordWrap) else Include(Result, ntfSingleLine);
  if AContext.AutoEllipsis then Include(Result, ntfEndEllipsis);
  case AContext.TextAlign of
    tcaTopCenter, tcaMiddleCenter, tcaBottomCenter: Include(Result, ntfCenter);
    tcaTopRight, tcaMiddleRight, tcaBottomRight: Include(Result, ntfRight);
  end;
  case AContext.TextAlign of
    tcaMiddleLeft, tcaMiddleCenter, tcaMiddleRight: Include(Result, ntfVCenter);
    tcaBottomLeft, tcaBottomCenter, tcaBottomRight: Include(Result, ntfBottom);
  end;
  if AContext.RightToLeft then Include(Result, ntfRightToLeft);
end;

class function TThemedToolButtonRenderer.MeasureText(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext; const AMaxWidth: Integer): TSize;
var
  LFlags: TNimbusTextFlags;
begin
  if (AContext.Caption = '') or (AContext.Font = nil) then
  begin
    Result := TSize.Create(0, 0);
    Exit;
  end;
  LFlags := TextFlags(AContext);
  Exclude(LFlags, ntfCenter);
  Exclude(LFlags, ntfRight);
  Exclude(LFlags, ntfVCenter);
  Exclude(LFlags, ntfBottom);
  Result := ACanvas.MeasureText(AContext.Caption, AContext.Font, Max(1, AMaxWidth), LFlags);
end;

class function TThemedToolButtonRenderer.EffectivePlacement(const AContext: TThemedToolButtonRenderContext): TThemedToolButtonImagePlacement;
begin
  Result := AContext.ImagePlacement;
  if AContext.RightToLeft then
    case Result of
      ttbipLeft: Result := ttbipRight;
      ttbipRight: Result := ttbipLeft;
    end;
end;

class procedure TThemedToolButtonRenderer.ResolveContentLayout(const ACanvas: INimbusRenderCanvas; var AContext: TThemedToolButtonRenderContext);
var
  LContent: TRect;
  LImageSize, LSpacing, LTotalHeight, LTotalImageWidth, LStartY, LImageX: Integer;
  LHasImage, LHasText: Boolean;
  LTextSize, LImageExtent: TSize;
  LPlacement: TThemedToolButtonImagePlacement;
begin
  LContent := AContext.ContentBounds;
  LImageSize := Max(1, Scale(AContext, AContext.ImageSize));
  LSpacing := Max(0, Scale(AContext, AContext.ImageTextSpacing));
  LHasImage := AContext.IconHandle <> 0;
  LHasText := AContext.Caption <> '';
  AContext.ImageBounds := Rect(0, 0, 0, 0);
  AContext.TextBounds := Rect(0, 0, 0, 0);
  if not LHasImage and not LHasText then Exit;
  LImageExtent := TSize.Create(Min(LContent.Width, LImageSize), Min(LContent.Height, LImageSize));
  if LHasImage and not LHasText then
    AContext.ImageBounds := AlignRect(LContent, LImageExtent, AContext.ImageAlign)
  else if not LHasImage then
    AContext.TextBounds := LContent
  else
  begin
    LPlacement := EffectivePlacement(AContext);
    if LPlacement = ttbipOverlay then
    begin
      AContext.ImageBounds := AlignRect(LContent, LImageExtent, AContext.ImageAlign);
      AContext.TextBounds := LContent;
    end
    else if LPlacement in [ttbipTop, ttbipBottom] then
    begin
      LTextSize := MeasureText(ACanvas, AContext, LContent.Width);
      LTotalHeight := LImageSize + LSpacing + LTextSize.cy;
      LStartY := AlignY(LContent, LTotalHeight, AContext.ImageAlign);
      LImageX := AlignX(LContent, LImageSize, AContext.ImageAlign);
      if LPlacement = ttbipTop then
      begin
        AContext.ImageBounds := Rect(LImageX, LStartY, LImageX + LImageSize, LStartY + LImageSize);
        AContext.TextBounds := Rect(LContent.Left, AContext.ImageBounds.Bottom + LSpacing, LContent.Right, LContent.Bottom);
      end
      else
      begin
        AContext.TextBounds := Rect(LContent.Left, LStartY, LContent.Right, Min(LContent.Bottom, LStartY + LTextSize.cy));
        AContext.ImageBounds := Rect(LImageX, AContext.TextBounds.Bottom + LSpacing, LImageX + LImageSize, AContext.TextBounds.Bottom + LSpacing + LImageSize);
      end;
    end
    else
    begin
      LTotalImageWidth := LImageSize + LSpacing;
      if LPlacement = ttbipRight then
      begin
        AContext.ImageBounds := Rect(LContent.Right - LImageSize, LContent.Top + (LContent.Height - LImageSize) div 2, LContent.Right, LContent.Top + (LContent.Height - LImageSize) div 2 + LImageSize);
        AContext.TextBounds := Rect(LContent.Left, LContent.Top, Max(LContent.Left, LContent.Right - LTotalImageWidth), LContent.Bottom);
      end
      else
      begin
        AContext.ImageBounds := Rect(LContent.Left, LContent.Top + (LContent.Height - LImageSize) div 2, LContent.Left + LImageSize, LContent.Top + (LContent.Height - LImageSize) div 2 + LImageSize);
        AContext.TextBounds := Rect(Min(LContent.Right, AContext.ImageBounds.Right + LSpacing), LContent.Top, LContent.Right, LContent.Bottom);
      end;
    end;
  end;
  if not NimbusRectIsEmpty(AContext.ImageBounds) then OffsetRect(AContext.ImageBounds, Scale(AContext, AContext.ImageOffset.X), Scale(AContext, AContext.ImageOffset.Y));
  if not NimbusRectIsEmpty(AContext.TextBounds) then OffsetRect(AContext.TextBounds, Scale(AContext, AContext.TextOffset.X), Scale(AContext, AContext.TextOffset.Y));
end;

class procedure TThemedToolButtonRenderer.CalculateLayout(const ACanvas: INimbusRenderCanvas; var AContext: TThemedToolButtonRenderContext);
var
  LSplitWidth, LLeft, LTop, LRight, LBottom: Integer;
begin
  AContext.MainBounds := AContext.Bounds;
  AContext.DropDownBounds := Rect(0, 0, 0, 0);
  LSplitWidth := Max(1, Scale(AContext, AContext.SplitButtonWidth));
  if AContext.DropDownMode = ttbddSplit then
  begin
    LSplitWidth := Min(LSplitWidth, Max(1, AContext.Bounds.Width div 2));
    if AContext.RightToLeft then
    begin
      AContext.DropDownBounds := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Left + LSplitWidth, AContext.Bounds.Bottom);
      AContext.MainBounds.Left := AContext.DropDownBounds.Right;
    end
    else
    begin
      AContext.DropDownBounds := Rect(AContext.Bounds.Right - LSplitWidth, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
      AContext.MainBounds.Right := AContext.DropDownBounds.Left;
    end;
  end
  else if AContext.DropDownMode = ttbddArrow then
    AContext.DropDownBounds := AContext.Bounds;
  LLeft := AContext.MainBounds.Left + Scale(AContext, AContext.PaddingLeft);
  LTop := AContext.MainBounds.Top + Scale(AContext, AContext.PaddingTop);
  LRight := AContext.MainBounds.Right - Scale(AContext, AContext.PaddingRight);
  LBottom := AContext.MainBounds.Bottom - Scale(AContext, AContext.PaddingBottom);
  if LRight < LLeft then LRight := LLeft;
  if LBottom < LTop then LBottom := LTop;
  AContext.ContentBounds := Rect(LLeft, LTop, LRight, LBottom);
  ResolveContentLayout(ACanvas, AContext);
end;

class function TThemedToolButtonRenderer.ResolveHotBorderColor(const AContext: TThemedToolButtonRenderContext): TThemeColor;
begin
  if AContext.HighlightStyle = ttbhsDelphiToolButton then Result := NimbusColorWithAlpha(NimbusFocusBorderColor(AContext.Palette), 180)
  else Result := NimbusControlBorderColor(AContext.Palette);
end;

class function TThemedToolButtonRenderer.ResolveCheckedFillColor(const AContext: TThemedToolButtonRenderContext; const ABaseFill: TThemeColor; const AHot: Boolean): TThemeColor;
var
  LBase, LSelected: TThemeColor;
begin
  LBase := ABaseFill;
  if ThemeColorAlpha(LBase) = 0 then LBase := NimbusPanelBackColor(AContext.Palette);
  if AContext.Palette <> nil then LSelected := AContext.Palette.SelectedBackColor else LSelected := NimbusPressedBackColor(AContext.Palette);
  if ThemeColorAlpha(LSelected) = 0 then LSelected := NimbusPressedBackColor(AContext.Palette);
  if AHot then Result := NimbusBlendColor(LBase, LSelected, 150) else Result := NimbusBlendColor(LBase, LSelected, 100);
end;

class procedure TThemedToolButtonRenderer.ResolveColors(const AContext: TThemedToolButtonRenderContext; out AFill, ABorder, AFore: TThemeColor);
var
  LHot: Boolean;
begin
  AFore := AContext.CurrentColor;
  if AFore = 0 then AFore := NimbusControlForeColor(AContext.Palette);
  AFill := ThemeColor(0, 0, 0, 0);
  ABorder := ThemeColor(0, 0, 0, 0);
  if not AContext.Enabled then
  begin
    AFore := NimbusDisabledForeColor(AContext.Palette);
    if AContext.ButtonStyle <> ttbsGhost then AFill := NimbusDisabledBackColor(AContext.Palette);
    if not (AContext.ButtonStyle in [ttbsFlat, ttbsGhost]) then ABorder := NimbusControlBorderColor(AContext.Palette);
    Exit;
  end;
  case AContext.ButtonStyle of
    ttbsFilled:
      begin
        if AContext.UseThemeAccent then
        begin
          AFill := NimbusAccentColor(AContext.Palette);
          if AContext.CurrentColor = 0 then AFore := NimbusSelectedForeColor(AContext.Palette);
        end
        else
          AFill := NimbusControlBackColor(AContext.Palette);
        ABorder := NimbusControlBorderColor(AContext.Palette);
      end;
    ttbsOutline: ABorder := NimbusControlBorderColor(AContext.Palette);
  end;
  if AContext.HighlightStyle = ttbhsNone then Exit;
  LHot := AContext.Hot or AContext.DropDownHot or (AContext.Focused and AContext.ShowFocusRectangle);
  if AContext.Pressed or ((AContext.DropDownMode = ttbddArrow) and AContext.DropDownPressed) then
  begin
    AFill := NimbusPressedBackColor(AContext.Palette);
    ABorder := ResolveHotBorderColor(AContext);
    AFore := NimbusSelectedForeColor(AContext.Palette);
  end
  else if AContext.Checked then
  begin
    AFill := ResolveCheckedFillColor(AContext, AFill, LHot);
    if LHot then
      ABorder := ResolveHotBorderColor(AContext)
    else if AContext.ButtonStyle in [ttbsFilled, ttbsOutline] then
      ABorder := NimbusControlBorderColor(AContext.Palette)
    else
      ABorder := NimbusColorWithAlpha(NimbusControlBorderColor(AContext.Palette), 150);
  end
  else if LHot then
  begin
    AFill := NimbusHoverBackColor(AContext.Palette);
    ABorder := ResolveHotBorderColor(AContext);
  end;
end;

class procedure TThemedToolButtonRenderer.DrawBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext);
var
  LFill, LBorder, LFore, LSeparator, LDropFill: TThemeColor;
  LRect: TRect;
  LRadius, LX: Integer;
begin
  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  ResolveColors(AContext, LFill, LBorder, LFore);
  LRadius := Max(0, Scale(AContext, AContext.CornerRadius));
  if ThemeColorAlpha(LFill) <> 0 then ACanvas.FillRoundedRectangle(LFill, AContext.Bounds, LRadius);
  if ThemeColorAlpha(LBorder) <> 0 then ACanvas.DrawRoundedRectangle(LBorder, AContext.Bounds, LRadius, 1.0);
  if (AContext.DropDownMode = ttbddSplit) and not NimbusRectIsEmpty(AContext.DropDownBounds) then
  begin
    if AContext.DropDownHot or AContext.DropDownPressed then
    begin
      if AContext.DropDownPressed then LDropFill := NimbusPressedBackColor(AContext.Palette) else LDropFill := NimbusHoverBackColor(AContext.Palette);
      LRect := AContext.DropDownBounds;
      InflateRect(LRect, -1, -1);
      if not NimbusRectIsEmpty(LRect) then ACanvas.FillRoundedRectangle(LDropFill, LRect, Max(0, LRadius - 1));
    end;
    if ThemeColorAlpha(LBorder) <> 0 then LSeparator := LBorder else LSeparator := NimbusColorWithAlpha(LFore, 70);
    if AContext.RightToLeft then LX := AContext.DropDownBounds.Right else LX := AContext.DropDownBounds.Left;
    ACanvas.DrawLine(LSeparator, LX, AContext.Bounds.Top + Scale(AContext, 3), LX, AContext.Bounds.Bottom - Scale(AContext, 4));
  end;
end;

class procedure TThemedToolButtonRenderer.DrawContent(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext);
var
  LFill, LBorder, LFore: TThemeColor;
  LImageRect, LTextRect: TRect;
  LOffset: Integer;
begin
  ResolveColors(AContext, LFill, LBorder, LFore);
  LOffset := 0;
  if AContext.Pressed and (AContext.DropDownMode <> ttbddArrow) then LOffset := Scale(AContext, 1);
  if (AContext.IconHandle <> 0) and not NimbusRectIsEmpty(AContext.ImageBounds) then
  begin
    LImageRect := AContext.ImageBounds;
    OffsetRect(LImageRect, LOffset, LOffset);
    ACanvas.DrawIcon(AContext.IconHandle, LImageRect);
  end;
  if (AContext.Caption <> '') and not NimbusRectIsEmpty(AContext.TextBounds) then
  begin
    LTextRect := AContext.TextBounds;
    OffsetRect(LTextRect, LOffset, LOffset);
    ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LTextRect, TextFlags(AContext));
  end;
end;

class procedure TThemedToolButtonRenderer.DrawDropDown(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext);
var
  LFill, LBorder, LFore: TThemeColor;
  LBounds: TRect;
  LSize, LCX, LCY: Integer;
  P1, P2, P3: TPoint;
begin
  if AContext.DropDownMode = ttbddNone then Exit;
  if AContext.DropDownMode = ttbddSplit then LBounds := AContext.DropDownBounds
  else if AContext.RightToLeft then LBounds := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Left + Scale(AContext, 18), AContext.Bounds.Bottom)
  else LBounds := Rect(AContext.Bounds.Right - Scale(AContext, 18), AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
  if NimbusRectIsEmpty(LBounds) then Exit;
  ResolveColors(AContext, LFill, LBorder, LFore);
  LSize := Max(3, Scale(AContext, 4));
  LCX := LBounds.Left + LBounds.Width div 2;
  LCY := LBounds.Top + LBounds.Height div 2 + Scale(AContext, 1);
  P1 := Point(LCX - LSize, LCY - Scale(AContext, 2));
  P2 := Point(LCX + LSize, LCY - Scale(AContext, 2));
  P3 := Point(LCX, LCY + LSize);
  ACanvas.FillTriangle(LFore, P1, P2, P3);
end;

class procedure TThemedToolButtonRenderer.DrawFocus(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolButtonRenderContext);
begin
end;

class procedure TThemedToolButtonRenderer.Render(const ACanvas: INimbusRenderCanvas; var AContext: TThemedToolButtonRenderContext);
begin
  CalculateLayout(ACanvas, AContext);
  DrawBackground(ACanvas, AContext);
  DrawContent(ACanvas, AContext);
  DrawDropDown(ACanvas, AContext);
  DrawFocus(ACanvas, AContext);
end;

end.

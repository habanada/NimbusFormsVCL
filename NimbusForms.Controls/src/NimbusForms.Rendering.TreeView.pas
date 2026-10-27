{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.TreeView;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedTreeItemMetrics = record
    Indent: Integer;
    LeftPadding: Integer;
    Spacing: Integer;
    ChevronSize: Integer;
    BadgeHeight: Integer;
    BadgePadding: Integer;
    RightPadding: Integer;
    CheckSize: Integer;
    StatusSize: Integer;
    ProgressHeight: Integer;
    SelectionRadius: Integer;
    DropIndicatorThickness: Integer;
    GlyphSize: Integer;
    ChevronStroke: Single;
  end;

  TThemedTreeItemLayout = record
    RowRect: TRect;
    SelectionRect: TRect;
    StatusRect: TRect;
    ChevronRect: TRect;
    CheckRect: TRect;
    ImageRect: TRect;
    TextRect: TRect;
    TitleRect: TRect;
    SubtitleRect: TRect;
    RightImageRect: TRect;
    FavoriteRect: TRect;
    BadgeRect: TRect;
    ProgressRect: TRect;
  end;

  TThemedTreeItemRenderContext = record
    Bounds: TRect;
    ClientWidth: Integer;
    Level: Integer;
    Text: string;
    Subtitle: string;
    BadgeText: string;
    FilterText: string;
    Font: TFont;
    GlyphFont: TFont;
    RightGlyphFont: TFont;
    GlyphText: string;
    RightGlyphText: string;
    Image: Vcl.Graphics.TBitmap;
    RightImage: Vcl.Graphics.TBitmap;
    Palette: TThemePalette;
    BackColor: TColor;
    ForeColor: TColor;
    BadgeColor: TColor;
    StatusColor: TColor;
    GlyphColor: TColor;
    RightGlyphColor: TColor;
    Metrics: TThemedTreeItemMetrics;
    CheckState: Integer;
    ProgressValue: Integer;
    Selected: Boolean;
    Hovered: Boolean;
    Disabled: Boolean;
    Separator: Boolean;
    Expanded: Boolean;
    HasChildren: Boolean;
    ShowCheckBox: Boolean;
    ShowSubtitle: Boolean;
    ShowStatus: Boolean;
    ShowFavorite: Boolean;
    ShowProgress: Boolean;
    RoundedSelection: Boolean;
    HighlightFilterMatches: Boolean;
    UseThemeGlyphColor: Boolean;
    UseThemeRightGlyphColor: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedTreeViewRenderer = class
  private
    class function ResolveBackColor(const AContext: TThemedTreeItemRenderContext): TThemeColor; static;
    class function ResolveForeColor(const AContext: TThemedTreeItemRenderContext): TThemeColor; static;
    class function ResolveMutedColor(const AContext: TThemedTreeItemRenderContext): TThemeColor; static;
    class function ResolveAccentColor(const AContext: TThemedTreeItemRenderContext): TThemeColor; static;
    class function ResolveDisabledColor(const AContext: TThemedTreeItemRenderContext): TThemeColor; static;
    class procedure DrawChevron(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: TThemeColor; const AExpanded: Boolean; const AStroke: Single); static;
    class procedure DrawCheckBox(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AContext: TThemedTreeItemRenderContext); static;
    class procedure DrawStar(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: TThemeColor); static;
    class procedure DrawFilteredText(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTreeItemRenderContext; const ARect: TRect; const AColor: TThemeColor); static;
  public
    class function CalculateLayout(const AContext: TThemedTreeItemRenderContext; const ABadgeWidth: Integer): TThemedTreeItemLayout; static;
    class procedure RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTreeItemRenderContext; out ALayout: TThemedTreeItemLayout); static;
    class procedure RenderDropIndicator(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTreeItemRenderContext; const ARowRect: TRect; const APosition: Integer); static;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  System.UITypes,
  NimbusForms.Rendering.Types;

class function TThemedTreeViewRenderer.ResolveBackColor(const AContext: TThemedTreeItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.MenuBackColor else Result := ColorToThemeColor(AContext.BackColor);
end;

class function TThemedTreeViewRenderer.ResolveForeColor(const AContext: TThemedTreeItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.MenuForeColor else Result := ColorToThemeColor(AContext.ForeColor);
end;

class function TThemedTreeViewRenderer.ResolveMutedColor(const AContext: TThemedTreeItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.MutedForeColor else Result := ColorToThemeColor(clGrayText);
end;

class function TThemedTreeViewRenderer.ResolveAccentColor(const AContext: TThemedTreeItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.AccentColor else Result := ColorToThemeColor(clHighlight);
end;

class function TThemedTreeViewRenderer.ResolveDisabledColor(const AContext: TThemedTreeItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.DisabledForeColor else Result := ColorToThemeColor(clGrayText);
end;

class function TThemedTreeViewRenderer.CalculateLayout(const AContext: TThemedTreeItemRenderContext; const ABadgeWidth: Integer): TThemedTreeItemLayout;
var
  LCurrentX, LRightX, LImageWidth, LImageHeight, LRightWidth, LRightHeight: Integer;
begin
  Result := Default(TThemedTreeItemLayout);
  Result.RowRect := Rect(0, AContext.Bounds.Top, AContext.ClientWidth, AContext.Bounds.Bottom);
  Result.SelectionRect := Rect(AContext.Metrics.LeftPadding div 2, Result.RowRect.Top + 2, Max(AContext.Metrics.LeftPadding div 2 + 1, AContext.ClientWidth - AContext.Metrics.LeftPadding div 2), Result.RowRect.Bottom - 2);
  LCurrentX := AContext.Metrics.LeftPadding + AContext.Level * AContext.Metrics.Indent;
  if AContext.ShowStatus and (AContext.StatusColor <> clNone) then
  begin
    Result.StatusRect := Rect(LCurrentX, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.StatusSize) div 2, LCurrentX + AContext.Metrics.StatusSize, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.StatusSize) div 2);
    LCurrentX := Result.StatusRect.Right + AContext.Metrics.Spacing;
  end;
  Result.ChevronRect := Rect(LCurrentX, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.ChevronSize) div 2, LCurrentX + AContext.Metrics.ChevronSize, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.ChevronSize) div 2);
  LCurrentX := Result.ChevronRect.Right + AContext.Metrics.Spacing;
  if AContext.ShowCheckBox then
  begin
    Result.CheckRect := Rect(LCurrentX, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.CheckSize) div 2, LCurrentX + AContext.Metrics.CheckSize, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.CheckSize) div 2);
    LCurrentX := Result.CheckRect.Right + AContext.Metrics.Spacing;
  end;
  LImageWidth := 0;
  LImageHeight := 0;
  if AContext.GlyphText <> '' then
  begin
    LImageWidth := AContext.Metrics.GlyphSize;
    LImageHeight := AContext.Metrics.GlyphSize;
  end
  else if (AContext.Image <> nil) and not AContext.Image.Empty then
  begin
    LImageWidth := AContext.Image.Width;
    LImageHeight := AContext.Image.Height;
  end;
  if LImageWidth > 0 then
  begin
    Result.ImageRect := Rect(LCurrentX, AContext.Bounds.Top + (AContext.Bounds.Height - LImageHeight) div 2, LCurrentX + LImageWidth, AContext.Bounds.Top + (AContext.Bounds.Height - LImageHeight) div 2 + LImageHeight);
    LCurrentX := Result.ImageRect.Right + AContext.Metrics.Spacing;
  end;
  LRightX := AContext.ClientWidth - AContext.Metrics.RightPadding;
  LRightWidth := 0;
  LRightHeight := 0;
  if AContext.RightGlyphText <> '' then
  begin
    LRightWidth := AContext.Metrics.GlyphSize;
    LRightHeight := AContext.Metrics.GlyphSize;
  end
  else if (AContext.RightImage <> nil) and not AContext.RightImage.Empty then
  begin
    LRightWidth := AContext.RightImage.Width;
    LRightHeight := AContext.RightImage.Height;
  end;
  if LRightWidth > 0 then
  begin
    Dec(LRightX, LRightWidth);
    Result.RightImageRect := Rect(LRightX, AContext.Bounds.Top + (AContext.Bounds.Height - LRightHeight) div 2, LRightX + LRightWidth, AContext.Bounds.Top + (AContext.Bounds.Height - LRightHeight) div 2 + LRightHeight);
    Dec(LRightX, AContext.Metrics.Spacing);
  end;
  if AContext.ShowFavorite then
  begin
    Result.FavoriteRect := Rect(LRightX - AContext.Metrics.ChevronSize, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.ChevronSize) div 2, LRightX, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.ChevronSize) div 2);
    LRightX := Result.FavoriteRect.Left - AContext.Metrics.Spacing;
  end;
  if (AContext.BadgeText <> '') and (ABadgeWidth > 0) then
  begin
    Result.BadgeRect := Rect(LRightX - ABadgeWidth, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.BadgeHeight) div 2, LRightX, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.BadgeHeight) div 2);
    LRightX := Result.BadgeRect.Left - AContext.Metrics.Spacing;
  end;
  Result.TextRect := Rect(LCurrentX, AContext.Bounds.Top, Max(LCurrentX + 1, LRightX - AContext.Metrics.Spacing), AContext.Bounds.Bottom);
  if AContext.ShowSubtitle and (AContext.Subtitle <> '') then
  begin
    Result.TitleRect := Rect(Result.TextRect.Left, Result.TextRect.Top + 3, Result.TextRect.Right, Result.TextRect.Top + Max(1, Result.TextRect.Height div 2 + 1));
    Result.SubtitleRect := Rect(Result.TextRect.Left, Result.TextRect.Top + Result.TextRect.Height div 2, Result.TextRect.Right, Result.TextRect.Bottom - 2);
  end
  else
    Result.TitleRect := Result.TextRect;
  if AContext.ShowProgress then
    Result.ProgressRect := Rect(AContext.Metrics.LeftPadding, AContext.Bounds.Bottom - AContext.Metrics.ProgressHeight - 2, Max(AContext.Metrics.LeftPadding + 1, AContext.ClientWidth - AContext.Metrics.LeftPadding), AContext.Bounds.Bottom - 2);
end;

class procedure TThemedTreeViewRenderer.DrawChevron(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: TThemeColor; const AExpanded: Boolean; const AStroke: Single);
var
  CX, CY, Q, E: Integer;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  CX := (ARect.Left + ARect.Right) div 2;
  CY := (ARect.Top + ARect.Bottom) div 2;
  Q := Max(2, ARect.Width div 4);
  E := Max(1, ARect.Width div 8);
  if AExpanded then
  begin
    ACanvas.DrawLine(AColor, CX - Q, CY - E, CX, CY + E, AStroke);
    ACanvas.DrawLine(AColor, CX, CY + E, CX + Q, CY - E, AStroke);
  end
  else
  begin
    ACanvas.DrawLine(AColor, CX - E, CY - Q, CX + E, CY, AStroke);
    ACanvas.DrawLine(AColor, CX + E, CY, CX - E, CY + Q, AStroke);
  end;
end;

class procedure TThemedTreeViewRenderer.DrawCheckBox(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AContext: TThemedTreeItemRenderContext);
var
  LBorder, LBack, LAccent, LMark: TThemeColor;
  CX, CY: Integer;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  if AContext.Palette <> nil then
  begin
    LBorder := AContext.Palette.ControlBorderColor;
    LBack := AContext.Palette.InputBackColor;
    LAccent := AContext.Palette.AccentColor;
    LMark := AContext.Palette.SelectedForeColor;
    if AContext.Disabled then
    begin
      LBack := AContext.Palette.DisabledBackColor;
      LBorder := AContext.Palette.DisabledForeColor;
      LAccent := LBorder;
    end;
  end
  else
  begin
    LBorder := ColorToThemeColor(clBtnShadow);
    LBack := ColorToThemeColor(clWindow);
    LAccent := ColorToThemeColor(clHighlight);
    LMark := ColorToThemeColor(clHighlightText);
    if AContext.Disabled then
    begin
      LBack := ColorToThemeColor(clBtnFace);
      LBorder := ColorToThemeColor(clGrayText);
      LAccent := LBorder;
    end;
  end;
  if AContext.CheckState = 0 then ACanvas.FillRectangle(LBack, ARect) else ACanvas.FillRectangle(LAccent, ARect);
  ACanvas.DrawRectangle(LBorder, ARect, 1.0);
  CX := (ARect.Left + ARect.Right) div 2;
  CY := (ARect.Top + ARect.Bottom) div 2;
  if AContext.CheckState = 1 then
  begin
    ACanvas.DrawLine(LMark, ARect.Left + Max(3, ARect.Width div 4), CY, CX - 1, ARect.Bottom - Max(3, ARect.Height div 4), 2.0);
    ACanvas.DrawLine(LMark, CX - 1, ARect.Bottom - Max(3, ARect.Height div 4), ARect.Right - Max(3, ARect.Width div 4), ARect.Top + Max(3, ARect.Height div 4), 2.0);
  end
  else if AContext.CheckState = 2 then
    ACanvas.FillRectangle(LMark, Rect(ARect.Left + 4, CY - 1, ARect.Right - 4, CY + 2));
end;

class procedure TThemedTreeViewRenderer.DrawStar(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: TThemeColor);
var
  LPoints: TNimbusPointBuffer;
  I, CX, CY: Integer;
  LAngle, LStep, LRadius, LOuter, LInner: Double;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  CX := (ARect.Left + ARect.Right) div 2;
  CY := (ARect.Top + ARect.Bottom) div 2;
  LOuter := Min(ARect.Width, ARect.Height) / 2.0;
  LInner := LOuter * 0.45;
  LAngle := -Pi / 2;
  LStep := Pi / 5;
  for I := 0 to 9 do
  begin
    if Odd(I) then LRadius := LInner else LRadius := LOuter;
    LPoints[I] := Point(Round(CX + Cos(LAngle) * LRadius), Round(CY + Sin(LAngle) * LRadius));
    LAngle := LAngle + LStep;
  end;
  ACanvas.FillPolygon(AColor, @LPoints, 10);
end;

class procedure TThemedTreeViewRenderer.DrawFilteredText(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTreeItemRenderContext; const ARect: TRect; const AColor: TThemeColor);
var
  LIndex: Integer;
  LBefore, LMatch, LAfter: string;
  LBeforeSize, LMatchSize: TSize;
  LRect, LMatchRect: TRect;
  LAccent, LHighlight: TThemeColor;
  LFlags: TNimbusTextFlags;
begin
  if AContext.Text = '' then Exit;
  LFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if AContext.RightToLeft then
  begin
    Include(LFlags, ntfRightToLeft);
    Include(LFlags, ntfRight);
  end;
  if (not AContext.HighlightFilterMatches) or (AContext.FilterText = '') or AContext.RightToLeft then
  begin
    ACanvas.DrawText(AContext.Text, AContext.Font, AColor, ARect, LFlags);
    Exit;
  end;
  LIndex := Pos(LowerCase(AContext.FilterText), LowerCase(AContext.Text));
  if LIndex <= 0 then
  begin
    ACanvas.DrawText(AContext.Text, AContext.Font, AColor, ARect, LFlags);
    Exit;
  end;
  LBefore := Copy(AContext.Text, 1, LIndex - 1);
  LMatch := Copy(AContext.Text, LIndex, Length(AContext.FilterText));
  LAfter := Copy(AContext.Text, LIndex + Length(AContext.FilterText), MaxInt);
  LBeforeSize := ACanvas.MeasureText(LBefore, AContext.Font, MaxInt div 4, [ntfSingleLine, ntfNoPrefix]);
  LMatchSize := ACanvas.MeasureText(LMatch, AContext.Font, MaxInt div 4, [ntfSingleLine, ntfNoPrefix]);
  LRect := ARect;
  LRect.Right := Min(ARect.Right, LRect.Left + LBeforeSize.cx);
  if LBefore <> '' then ACanvas.DrawText(LBefore, AContext.Font, AColor, LRect, [ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  LMatchRect := Rect(LRect.Right, ARect.Top + Max(0, (ARect.Height - LMatchSize.cy) div 2), Min(ARect.Right, LRect.Right + LMatchSize.cx), ARect.Top + Max(0, (ARect.Height - LMatchSize.cy) div 2) + LMatchSize.cy);
  LAccent := ResolveAccentColor(AContext);
  LHighlight := ThemeColor(90, ThemeColorRed(LAccent), ThemeColorGreen(LAccent), ThemeColorBlue(LAccent));
  if not NimbusRectIsEmpty(LMatchRect) then ACanvas.FillRectangle(LHighlight, LMatchRect);
  LRect := Rect(LMatchRect.Left, ARect.Top, LMatchRect.Right, ARect.Bottom);
  if LMatch <> '' then ACanvas.DrawText(LMatch, AContext.Font, AColor, LRect, [ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  LRect := Rect(LMatchRect.Right, ARect.Top, ARect.Right, ARect.Bottom);
  if LAfter <> '' then ACanvas.DrawText(LAfter, AContext.Font, AColor, LRect, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
end;


class procedure TThemedTreeViewRenderer.RenderDropIndicator(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTreeItemRenderContext; const ARowRect: TRect; const APosition: Integer);
var
  LAccent: TThemeColor;
  LRect: TRect;
  LY, LThickness, LDot: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ARowRect) or (APosition <= 0) then Exit;
  LAccent := ResolveAccentColor(AContext);
  LThickness := Max(1, AContext.Metrics.DropIndicatorThickness);
  if APosition = 3 then
  begin
    LRect := Rect(AContext.Metrics.LeftPadding div 2, ARowRect.Top + 2, Max(AContext.Metrics.LeftPadding div 2 + 1, AContext.ClientWidth - AContext.Metrics.LeftPadding div 2), ARowRect.Bottom - 2);
    if AContext.RoundedSelection then ACanvas.DrawRoundedRectangle(LAccent, LRect, AContext.Metrics.SelectionRadius, LThickness) else ACanvas.DrawRectangle(LAccent, LRect, LThickness);
    Exit;
  end;
  if APosition = 1 then LY := ARowRect.Top else LY := ARowRect.Bottom - LThickness;
  LRect := Rect(AContext.Metrics.LeftPadding, LY, Max(AContext.Metrics.LeftPadding + 1, AContext.ClientWidth - AContext.Metrics.RightPadding), LY + LThickness);
  ACanvas.FillRectangle(LAccent, LRect);
  LDot := Max(5, LThickness * 3);
  ACanvas.FillEllipse(LAccent, Rect(AContext.Metrics.LeftPadding - LDot div 2, LY - (LDot - LThickness) div 2, AContext.Metrics.LeftPadding - LDot div 2 + LDot, LY - (LDot - LThickness) div 2 + LDot));
end;

class procedure TThemedTreeViewRenderer.RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTreeItemRenderContext; out ALayout: TThemedTreeItemLayout);
var
  LBack, LFore, LMuted, LDisabled, LAccent, LSelection, LHover, LBadge, LBadgeFore, LGlyph, LRightGlyph, LProgressBack: TThemeColor;
  LBadgeSize: TSize;
  LBadgeWidth, LValue, LFillWidth: Integer;
  LFlags: TNimbusTextFlags;
begin
  ALayout := Default(TThemedTreeItemLayout);
  if (ACanvas = nil) or (AContext.ClientWidth <= 0) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  LBack := ResolveBackColor(AContext);
  LFore := ResolveForeColor(AContext);
  LMuted := ResolveMutedColor(AContext);
  LDisabled := ResolveDisabledColor(AContext);
  LAccent := ResolveAccentColor(AContext);
  if AContext.Palette <> nil then
  begin
    LSelection := AContext.Palette.MenuSelectedBackColor;
    LHover := AContext.Palette.HoverBackColor;
    LBadgeFore := AContext.Palette.SelectedForeColor;
    LProgressBack := AContext.Palette.ControlBorderColor;
  end
  else
  begin
    LSelection := ColorToThemeColor(clHighlight);
    LHover := ColorToThemeColor(clBtnFace);
    LBadgeFore := ColorToThemeColor(clHighlightText);
    LProgressBack := ColorToThemeColor(clBtnShadow);
  end;
  LBadgeWidth := 0;
  if AContext.BadgeText <> '' then
  begin
    LBadgeSize := ACanvas.MeasureText(AContext.BadgeText, AContext.Font, MaxInt div 4, [ntfSingleLine, ntfNoPrefix]);
    LBadgeWidth := LBadgeSize.cx + AContext.Metrics.BadgePadding;
  end;
  ALayout := CalculateLayout(AContext, LBadgeWidth);
  ACanvas.FillRectangle(LBack, ALayout.RowRect);
  if AContext.Separator then
  begin
    ACanvas.DrawLine(LMuted, AContext.Metrics.LeftPadding, (ALayout.RowRect.Top + ALayout.RowRect.Bottom) div 2, AContext.ClientWidth - AContext.Metrics.RightPadding, (ALayout.RowRect.Top + ALayout.RowRect.Bottom) div 2, 1.0);
    Exit;
  end;
  if AContext.Selected then
  begin
    if AContext.RoundedSelection then ACanvas.FillRoundedRectangle(LSelection, ALayout.SelectionRect, AContext.Metrics.SelectionRadius) else ACanvas.FillRectangle(LSelection, ALayout.RowRect);
    if AContext.Palette <> nil then LFore := AContext.Palette.SelectedForeColor else LFore := ColorToThemeColor(clHighlightText);
  end
  else if AContext.Hovered and not AContext.Disabled then
  begin
    if AContext.RoundedSelection then ACanvas.FillRoundedRectangle(LHover, ALayout.SelectionRect, AContext.Metrics.SelectionRadius) else ACanvas.FillRectangle(LHover, ALayout.RowRect);
  end;
  if AContext.Disabled then LFore := LDisabled;
  if not NimbusRectIsEmpty(ALayout.StatusRect) then ACanvas.FillEllipse(ColorToThemeColor(AContext.StatusColor), ALayout.StatusRect);
  if AContext.HasChildren then DrawChevron(ACanvas, ALayout.ChevronRect, LMuted, AContext.Expanded, AContext.Metrics.ChevronStroke);
  if AContext.ShowCheckBox then DrawCheckBox(ACanvas, ALayout.CheckRect, AContext);
  if not NimbusRectIsEmpty(ALayout.ImageRect) then
  begin
    if AContext.GlyphText <> '' then
    begin
      if AContext.UseThemeGlyphColor or (AContext.GlyphColor = clNone) then LGlyph := LFore else LGlyph := ColorToThemeColor(AContext.GlyphColor);
      ACanvas.DrawText(AContext.GlyphText, AContext.GlyphFont, LGlyph, ALayout.ImageRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end
    else if (AContext.Image <> nil) and not AContext.Image.Empty then
      ACanvas.DrawBitmap(AContext.Image, ALayout.ImageRect);
  end;
  if not NimbusRectIsEmpty(ALayout.RightImageRect) then
  begin
    if AContext.RightGlyphText <> '' then
    begin
      if AContext.UseThemeRightGlyphColor or (AContext.RightGlyphColor = clNone) then LRightGlyph := LFore else LRightGlyph := ColorToThemeColor(AContext.RightGlyphColor);
      ACanvas.DrawText(AContext.RightGlyphText, AContext.RightGlyphFont, LRightGlyph, ALayout.RightImageRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end
    else if (AContext.RightImage <> nil) and not AContext.RightImage.Empty then
      ACanvas.DrawBitmap(AContext.RightImage, ALayout.RightImageRect);
  end;
  if not NimbusRectIsEmpty(ALayout.FavoriteRect) then DrawStar(ACanvas, ALayout.FavoriteRect, LAccent);
  if not NimbusRectIsEmpty(ALayout.BadgeRect) then
  begin
    if AContext.BadgeColor = clNone then LBadge := LAccent else LBadge := ColorToThemeColor(AContext.BadgeColor);
    ACanvas.FillRoundedRectangle(LBadge, ALayout.BadgeRect, ALayout.BadgeRect.Height div 2);
    ACanvas.DrawText(AContext.BadgeText, AContext.Font, LBadgeFore, ALayout.BadgeRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  end;
  DrawFilteredText(ACanvas, AContext, ALayout.TitleRect, LFore);
  if AContext.ShowSubtitle and (AContext.Subtitle <> '') and not NimbusRectIsEmpty(ALayout.SubtitleRect) then
  begin
    LFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
    if AContext.RightToLeft then
    begin
      Include(LFlags, ntfRightToLeft);
      Include(LFlags, ntfRight);
    end;
    if AContext.Disabled then ACanvas.DrawText(AContext.Subtitle, AContext.Font, LDisabled, ALayout.SubtitleRect, LFlags) else ACanvas.DrawText(AContext.Subtitle, AContext.Font, LMuted, ALayout.SubtitleRect, LFlags);
  end;
  if AContext.ShowProgress and not NimbusRectIsEmpty(ALayout.ProgressRect) then
  begin
    ACanvas.FillRectangle(LProgressBack, ALayout.ProgressRect);
    LValue := EnsureRange(AContext.ProgressValue, 0, 100);
    LFillWidth := MulDiv(ALayout.ProgressRect.Width, LValue, 100);
    if LFillWidth > 0 then ACanvas.FillRectangle(LAccent, Rect(ALayout.ProgressRect.Left, ALayout.ProgressRect.Top, ALayout.ProgressRect.Left + LFillWidth, ALayout.ProgressRect.Bottom));
  end;
end;

end.

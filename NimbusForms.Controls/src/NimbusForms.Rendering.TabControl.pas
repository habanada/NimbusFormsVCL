{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.TabControl;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedTabRenderItem = record
    Index: Integer;
    TabRect: TRect;
    CloseRect: TRect;
    ImageIcon: HICON;
    Selected: Boolean;
    Hovered: Boolean;
    Pinned: Boolean;
    ReserveCloseButtonSpace: Boolean;
    ShowCloseButton: Boolean;
    CloseHovered: Boolean;
    ClosePressed: Boolean;
    Text: string;
    BadgeText: string;
    TextFlags: TNimbusTextFlags;
  end;

  TThemedTabRenderItems = array of TThemedTabRenderItem;

  TThemedTabRenderContext = record
    Bounds: TRect;
    PageBounds: TRect;
    BorderBounds: TRect;
    Font: TFont;
    Items: TThemedTabRenderItems;
    HeaderBottom: Integer;
    BorderThickness: Integer;
    TextPaddingLeft: Integer;
    TextPaddingTop: Integer;
    TextPaddingHorizontal: Integer;
    TextPaddingVertical: Integer;
    CloseButtonAreaWidth: Integer;
    IconSize: Integer;
    BadgeHorizontalPadding: Integer;
    BadgeHeight: Integer;
    ActiveIndicatorHeight: Integer;
    ImageSpacing: Integer;
    ShowActiveIndicator: Boolean;
    DpiScale: Single;
    PanelBackColor: TThemeColor;
    TabBackColor: TThemeColor;
    TabForeColor: TThemeColor;
    ActiveTabBackColor: TThemeColor;
    ActiveTabForeColor: TThemeColor;
    BorderColor: TThemeColor;
    HoverBackColor: TThemeColor;
    PressedBackColor: TThemeColor;
    AccentColor: TThemeColor;
    MutedForeColor: TThemeColor;
  end;

  TThemedTabRenderer = class
  protected
    procedure FillTopRoundedTab(const ACanvas: INimbusRenderCanvas; const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer); virtual;
    procedure DrawTopRoundedTab(const ACanvas: INimbusRenderCanvas; const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer; const AWidth: Single); virtual;
    procedure DrawTab(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem); virtual;
    procedure DrawImage(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; var AContentRect: TRect); virtual;
    procedure DrawBadge(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; var AContentRect: TRect); virtual;
    procedure DrawPinnedGlyph(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; var AContentRect: TRect); virtual;
    procedure DrawText(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; const AContentRect: TRect; const AForeColor: TThemeColor); virtual;
    procedure DrawCloseButton(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; const AForeColor: TThemeColor); virtual;
  public
    procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext); virtual;
  end;

implementation

uses
  System.Math;

procedure TThemedTabRenderer.FillTopRoundedTab(const ACanvas: INimbusRenderCanvas; const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
var
  LRadius: Integer;
  LBottomRect: TRect;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  LRadius := EnsureRange(ARadius, 0, Min(ARect.Width div 2, ARect.Height div 2));
  if LRadius = 0 then
  begin
    ACanvas.FillRectangle(AColor, ARect);
    Exit;
  end;
  ACanvas.FillRoundedRectangle(AColor, ARect, LRadius);
  LBottomRect := Rect(ARect.Left, ARect.Top + LRadius, ARect.Right, ARect.Bottom);
  ACanvas.FillRectangle(AColor, LBottomRect);
end;

procedure TThemedTabRenderer.DrawTopRoundedTab(const ACanvas: INimbusRenderCanvas; const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer; const AWidth: Single);
var
  LRadius, LDiameter, LRight, LBottom: Integer;
  LArcRect: TRect;
begin
  if NimbusRectIsEmpty(ARect) or (AWidth <= 0) then Exit;
  LRadius := EnsureRange(ARadius, 0, Min(ARect.Width div 2, ARect.Height div 2));
  if (LRadius = 0) or (ARect.Width <= (LRadius * 2) + 4) or (ARect.Height <= (LRadius * 2) + 4) then
  begin
    ACanvas.DrawRectangle(AColor, ARect, AWidth);
    Exit;
  end;
  LDiameter := LRadius * 2;
  LRight := ARect.Right - 1;
  LBottom := ARect.Bottom - 1;
  ACanvas.DrawLine(AColor, ARect.Left, LBottom, ARect.Left, ARect.Top + LRadius, AWidth);
  LArcRect := Rect(ARect.Left, ARect.Top, ARect.Left + LDiameter + 1, ARect.Top + LDiameter + 1);
  ACanvas.DrawArc(AColor, LArcRect, 180, 90, AWidth);
  ACanvas.DrawLine(AColor, ARect.Left + LRadius, ARect.Top, LRight - LRadius, ARect.Top, AWidth);
  LArcRect := Rect(LRight - LDiameter, ARect.Top, LRight + 1, ARect.Top + LDiameter + 1);
  ACanvas.DrawArc(AColor, LArcRect, 270, 90, AWidth);
  ACanvas.DrawLine(AColor, LRight, ARect.Top + LRadius, LRight, LBottom, AWidth);
  ACanvas.DrawLine(AColor, LRight, LBottom, ARect.Left, LBottom, AWidth);
end;

procedure TThemedTabRenderer.DrawImage(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; var AContentRect: TRect);
var
  LImageRect: TRect;
begin
  if (AItem.ImageIcon = 0) or NimbusRectIsEmpty(AContentRect) then Exit;
  LImageRect := Rect(AContentRect.Left, AContentRect.Top + (AContentRect.Height - AContext.IconSize) div 2, AContentRect.Left + AContext.IconSize, AContentRect.Top + (AContentRect.Height - AContext.IconSize) div 2 + AContext.IconSize);
  ACanvas.DrawIcon(AItem.ImageIcon, LImageRect);
  Inc(AContentRect.Left, AContext.IconSize + AContext.ImageSpacing);
end;

procedure TThemedTabRenderer.DrawBadge(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; var AContentRect: TRect);
var
  LSize: TSize;
  LBadgeWidth: Integer;
  LBadgeRect: TRect;
  LFlags: TNimbusTextFlags;
begin
  if (AItem.BadgeText = '') or NimbusRectIsEmpty(AContentRect) then Exit;
  LFlags := [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix];
  LSize := ACanvas.MeasureText(AItem.BadgeText, AContext.Font, 0, [ntfSingleLine, ntfNoPrefix]);
  LBadgeWidth := LSize.cx + (AContext.BadgeHorizontalPadding * 2);
  LBadgeRect := Rect(AContentRect.Right - LBadgeWidth, AContentRect.Top + (AContentRect.Height - AContext.BadgeHeight) div 2, AContentRect.Right, AContentRect.Top + (AContentRect.Height - AContext.BadgeHeight) div 2 + AContext.BadgeHeight);
  if (LBadgeRect.Width <= 0) or (LBadgeRect.Left <= AContentRect.Left) then Exit;
  Dec(AContentRect.Right, LBadgeWidth + AContext.ImageSpacing);
  ACanvas.FillRectangle(AContext.AccentColor, LBadgeRect);
  ACanvas.DrawText(AItem.BadgeText, AContext.Font, AContext.ActiveTabForeColor, LBadgeRect, LFlags);
end;

procedure TThemedTabRenderer.DrawPinnedGlyph(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; var AContentRect: TRect);
var
  LPinRect, LDotRect: TRect;
  LDotSize: Integer;
begin
  if not AItem.Pinned or NimbusRectIsEmpty(AContentRect) then Exit;
  LPinRect := Rect(AContentRect.Left, AContentRect.Top + (AContentRect.Height - AContext.IconSize) div 2, AContentRect.Left + AContext.IconSize, AContentRect.Top + (AContentRect.Height - AContext.IconSize) div 2 + AContext.IconSize);
  LDotSize := Max(4, AContext.IconSize div 3);
  LDotRect := Rect(LPinRect.Left + (LPinRect.Width - LDotSize) div 2, LPinRect.Top + (LPinRect.Height - LDotSize) div 2, LPinRect.Left + (LPinRect.Width - LDotSize) div 2 + LDotSize, LPinRect.Top + (LPinRect.Height - LDotSize) div 2 + LDotSize);
  ACanvas.FillEllipse(AContext.AccentColor, LDotRect);
  Inc(AContentRect.Left, AContext.IconSize);
end;

procedure TThemedTabRenderer.DrawText(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; const AContentRect: TRect; const AForeColor: TThemeColor);
begin
  if NimbusRectIsEmpty(AContentRect) then Exit;
  ACanvas.DrawText(AItem.Text, AContext.Font, AForeColor, AContentRect, AItem.TextFlags);
end;

procedure TThemedTabRenderer.DrawCloseButton(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem; const AForeColor: TThemeColor);
var
  LCircleRect: TRect;
  LCenterX, LCenterY, LOffset: Integer;
  LCloseColor, LBackColor: TThemeColor;
  LLineWidth: Single;
begin
  if not AItem.ShowCloseButton or NimbusRectIsEmpty(AItem.CloseRect) then Exit;
  LCircleRect := Rect(AItem.CloseRect.Left + 1, AItem.CloseRect.Top + 1, AItem.CloseRect.Right - 1, AItem.CloseRect.Bottom - 1);
  if AItem.CloseHovered or AItem.ClosePressed then
  begin
    if AItem.ClosePressed then LBackColor := AContext.PressedBackColor else LBackColor := AContext.HoverBackColor;
    ACanvas.FillEllipse(LBackColor, LCircleRect);
  end;
  LCenterX := AItem.CloseRect.Left + AItem.CloseRect.Width div 2;
  LCenterY := AItem.CloseRect.Top + AItem.CloseRect.Height div 2;
  LOffset := Max(3, AItem.CloseRect.Width div 4);
  if AItem.CloseHovered then LCloseColor := AForeColor else LCloseColor := AContext.MutedForeColor;
  LLineWidth := Max(1.0, 1.25 * AContext.DpiScale);
  ACanvas.DrawLine(LCloseColor, LCenterX - LOffset, LCenterY - LOffset, LCenterX + LOffset, LCenterY + LOffset, LLineWidth);
  ACanvas.DrawLine(LCloseColor, LCenterX + LOffset, LCenterY - LOffset, LCenterX - LOffset, LCenterY + LOffset, LLineWidth);
end;

procedure TThemedTabRenderer.DrawTab(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext; const AItem: TThemedTabRenderItem);
var
  LBackColor, LForeColor, LBorderColor: TThemeColor;
  LDrawRect, LContentRect, LIndicatorRect: TRect;
  LRadius: Integer;
begin
  if NimbusRectIsEmpty(AItem.TabRect) then Exit;
  if AItem.Selected then
  begin
    LBackColor := AContext.ActiveTabBackColor;
    LForeColor := AContext.ActiveTabForeColor;
  end
  else
  begin
    LBackColor := AContext.TabBackColor;
    LForeColor := AContext.TabForeColor;
    if AItem.Hovered then LBackColor := AContext.HoverBackColor;
  end;
  LBorderColor := AContext.BorderColor;
  LDrawRect := AItem.TabRect;
  Dec(LDrawRect.Right);
  if NimbusRectIsEmpty(LDrawRect) then Exit;
  if AItem.Selected then LRadius := Min(5, Max(2, LDrawRect.Height div 5)) else LRadius := Min(3, Max(1, LDrawRect.Height div 8));
  FillTopRoundedTab(ACanvas, LBackColor, LDrawRect, LRadius);
  DrawTopRoundedTab(ACanvas, LBorderColor, LDrawRect, LRadius, AContext.BorderThickness);
  if AItem.Selected then
  begin
    ACanvas.DrawLine(AContext.PanelBackColor, LDrawRect.Left + 2, LDrawRect.Bottom - 1, LDrawRect.Right - 3, LDrawRect.Bottom - 1, AContext.BorderThickness + 1);
    if AContext.ShowActiveIndicator then
    begin
      LIndicatorRect := Rect(LDrawRect.Left + 2, LDrawRect.Top, LDrawRect.Right - 1, LDrawRect.Top + AContext.ActiveIndicatorHeight);
      if not NimbusRectIsEmpty(LIndicatorRect) then ACanvas.FillRectangle(AContext.AccentColor, LIndicatorRect);
    end;
  end;
  LContentRect := Rect(AItem.TabRect.Left + AContext.TextPaddingLeft, AItem.TabRect.Top + AContext.TextPaddingTop, AItem.TabRect.Right - (AContext.TextPaddingHorizontal - AContext.TextPaddingLeft), AItem.TabRect.Bottom - (AContext.TextPaddingVertical - AContext.TextPaddingTop));
  if AItem.ReserveCloseButtonSpace then Dec(LContentRect.Right, AContext.CloseButtonAreaWidth);
  DrawImage(ACanvas, AContext, AItem, LContentRect);
  DrawBadge(ACanvas, AContext, AItem, LContentRect);
  DrawPinnedGlyph(ACanvas, AContext, AItem, LContentRect);
  DrawText(ACanvas, AContext, AItem, LContentRect, LForeColor);
  DrawCloseButton(ACanvas, AContext, AItem, LForeColor);
end;

procedure TThemedTabRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTabRenderContext);
var
  I: Integer;
  LHeaderRect: TRect;
  LPanelBack, LTabBack, LBorder: TThemeColor;
begin
  if ACanvas = nil then Exit;
  LPanelBack := AContext.PanelBackColor;
  LTabBack := AContext.TabBackColor;
  LBorder := AContext.BorderColor;
  ACanvas.FillRectangle(LPanelBack, AContext.Bounds);
  if AContext.HeaderBottom > 0 then
  begin
    LHeaderRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Right, Min(AContext.Bounds.Bottom, AContext.HeaderBottom));
    ACanvas.FillRectangle(LTabBack, LHeaderRect);
    ACanvas.DrawLine(LBorder, AContext.Bounds.Left, AContext.HeaderBottom - 1, AContext.Bounds.Right - 1, AContext.HeaderBottom - 1, AContext.BorderThickness);
  end;
  ACanvas.FillRectangle(LPanelBack, AContext.PageBounds);
  ACanvas.DrawRectangle(LBorder, AContext.BorderBounds, AContext.BorderThickness);
  for I := 0 to High(AContext.Items) do if not AContext.Items[I].Selected then DrawTab(ACanvas, AContext, AContext.Items[I]);
  for I := 0 to High(AContext.Items) do if AContext.Items[I].Selected then DrawTab(ACanvas, AContext, AContext.Items[I]);
end;

end.

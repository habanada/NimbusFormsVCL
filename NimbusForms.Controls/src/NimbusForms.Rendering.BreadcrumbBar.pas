{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.BreadcrumbBar;

interface

uses
  System.Types, System.Classes, Vcl.Graphics, Vcl.ImgList,
  NimbusForms.Controls.BreadcrumbBar, NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedBreadcrumbRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    Font: TFont;
    Segments: TThemedBreadcrumbSegments;
    SegmentRects: TArray<TRect>;
    DropRects: TArray<TRect>;
    OverflowRect: TRect;
    FocusedIndex: Integer;
    HasFocus: Boolean;
    Images: TCustomImageList;
    ImageBuffer: Vcl.Graphics.TBitmap;
    ImageSize: Integer;
    HotIndex: Integer;
    HotDropDown: Boolean;
    BorderThickness: Integer;
    ShowDropDowns: Boolean;
    RightToLeft: Boolean;
    Enabled: Boolean;
  end;

  TThemedBreadcrumbRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedBreadcrumbRenderContext); static;
  end;

implementation

uses
  System.Math, NimbusForms.Theming.Types, NimbusForms.Rendering.Types;

class procedure TThemedBreadcrumbRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedBreadcrumbRenderContext);
var
  I, LX, LY, LSize: Integer;
  LBounds, LDrop, LTextRect, LImageRect: TRect;
  LBack, LFore, LBorder, LHot: TThemeColor;
  LFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or (AContext.Segments = nil) then Exit;
  LBack := NimbusInputBackColor(AContext.Palette);
  LFore := NimbusInputForeColor(AContext.Palette);
  LBorder := NimbusInputBorderColor(AContext.Palette);
  LHot := NimbusHoverBackColor(AContext.Palette);
  if not AContext.Enabled then LFore := NimbusDisabledForeColor(AContext.Palette);
  ACanvas.FillRectangle(LBack, AContext.Bounds);
  if AContext.BorderThickness > 0 then
    ACanvas.DrawRoundedRectangle(LBorder, Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Right - 1, AContext.Bounds.Bottom - 1), 4, AContext.BorderThickness);
  LFlags := [ntfSingleLine, ntfVCenter, ntfNoPrefix, ntfEndEllipsis];
  if AContext.RightToLeft then Include(LFlags, ntfRightToLeft);
  if not NimbusRectIsEmpty(AContext.OverflowRect) then
  begin
    ACanvas.FillRoundedRectangle(LHot, AContext.OverflowRect, 3);
    ACanvas.DrawText('…', AContext.Font, LFore, AContext.OverflowRect, [ntfSingleLine, ntfVCenter, ntfCenter, ntfNoPrefix]);
  end;
  for I := 0 to Min(AContext.Segments.Count, Length(AContext.SegmentRects)) - 1 do
    begin
      LBounds := AContext.SegmentRects[I];
      if NimbusRectIsEmpty(LBounds) then Continue;
      LDrop := AContext.DropRects[I];
      if (I = AContext.HotIndex) or (AContext.HasFocus and (I = AContext.FocusedIndex)) then ACanvas.FillRoundedRectangle(LHot, LBounds, 3);
      LTextRect := LBounds;
      Inc(LTextRect.Left, 7);
      Dec(LTextRect.Right, 7);
      if AContext.ShowDropDowns then LTextRect.Right := LDrop.Left - 2;
      if (AContext.Images <> nil) and (AContext.Segments[I].ImageIndex >= 0) and (AContext.Segments[I].ImageIndex < AContext.Images.Count) then
      begin
        AContext.Images.GetBitmap(AContext.Segments[I].ImageIndex, AContext.ImageBuffer);
        LSize := Min(AContext.ImageSize, LTextRect.Height);
        if LSize > 0 then
        begin
          LImageRect := Rect(LTextRect.Left, LBounds.Top + (LBounds.Height - LSize) div 2, LTextRect.Left + LSize, LBounds.Top + (LBounds.Height + LSize) div 2);
          ACanvas.DrawBitmap(AContext.ImageBuffer, LImageRect);
          Inc(LTextRect.Left, LSize + 4);
        end;
      end;
      ACanvas.DrawText(AContext.Segments[I].Caption, AContext.Font, LFore, LTextRect, LFlags);
      if AContext.ShowDropDowns and not NimbusRectIsEmpty(LDrop) then
      begin
        LX := LDrop.Left + LDrop.Width div 2;
        LY := LDrop.Top + LDrop.Height div 2;
        ACanvas.DrawLine(LFore, LX - 3, LY - 1, LX, LY + 2, 1.0);
        ACanvas.DrawLine(LFore, LX, LY + 2, LX + 3, LY - 1, 1.0);
      end;
    end;
end;

end.

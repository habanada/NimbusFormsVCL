{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.IDEScrollBar;

interface

uses
  System.Types, NimbusForms.Rendering.Canvas, NimbusForms.Rendering.ScrollBar, NimbusForms.Theming.Types;

type
  TNimbusIDEMarkerShape = (imsBar, imsLine, imsRectangle, imsCircle);
  TNimbusIDEMarkerLane = (imlLeft, imlRight);
  TNimbusIDEMarkerTone = (imtAccent, imtSuccess, imtWarning, imtError, imtInfo, imtMuted);
  TNimbusIDEMarkerGeometry = record
    First: Integer;
    Last: Integer;
    Shape: TNimbusIDEMarkerShape;
    Lane: TNimbusIDEMarkerLane;
    Tone: TNimbusIDEMarkerTone;
  end;
  TThemedIDEScrollBarRenderer = class
  public
    class function MarkerRect(const AContext: TNimbusScrollBarRenderContext; const AMarker: TNimbusIDEMarkerGeometry; const AWidth: Integer): TRect; static;
    class procedure DrawMarker(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext; const AMarker: TNimbusIDEMarkerGeometry; const AWidth: Integer); static;
  end;

implementation

uses
  System.Math, NimbusForms.Rendering.Types;

class function TThemedIDEScrollBarRenderer.MarkerRect(const AContext: TNimbusScrollBarRenderContext; const AMarker: TNimbusIDEMarkerGeometry; const AWidth: Integer): TRect;
var
  LLayout: TNimbusScrollBarLayout;
  LStart, LFinish, LSpan, LWidth, LLeft, LTop: Integer;
  LRange: Int64;
begin
  TThemedScrollBarRenderer.CalculateLayout(AContext, LLayout);
  LRange := Int64(AContext.Maximum) - AContext.Minimum;
  if (LRange <= 0) or (LLayout.TrackRect.Height <= 0) then Exit(Rect(0, 0, 0, 0));
  LSpan := LLayout.TrackRect.Height;
  LStart := LLayout.TrackRect.Top + Round((Int64(EnsureRange(AMarker.First, AContext.Minimum, AContext.Maximum)) - AContext.Minimum) / LRange * (LSpan - 1));
  LFinish := LLayout.TrackRect.Top + Round((Int64(EnsureRange(AMarker.Last, AContext.Minimum, AContext.Maximum)) - AContext.Minimum) / LRange * (LSpan - 1));
  if LFinish < LStart then LFinish := LStart;
  LWidth := Min(Max(2, AWidth), Max(2, LLayout.TrackRect.Width div 3));
  if AMarker.Lane = imlLeft then LLeft := LLayout.TrackRect.Left + 2 else LLeft := LLayout.TrackRect.Right - LWidth - 2;
  LTop := LStart;
  case AMarker.Shape of
    imsLine: Result := Rect(LLeft, LTop, LLeft + LWidth, LTop + 2);
    imsRectangle: Result := Rect(LLeft, LTop, LLeft + LWidth, Max(LTop + 3, LFinish + 1));
    imsCircle: Result := Rect(LLeft, LTop - LWidth div 2, LLeft + LWidth, LTop + (LWidth + 1) div 2);
  else
    Result := Rect(LLeft, LTop, LLeft + LWidth, Max(LTop + 2, LFinish + 1));
  end;
  if Result.Top < LLayout.TrackRect.Top then OffsetRect(Result, 0, LLayout.TrackRect.Top - Result.Top);
  if Result.Bottom > LLayout.TrackRect.Bottom then OffsetRect(Result, 0, LLayout.TrackRect.Bottom - Result.Bottom);
end;

class procedure TThemedIDEScrollBarRenderer.DrawMarker(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext; const AMarker: TNimbusIDEMarkerGeometry; const AWidth: Integer);
var
  LRect: TRect;
  LColor: TThemeColor;
begin
  LRect := MarkerRect(AContext, AMarker, AWidth);
  if NimbusRectIsEmpty(LRect) then Exit;
  case AMarker.Tone of
    imtAccent: LColor := NimbusAccentColor(AContext.Palette);
    imtSuccess: LColor := $FF32A66A;
    imtWarning: LColor := $FFFFBD47;
    imtError: LColor := $FFE35B66;
    imtInfo: LColor := $FF3F9AD8;
  else
    LColor := NimbusDisabledForeColor(AContext.Palette);
  end;
  if not AContext.Enabled then LColor := NimbusDisabledForeColor(AContext.Palette);
  case AMarker.Shape of
    imsCircle: ACanvas.FillEllipse(LColor, LRect);
    imsLine: ACanvas.DrawLine(LColor, LRect.Left, LRect.Top, LRect.Right, LRect.Top, 2);
  else
    ACanvas.FillRectangle(LColor, LRect);
  end;
end;

end.

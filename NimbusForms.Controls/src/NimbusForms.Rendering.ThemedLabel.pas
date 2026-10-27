{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ThemedLabel;

interface

uses
  System.Types,
  System.Classes,
  Vcl.Graphics,
  Vcl.StdCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedLabelRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect;
      const ACaption: string; const AFont: TFont; const APalette: TThemePalette;
      const AAlignment: TAlignment; const ALayout: TTextLayout; const AWordWrap,
      AShowAccelChar, AEnabled, AUseMutedForeColor, ARightToLeft: Boolean); static;
  end;

implementation

uses
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedLabelRenderer.Render(const ACanvas: INimbusRenderCanvas;
  const ABounds: TRect; const ACaption: string; const AFont: TFont;
  const APalette: TThemePalette; const AAlignment: TAlignment;
  const ALayout: TTextLayout; const AWordWrap, AShowAccelChar, AEnabled,
  AUseMutedForeColor, ARightToLeft: Boolean);
var
  LFlags: TNimbusTextFlags;
  LColor: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) or (ACaption = '') then
    Exit;
  LFlags := [];
  case AAlignment of
    taRightJustify: if ARightToLeft then Exclude(LFlags, ntfRight) else Include(LFlags, ntfRight);
    taCenter: Include(LFlags, ntfCenter);
    taLeftJustify: if ARightToLeft then Include(LFlags, ntfRight);
  end;
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  case ALayout of
    tlCenter: Include(LFlags, ntfVCenter);
    tlBottom: Include(LFlags, ntfBottom);
  end;
  if AWordWrap then Include(LFlags, ntfWordWrap) else Include(LFlags, ntfSingleLine);
  if not AShowAccelChar then Include(LFlags, ntfNoPrefix);
  if not AWordWrap then Include(LFlags, ntfEndEllipsis);
  if not AEnabled then
    LColor := NimbusDisabledForeColor(APalette)
  else if AUseMutedForeColor then
    LColor := NimbusMutedForeColor(APalette)
  else
    LColor := NimbusControlForeColor(APalette);
  ACanvas.DrawText(ACaption, AFont, LColor, ABounds, LFlags);
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Panel;

interface

uses
  System.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedPanelRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect;
      const APalette: TThemePalette; const AShowBorder: Boolean;
      const ACornerRadius: Integer); static;
  end;

implementation

uses
  NimbusForms.Rendering.Types;

class procedure TThemedPanelRenderer.Render(const ACanvas: INimbusRenderCanvas;
  const ABounds: TRect; const APalette: TThemePalette; const AShowBorder: Boolean;
  const ACornerRadius: Integer);
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then
    Exit;
  ACanvas.FillRoundedRectangle(NimbusPanelBackColor(APalette), ABounds, ACornerRadius);
  if AShowBorder then
    ACanvas.DrawRoundedRectangle(NimbusControlBorderColor(APalette), ABounds, ACornerRadius, 1.0);
end;

end.

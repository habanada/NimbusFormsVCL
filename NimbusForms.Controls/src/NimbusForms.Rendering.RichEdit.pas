{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.RichEdit;

interface

uses
  System.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedRichEditRenderer = class
  public
    class procedure RenderFrame(const ACanvas: INimbusRenderCanvas; const ABounds: TRect;
      const APalette: TThemePalette; const AEnabled, AReadOnly, AFocused,
      AShowBorder: Boolean; const ABorderThickness, ACornerRadius: Integer); static;
  end;

implementation

uses
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedRichEditRenderer.RenderFrame(const ACanvas: INimbusRenderCanvas;
  const ABounds: TRect; const APalette: TThemePalette; const AEnabled, AReadOnly,
  AFocused, AShowBorder: Boolean; const ABorderThickness, ACornerRadius: Integer);
var
  LBack, LBorder: TThemeColor;
  I: Integer;
  LRect: TRect;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then
    Exit;
  if not AEnabled then
    LBack := NimbusDisabledBackColor(APalette)
  else if AReadOnly then
    LBack := NimbusPanelBackColor(APalette)
  else
    LBack := NimbusInputBackColor(APalette);
  if AFocused and AEnabled then
    LBorder := NimbusFocusBorderColor(APalette)
  else
    LBorder := NimbusInputBorderColor(APalette);
  ACanvas.FillRectangle(NimbusPanelBackColor(APalette), ABounds);
  ACanvas.FillRoundedRectangle(LBack, ABounds, ACornerRadius);
  if AShowBorder then
  begin
    LRect := ABounds;
    for I := 1 to ABorderThickness do
    begin
      if NimbusRectIsEmpty(LRect) then Break;
      ACanvas.DrawRoundedRectangle(LBorder, LRect, ACornerRadius, 1.0);
      InflateRect(LRect, -1, -1);
    end;
  end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.NotificationBar;

interface

uses System.Types, Vcl.Graphics, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas,
  NimbusForms.Controls.NotificationBar.Types;

type
  TNimbusNotificationView = record
    MessageIndex: Integer;
    Bounds, TextBounds, IconBounds, CloseBounds, PreviousBounds, NextBounds, CounterBounds: TRect;
    ActionBounds: TArray<TRect>;
    Counter: string;
    WordWrap: Boolean;
    MaxLines: Integer;
  end;
  TNimbusNotificationViews = TArray<TNimbusNotificationView>;

  TThemedIdeNotificationBarRenderer = class
  public
    class function Layout(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const AMessages: TThemedIdeNotificationMessages; const AWidth, APPI, AMaxStackItems,
      ACarouselIndex: Integer; const AMode: TNimbusNotificationDisplayMode;
      const ACompact, AMultiline, AClose: Boolean; out AViews: TNimbusNotificationViews): Integer; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const APalette: TThemePalette; const AMessages: TThemedIdeNotificationMessages;
      const AViews: TNimbusNotificationViews; const APPI, AHotView, AHotAction, AFocusView,
      AFocusAction: Integer; const AEnabled, ACountdown: Boolean; const AHoveredLink: string); static;
  end;

implementation

uses Winapi.Windows, System.Classes, System.SysUtils, System.Math, System.UITypes, Vcl.StdCtrls,
  System.Generics.Collections, System.Generics.Defaults, NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types, NimbusForms.Rendering.Markup;

class function TThemedIdeNotificationBarRenderer.Layout(const ACanvas: INimbusRenderCanvas;
  const AFont: TFont; const AMessages: TThemedIdeNotificationMessages; const AWidth, APPI,
  AMaxStackItems, ACarouselIndex: Integer; const AMode: TNimbusNotificationDisplayMode;
  const ACompact, AMultiline, AClose: Boolean; out AViews: TNimbusNotificationViews): Integer;
var
  Order: TArray<Integer>;
  I, J, N, First, X, Y, W, H, Pad, Icon, ActionHeight, RightEdge, Lines: Integer;
  TotalActions, VisibleActions: Integer;
  ActionWidths: TArray<Integer>;
  InlineActions: Boolean;
  M: TThemedIdeNotificationMessage;
  V: TNimbusNotificationView;
  S, ActionSize: TSize;
  Markup: TThemedMarkupRenderer;
begin
  Result := 0;
  AViews := nil;
  N := AMessages.Count;
  if N = 0 then Exit;
  Order := AMessages.DisplayOrder;
  First := 0;
  if AMode = nndCarousel then begin First := EnsureRange(ACarouselIndex, 0, N - 1); N := 1; end
  else N := Min(N, AMaxStackItems);
  SetLength(AViews, N);
  Pad := NimbusScaleValue(6, APPI);
  Icon := NimbusScaleValue(18, APPI);
  ActionHeight := NimbusScaleValue(22, APPI);
  for I := 0 to N - 1 do
  begin
    V := Default(TNimbusNotificationView);
    V.MessageIndex := Order[First + I];
    M := AMessages[V.MessageIndex];
    V.IconBounds := Rect(Pad + NimbusScaleValue(4, APPI), Result + Pad,
      Pad + NimbusScaleValue(4, APPI) + Icon, Result + Pad + Icon);
    X := V.IconBounds.Right + Pad;
    RightEdge := Max(X + 1, AWidth - Pad);
    if AClose then Dec(RightEdge, ActionHeight + Pad);
    W := Max(1, RightEdge - X);
    Markup := M.PrepareText(AFont);
    Lines := 0;
    if not AMultiline or ACompact or M.Compact then Lines := 1;
    V.WordWrap := AMultiline and (Lines = 0);
    V.MaxLines := Lines;
    Markup.PrepareLayout(ACanvas, W, AMultiline and (Lines = 0), Lines, 0, False, False, epEndEllipsis, nmvNormal);
    S := Markup.Measure;
    TotalActions := 0;
    VisibleActions := 0;
    SetLength(ActionWidths, M.Actions.Count);
    for J := 0 to M.Actions.Count - 1 do
    begin
      if not M.Actions[J].IsVisible then begin ActionWidths[J] := 0; Continue; end;
      Inc(VisibleActions);
      ActionSize := ACanvas.MeasureText(M.Actions[J].DisplayText, AFont, W, [ntfSingleLine, ntfNoPrefix]);
      H := ActionSize.cx;
      ActionWidths[J] := Min(W, Max(ActionHeight, H + Pad * 2));
      Inc(TotalActions, ActionWidths[J] + Pad);
    end;
    InlineActions := (VisibleActions > 0) and (S.cy <= Max(Icon, ActionHeight)) and
      (TotalActions + S.cx + Pad <= W);
    if InlineActions then
    begin
      Dec(W, TotalActions + Pad);
      Markup.PrepareLayout(ACanvas, W, V.WordWrap, Lines, 0, False, False, epEndEllipsis, nmvNormal);
      S := Markup.Measure;
    end;
    H := Max(Icon, S.cy);
    if InlineActions then H := Max(H, ActionHeight);
    V.TextBounds := Rect(X, Result + Pad, X + W, Result + Pad + H);
    SetLength(V.ActionBounds, M.Actions.Count);
    Y := V.TextBounds.Bottom + NimbusScaleValue(4, APPI);
    if InlineActions then begin X := RightEdge - TotalActions; Y := Result + Pad; end;
    for J := 0 to M.Actions.Count - 1 do
    begin
      if ActionWidths[J] = 0 then Continue;
      H := ActionWidths[J];
      if not InlineActions and (X > V.TextBounds.Left) and (X + H > RightEdge) then
      begin X := V.TextBounds.Left; Inc(Y, ActionHeight + NimbusScaleValue(4, APPI)); end;
      V.ActionBounds[J] := Rect(X, Y, X + H, Y + ActionHeight);
      Inc(X, H + Pad);
    end;
    H := V.TextBounds.Bottom + Pad;
    if (VisibleActions > 0) and not InlineActions then H := Y + ActionHeight + Pad;
    H := Max(H, Result + NimbusScaleValue(34, APPI));
    if AMode = nndCarousel then
    begin
      V.PreviousBounds := Rect(V.TextBounds.Left, H, V.TextBounds.Left + ActionHeight, H + ActionHeight);
      V.CounterBounds := Rect(V.PreviousBounds.Right, H, V.PreviousBounds.Right + NimbusScaleValue(70, APPI), H + ActionHeight);
      V.NextBounds := Rect(V.CounterBounds.Right, H, V.CounterBounds.Right + ActionHeight, H + ActionHeight);
      V.Counter := Format('%d / %d', [First + 1, AMessages.Count]);
      Inc(H, ActionHeight + NimbusScaleValue(4, APPI));
    end;
    V.Bounds := Rect(0, Result, AWidth, H);
    if AClose then V.CloseBounds := Rect(AWidth - ActionHeight - Pad, Result + NimbusScaleValue(3, APPI),
      AWidth - Pad, Result + NimbusScaleValue(3, APPI) + ActionHeight);
    AViews[I] := V;
    Result := H + NimbusScaleValue(1, APPI);
  end;
end;

class procedure TThemedIdeNotificationBarRenderer.Render(const ACanvas: INimbusRenderCanvas;
  const AFont: TFont; const APalette: TThemePalette; const AMessages: TThemedIdeNotificationMessages;
  const AViews: TNimbusNotificationViews; const APPI, AHotView, AHotAction, AFocusView,
  AFocusAction: Integer; const AEnabled, ACountdown: Boolean; const AHoveredLink: string);
var
  I, J, X, Y, D: Integer;
  V: TNimbusNotificationView;
  M: TThemedIdeNotificationMessage;
  Severity, Fore, Back, Color: TThemeColor;
  Glyph, Hover: string;
  GlyphFont: TFont;
  Bitmap: Vcl.Graphics.TBitmap;
  B: TRect;
  Remaining: Double;
  Links: TArray<string>;

  procedure Button(const R: TRect; const Text: string; const Target: Integer; const Enabled: Boolean);
  var C: TThemeColor;
  begin
    if not Enabled then C := NimbusDisabledForeColor(APalette) else C := Fore;
    if Enabled and (I = AHotView) and (AHotAction = Target) then
      ACanvas.FillRectangle(NimbusHoverBackColor(APalette), R);
    if (I = AFocusView) and (Target = AFocusAction) then
      ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(APalette), R);
    ACanvas.DrawText(Text, AFont, C, R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  end;

begin
  GlyphFont := TFont.Create;
  Bitmap := Vcl.Graphics.TBitmap.Create;
  try
    GlyphFont.Assign(AFont);
    GlyphFont.Name := 'Segoe MDL2 Assets';
    for I := 0 to High(AViews) do
    begin
      V := AViews[I];
      M := AMessages[V.MessageIndex];
      Severity := NimbusAccentColor(APalette);
      Glyph := Char($E946);
      case M.Severity of
        nnsSuccess: begin Severity := NimbusSuccessColor; Glyph := Char($E73E); end;
        nnsWarning: begin Severity := NimbusWarningColor; Glyph := Char($E7BA); end;
        nnsError: begin Severity := NimbusDangerColor; Glyph := Char($E783); end;
        nnsCustom: if M.CustomColor <> 0 then Severity := M.CustomColor;
      end;
      Fore := NimbusControlForeColor(APalette);
      if not AEnabled then Fore := NimbusDisabledForeColor(APalette);
      Back := NimbusBlendColor(NimbusInputBackColor(APalette), Severity, 24);
      ACanvas.FillRectangle(Back, V.Bounds);
      ACanvas.FillRectangle(Severity, Rect(V.Bounds.Left, V.Bounds.Top,
        V.Bounds.Left + NimbusScaleValue(3, APPI), V.Bounds.Bottom));
      ACanvas.DrawLine(NimbusControlBorderColor(APalette), 0, V.Bounds.Bottom - 1, V.Bounds.Right, V.Bounds.Bottom - 1);
      if M.CustomGlyph <> '' then Glyph := M.CustomGlyph;
      if (M.Picture.Graphic <> nil) and not M.Picture.Graphic.Empty then
      begin
        if M.Picture.Graphic is Vcl.Graphics.TBitmap then ACanvas.DrawBitmap(M.Picture.Bitmap, V.IconBounds)
        else if M.Picture.Graphic is TIcon then ACanvas.DrawIcon(M.Picture.Icon.Handle, V.IconBounds)
        else
        begin
          Bitmap.SetSize(V.IconBounds.Width, V.IconBounds.Height);
          Bitmap.Canvas.Brush.Color := ThemeColorToColor(Back);
          Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
          Bitmap.Canvas.StretchDraw(Rect(0, 0, Bitmap.Width, Bitmap.Height), M.Picture.Graphic);
          ACanvas.DrawBitmap(Bitmap, V.IconBounds);
        end;
      end
      else ACanvas.DrawText(Glyph, GlyphFont, Severity, V.IconBounds, [ntfCenter, ntfVCenter, ntfSingleLine]);
      Hover := '';
      if I = AHotView then Hover := AHoveredLink;
      if (I = AFocusView) and (AFocusAction <= -5) then
      begin
        Links := M.PrepareText(AFont).LinkTargets;
        J := -5 - AFocusAction;
        if J < Length(Links) then Hover := Links[J];
        ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(APalette), V.TextBounds);
      end;
      M.PrepareText(AFont).Render(ACanvas, V.TextBounds, taLeftJustify, tlTop, V.WordWrap,
        V.MaxLines, 0, False, AEnabled, False, epEndEllipsis, nmvNormal, APalette, ThemeColorToColor(Fore), Hover);
      for J := 0 to High(V.ActionBounds) do
      begin
        B := V.ActionBounds[J];
        if IsRectEmpty(B) then Continue;
        if M.Actions[J].Style = nnasCompactButton then
          ACanvas.DrawRectangle(NimbusControlBorderColor(APalette), B);
        Color := NimbusAccentColor(APalette);
        if not AEnabled or not M.Actions[J].IsEnabled then Color := NimbusDisabledForeColor(APalette);
        if (I = AHotView) and (J = AHotAction) and AEnabled and M.Actions[J].IsEnabled then
          ACanvas.FillRectangle(NimbusHoverBackColor(APalette), B);
        ACanvas.DrawText(M.Actions[J].DisplayText, AFont, Color, B,
          [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis]);
        if (I = AFocusView) and (J = AFocusAction) then
          ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(APalette), B);
      end;
      if not IsRectEmpty(V.CloseBounds) then
      begin
        B := V.CloseBounds;
        if (I = AHotView) and (AHotAction = -2) and AEnabled then
          ACanvas.FillRectangle(NimbusHoverBackColor(APalette), B);
        X := (B.Left + B.Right) div 2;
        Y := (B.Top + B.Bottom) div 2;
        D := NimbusScaleValue(4, APPI);
        ACanvas.DrawLine(Fore, X - D, Y - D, X + D, Y + D);
        ACanvas.DrawLine(Fore, X - D, Y + D, X + D, Y - D);
        if (I = AFocusView) and (AFocusAction = -2) then ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(APalette), B);
      end;
      if V.Counter <> '' then
      begin
        Button(V.PreviousBounds, Char($2039), -3, AEnabled and (AMessages.Count > 1));
        Button(V.NextBounds, Char($203A), -4, AEnabled and (AMessages.Count > 1));
        ACanvas.DrawText(V.Counter, AFont, Fore, V.CounterBounds, [ntfCenter, ntfVCenter, ntfSingleLine]);
      end;
      if ACountdown and not M.Sticky and (M.AutoDismissMilliseconds > 0) then
      begin
        Remaining := Max(0.0, 1.0 - (GetTickCount64 - M.CreatedTick) / M.AutoDismissMilliseconds);
        B := Rect(V.TextBounds.Left, V.Bounds.Bottom - NimbusScaleValue(2, APPI),
          V.TextBounds.Left + Round(V.TextBounds.Width * Remaining), V.Bounds.Bottom);
        ACanvas.FillRectangle(Severity, B);
      end;
    end;
  finally Bitmap.Free; GlyphFont.Free; end;
end;

end.

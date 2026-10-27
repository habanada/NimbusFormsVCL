{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Avatar;

interface

uses
  System.Types, System.UITypes, Vcl.Graphics, NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

type
  TThemedAvatarShape = (tasCircle, tasRounded, tasSquare);
  TThemedAvatarSize = (tavCompact, tavNormal, tavLarge);
  TThemedAvatarStatus = (tavsNone, tavsOnline, tavsAway, tavsBusy, tavsOffline, tavsConnecting, tavsDoNotDisturb, tavsInvisible);
  TThemedAvatarPart = (tapNone, tapAvatar, tapStatus, tapCounter, tapStar, tapBadge);
  TThemedAvatarBadgeKind = (tabkDot, tabkCounter, tabkText, tabkStar);
  TThemedAvatarBadgeTone = (tabtAccent, tabtSuccess, tabtWarning, tabtDanger, tabtInfo, tabtNeutral);
  TThemedAvatarBadgeAnchor = (tabaTopLeft, tabaTopRight, tabaBottomLeft, tabaBottomRight);

  TThemedAvatarBadgeInfo = record
    Part: TThemedAvatarPart;
    ID, Tag, Count, Limit, Size, OffsetX, OffsetY: Integer;
    Key, Text, Hint: string;
    Kind: TThemedAvatarBadgeKind;
    Tone: TThemedAvatarBadgeTone;
    Anchor: TThemedAvatarBadgeAnchor;
    Color, TextColor: TColor;
    Enabled, Visible, HideWhenZero: Boolean;
  end;

  TThemedAvatarBadgeLayout = record
    Info: TThemedAvatarBadgeInfo;
    Bounds: TRect;
    Text: string;
  end;

  TThemedAvatarHitInfo = record
    Part: TThemedAvatarPart;
    BadgeID, Tag, Count: Integer;
    Key, Text, Hint: string;
    Bounds: TRect;
    Enabled: Boolean;
  end;

  TThemedAvatarRenderer = class
  public
    class function AvatarBounds(const ABounds: TRect): TRect; static;
    class function BuildBadgeLayout(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; AFont: TFont;
      APPI: Integer; const AItems: TArray<TThemedAvatarBadgeInfo>): TArray<TThemedAvatarBadgeLayout>; static;
    class function HitTest(const APoint: TPoint; const ABounds: TRect; AShape: TThemedAvatarShape;
      const ALayout: TArray<TThemedAvatarBadgeLayout>): TThemedAvatarHitInfo; static;
    class procedure RenderBadges(const ACanvas: INimbusRenderCanvas; APalette: TThemePalette; AFont: TFont;
      const ALayout: TArray<TThemedAvatarBadgeLayout>; AEnabled: Boolean; AHotID, APressedID, AFocusID, APPI: Integer); static;
    class procedure RenderFocus(const ACanvas: INimbusRenderCanvas; const ABounds: TRect;
      APalette: TThemePalette; AShape: TThemedAvatarShape; APPI: Integer); static;
    class procedure PrepareImage(const ASource, ATarget: Vcl.Graphics.TBitmap; AShape: TThemedAvatarShape); overload; static;
    class procedure PrepareImage(const ASource: TGraphic; const ATarget: Vcl.Graphics.TBitmap; AShape: TThemedAvatarShape); overload; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette;
      const AFont: TFont; const AInitials: string; AShowInitials, AEnabled: Boolean; AShape: TThemedAvatarShape;
      AStatus: TThemedAvatarStatus; AShowStatus: Boolean; ACounter: Integer; AShowCounter, AShowStar: Boolean;
      ACustomColor: TColor; ABorderWidth: Integer; const AImage: Vcl.Graphics.TBitmap; out ABadgeRect: TRect); static;
  end;

implementation

uses
  System.Math, System.SysUtils, System.Classes, Winapi.Windows, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  NimbusForms.Rendering.Types;

class function TThemedAvatarRenderer.AvatarBounds(const ABounds: TRect): TRect;
var Size: Integer;
begin
  Size := Max(0, Min(ABounds.Width, ABounds.Height));
  Result := Rect(ABounds.Left + (ABounds.Width - Size) div 2, ABounds.Top + (ABounds.Height - Size) div 2, 0, 0);
  Result.Right := Result.Left + Size; Result.Bottom := Result.Top + Size;
end;

class function TThemedAvatarRenderer.BuildBadgeLayout(const ACanvas: INimbusRenderCanvas; const ABounds: TRect;
  AFont: TFont; APPI: Integer; const AItems: TArray<TThemedAvatarBadgeInfo>): TArray<TThemedAvatarBadgeLayout>;
var R, B, Intersection: TRect; Item: TThemedAvatarBadgeInfo; Entry: TThemedAvatarBadgeLayout;
  Used: array[TThemedAvatarBadgeAnchor] of Integer; I, J, W, H, Gap, FontHeight, X, Y, Step, N: Integer;
  TextSize: TSize; Collision: Boolean;
begin
  Result := nil; R := AvatarBounds(ABounds);
  if (R.Width <= 0) or (R.Height <= 0) then Exit;
  FillChar(Used, SizeOf(Used), 0); Gap := Max(1, NimbusScaleValue(2, APPI));
  FontHeight := Abs(AFont.Height);
  for I := 0 to High(AItems) do
  begin
    Item := AItems[I];
    if not Item.Visible or ((Item.Kind = tabkCounter) and Item.HideWhenZero and (Item.Count = 0)) then Continue;
    Entry.Info := Item; Entry.Text := Item.Text;
    if Item.Kind = tabkCounter then
      if Item.Count > Item.Limit then Entry.Text := IntToStr(Item.Limit) + '+' else Entry.Text := IntToStr(Item.Count);
    if (Item.Kind = tabkText) and (Entry.Text = '') then Continue;
    if Item.Size > 0 then H := NimbusScaleValue(Item.Size, APPI)
    else if Item.Kind = tabkDot then H := Max(NimbusScaleValue(8, APPI), R.Height div 4)
    else H := Max(NimbusScaleValue(16, APPI), R.Height div 3);
    if Item.Kind in [tabkText, tabkCounter] then H := Max(H, FontHeight + Gap * 2);
    H := Min(R.Height, Max(1, H)); W := H;
    if Item.Kind in [tabkText, tabkCounter] then
    begin
      TextSize := ACanvas.MeasureText(Entry.Text, AFont, R.Width, [ntfSingleLine, ntfNoPrefix]);
      W := Max(H, TextSize.cx + Gap * 4);
    end;
    W := Min(W, R.Width);
    if Item.Anchor in [tabaTopLeft, tabaBottomLeft] then X := R.Left + Used[Item.Anchor]
    else X := R.Right - W - Used[Item.Anchor];
    if (X < R.Left) or (X + W > R.Right) then
      if Item.Anchor in [tabaTopLeft, tabaBottomLeft] then X := R.Left else X := R.Right - W;
    if Item.Anchor in [tabaTopLeft, tabaTopRight] then begin Y := R.Top; Step := H + Gap; end
    else begin Y := R.Bottom - H; Step := -H - Gap; end;
    X := EnsureRange(X + NimbusScaleValue(Item.OffsetX, APPI), R.Left, R.Right - W);
    Y := EnsureRange(Y + NimbusScaleValue(Item.OffsetY, APPI), R.Top, R.Bottom - H);
    repeat
      B := Rect(X, Y, X + W, Y + H); Collision := False;
      for J := 0 to High(Result) do
        if System.Types.IntersectRect(Intersection, B, Result[J].Bounds) then begin Collision := True; Break; end;
      if Collision then Inc(Y, Step);
    until not Collision or (Y < R.Top) or (Y + H > R.Bottom);
    if Collision then Continue;
    Entry.Bounds := B; N := Length(Result); SetLength(Result, N + 1); Result[N] := Entry;
    Inc(Used[Item.Anchor], W + Gap);
  end;
end;

function AvatarRoundedContains(const R: TRect; const P: TPoint; Radius: Integer): Boolean;
var CX, CY: Integer;
begin
  Result := PtInRect(R, P); if not Result or (Radius <= 0) then Exit;
  Radius := Min(Radius, Min(R.Width, R.Height) div 2);
  CX := EnsureRange(P.X, R.Left + Radius, R.Right - Radius);
  CY := EnsureRange(P.Y, R.Top + Radius, R.Bottom - Radius);
  Result := Sqr(Double(P.X - CX)) + Sqr(Double(P.Y - CY)) <= Sqr(Double(Radius));
end;

class function TThemedAvatarRenderer.HitTest(const APoint: TPoint; const ABounds: TRect; AShape: TThemedAvatarShape;
  const ALayout: TArray<TThemedAvatarBadgeLayout>): TThemedAvatarHitInfo;
var I, Radius: Integer; R: TRect; Info: TThemedAvatarBadgeInfo;
begin
  Result := Default(TThemedAvatarHitInfo); Result.BadgeID := -1;
  for I := High(ALayout) downto 0 do
    if AvatarRoundedContains(ALayout[I].Bounds, APoint, ALayout[I].Bounds.Height div 2) then
    begin
      Info := ALayout[I].Info; Result.Part := Info.Part; Result.BadgeID := Info.ID; Result.Tag := Info.Tag;
      Result.Key := Info.Key; Result.Text := ALayout[I].Text; Result.Count := Info.Count; Result.Hint := Info.Hint;
      Result.Enabled := Info.Enabled; Result.Bounds := ALayout[I].Bounds; Exit;
    end;
  R := AvatarBounds(ABounds); Radius := 0;
  case AShape of tasCircle: Radius := R.Width div 2; tasRounded: Radius := R.Width div 5; end;
  if AvatarRoundedContains(R, APoint, Radius) then
  begin Result.Part := tapAvatar; Result.BadgeID := -2; Result.Bounds := R; Result.Enabled := True; end;
end;

class procedure TThemedAvatarRenderer.RenderBadges(const ACanvas: INimbusRenderCanvas; APalette: TThemePalette;
  AFont: TFont; const ALayout: TArray<TThemedAvatarBadgeLayout>; AEnabled: Boolean;
  AHotID, APressedID, AFocusID, APPI: Integer);
var Entry: TThemedAvatarBadgeLayout; R, Halo: TRect; Back, Fore: TThemeColor;
  Gap, I, CX, CY, Outer, Inner, Radius: Integer; Points: TNimbusPointBuffer;
begin
  Gap := Max(1, NimbusScaleValue(1, APPI));
  for Entry in ALayout do
  begin
    R := Entry.Bounds;
    case Entry.Info.Tone of
      tabtSuccess: Back := NimbusSuccessColor;
      tabtWarning: Back := NimbusWarningColor;
      tabtDanger: Back := NimbusDangerColor;
      tabtInfo: Back := ThemeColor(255, 45, 125, 220);
      tabtNeutral: Back := NimbusMutedForeColor(APalette);
    else Back := NimbusAccentColor(APalette);
    end;
    if Entry.Info.Color <> clNone then Back := ColorToThemeColor(Entry.Info.Color);
    if not AEnabled or not Entry.Info.Enabled then Back := NimbusDisabledBackColor(APalette)
    else if Entry.Info.ID = APressedID then Back := NimbusDarkenColor(Back, 30)
    else if Entry.Info.ID = AHotID then Back := NimbusBlendColor(Back, ThemeColor(255, 255, 255, 255), 35);
    if (ThemeColorRed(Back) * 299 + ThemeColorGreen(Back) * 587 + ThemeColorBlue(Back) * 114) >= 145000 then
      Fore := ThemeColor(255, 22, 26, 32) else Fore := ThemeColor(255, 255, 255, 255);
    if Entry.Info.TextColor <> clNone then Fore := ColorToThemeColor(Entry.Info.TextColor);
    if not AEnabled or not Entry.Info.Enabled then Fore := NimbusDisabledForeColor(APalette);
    Halo := R; InflateRect(Halo, Gap, Gap); Radius := R.Height div 2;
    ACanvas.FillRoundedRectangle(NimbusControlBackColor(APalette), Halo, Radius + Gap);
    ACanvas.FillRoundedRectangle(Back, R, Radius);
    if Entry.Info.Kind = tabkStar then
    begin
      CX := (R.Left + R.Right) div 2; CY := (R.Top + R.Bottom) div 2;
      Outer := Max(1, R.Height div 2 - Gap * 2); Inner := Max(1, Outer div 2);
      for I := 0 to 9 do
        if Odd(I) then Points[I] := Point(CX + Round(Inner * Cos((I * 36 - 90) * Pi / 180)), CY + Round(Inner * Sin((I * 36 - 90) * Pi / 180)))
        else Points[I] := Point(CX + Round(Outer * Cos((I * 36 - 90) * Pi / 180)), CY + Round(Outer * Sin((I * 36 - 90) * Pi / 180)));
      ACanvas.FillPolygon(Fore, @Points, 10);
    end
    else if Entry.Info.Kind in [tabkText, tabkCounter] then
      ACanvas.DrawText(Entry.Text, AFont, Fore, R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
    if Entry.Info.ID = AFocusID then
    begin InflateRect(R, -Gap, -Gap); ACanvas.DrawDashedRectangle(Fore, R, Gap); end;
  end;
end;

class procedure TThemedAvatarRenderer.RenderFocus(const ACanvas: INimbusRenderCanvas; const ABounds: TRect;
  APalette: TThemePalette; AShape: TThemedAvatarShape; APPI: Integer);
var R: TRect; Width: Integer;
begin
  R := AvatarBounds(ABounds); Width := Max(1, NimbusScaleValue(1, APPI));
  InflateRect(R, -Width * 3, -Width * 3);
  if (R.Width <= 0) or (R.Height <= 0) then Exit;
  case AShape of
    tasCircle: ACanvas.DrawEllipse(NimbusFocusBorderColor(APalette), R, Width);
    tasRounded: ACanvas.DrawRoundedRectangle(NimbusFocusBorderColor(APalette), R, R.Width div 5, Width);
    tasSquare: ACanvas.DrawDashedRectangle(NimbusFocusBorderColor(APalette), R, Width);
  end;
end;

class procedure TThemedAvatarRenderer.PrepareImage(const ASource, ATarget: Vcl.Graphics.TBitmap; AShape: TThemedAvatarShape);
begin
  PrepareImage(TGraphic(ASource), ATarget, AShape);
end;

class procedure TThemedAvatarRenderer.PrepareImage(const ASource: TGraphic; const ATarget: Vcl.Graphics.TBitmap; AShape: TThemedAvatarShape);
const
  CSupersample = 3;
var
  G, HighGraphics: TGPGraphics;
  Path: TGPGraphicsPath;
  SourceImage, HighImage, FinalImage: TGPBitmap;
  Data: TBitmapData;
  Y: Integer;
  Size, HighSize, Radius: Integer;
  GR: TGPRect;
  Stream: TMemoryStream; Adapter: IStream; Bitmap: Vcl.Graphics.TBitmap; Format: Integer;
begin
  if (ASource = nil) or (ATarget = nil) then Exit;
  Size := Min(ATarget.Width, ATarget.Height);
  if (Size <= 0) or (ASource.Width <= 0) or (ASource.Height <= 0) then Exit;
  HighSize := Size * CSupersample;
  ATarget.PixelFormat := pf32bit;
  HighImage := TGPBitmap.Create(HighSize, HighSize, PixelFormat32bppPARGB);
  try
    HighGraphics := TGPGraphics.Create(HighImage);
    try
      HighGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
      HighGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      HighGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      HighGraphics.SetCompositingQuality(CompositingQualityHighQuality);
      HighGraphics.Clear(0);
      Path := TGPGraphicsPath.Create;
      try
        Radius := Max(1, HighSize div 5);
        case AShape of
          tasCircle: Path.AddEllipse(Single(0), Single(0), Single(HighSize), Single(HighSize));
          tasSquare: begin GR.X := 0; GR.Y := 0; GR.Width := HighSize; GR.Height := HighSize; Path.AddRectangle(GR); end;
          tasRounded:
            begin
              Path.AddArc(Single(0), Single(0), Single(Radius * 2), Single(Radius * 2), Single(180), Single(90));
              Path.AddArc(Single(HighSize - Radius * 2), Single(0), Single(Radius * 2), Single(Radius * 2), Single(270), Single(90));
              Path.AddArc(Single(HighSize - Radius * 2), Single(HighSize - Radius * 2), Single(Radius * 2), Single(Radius * 2), Single(0), Single(90));
              Path.AddArc(Single(0), Single(HighSize - Radius * 2), Single(Radius * 2), Single(Radius * 2), Single(90), Single(90));
              Path.CloseFigure;
            end;
        end;
        HighGraphics.SetClip(Path);
        Stream := TMemoryStream.Create;
        try
          if ASource is Vcl.Graphics.TBitmap then
          begin
            Bitmap := Vcl.Graphics.TBitmap(ASource);
            if (Bitmap.PixelFormat = pf32bit) and (Bitmap.AlphaFormat <> afIgnored) then
            begin
              if Bitmap.AlphaFormat = afPremultiplied then Format := PixelFormat32bppPARGB else Format := PixelFormat32bppARGB;
              SourceImage := TGPBitmap.Create(Bitmap.Width, Bitmap.Height, Format);
              try
                GR.X := 0; GR.Y := 0; GR.Width := Bitmap.Width; GR.Height := Bitmap.Height;
                if SourceImage.LockBits(GR, ImageLockModeWrite, Format, Data) <> Ok then
                begin SourceImage.Free; Exit; end;
                try
                  for Y := 0 to Bitmap.Height - 1 do
                    Move(Bitmap.ScanLine[Y]^, PByte(NativeInt(Data.Scan0) + NativeInt(Y) * Data.Stride)^, Bitmap.Width * 4);
                finally SourceImage.UnlockBits(Data); end;
              except SourceImage.Free; raise; end;
            end
            else SourceImage := TGPBitmap.Create(Bitmap.Handle, Bitmap.Palette);
          end
          else
          begin
            ASource.SaveToStream(Stream); Stream.Position := 0;
            Adapter := TStreamAdapter.Create(Stream, soReference);
            SourceImage := TGPBitmap.Create(Adapter);
          end;
          try
            HighGraphics.DrawImage(SourceImage, 0, 0, HighSize, HighSize);
          finally SourceImage.Free; end;
        finally
          Adapter := nil; Stream.Free;
        end;
        HighGraphics.ResetClip;
      finally
        Path.Free;
      end;
    finally
      HighGraphics.Free;
    end;
    FinalImage := TGPBitmap.Create(Size, Size, PixelFormat32bppPARGB);
    try
      G := TGPGraphics.Create(FinalImage);
      try
        G.SetSmoothingMode(SmoothingModeAntiAlias);
        G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
        G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
        G.SetCompositingQuality(CompositingQualityHighQuality);
        G.Clear(0);
        G.DrawImage(HighImage, 0, 0, Size, Size);
      finally
        G.Free;
      end;
      GR.X := 0;
      GR.Y := 0;
      GR.Width := Size;
      GR.Height := Size;
      if FinalImage.LockBits(GR, ImageLockModeRead, PixelFormat32bppPARGB, Data) <> Ok then Exit;
      try
        for Y := 0 to Size - 1 do
          Move(PByte(NativeInt(Data.Scan0) + NativeInt(Y) * Data.Stride)^, ATarget.ScanLine[Y]^, Size * 4);
      finally
        FinalImage.UnlockBits(Data);
      end;
      ATarget.AlphaFormat := afPremultiplied;
    finally
      FinalImage.Free;
    end;
  finally
    HighImage.Free;
  end;
end;

class procedure TThemedAvatarRenderer.Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette;
  const AFont: TFont; const AInitials: string; AShowInitials, AEnabled: Boolean; AShape: TThemedAvatarShape;
  AStatus: TThemedAvatarStatus; AShowStatus: Boolean; ACounter: Integer; AShowCounter, AShowStar: Boolean;
  ACustomColor: TColor; ABorderWidth: Integer; const AImage: Vcl.Graphics.TBitmap; out ABadgeRect: TRect);
var R, B, StarRect, BorderRect: TRect; Size, D, I, CX, CY, Outer, Inner: Integer;
    Back, Fore, Border, StatusColor: TThemeColor;
    LabelText: string; Points: TNimbusPointBuffer;
begin
  ABadgeRect := Rect(0, 0, 0, 0);
  Size := Min(ABounds.Width, ABounds.Height);
  if Size <= 0 then Exit;
  R := Rect(ABounds.Left + (ABounds.Width - Size) div 2, ABounds.Top + (ABounds.Height - Size) div 2,
    ABounds.Left + (ABounds.Width + Size) div 2, ABounds.Top + (ABounds.Height + Size) div 2);
  Back := NimbusAccentColor(APalette);
  Border := NimbusControlBorderColor(APalette);
  if ACustomColor <> clNone then Back := ColorToThemeColor(ACustomColor);
  if not AEnabled then
  begin
    Back := NimbusDisabledBackColor(APalette);
  end;
  if (ThemeColorRed(Back) * 299 + ThemeColorGreen(Back) * 587 + ThemeColorBlue(Back) * 114) >= 145000 then
    Fore := ThemeColor(255, 22, 26, 32)
  else Fore := ThemeColor(255, 255, 255, 255);
  if (AImage <> nil) and (AImage.Width > 0) and (AImage.Height > 0) then ACanvas.DrawBitmap(AImage, R)
  else
  begin
    case AShape of
      tasCircle: ACanvas.FillEllipse(Back, R);
      tasRounded: ACanvas.FillRoundedRectangle(Back, R, Size div 5);
      tasSquare: ACanvas.FillRectangle(Back, R);
    end;
    if AShowInitials and (AInitials <> '') then
    begin
      ACanvas.DrawText(AInitials, AFont, Fore, R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end;
  end;
  if ABorderWidth > 0 then
  begin
    BorderRect := R; I := (ABorderWidth + 1) div 2; InflateRect(BorderRect, -I, -I);
    if (BorderRect.Width > 0) and (BorderRect.Height > 0) then
      case AShape of
        tasCircle: ACanvas.DrawEllipse(Border, BorderRect, ABorderWidth);
        tasRounded: ACanvas.DrawRoundedRectangle(Border, BorderRect, Max(0, Size div 5 - I), ABorderWidth);
        tasSquare: ACanvas.DrawRectangle(Border, BorderRect, ABorderWidth);
      end;
  end;
  D := Max(7, Size div 4);
  if AShowStatus and (AStatus <> tavsNone) then
  begin
    B := Rect(R.Left, R.Bottom - D, R.Left + D, R.Bottom);
    case AStatus of
      tavsOnline: StatusColor := NimbusSuccessColor;
      tavsAway: StatusColor := NimbusWarningColor;
      tavsBusy, tavsDoNotDisturb: StatusColor := NimbusDangerColor;
      tavsConnecting: StatusColor := ThemeColor(255, 45, 125, 220);
    else
      StatusColor := NimbusControlBorderColor(APalette);
    end;
    ACanvas.FillEllipse(NimbusInputBackColor(APalette), Rect(B.Left - 1, B.Top - 1, B.Right + 1, B.Bottom + 1));
    ACanvas.FillEllipse(StatusColor, B);
    ABadgeRect := B;
  end;
  if AShowCounter and (ACounter > 0) then
  begin
    LabelText := IntToStr(Min(ACounter, 99));
    if ACounter > 99 then LabelText := '99+';
    D := Max(14, Size div 3);
    B := Rect(R.Right - D, R.Top, R.Right, R.Top + D);
    ACanvas.FillEllipse(NimbusDangerColor, B);
    ACanvas.DrawText(LabelText, AFont, ThemeColor(255,255,255,255), B, [ntfCenter, ntfVCenter, ntfSingleLine]);
    ABadgeRect := B;
  end;
  if AShowStar then
  begin
    D := Max(12, Size div 3);
    StarRect := Rect(R.Right - D, R.Bottom - D, R.Right, R.Bottom);
    CX := (StarRect.Left + StarRect.Right) div 2;
    CY := (StarRect.Top + StarRect.Bottom) div 2;
    Outer := Max(4, D div 2 - 1);
    Inner := Max(2, Outer div 2);
    for I := 0 to 9 do
      if (I mod 2) = 0 then Points[I] := Point(CX + Round(Outer * Cos((I * 36 - 90) * Pi / 180)), CY + Round(Outer * Sin((I * 36 - 90) * Pi / 180)))
      else Points[I] := Point(CX + Round(Inner * Cos((I * 36 - 90) * Pi / 180)), CY + Round(Inner * Sin((I * 36 - 90) * Pi / 180)));
    ACanvas.FillPolygon(NimbusWarningColor, @Points, 10);
    ABadgeRect := StarRect;
  end;
end;

end.

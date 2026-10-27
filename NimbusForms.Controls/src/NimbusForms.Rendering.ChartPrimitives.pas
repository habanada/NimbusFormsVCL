{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ChartPrimitives;

interface

uses System.Classes, System.Types, System.Generics.Collections, Vcl.Graphics,
  NimbusForms.Rendering.Charts, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

type
  TNimbusChartPrimitiveBuilder = class
  private
    FItems: TList<TNimbusChartPrimitive>;
    FContext: TNimbusChartRenderContext;
    FClipBounds: TRect;
    function NewPrimitive(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor; const Hit: TNimbusChartHit): TNimbusChartPrimitive;
  public
    constructor Create(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout);
    destructor Destroy; override;
    procedure Box(const Bounds: TRect; const Color: TThemeColor; const Hit: TNimbusChartHit; const Radius: Single = 0; const Outline: Boolean = False);
    procedure Ellipse(const Bounds: TRect; const Color: TThemeColor; const Hit: TNimbusChartHit; const Outline: Boolean = False);
    procedure Text(const Value: string; const Bounds: TRect; const Color: TThemeColor; const Hit: TNimbusChartHit; const Flags: TNimbusTextFlags);
    procedure Line(const Points: TArray<TPointF>; const Color: TThemeColor; const Width: Single; const Hit: TNimbusChartHit);
    procedure Polygon(const Points: TArray<TPointF>; const Color: TThemeColor; const Hit: TNimbusChartHit);
    procedure Arc(const Bounds: TRect; const Color: TThemeColor; const Start, Sweep, Width: Single; const Hit: TNimbusChartHit);
    procedure Sector(const Bounds: TRect; const Color: TThemeColor; const Start, Sweep, InnerRadius: Single; const Hit: TNimbusChartHit);
    function Color(const Index: Integer; const CustomColor: TColor = clNone): TThemeColor;
    function Finish: TArray<TNimbusChartPrimitive>;
    property ClipBounds: TRect read FClipBounds write FClipBounds;
  end;

function NimbusChartContrastColor(const Color: TThemeColor): TThemeColor;
function NimbusChartMeasureLabel(const C: TNimbusChartRenderContext; const Text: string; const MaximumWidth: Integer): TSize;
function NimbusChartRadialLabel(const Center: TPointF; const Radius, Angle, Gap: Double; const Size: TSize; out Flags: TNimbusTextFlags): TRect;

implementation

uses System.Math, NimbusForms.Charts.Types, NimbusForms.Rendering.Canvas;

procedure TNimbusChartPrimitiveBuilder.Sector(const Bounds: TRect; const Color: TThemeColor; const Start, Sweep, InnerRadius: Single; const Hit: TNimbusChartHit);
var A: TNimbusChartPrimitive;
begin
  if Bounds.IsEmpty then Exit;
  A := NewPrimitive(ncpSector, Color, Hit); A.Bounds := Bounds; A.StartAngle := Start; A.SweepAngle := Sweep;
  A.InnerRadius := Max(0.0, InnerRadius); FItems.Add(A);
end;

function NimbusChartMeasureLabel(const C: TNimbusChartRenderContext; const Text: string; const MaximumWidth: Integer): TSize;
var Bitmap: TBitmap; Canvas: INimbusRenderCanvas;
begin
  if C.MeasureCanvas <> nil then Exit(C.MeasureCanvas.MeasureText(Text, C.Font, MaximumWidth, [ntfSingleLine, ntfNoPrefix]));
  Bitmap := TBitmap.Create;
  try
    Bitmap.SetSize(1, 1); Canvas := TNimbusRenderCanvas.Create; Canvas.BeginRender(Bitmap.Canvas);
    try Result := Canvas.MeasureText(Text, C.Font, MaximumWidth, [ntfSingleLine, ntfNoPrefix]) finally Canvas.EndRender end;
  finally Canvas := nil; Bitmap.Free end;
end;

function NimbusChartRadialLabel(const Center: TPointF; const Radius, Angle, Gap: Double; const Size: TSize; out Flags: TNimbusTextFlags): TRect;
var X, Y, DX, DY: Double; Width, Height: Integer;
begin
  DX := Cos(Angle); DY := Sin(Angle); X := Center.X + DX * (Radius + Gap); Y := Center.Y + DY * (Radius + Gap);
  if Abs(DX) < 0.25 then Y := Center.Y + Sign(DY) * (Radius + Gap);
  if Abs(DY) < 0.25 then X := Center.X + Sign(DX) * (Radius + Gap);
  Width := Max(1, Size.cx); Height := Max(1, Size.cy); Flags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if DX < -0.25 then begin X := X - Width; Include(Flags, ntfRight) end
  else if DX < 0.25 then begin X := X - Width / 2; Include(Flags, ntfCenter) end;
  if DY < -0.25 then Y := Y - Height else if DY < 0.25 then Y := Y - Height / 2;
  Result := Rect(Round(X), Round(Y), Round(X) + Width, Round(Y) + Height);
end;

function NimbusChartContrastColor(const Color: TThemeColor): TThemeColor;
begin if (((Color shr 16) and 255) * 299 + ((Color shr 8) and 255) * 587 + (Color and 255) * 114) >= 150000 then Result := $FF202020 else Result := $FFFFFFFF end;

constructor TNimbusChartPrimitiveBuilder.Create(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout);
var Flags: TNimbusTextFlags; I, Height, Width, X, Y: Integer; Bounds: TRect; Hit: TNimbusChartHit;
begin
  inherited Create; FItems := TList<TNimbusChartPrimitive>.Create; FContext := C;
  Flags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if C.Model.Options.ShowTitle then Text(C.Model.Title, L.TitleBounds, ChartForeColor(C), TNimbusChartHit.None, Flags);
  if C.Model.Options.ShowSubtitle then Text(C.Model.Subtitle, L.SubtitleBounds, ChartForeColor(C), TNimbusChartHit.None, Flags);
  if C.Model.Legend.Visible and not L.LegendBounds.IsEmpty then
  begin
    Height := Max(1, Round(24 * C.PPI / 96)); X := L.LegendBounds.Left; Y := L.LegendBounds.Top;
    Width := L.LegendBounds.Width;
    if C.Model.Legend.Position in [nclpTop, nclpBottom] then Width := Min(Width, Max(Round(100 * C.PPI / 96), Width div Max(1, C.Model.Series.Count)));
    for I := 0 to C.Model.Series.Count - 1 do
    begin
      Hit := TNimbusChartHit.None; Hit.Area := nchaLegend; Hit.SeriesIndex := I; Hit.Text := C.Model.Series[I].Name; Bounds := Rect(X, Y, X + Width, Y + Height);
      Box(Rect(X + 3, Y + Height div 3, X + Height div 2, Y + Height * 2 div 3), Color(I, C.Model.Series[I].Color), Hit, 2);
      Text(C.Model.Series[I].Name, Rect(X + Height, Y, X + Width, Y + Height), ChartForeColor(C), Hit, Flags);
      if C.Model.Legend.Position in [nclpLeft, nclpRight] then Inc(Y, Height) else Inc(X, Width);
    end;
  end;
end;

destructor TNimbusChartPrimitiveBuilder.Destroy;
begin FItems.Free; inherited end;

function TNimbusChartPrimitiveBuilder.NewPrimitive(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor; const Hit: TNimbusChartHit): TNimbusChartPrimitive;
begin
  Result := Default(TNimbusChartPrimitive); Result.Kind := Kind; Result.Color := Color; Result.Hit := Hit; Result.Width := Max(1.0, FContext.PPI / 96);
  if not FClipBounds.IsEmpty then begin Result.UseClip := True; Result.ClipBounds := FClipBounds end;
  if not FContext.Enabled then Result.Color := NimbusBlendColor(Color, ChartBackColor(FContext), 160);
end;

procedure TNimbusChartPrimitiveBuilder.Box(const Bounds: TRect; const Color: TThemeColor; const Hit: TNimbusChartHit; const Radius: Single; const Outline: Boolean);
var A: TNimbusChartPrimitive;
begin
  if Bounds.IsEmpty then Exit; A := NewPrimitive(ncpRect, Color, Hit); if Outline then A.Kind := ncpOutlineRect;
  A.Bounds := Bounds; A.UseCornerRadius := True; A.CornerRadius := Radius; FItems.Add(A);
end;

procedure TNimbusChartPrimitiveBuilder.Ellipse(const Bounds: TRect; const Color: TThemeColor; const Hit: TNimbusChartHit; const Outline: Boolean);
var A: TNimbusChartPrimitive;
begin if Bounds.IsEmpty then Exit; A := NewPrimitive(ncpEllipse, Color, Hit); if Outline then A.Kind := ncpOutlineEllipse; A.Bounds := Bounds; FItems.Add(A) end;

procedure TNimbusChartPrimitiveBuilder.Text(const Value: string; const Bounds: TRect; const Color: TThemeColor; const Hit: TNimbusChartHit; const Flags: TNimbusTextFlags);
var A: TNimbusChartPrimitive; TextClip: TRect;
begin
  if (Value = '') or Bounds.IsEmpty then Exit;
  TextClip := Bounds;
  if not FClipBounds.IsEmpty then
    if not IntersectRect(TextClip, Bounds, FClipBounds) then Exit;
  A := NewPrimitive(ncpText, Color, Hit); A.Text := Value; A.Bounds := Bounds; A.TextFlags := Flags;
  A.UseClip := True; A.ClipBounds := TextClip; FItems.Add(A);
end;

procedure TNimbusChartPrimitiveBuilder.Line(const Points: TArray<TPointF>; const Color: TThemeColor; const Width: Single; const Hit: TNimbusChartHit);
var A: TNimbusChartPrimitive;
begin if Length(Points) < 2 then Exit; A := NewPrimitive(ncpLine, Color, Hit); A.Points := Points; A.Width := Max(0.1, Width); FItems.Add(A) end;

procedure TNimbusChartPrimitiveBuilder.Polygon(const Points: TArray<TPointF>; const Color: TThemeColor; const Hit: TNimbusChartHit);
var A: TNimbusChartPrimitive;
begin if Length(Points) < 3 then Exit; A := NewPrimitive(ncpPolygon, Color, Hit); A.Points := Points; FItems.Add(A) end;

procedure TNimbusChartPrimitiveBuilder.Arc(const Bounds: TRect; const Color: TThemeColor; const Start, Sweep, Width: Single; const Hit: TNimbusChartHit);
var A: TNimbusChartPrimitive;
begin if Bounds.IsEmpty or (Sweep <= 0) then Exit; A := NewPrimitive(ncpArc, Color, Hit); A.Bounds := Bounds; A.StartAngle := Start; A.SweepAngle := Min(360.0, Sweep); A.Width := Max(0.1, Width); FItems.Add(A) end;

function TNimbusChartPrimitiveBuilder.Color(const Index: Integer; const CustomColor: TColor): TThemeColor;
begin
  if CustomColor <> clNone then Result := ColorToThemeColor(CustomColor)
  else if FContext.ChartPalette <> nil then Result := ColorToThemeColor(FContext.ChartPalette.GetSeriesColor(Index)) else Result := ChartAccentColor(FContext);
  if (CustomColor <> clNone) and (FContext.ColorInfluence > 0) then Result := NimbusBlendColor(Result, ChartAccentColor(FContext), FContext.ColorInfluence);
end;

function TNimbusChartPrimitiveBuilder.Finish: TArray<TNimbusChartPrimitive>;
begin Result := FItems.ToArray end;

end.

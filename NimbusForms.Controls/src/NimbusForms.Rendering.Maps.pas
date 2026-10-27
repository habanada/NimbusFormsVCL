{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Maps;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusMapChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

implementation

uses System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics,
  NimbusForms.Rendering.ChartPrimitives, NimbusForms.Charts.Maps.Data, NimbusForms.Charts.Sparkline.Types,
  NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusMapChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType in [nctChoroplethMap, nctCountryMap] end;

function TNimbusMapChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
type TDataPoint = record SeriesIndex, PointIndex, ColorIndex: Integer; Point: TNimbusChartPoint end;
var Shapes: TArray<TNimbusMapShape>; Shape, WorldShape: TNimbusMapShape; Cities: TArray<TNimbusMapCity>; City: TNimbusMapCity;
  Builder: TNimbusChartPrimitiveBuilder; Data: TDictionary<string, TDataPoint>; DP: TDataPoint; I, J, P, R, K, N, DataColorIndex: Integer;
  Ring, Polygon: TArray<TPointF>; XCenter: TPointF; V, Minimum, Maximum, Scale, X, Y, W, H, Zoom, Left, Top, Right, Bottom, Radius: Double;
  Bounds, MapBounds: TRectF; Hit: TNimbusChartHit; Col, LowColor, HighColor: TThemeColor; O: TNimbusChartOptions;
  IsCountry, Found, ShowShape: Boolean; Point: TNimbusChartPoint; TextBounds: TRect;
  function InRegion(const Region: string): Boolean;
  begin
    case O.MapRegion of
      ncmrEurope: Result := SameText(Region, 'Europe'); ncmrAfrica: Result := SameText(Region, 'Africa');
      ncmrNorthAmerica: Result := SameText(Region, 'North America'); ncmrSouthAmerica: Result := SameText(Region, 'South America');
      ncmrAmericas: Result := SameText(Region, 'North America') or SameText(Region, 'South America');
      ncmrAsia: Result := SameText(Region, 'Asia'); ncmrOceania: Result := SameText(Region, 'Oceania');
    else Result := True end;
  end;
  function Project(const Point: TPointF): TPointF;
  begin Result := TPointF.Create(X + (Point.X - Bounds.Left) * Scale, Y + (Bounds.Bottom - Point.Y) * Scale) end;
  function Key(const Value: string): string;
  begin Result := UpperCase(Trim(Value)) end;
begin
  Result := nil; if C.Model = nil then Exit; O := C.Model.Options; IsCountry := C.Model.ChartType = nctCountryMap;
  Builder := TNimbusChartPrimitiveBuilder.Create(C, L); Data := TDictionary<string, TDataPoint>.Create;
  try
    Builder.ClipBounds := L.PlotArea;
    if IsCountry then Shapes := NimbusCountryMapShapes(O.CountryMapIsoA3) else Shapes := NimbusWorldMapShapes;
    if IsCountry and (Length(Shapes) = 0) then
      for WorldShape in NimbusWorldMapShapes do if SameText(WorldShape.Code, O.CountryMapIsoA3) then begin Shapes := [WorldShape]; Break end;
    Left := MaxDouble; Top := MaxDouble; Right := -MaxDouble; Bottom := -MaxDouble;
    for Shape in Shapes do if IsCountry or InRegion(Shape.Region) then
    begin
      if (not IsCountry) and (O.MapRegion = ncmrWorld) and SameText(Shape.Code, 'ATA') then Continue;
      Left := Min(Left, Shape.Bounds.Left); Top := Min(Top, Shape.Bounds.Top); Right := Max(Right, Shape.Bounds.Right); Bottom := Max(Bottom, Shape.Bounds.Bottom);
    end;
    if (Left >= Right) or (Top >= Bottom) or L.PlotArea.IsEmpty then begin Result := Builder.Finish; Exit end;
    Bounds := TRectF.Create(Left, Top, Right, Bottom); Minimum := MaxDouble; Maximum := -MaxDouble; DataColorIndex := 0;
    for I := 0 to C.Model.Series.Count - 1 do if C.Model.Series[I].Visible then for J := 0 to C.Model.Series[I].Points.Count - 1 do
    begin
      Point := C.Model.Series[I].Points[J]; if not Point.Visible or not SparklineFinite(Point.YValue) then Continue;
      DP.SeriesIndex := I; DP.PointIndex := J; DP.ColorIndex := DataColorIndex; Inc(DataColorIndex); DP.Point := Point; Data.AddOrSetValue(Key(Point.&Label), DP); Minimum := Min(Minimum, Point.YValue); Maximum := Max(Maximum, Point.YValue);
    end;
    if Minimum = MaxDouble then begin Minimum := 0; Maximum := 1 end;
    LowColor := NimbusBlendColor(ChartAccentColor(C), ChartBackColor(C), 210); HighColor := ChartAccentColor(C);
    Zoom := EnsureRange(O.MapZoom, 0.1, 20.0); Scale := Min(L.PlotArea.Width / Bounds.Width, L.PlotArea.Height / Bounds.Height) * Zoom;
    W := Bounds.Width * Scale; H := Bounds.Height * Scale;
    X := L.PlotArea.Left + (L.PlotArea.Width - W) / 2 + O.MapOffsetX * L.PlotArea.Width; Y := L.PlotArea.Top + (L.PlotArea.Height - H) / 2 + O.MapOffsetY * L.PlotArea.Height;
    MapBounds := TRectF.Create(X, Y, X + W, Y + H);
    for I := 0 to High(Shapes) do
    begin
      Shape := Shapes[I]; if not IsCountry and not InRegion(Shape.Region) then Continue;
      if not IsCountry and (O.MapRegion = ncmrWorld) and SameText(Shape.Code, 'ATA') then Continue;
      Found := Data.TryGetValue(Key(Shape.Code), DP); if not Found then Found := Data.TryGetValue(Key(Shape.Name), DP);
      Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.ElementIndex := I; Hit.Text := Shape.Name;
      Col := NimbusBlendColor(ChartBorderColor(C), ChartBackColor(C), 200);
      if O.MapEmptyColor <> clNone then Col := ColorToThemeColor(O.MapEmptyColor);
      if Found then
      begin
        Hit.SeriesIndex := DP.SeriesIndex; Hit.PointIndex := DP.PointIndex; Hit.YValue := DP.Point.YValue; Hit.XValue := DP.Point.XValue; Hit.Text := DP.Point.ToolTipText;
        if Hit.Text = '' then Hit.Text := Shape.Name + sLineBreak + 'Value: ' + SparklineFormatValue(DP.Point.YValue, C.Model.Series[DP.SeriesIndex].ValueFormat);
        V := 0.5; if Maximum > Minimum then V := EnsureRange((DP.Point.YValue - Minimum) / (Maximum - Minimum), 0.0, 1.0);
        Col := NimbusBlendColor(LowColor, HighColor, Round(V * 255));
        if O.MapColorMode = ncmCategorical then Col := ColorToThemeColor(C.Model.Palette.GetSeriesColor(DP.ColorIndex));
        if DP.Point.Color <> clNone then Col := ColorToThemeColor(DP.Point.Color);
      end;
      ShowShape := not IsCountry or O.CountryMapShowRegions;
      for P := 0 to High(Shape.Polygons) do
      begin
        Polygon := nil;
        for R := 0 to High(Shape.Polygons[P]) do
        begin
          Ring := Copy(Shape.Polygons[P][R]); if Length(Ring) < 3 then Continue; N := Length(Polygon); SetLength(Polygon, N + Length(Ring) + 2);
          for K := 0 to High(Ring) do Polygon[N + K] := Project(Ring[K]); Polygon[N + Length(Ring)] := Project(Ring[0]);
          Polygon[N + Length(Ring) + 1] := Polygon[0];
        end;
        if ShowShape then Builder.Polygon(Polygon, Col, Hit);
        if not IsCountry or O.CountryMapShowRegionBorders then for R := 0 to High(Shape.Polygons[P]) do
        begin
          Ring := Copy(Shape.Polygons[P][R]); if Length(Ring) < 3 then Continue;
          for K := 0 to High(Ring) do Ring[K] := Project(Ring[K]);
          SetLength(Ring, Length(Ring) + 1); Ring[High(Ring)] := Ring[0]; Builder.Line(Ring, ChartBorderColor(C), Max(0.4, C.PPI / 192), TNimbusChartHit.None);
        end;
      end;
      if IsCountry and O.CountryMapShowRegionLabels then
      begin
        XCenter := Project(TPointF.Create((Shape.Bounds.Left + Shape.Bounds.Right) / 2, (Shape.Bounds.Top + Shape.Bounds.Bottom) / 2));
        TextBounds := Rect(Round(XCenter.X - 50 * C.PPI / 96), Round(XCenter.Y - 10 * C.PPI / 96), Round(XCenter.X + 50 * C.PPI / 96), Round(XCenter.Y + 10 * C.PPI / 96));
        Builder.Text(Shape.Name, TextBounds, ChartForeColor(C), Hit, [ntfVCenter, ntfSingleLine, ntfCenter, ntfEndEllipsis, ntfNoPrefix]);
      end;
    end;
    if IsCountry and O.CountryMapShowCities then
    begin
      Cities := NimbusCountryMapCities(O.CountryMapIsoA3, O.CountryMapMaxCities, O.CountryMapCityMinPopulation);
      for I := 0 to High(Cities) do
      begin
        City := Cities[I]; XCenter := Project(TPointF.Create(City.Longitude, City.Latitude)); Radius := EnsureRange(Log10(Max(10, City.Population)) - 3, 2.0, 6.0) * C.PPI / 96;
        Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.ElementIndex := -I - 2; Hit.XValue := City.Longitude; Hit.YValue := City.Latitude; Hit.Text := City.Name + sLineBreak + 'Population: ' + IntToStr(City.Population);
        Builder.Ellipse(Rect(Round(XCenter.X - Radius), Round(XCenter.Y - Radius), Round(XCenter.X + Radius), Round(XCenter.Y + Radius)), ChartAccentColor(C), Hit);
        if O.CountryMapShowCityLabels then Builder.Text(City.Name, Rect(Round(XCenter.X + Radius + 3), Round(XCenter.Y - 11 * C.PPI / 96), Round(XCenter.X + Radius + 110 * C.PPI / 96), Round(XCenter.Y + 11 * C.PPI / 96)), ChartForeColor(C), Hit, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
      end;
    end;
    Result := Builder.Finish;
  finally Data.Free; Builder.Free end;
end;

end.

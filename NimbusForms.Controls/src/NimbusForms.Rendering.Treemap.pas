{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Treemap;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types, NimbusForms.Charts.Treemap.Types;

type
  TNimbusTreemapChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
    function GetTiles(const C: TNimbusChartRenderContext; const Plot: TRect): TArray<TNimbusTreemapTileInfo>;
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit; override;
  end;

implementation

uses Winapi.Windows, System.Classes, System.SysUtils, System.StrUtils, System.Math, System.Generics.Collections, Vcl.Graphics,
  NimbusForms.Charts.Sparkline.Types, NimbusForms.Theming.Types, NimbusForms.Rendering.Types, NimbusForms.Charts.Hierarchy;

type TTreeNode = TNimbusHierarchyNode;

function Related(const Path, Branch: string): Boolean;
begin Result := (Branch = '') or SameText(Path, Branch) or StartsText(Branch + '/', Path) end;

function TNimbusTreemapChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctTreemap end;

function TNimbusTreemapChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var Pad: Integer;
begin
  Result := inherited Arrange(C); if C.Model = nil then Exit; Pad := Round(C.Model.TreemapOptions.Padding * Max(1, C.PPI) / 96);
  InflateRect(Result.PlotArea, -Pad, -Pad); if C.Model.TreemapOptions.ShowBreadcrumb then Dec(Result.PlotArea.Bottom, Round(26 * Max(1, C.PPI) / 96));
  Result.PlotArea.Right := Max(Result.PlotArea.Left, Result.PlotArea.Right); Result.PlotArea.Bottom := Max(Result.PlotArea.Top, Result.PlotArea.Bottom);
end;

function TNimbusTreemapChartRenderer.GetTiles(const C: TNimbusChartRenderContext; const Plot: TRect): TArray<TNimbusTreemapTileInfo>;
var Root, VisibleRoot: TTreeNode; O: TNimbusTreemapOptions; DPI, RootTotal: Double; SingleTile: TNimbusTreemapTileInfo;
  function Layout(const Parent: TTreeNode; const Bounds: TRectF): TArray<TRectF>;
  var Sizes, Row: TArray<Double>; Total, Cursor, Area, Side, Sum, Height, Width, X, Y: Double;
    Remaining: TRectF; Index, Count, First, K, N: Integer; Horizontal: Boolean;
    function Worst(const Values: TArray<Double>; const Added, Edge: Double): Double;
    var Value, Minimum, Maximum, Sum: Double;
    begin
      Sum := 0; Minimum := Infinity; Maximum := 0;
      for Value in Values do begin Sum := Sum + Value; Minimum := Min(Minimum, Value); Maximum := Max(Maximum, Value) end;
      if Added > 0 then begin Sum := Sum + Added; Minimum := Min(Minimum, Added); Maximum := Max(Maximum, Added) end;
      Result := MaxDouble; if (Edge > 0) and (Minimum > 0) and (Sum > 0) then Result := Max(Sqr(Edge) * Maximum / Sqr(Sum), Sqr(Sum) / (Sqr(Edge) * Minimum));
    end;
    procedure Flush;
    var J: Integer; V: Double;
    begin
      Sum := 0; for V in Row do Sum := Sum + V; if (Sum <= 0) or (Remaining.Width <= 0) or (Remaining.Height <= 0) then Exit;
      if Remaining.Width >= Remaining.Height then
      begin
        Height := Sum / Remaining.Width; X := Remaining.Left;
        for J := 0 to High(Row) do begin Width := Row[J] / Height; if J = High(Row) then Width := Remaining.Right - X; Result[First + J] := TRectF.Create(X, Remaining.Top, X + Width, Remaining.Top + Height); X := X + Width end;
        Remaining.Top := Remaining.Top + Height;
      end
      else
      begin
        Width := Sum / Remaining.Height; Y := Remaining.Top;
        for J := 0 to High(Row) do begin Height := Row[J] / Width; if J = High(Row) then Height := Remaining.Bottom - Y; Result[First + J] := TRectF.Create(Remaining.Left, Y, Remaining.Left + Width, Y + Height); Y := Y + Height end;
        Remaining.Left := Remaining.Left + Width;
      end;
      Inc(First, Length(Row)); Row := nil;
    end;
  begin
    Count := Parent.Children.Count; SetLength(Result, Count); Total := 0; for K := 0 to Count - 1 do Total := Total + Parent.Children[K].Value; if Total <= 0 then Exit;
    if O.LayoutMode <> ntlSquarified then
    begin
      Horizontal := (O.LayoutMode = ntlHorizontal) or ((O.LayoutMode = ntlSliceAndDice) and (Bounds.Width >= Bounds.Height)); Cursor := Bounds.Top; if Horizontal then Cursor := Bounds.Left;
      for K := 0 to Count - 1 do
      begin
        Area := Parent.Children[K].Value / Total;
        if Horizontal then begin Width := Bounds.Width * Area; if K = Count - 1 then Width := Bounds.Right - Cursor; Result[K] := TRectF.Create(Cursor, Bounds.Top, Cursor + Width, Bounds.Bottom); Cursor := Cursor + Width end
        else begin Height := Bounds.Height * Area; if K = Count - 1 then Height := Bounds.Bottom - Cursor; Result[K] := TRectF.Create(Bounds.Left, Cursor, Bounds.Right, Cursor + Height); Cursor := Cursor + Height end;
      end; Exit;
    end;
    SetLength(Sizes, Count); for K := 0 to Count - 1 do Sizes[K] := Parent.Children[K].Value / Total * Bounds.Width * Bounds.Height;
    Row := nil; Remaining := Bounds; First := 0; Index := 0;
    while Index < Count do
    begin
      Side := Min(Remaining.Width, Remaining.Height);
      if (Length(Row) = 0) or (Worst(Row, 0, Side) >= Worst(Row, Sizes[Index], Side)) then begin N := Length(Row); SetLength(Row, N + 1); Row[N] := Sizes[Index]; Inc(Index) end else Flush;
    end;
    if Length(Row) > 0 then Flush;
  end;
  procedure Place(const Parent: TTreeNode; const Bounds: TRectF; Depth: Integer);
  var Content, R: TRectF; Rects: TArray<TRectF>; Tile: TNimbusTreemapTileInfo; Child: TTreeNode; K, N: Integer; Gap, Header: Double;
  begin
    if (Depth >= O.MaximumDepth) or (Parent.Children.Count = 0) then Exit; Content := Bounds;
    if (Depth > 0) and O.ShowHeaders then Content.Top := Content.Top + Min(O.HeaderHeight * DPI, Content.Height * 0.28);
    Gap := O.TileGap * DPI; if Depth > 0 then Gap := O.GroupGap * DPI; Content.Inflate(-Gap, -Gap);
    if (Content.Width <= 1) or (Content.Height <= 1) then Exit; Rects := Layout(Parent, Content);
    for K := 0 to Parent.Children.Count - 1 do
    begin
      Child := Parent.Children[K]; R := Rects[K]; if (R.Width < O.MinimumTileSize * DPI) or (R.Height < O.MinimumTileSize * DPI) then Continue;
      R.Inflate(-O.TileGap * DPI / 2, -O.TileGap * DPI / 2); Tile := Default(TNimbusTreemapTileInfo);
      Tile.Name := Child.Name; Tile.Path := Child.Path; Tile.Depth := Depth + 1; Tile.SeriesIndex := Child.SeriesIndex; Tile.PointIndex := Child.PointIndex; Tile.Tag := Child.Tag;
      Tile.Value := Child.Value; Tile.RootTotal := RootTotal; Tile.ParentTotal := Parent.Value; Tile.IsLeaf := Child.Children.Count = 0;
      Tile.Bounds := Rect(Round(R.Left), Round(R.Top), Round(R.Right), Round(R.Bottom)); Tile.ContentBounds := Tile.Bounds; Tile.Color := Child.Color;
      if O.ShowHeaders and not Tile.IsLeaf then
      begin Header := Min(O.HeaderHeight * DPI, R.Height); Tile.HeaderBounds := Rect(Tile.Bounds.Left, Tile.Bounds.Top, Tile.Bounds.Right, Tile.Bounds.Top + Round(Header)); Tile.ContentBounds.Top := Tile.HeaderBounds.Bottom end;
      Tile.ToolTipText := Child.ToolTipText;
      if Tile.ToolTipText = '' then begin Tile.ToolTipText := Tile.Name + sLineBreak + 'Value: ' + SparklineFormatValue(Tile.Value, O.ValueFormat); if RootTotal > 0 then Tile.ToolTipText := Tile.ToolTipText + sLineBreak + 'Share: ' + SparklineFormatValue(Tile.Value / RootTotal * 100, StringReplace(O.PercentFormat, '%', '', [rfReplaceAll])) + '%'; Tile.ToolTipText := Tile.ToolTipText + sLineBreak + 'Path: ' + Tile.Path end;
      N := Length(Result); SetLength(Result, N + 1); Result[N] := Tile; if not Tile.IsLeaf then Place(Child, Rects[K], Depth + 1);
    end;
  end;
begin
  Result := nil; if (C.Model = nil) or Plot.IsEmpty then Exit; O := C.Model.TreemapOptions; DPI := Max(1, C.PPI) / 96;
  if O.SortDescending then Root := NimbusBuildHierarchy(C.Model, C.ChartPalette, O.PathSeparator, False, True, False, nhsDescending, C.ColorInfluence, C.Enabled, ChartAccentColor(C), ChartBackColor(C))
  else Root := NimbusBuildHierarchy(C.Model, C.ChartPalette, O.PathSeparator, False, True, False, nhsAscending, C.ColorInfluence, C.Enabled, ChartAccentColor(C), ChartBackColor(C));
  try
    VisibleRoot := Root.Find(O.ZoomPath); if VisibleRoot = nil then VisibleRoot := Root; RootTotal := VisibleRoot.Value;
    if (VisibleRoot.Children.Count > 0) and (RootTotal > 0) then Place(VisibleRoot, TRectF.Create(Plot.Left, Plot.Top, Plot.Right, Plot.Bottom), 0)
    else if (VisibleRoot <> Root) and (RootTotal > 0) then
    begin
      SingleTile := Default(TNimbusTreemapTileInfo); SingleTile.Name := VisibleRoot.Name; SingleTile.Path := VisibleRoot.Path; SingleTile.Bounds := Plot; SingleTile.ContentBounds := Plot;
      SingleTile.SeriesIndex := VisibleRoot.SeriesIndex; SingleTile.PointIndex := VisibleRoot.PointIndex; SingleTile.Tag := VisibleRoot.Tag; SingleTile.Value := RootTotal; SingleTile.RootTotal := RootTotal;
      SingleTile.ParentTotal := RootTotal; SingleTile.IsLeaf := True; SingleTile.Color := VisibleRoot.Color; SingleTile.ToolTipText := VisibleRoot.ToolTipText;
      if SingleTile.ToolTipText = '' then SingleTile.ToolTipText := SingleTile.Name + sLineBreak + 'Value: ' + SparklineFormatValue(RootTotal, O.ValueFormat) + sLineBreak + 'Path: ' + SingleTile.Path;
      Result := [SingleTile];
    end;
  finally Root.Free end;
end;

function TNimbusTreemapChartRenderer.HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
var L: TNimbusChartLayout; Tiles: TArray<TNimbusTreemapTileInfo>; Tile: TNimbusTreemapTileInfo; Bounds: TRect; I, Best: Integer; Area, BestArea, DPI, InsetX, InsetY: Double;
begin
  Result := TNimbusChartHit.None; Result.Location := Location; if C.Model = nil then Exit; L := Arrange(C); Tiles := GetTiles(C, L.PlotArea); DPI := Max(1, C.PPI) / 96; Best := -1; BestArea := MaxDouble;
  for I := 0 to High(Tiles) do
  begin
    Tile := Tiles[I]; if not C.Model.TreemapOptions.AllowParentTiles and not Tile.IsLeaf then Continue;
    Bounds := Tile.ContentBounds; if Bounds.IsEmpty then Bounds := Tile.Bounds;
    InsetX := Max(2.5, Max(C.Model.TreemapOptions.TileGap, C.Model.TreemapOptions.GroupGap) + 1.5) * DPI; InsetY := InsetX;
    if Bounds.Width <= InsetX * 3 then InsetX := Max(0.75, Bounds.Width * 0.12); if Bounds.Height <= InsetY * 3 then InsetY := Max(0.75, Bounds.Height * 0.12);
    InflateRect(Bounds, -Ceil(InsetX), -Ceil(InsetY)); if not Bounds.Contains(Point(Round(Location.X), Round(Location.Y))) then Continue;
    Area := Tile.Bounds.Width * Tile.Bounds.Height; if Area < BestArea then begin Best := I; BestArea := Area end;
  end;
  if Best < 0 then Exit(inherited HitTest(C, Location)); Tile := Tiles[Best]; Result.Area := nchaSegment; Result.SeriesIndex := Tile.SeriesIndex; Result.PointIndex := Tile.PointIndex; Result.ElementIndex := Best; Result.YValue := Tile.Value; Result.Text := Tile.ToolTipText;
end;

function TNimbusTreemapChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var Tiles: TArray<TNimbusTreemapTileInfo>; Tile: TNimbusTreemapTileInfo; O: TNimbusTreemapOptions; A: TNimbusChartPrimitive;
  Fore, Back, Col, TextCol: TThemeColor; I, N: Integer; DPI, Share: Double; HoverPath, LabelText, ValueText, ShareText: string; Hovered, Selected, Marked, CompactAuto: Boolean; Bounds: TRect; Mode: TNimbusTreemapLabelMode;
  procedure Init(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor);
  begin A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Width := DPI; A.Hit := TNimbusChartHit.None; A.UseCornerRadius := True end;
  procedure Add;
  var Count: Integer;
  begin Count := Length(Result); SetLength(Result, Count + 1); Result[Count] := A end;
  procedure Text(const Value: string; const R: TRect; const Color: TThemeColor; Wrap: Boolean = False);
  begin Init(ncpText, Color); A.Text := Value; A.Bounds := R; A.TextFlags := [ntfEndEllipsis, ntfNoPrefix]; if Wrap then Include(A.TextFlags, ntfWordWrap) else begin Include(A.TextFlags, ntfSingleLine); Include(A.TextFlags, ntfVCenter) end; Add end;
begin
  Result := inherited Build(C, L); if C.Model = nil then Exit; O := C.Model.TreemapOptions; DPI := Max(1, C.PPI) / 96; Fore := ChartForeColor(C); Back := ChartBackColor(C); Tiles := GetTiles(C, L.PlotArea); HoverPath := '';
  if (C.Hovered.ElementIndex >= 0) and (C.Hovered.ElementIndex < Length(Tiles)) and (C.Hovered.Area = nchaSegment) then HoverPath := Tiles[C.Hovered.ElementIndex].Path;
  for I := 0 to High(Tiles) do
  begin
    Tile := Tiles[I]; Col := Tile.Color; Hovered := SameText(Tile.Path, HoverPath); Selected := O.EnableSelection and (C.Selected.Area = nchaSegment) and (C.Selected.ElementIndex = I);
    Marked := O.EnableMarking and (O.MarkedPath <> '') and (O.MarkingMode <> ntmNone) and (SameText(Tile.Path, O.MarkedPath) or ((O.MarkingMode = ntmBranch) and Related(Tile.Path, O.MarkedPath)));
    if O.EnableHoverFocus and (HoverPath <> '') and not Related(Tile.Path, HoverPath) and not Related(HoverPath, Tile.Path) then Col := NimbusBlendColor(Col, Back, Round(O.HoverDimOpacity * 255));
    if Hovered then Col := NimbusBlendColor(Col, $FFFFFFFF, 36); if Marked or Selected then Col := NimbusBlendColor(Col, $FFFFFFFF, 20);
    Init(ncpRect, Col); A.Bounds := Tile.Bounds; A.CornerRadius := Min(O.CornerRadius * DPI, Min(Tile.Bounds.Width, Tile.Bounds.Height) / 4); Add;
    if O.ShowGroupShading and not Tile.IsLeaf then begin A.Color := $0CFFFFFF; Add end;
    if O.ShowTileSheen and (Tile.Bounds.Height > 24 * DPI) then begin Init(ncpRect, $12FFFFFF); A.Bounds := Tile.Bounds; A.Bounds.Bottom := A.Bounds.Top + Round(Tile.Bounds.Height * 0.32); A.CornerRadius := O.CornerRadius * DPI; Add end;
    Init(ncpOutlineRect, NimbusColorWithAlpha(Back, 34)); A.Bounds := Tile.Bounds; A.CornerRadius := O.CornerRadius * DPI; Add;
    if Hovered or Marked or Selected then begin A.Color := $B9FFFFFF; Add; if Marked or Selected then begin A.Color := NimbusColorWithAlpha(ChartAccentColor(C), 145); InflateRect(A.Bounds, Round(1.5 * DPI), Round(1.5 * DPI)); Add end end;
    if not O.ShowLabels then Continue; Bounds := Tile.ContentBounds; InflateRect(Bounds, -Round(8 * DPI), -Round(6 * DPI));
    TextCol := $FFFFFFFF; if (((Col shr 16) and 255) * 299 + ((Col shr 8) and 255) * 587 + (Col and 255) * 114) / 1000 >= 150 then TextCol := NimbusColorWithAlpha(Fore, 230);
    if (Bounds.Width >= O.MinimumLabelWidth * DPI) and (Bounds.Height >= O.MinimumLabelHeight * DPI) then
    begin
      ValueText := SparklineFormatValue(Tile.Value, O.ValueFormat); Share := 0; if Tile.RootTotal > 0 then Share := Tile.Value / Tile.RootTotal;
      ShareText := SparklineFormatValue(Share * 100, StringReplace(O.PercentFormat, '%', '', [rfReplaceAll])) + '%'; Mode := O.LabelMode; CompactAuto := (Mode = nttAuto) and (Tile.Bounds.Height < 46 * DPI) and (Tile.Bounds.Height >= 28 * DPI) and (Tile.Bounds.Width >= 58 * DPI);
      if Mode = nttAuto then if (Tile.Bounds.Height >= 46 * DPI) and (Tile.Bounds.Width >= 92 * DPI) then Mode := nttNameValueAndPercent else if Tile.Bounds.Height >= 28 * DPI then Mode := nttNameAndValue else Mode := nttName;
      LabelText := Tile.Name; if (Mode <> nttName) and O.ShowValues then LabelText := LabelText + sLineBreak + ValueText;
      if (Mode = nttNameValueAndPercent) and O.ShowPercent then LabelText := LabelText + sLineBreak + ShareText
      else if (Mode = nttNameAndValue) and not O.ShowValues and O.ShowPercent then LabelText := LabelText + sLineBreak + ShareText;
      if CompactAuto and O.ShowValues and O.ShowPercent then LabelText := Tile.Name + sLineBreak + ValueText + '  ' + ShareText;
      if (O.LabelMode = nttAuto) and (Mode = nttName) and O.ShowPercent and (Tile.Bounds.Width >= 46 * DPI) and (Tile.Bounds.Height >= 18 * DPI) then LabelText := Tile.Name + '  ' + ShareText;
      Text(LabelText, Bounds, TextCol, True);
    end;
    if O.ShowHeaders and not Tile.HeaderBounds.IsEmpty and (Tile.HeaderBounds.Width >= 50 * DPI) then begin Bounds := Tile.HeaderBounds; InflateRect(Bounds, -Round(7 * DPI), 0); Text(Tile.Name, Bounds, TextCol) end;
  end;
  if O.ShowBreadcrumb then
  begin LabelText := 'All'; if O.ZoomPath <> '' then LabelText := LabelText + ' / ' + StringReplace(O.ZoomPath, '/', ' / ', [rfReplaceAll]); Text(LabelText, Rect(L.PlotArea.Left, L.PlotArea.Bottom + Round(7 * DPI), L.PlotArea.Right, L.PlotArea.Bottom + Round(27 * DPI)), NimbusColorWithAlpha(Fore, 175)) end;
  if O.ShowZoomBadge and (O.ZoomPath <> '') then
  begin Bounds := Rect(L.PlotArea.Right - Round(180 * DPI), L.PlotArea.Top + Round(8 * DPI), L.PlotArea.Right - Round(8 * DPI), L.PlotArea.Top + Round(32 * DPI)); Init(ncpRect, NimbusColorWithAlpha(Back, 210)); A.Bounds := Bounds; A.CornerRadius := 12 * DPI; Add; Text('Zoom: ' + O.ZoomPath, Bounds, Fore) end;
  if (Length(Tiles) = 0) and O.ShowEmptyState then Text('No treemap data', L.PlotArea, NimbusColorWithAlpha(Fore, 150));
end;

end.

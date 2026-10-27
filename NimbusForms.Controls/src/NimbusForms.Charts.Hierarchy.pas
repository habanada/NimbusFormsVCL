{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Hierarchy;

interface

uses System.Generics.Collections, NimbusForms.Charts.Types, NimbusForms.Theming.Types;

type
  TNimbusHierarchySortMode = (nhsNone, nhsAscending, nhsDescending);
  TNimbusHierarchyNode = class
  public
    Name, Path, ToolTipText: string;
    OwnValue, Value: Double;
    SeriesIndex, PointIndex: Integer;
    Tag: NativeInt;
    Color: TThemeColor;
    ExplicitColor: Boolean;
    Children: TObjectList<TNimbusHierarchyNode>;
    constructor Create;
    destructor Destroy; override;
    function Child(const AName: string): TNimbusHierarchyNode;
    function Find(const APath: string): TNimbusHierarchyNode;
    procedure Aggregate(const SortMode: TNimbusHierarchySortMode);
    function MaximumDepth: Integer;
  end;

function NimbusBuildHierarchy(Model: TNimbusChartModel; Palette: TNimbusChartPalette; const Separator: string;
  const SeriesGroups, PrefixPlainLabels, IntermediateSources: Boolean; const SortMode: TNimbusHierarchySortMode;
  const ThemeInfluence: Integer; const Enabled: Boolean; const Accent, Back: TThemeColor): TNimbusHierarchyNode;

implementation

uses System.SysUtils, System.Math, Vcl.Graphics, NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Types;

constructor TNimbusHierarchyNode.Create;
begin inherited; Children := TObjectList<TNimbusHierarchyNode>.Create(True); SeriesIndex := -1; PointIndex := -1 end;

destructor TNimbusHierarchyNode.Destroy;
begin Children.Free; inherited end;

function TNimbusHierarchyNode.Child(const AName: string): TNimbusHierarchyNode;
var Node: TNimbusHierarchyNode;
begin
  for Node in Children do if SameText(Node.Name, AName) then Exit(Node);
  Result := TNimbusHierarchyNode.Create; Result.Name := AName; Result.Path := AName; if Path <> '' then Result.Path := Path + '/' + AName; Children.Add(Result);
end;

function TNimbusHierarchyNode.Find(const APath: string): TNimbusHierarchyNode;
var Node: TNimbusHierarchyNode;
begin
  Result := nil; if SameText(Path, APath) then Exit(Self); for Node in Children do begin Result := Node.Find(APath); if Result <> nil then Exit end;
end;

procedure TNimbusHierarchyNode.Aggregate(const SortMode: TNimbusHierarchySortMode);
var Node: TNimbusHierarchyNode; I, J: Integer;
begin
  Value := OwnValue; for Node in Children do begin Node.Aggregate(SortMode); Value := Value + Node.Value; if Color = 0 then Color := Node.Color end;
  if SortMode = nhsNone then Exit;
  for I := 1 to Children.Count - 1 do
  begin
    J := I; while J > 0 do
    begin
      if SortMode = nhsDescending then begin if Children[J - 1].Value >= Children[J].Value then Break end
      else if Children[J - 1].Value <= Children[J].Value then Break;
      Children.Exchange(J - 1, J); Dec(J);
    end;
  end;
end;

function TNimbusHierarchyNode.MaximumDepth: Integer;
var Node: TNimbusHierarchyNode;
begin Result := 0; for Node in Children do Result := Max(Result, 1 + Node.MaximumDepth) end;

function NimbusBuildHierarchy(Model: TNimbusChartModel; Palette: TNimbusChartPalette; const Separator: string;
  const SeriesGroups, PrefixPlainLabels, IntermediateSources: Boolean; const SortMode: TNimbusHierarchySortMode;
  const ThemeInfluence: Integer; const Enabled: Boolean; const Accent, Back: TThemeColor): TNimbusHierarchyNode;
var Series: TNimbusChartSeries; Point: TNimbusChartPoint; Parent, Node: TNimbusHierarchyNode;
  I, J: Integer; Part, Path: string; Parts: TArray<string>; BaseColor, SeriesColor, Color: TThemeColor;
begin
  Result := TNimbusHierarchyNode.Create;
  try
    if Model <> nil then for I := 0 to Model.Series.Count - 1 do
    begin
      Series := Model.Series[I]; if not Series.Visible then Continue; BaseColor := Accent; if Palette <> nil then BaseColor := ColorToThemeColor(Palette.GetSeriesColor(I));
      SeriesColor := BaseColor;
      if Series.Color <> clNone then begin SeriesColor := ColorToThemeColor(Series.Color); if ThemeInfluence > 0 then SeriesColor := NimbusBlendColor(SeriesColor, BaseColor, Round(ThemeInfluence * 255 / 100)) end;
      if not Enabled then SeriesColor := NimbusBlendColor(SeriesColor, Back, 160);
      Parent := Result;
      if SeriesGroups then
      begin
        Parent := Result.Child(Series.Name); Parent.SeriesIndex := I; Parent.Tag := Series.Tag; Parent.Color := BaseColor;
        if Series.Color <> clNone then begin Parent.Color := ColorToThemeColor(Series.Color); Parent.ExplicitColor := True;
          if ThemeInfluence > 0 then Parent.Color := NimbusBlendColor(Parent.Color, BaseColor, Round(ThemeInfluence * 255 / 100)) end;
        if not Enabled then Parent.Color := NimbusBlendColor(Parent.Color, Back, 160);
      end;
      for J := 0 to Series.Points.Count - 1 do
      begin
        Point := Series.Points[J]; if not Point.Visible or not SparklineFinite(Point.YValue) or (Point.YValue <= 0) then Continue;
        Path := Point.&Label; if Path = '' then if IntermediateSources then Path := IntToStr(J) else Path := IntToStr(J + 1); Path := StringReplace(StringReplace(Path, '\', '/', [rfReplaceAll]), '|', '/', [rfReplaceAll]);
        if (Separator <> '') and (Separator <> '/') then Path := StringReplace(Path, Separator, '/', [rfReplaceAll]);
        if PrefixPlainLabels and (Pos('/', Path) = 0) and (Series.Name <> '') then Path := Series.Name + '/' + Path;
        Color := BaseColor; if Series.Color <> clNone then Color := ColorToThemeColor(Series.Color); if Point.Color <> clNone then Color := ColorToThemeColor(Point.Color);
        if (ThemeInfluence > 0) and ((Point.Color <> clNone) or (Series.Color <> clNone)) then Color := NimbusBlendColor(Color, BaseColor, Round(ThemeInfluence * 255 / 100));
        if not Enabled then Color := NimbusBlendColor(Color, Back, 160);
        Parts := Path.Split(['/']); Node := Parent;
        for Part in Parts do if Trim(Part) <> '' then
        begin
          Node := Node.Child(Trim(Part)); if IntermediateSources and (Node.SeriesIndex < 0) then begin Node.SeriesIndex := I; Node.Color := SeriesColor; Node.Tag := Series.Tag end;
        end;
        if Node = Parent then Node := Node.Child('Value');
        Node.OwnValue := Node.OwnValue + Point.YValue; Node.SeriesIndex := I; Node.PointIndex := J; Node.ToolTipText := Point.ToolTipText; Node.Tag := Point.Tag;
        Node.Color := Color; Node.ExplicitColor := Point.Color <> clNone;
      end;
    end;
    Result.Aggregate(SortMode);
  except Result.Free; raise end;
end;

end.

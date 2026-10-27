{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Treemap;

interface

uses Winapi.Windows, System.Classes, System.Types, Vcl.Controls, NimbusForms.Controls.Chart,
  NimbusForms.Charts.Treemap.Types, NimbusForms.Rendering.Charts, NimbusForms.Rendering.Treemap;

type
  TNimbusTreemapTileEvent = procedure(Sender: TObject; const Tile: TNimbusTreemapTileInfo; const Location: TPointF) of object;

  TThemedTreemapChart = class(TThemedChart)
  private
    FRenderer: INimbusChartRenderer;
    FSelectedPath: string;
    FTreemapRenderer: TNimbusTreemapChartRenderer;
    FOnTileHovered, FOnTileClicked, FOnTileSelected: TNimbusTreemapTileEvent;
    FOnZoomChanged, FOnMarkingChanged: TNotifyEvent;
    function GetOptions: TNimbusTreemapOptions;
    procedure SetOptions(const Value: TNimbusTreemapOptions);
    function GetEnableTreemapRichToolTip: Boolean;
    procedure SetEnableTreemapRichToolTip(const Value: Boolean);
    function GetEnableTreemapZoom: Boolean;
    procedure SetEnableTreemapZoom(const Value: Boolean);
    function GetZoomOnDoubleClick: Boolean;
    procedure SetZoomOnDoubleClick(const Value: Boolean);
    function GetZoomWithMouseWheel: Boolean;
    procedure SetZoomWithMouseWheel(const Value: Boolean);
    function GetEnableTreemapMarking: Boolean;
    procedure SetEnableTreemapMarking(const Value: Boolean);
    function GetMarkingMode: TNimbusTreemapMarkingMode;
    procedure SetMarkingMode(const Value: TNimbusTreemapMarkingMode);
    function GetLayoutMode: TNimbusTreemapLayoutMode;
    procedure SetLayoutMode(const Value: TNimbusTreemapLayoutMode);
    function GetZoomPath: string;
    procedure SetZoomPath(const Value: string);
    function GetMarkedPath: string;
    procedure SetMarkedPath(const Value: string);
    procedure EmitTile(const Hit: TNimbusChartHit; const Event: TNimbusTreemapTileEvent);
    function TileForHit(const Hit: TNimbusChartHit; out Tile: TNimbusTreemapTileInfo): Boolean;
  protected
    procedure SetSelected(const AHit: TNimbusChartHit); override;
    function KeepSelectionOnModelChange: Boolean; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetTiles: TArray<TNimbusTreemapTileInfo>;
    procedure ZoomToPath(const Path: string);
    procedure ZoomToParent;
    procedure ResetTreemapZoom;
    procedure MarkPath(const Path: string);
    procedure ClearMarking;
    procedure ResetView; override;
  published
    property EnableTreemapRichToolTip: Boolean read GetEnableTreemapRichToolTip write SetEnableTreemapRichToolTip default True;
    property EnableTreemapZoom: Boolean read GetEnableTreemapZoom write SetEnableTreemapZoom default True;
    property ZoomOnDoubleClick: Boolean read GetZoomOnDoubleClick write SetZoomOnDoubleClick default True;
    property ZoomWithMouseWheel: Boolean read GetZoomWithMouseWheel write SetZoomWithMouseWheel default True;
    property EnableTreemapMarking: Boolean read GetEnableTreemapMarking write SetEnableTreemapMarking default True;
    property MarkingMode: TNimbusTreemapMarkingMode read GetMarkingMode write SetMarkingMode default ntmBranch;
    property LayoutMode: TNimbusTreemapLayoutMode read GetLayoutMode write SetLayoutMode default ntlSquarified;
    property ZoomPath: string read GetZoomPath write SetZoomPath;
    property MarkedPath: string read GetMarkedPath write SetMarkedPath;
    property TreemapOptions: TNimbusTreemapOptions read GetOptions write SetOptions;
    property OnTreemapTileHovered: TNimbusTreemapTileEvent read FOnTileHovered write FOnTileHovered;
    property OnTreemapTileClicked: TNimbusTreemapTileEvent read FOnTileClicked write FOnTileClicked;
    property OnTreemapTileSelected: TNimbusTreemapTileEvent read FOnTileSelected write FOnTileSelected;
    property OnTreemapZoomChanged: TNotifyEvent read FOnZoomChanged write FOnZoomChanged;
    property OnTreemapMarkingChanged: TNotifyEvent read FOnMarkingChanged write FOnMarkingChanged;
  end;

implementation

uses System.SysUtils, System.Math, NimbusForms.Charts.Types;

constructor TThemedTreemapChart.Create(AOwner: TComponent);
begin inherited; FTreemapRenderer := TNimbusTreemapChartRenderer.Create; FRenderer := FTreemapRenderer; RendererFactory.RegisterFirst(FRenderer); ChartType := nctTreemap; ShowToolTip := True; TabStop := True end;

function TThemedTreemapChart.GetOptions: TNimbusTreemapOptions;
begin Result := Model.TreemapOptions end;

procedure TThemedTreemapChart.SetOptions(const Value: TNimbusTreemapOptions);
begin if Value <> nil then Model.TreemapOptions.Assign(Value) end;

function TThemedTreemapChart.GetTiles: TArray<TNimbusTreemapTileInfo>;
var C: TNimbusChartRenderContext; L: TNimbusChartLayout;
begin C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FTreemapRenderer.Arrange(C); Result := FTreemapRenderer.GetTiles(C, L.PlotArea) end;

function TThemedTreemapChart.TileForHit(const Hit: TNimbusChartHit; out Tile: TNimbusTreemapTileInfo): Boolean;
var Tiles: TArray<TNimbusTreemapTileInfo>;
begin Result := False; Tile := Default(TNimbusTreemapTileInfo); if Hit.Area <> nchaSegment then Exit; Tiles := GetTiles; if (Hit.ElementIndex >= 0) and (Hit.ElementIndex < Length(Tiles)) then begin Tile := Tiles[Hit.ElementIndex]; Result := True end end;

procedure TThemedTreemapChart.EmitTile(const Hit: TNimbusChartHit; const Event: TNimbusTreemapTileEvent);
var Tile: TNimbusTreemapTileInfo;
begin if Assigned(Event) and TileForHit(Hit, Tile) then Event(Self, Tile, Hit.Location) end;

procedure TThemedTreemapChart.SetSelected(const AHit: TNimbusChartHit);
var Changed: Boolean; Tile: TNimbusTreemapTileInfo;
begin
  if ChartType <> nctTreemap then begin inherited; Exit end; if (AHit.Area <> nchaNone) and not TreemapOptions.EnableSelection then Exit;
  Changed := not SelectedResult.SameElement(AHit); FSelectedPath := ''; if TileForHit(AHit, Tile) then FSelectedPath := Tile.Path; inherited; if Changed then EmitTile(AHit, FOnTileSelected);
end;

function TThemedTreemapChart.KeepSelectionOnModelChange: Boolean;
var Tile: TNimbusTreemapTileInfo;
begin Result := (FTreemapRenderer <> nil) and (ChartType = nctTreemap) and (FSelectedPath <> '') and TreemapOptions.EnableSelection; if Result then Result := TileForHit(SelectedResult, Tile) and SameText(Tile.Path, FSelectedPath) end;

procedure TThemedTreemapChart.ZoomToPath(const Path: string);
begin if not TreemapOptions.EnableZoom then Exit; ClearSelection; TreemapOptions.ZoomPath := Path; if Assigned(FOnZoomChanged) then FOnZoomChanged(Self) end;

procedure TThemedTreemapChart.ZoomToParent;
var Path: string; Index: Integer;
begin Path := TreemapOptions.ZoomPath; Index := LastDelimiter('/', Path); if Index <= 0 then Path := '' else Path := Copy(Path, 1, Index - 1); ZoomToPath(Path) end;

procedure TThemedTreemapChart.ResetTreemapZoom;
begin ClearSelection; TreemapOptions.ZoomPath := ''; if Assigned(FOnZoomChanged) then FOnZoomChanged(Self) end;

procedure TThemedTreemapChart.MarkPath(const Path: string);
begin if not TreemapOptions.EnableMarking then Exit; TreemapOptions.MarkedPath := Path; if Assigned(FOnMarkingChanged) then FOnMarkingChanged(Self) end;

procedure TThemedTreemapChart.ClearMarking;
begin TreemapOptions.MarkedPath := ''; if Assigned(FOnMarkingChanged) then FOnMarkingChanged(Self) end;

procedure TThemedTreemapChart.ResetView;
begin inherited; if ChartType = nctTreemap then begin ResetTreemapZoom; ClearMarking end end;

procedure TThemedTreemapChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var Before: TNimbusChartHit;
begin Before := HoverResult; inherited; if (ChartType = nctTreemap) and not Before.SameElement(HoverResult) then EmitTile(HoverResult, FOnTileHovered) end;

procedure TThemedTreemapChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Hit: TNimbusChartHit; Tile: TNimbusTreemapTileInfo;
begin
  Hit := HitTestChart(Point(X, Y)); inherited;
  if (ChartType = nctTreemap) and Enabled and (Button = mbLeft) and TileForHit(Hit, Tile) then
  begin EmitTile(Hit, FOnTileClicked); if TreemapOptions.EnableMarking then MarkPath(Tile.Path) end;
end;

function TThemedTreemapChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var P: TPoint; Hit: TNimbusChartHit; Tile: TNimbusTreemapTileInfo;
begin
  if (ChartType <> nctTreemap) or not Enabled or not TreemapOptions.EnableZoom or not TreemapOptions.ZoomWithMouseWheel then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  Result := False; if WheelDelta < 0 then begin if TreemapOptions.ZoomPath <> '' then begin ZoomToParent; Result := True end; Exit end;
  P := ScreenToClient(MousePos); Hit := HitTestChart(P); if TileForHit(Hit, Tile) then begin ZoomToPath(Tile.Path); Result := True end;
end;

procedure TThemedTreemapChart.DblClick;
var Tile: TNimbusTreemapTileInfo;
begin
  if (ChartType = nctTreemap) and TreemapOptions.EnableZoom and TreemapOptions.ZoomOnDoubleClick then
    if TileForHit(HoverResult, Tile) then if SameText(TreemapOptions.ZoomPath, Tile.Path) then ZoomToParent else ZoomToPath(Tile.Path) else ResetTreemapZoom;
  inherited;
end;

procedure TThemedTreemapChart.KeyDown(var Key: Word; Shift: TShiftState);
var Tiles: TArray<TNimbusTreemapTileInfo>; Index, Delta: Integer; Tile: TNimbusTreemapTileInfo; Hit: TNimbusChartHit;
begin
  if ChartType = nctTreemap then
  begin
    if Key in [VK_ESCAPE, VK_BACK] then begin ResetTreemapZoom; ClearMarking; Key := 0; Exit end;
    if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
    begin
      Tiles := GetTiles; Index := SelectedResult.ElementIndex; Delta := 1; if Key in [VK_LEFT, VK_UP] then Delta := -1; Inc(Index, Delta);
      if Index < 0 then Index := 0;
      while (Index >= 0) and (Index < Length(Tiles)) do
      begin
        Tile := Tiles[Index]; if Tile.IsLeaf or TreemapOptions.AllowParentTiles then
        begin
          Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.ElementIndex := Index; Hit.SeriesIndex := Tile.SeriesIndex; Hit.PointIndex := Tile.PointIndex;
          Hit.YValue := Tile.Value; Hit.Text := Tile.ToolTipText; Hit.Location := TPointF.Create(Tile.ContentBounds.CenterPoint.X, Tile.ContentBounds.CenterPoint.Y); SetSelected(Hit); Break;
        end; Inc(Index, Delta);
      end;
      Key := 0; Exit;
    end;
  end;
  inherited;
end;

function TThemedTreemapChart.GetEnableTreemapRichToolTip: Boolean;
begin Result := ShowToolTip end;

procedure TThemedTreemapChart.SetEnableTreemapRichToolTip(const Value: Boolean);
begin ShowToolTip := Value end;

function TThemedTreemapChart.GetEnableTreemapZoom: Boolean;
begin Result := TreemapOptions.EnableZoom end;

procedure TThemedTreemapChart.SetEnableTreemapZoom(const Value: Boolean);
begin TreemapOptions.EnableZoom := Value end;

function TThemedTreemapChart.GetZoomOnDoubleClick: Boolean;
begin Result := TreemapOptions.ZoomOnDoubleClick end;

procedure TThemedTreemapChart.SetZoomOnDoubleClick(const Value: Boolean);
begin TreemapOptions.ZoomOnDoubleClick := Value end;

function TThemedTreemapChart.GetZoomWithMouseWheel: Boolean;
begin Result := TreemapOptions.ZoomWithMouseWheel end;

procedure TThemedTreemapChart.SetZoomWithMouseWheel(const Value: Boolean);
begin TreemapOptions.ZoomWithMouseWheel := Value end;

function TThemedTreemapChart.GetEnableTreemapMarking: Boolean;
begin Result := TreemapOptions.EnableMarking end;

procedure TThemedTreemapChart.SetEnableTreemapMarking(const Value: Boolean);
begin TreemapOptions.EnableMarking := Value end;

function TThemedTreemapChart.GetMarkingMode: TNimbusTreemapMarkingMode;
begin Result := TreemapOptions.MarkingMode end;

procedure TThemedTreemapChart.SetMarkingMode(const Value: TNimbusTreemapMarkingMode);
begin TreemapOptions.MarkingMode := Value end;

function TThemedTreemapChart.GetLayoutMode: TNimbusTreemapLayoutMode;
begin Result := TreemapOptions.LayoutMode end;

procedure TThemedTreemapChart.SetLayoutMode(const Value: TNimbusTreemapLayoutMode);
begin TreemapOptions.LayoutMode := Value end;

function TThemedTreemapChart.GetZoomPath: string;
begin Result := TreemapOptions.ZoomPath end;

procedure TThemedTreemapChart.SetZoomPath(const Value: string);
begin TreemapOptions.ZoomPath := Value end;

function TThemedTreemapChart.GetMarkedPath: string;
begin Result := TreemapOptions.MarkedPath end;

procedure TThemedTreemapChart.SetMarkedPath(const Value: string);
begin TreemapOptions.MarkedPath := Value end;

initialization
  RegisterClass(TThemedTreemapChart);

end.

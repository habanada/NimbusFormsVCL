{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.StreamGraph;

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.Types, Vcl.Controls, NimbusForms.Controls.Chart,
  NimbusForms.Charts.StreamGraph.Types, NimbusForms.Rendering.Charts, NimbusForms.Rendering.StreamGraph;

type
  TNimbusStreamBandEvent = procedure(Sender: TObject; const Band: TNimbusStreamBandInfo; const Location: TPointF) of object;

  TThemedStreamGraphChart = class(TThemedChart)
  private
    FRenderer: INimbusChartRenderer;
    FStreamRenderer: TNimbusStreamGraphChartRenderer;
    FRangeCandidate, FRangeDragging, FPanning: Boolean;
    FDragStart, FDragCurrent: TPoint;
    FPanFirst, FPanLast: Integer;
    FOnBandHovered, FOnBandClicked, FOnBandSelected: TNimbusStreamBandEvent;
    FOnStreamZoomChanged: TNotifyEvent;
    function GetOptions: TNimbusStreamGraphOptions;
    procedure SetOptions(const Value: TNimbusStreamGraphOptions);
    function Geometry: TNimbusStreamGeometry;
    function BandForHit(const Hit: TNimbusChartHit; out Band: TNimbusStreamBandInfo): Boolean;
    procedure EmitBand(const Hit: TNimbusChartHit; const Event: TNimbusStreamBandEvent);
    procedure StopInteraction;
    procedure ZoomAroundIndex(const Index: Integer; ZoomIn: Boolean);
    function GetHoverBand: TNimbusStreamBandInfo;
    function GetSelectedBand: TNimbusStreamBandInfo;
    function GetIsZoomed: Boolean;
    function GetBaselineMode: TNimbusStreamBaselineMode;
    procedure SetBaselineMode(const Value: TNimbusStreamBaselineMode);
    function GetCurveMode: TNimbusStreamCurveMode;
    procedure SetCurveMode(const Value: TNimbusStreamCurveMode);
    function GetShowStreamGraphGrid: Boolean;
    procedure SetShowStreamGraphGrid(const Value: Boolean);
    function GetShowStreamGraphAxes: Boolean;
    procedure SetShowStreamGraphAxes(const Value: Boolean);
    function GetShowStreamGraphLegend: Boolean;
    procedure SetShowStreamGraphLegend(const Value: Boolean);
    function GetShowBandLabels: Boolean;
    procedure SetShowBandLabels(const Value: Boolean);
    function GetShowEndLabels: Boolean;
    procedure SetShowEndLabels(const Value: Boolean);
    function GetNormalizeToPercent: Boolean;
    procedure SetNormalizeToPercent(const Value: Boolean);
    function GetEnableStreamGraphSelection: Boolean;
    procedure SetEnableStreamGraphSelection(const Value: Boolean);
    function GetEnableRangeZoom: Boolean;
    procedure SetEnableRangeZoom(const Value: Boolean);
    function GetEnableDragRangeZoom: Boolean;
    procedure SetEnableDragRangeZoom(const Value: Boolean);
    function GetEnableMouseWheelZoom: Boolean;
    procedure SetEnableMouseWheelZoom(const Value: Boolean);
    function GetEnableStreamGraphPan: Boolean;
    procedure SetEnableStreamGraphPan(const Value: Boolean);
    function GetShowZoomNavigator: Boolean;
    procedure SetShowZoomNavigator(const Value: Boolean);
    function GetShowZoomBadge: Boolean;
    procedure SetShowZoomBadge(const Value: Boolean);
    function GetEnableStreamGraphRichToolTip: Boolean;
    procedure SetEnableStreamGraphRichToolTip(const Value: Boolean);
    function GetFillOpacity: Single;
    procedure SetFillOpacity(const Value: Single);
    function GetBandGap: Single;
    procedure SetBandGap(const Value: Single);
  protected
    procedure SetSelected(const AHit: TNimbusChartHit); override;
    function KeepSelectionOnModelChange: Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure DestroyWnd; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ZoomToRange(const StartIndex, EndIndex: Integer);
    procedure ResetStreamZoom;
    procedure ZoomInAt(const Index: Integer);
    procedure ZoomOutAt(const Index: Integer);
    procedure SelectBand(const SeriesIndex, CategoryIndex: Integer);
    procedure ClearStreamSelection;
    procedure ResetView; override;
    property HoverBand: TNimbusStreamBandInfo read GetHoverBand;
    property SelectedBand: TNimbusStreamBandInfo read GetSelectedBand;
    property IsStreamZoomed: Boolean read GetIsZoomed;
  published
    property BaselineMode: TNimbusStreamBaselineMode read GetBaselineMode write SetBaselineMode default nsbSilhouette;
    property CurveMode: TNimbusStreamCurveMode read GetCurveMode write SetCurveMode default nscSmooth;
    property ShowStreamGraphGrid: Boolean read GetShowStreamGraphGrid write SetShowStreamGraphGrid default True;
    property ShowStreamGraphAxes: Boolean read GetShowStreamGraphAxes write SetShowStreamGraphAxes default True;
    property ShowStreamGraphLegend: Boolean read GetShowStreamGraphLegend write SetShowStreamGraphLegend default True;
    property ShowBandLabels: Boolean read GetShowBandLabels write SetShowBandLabels default True;
    property ShowEndLabels: Boolean read GetShowEndLabels write SetShowEndLabels default True;
    property NormalizeToPercent: Boolean read GetNormalizeToPercent write SetNormalizeToPercent default False;
    property EnableStreamGraphSelection: Boolean read GetEnableStreamGraphSelection write SetEnableStreamGraphSelection default True;
    property EnableRangeZoom: Boolean read GetEnableRangeZoom write SetEnableRangeZoom default True;
    property EnableDragRangeZoom: Boolean read GetEnableDragRangeZoom write SetEnableDragRangeZoom default True;
    property EnableMouseWheelZoom: Boolean read GetEnableMouseWheelZoom write SetEnableMouseWheelZoom default True;
    property EnableStreamGraphPan: Boolean read GetEnableStreamGraphPan write SetEnableStreamGraphPan default True;
    property ShowZoomNavigator: Boolean read GetShowZoomNavigator write SetShowZoomNavigator default True;
    property ShowZoomBadge: Boolean read GetShowZoomBadge write SetShowZoomBadge default True;
    property EnableStreamGraphRichToolTip: Boolean read GetEnableStreamGraphRichToolTip write SetEnableStreamGraphRichToolTip default True;
    property FillOpacity: Single read GetFillOpacity write SetFillOpacity;
    property BandGap: Single read GetBandGap write SetBandGap;
    property StreamGraphOptions: TNimbusStreamGraphOptions read GetOptions write SetOptions;
    property OnBandHovered: TNimbusStreamBandEvent read FOnBandHovered write FOnBandHovered;
    property OnBandClicked: TNimbusStreamBandEvent read FOnBandClicked write FOnBandClicked;
    property OnBandSelected: TNimbusStreamBandEvent read FOnBandSelected write FOnBandSelected;
    property OnStreamZoomChanged: TNotifyEvent read FOnStreamZoomChanged write FOnStreamZoomChanged;
  end;

implementation

uses System.Math, NimbusForms.Charts.Types;

constructor TThemedStreamGraphChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); FStreamRenderer := TNimbusStreamGraphChartRenderer.Create; FRenderer := FStreamRenderer;
  RendererFactory.RegisterFirst(FRenderer); ChartType := nctStreamGraph; ShowToolTip := True; ShowBorder := False; ShowCrosshair := False; TabStop := True;
end;

function TThemedStreamGraphChart.GetOptions: TNimbusStreamGraphOptions;
begin Result := Model.StreamGraphOptions end;

procedure TThemedStreamGraphChart.SetOptions(const Value: TNimbusStreamGraphOptions);
begin if Value <> nil then Model.StreamGraphOptions.Assign(Value) end;

function TThemedStreamGraphChart.GetIsZoomed: Boolean;
begin Result := StreamGraphOptions.EnableRangeZoom and StreamGraphOptions.IsZoomed end;

function TThemedStreamGraphChart.Geometry: TNimbusStreamGeometry;
var C: TNimbusChartRenderContext; L: TNimbusChartLayout;
begin C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FStreamRenderer.Arrange(C); Result := FStreamRenderer.GetGeometry(C, L.PlotArea) end;

function TThemedStreamGraphChart.BandForHit(const Hit: TNimbusChartHit; out Band: TNimbusStreamBandInfo): Boolean;
var G: TNimbusStreamGeometry; Row: TNimbusStreamBandGeometry; Info: TNimbusStreamBandInfo;
begin
  Result := False; Band := Default(TNimbusStreamBandInfo); Band.SeriesIndex := -1; Band.PointIndex := -1; Band.CategoryIndex := -1;
  if Hit.Area = nchaNone then Exit; G := Geometry;
  for Row in G.Bands do if Row.SeriesIndex = Hit.SeriesIndex then for Info in Row.Samples do if Info.CategoryIndex = Hit.ElementIndex then begin Band := Info; Exit(True) end;
end;

function TThemedStreamGraphChart.GetHoverBand: TNimbusStreamBandInfo;
begin BandForHit(HoverResult, Result) end;

function TThemedStreamGraphChart.GetSelectedBand: TNimbusStreamBandInfo;
begin BandForHit(SelectedResult, Result) end;

procedure TThemedStreamGraphChart.EmitBand(const Hit: TNimbusChartHit; const Event: TNimbusStreamBandEvent);
var Band: TNimbusStreamBandInfo;
begin if Assigned(Event) and BandForHit(Hit, Band) then Event(Self, Band, Hit.Location) end;

function TThemedStreamGraphChart.KeepSelectionOnModelChange: Boolean;
var Hit: TNimbusChartHit;
begin
  Result := False; if (FStreamRenderer = nil) or (ChartType <> nctStreamGraph) then Exit; Hit := SelectedResult;
  if (Hit.SeriesIndex < 0) or (Hit.SeriesIndex >= Model.Series.Count) then Exit;
  if not Model.Series[Hit.SeriesIndex].Visible then Exit;
  if (Hit.PointIndex >= 0) and (Hit.PointIndex >= Model.Series[Hit.SeriesIndex].Points.Count) then Exit;
  if Hit.PointIndex >= 0 then if not Model.Series[Hit.SeriesIndex].Points[Hit.PointIndex].Visible then Exit;
  Result := StreamGraphOptions.EnableSelection and (StreamGraphOptions.SelectionMode <> nssNone);
end;

procedure TThemedStreamGraphChart.SetSelected(const AHit: TNimbusChartHit);
var Changed: Boolean;
begin
  if ChartType <> nctStreamGraph then begin inherited; Exit end;
  if AHit.Area <> nchaNone then
    if not StreamGraphOptions.EnableSelection or (StreamGraphOptions.SelectionMode = nssNone) or ((StreamGraphOptions.SelectionMode = nssTimeSlice) and not StreamGraphOptions.EnableTimeSliceSelection) then Exit;
  Changed := not SelectedResult.SameElement(AHit); inherited SetSelected(AHit); if Changed then EmitBand(AHit, FOnBandSelected);
end;

procedure TThemedStreamGraphChart.SelectBand(const SeriesIndex, CategoryIndex: Integer);
var G: TNimbusStreamGeometry; Band: TNimbusStreamBandGeometry; Info: TNimbusStreamBandInfo; Hit: TNimbusChartHit;
begin
  G := Geometry; for Band in G.Bands do if Band.SeriesIndex = SeriesIndex then for Info in Band.Samples do if Info.CategoryIndex = CategoryIndex then
  begin
    Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.SeriesIndex := SeriesIndex; Hit.PointIndex := Info.PointIndex;
    Hit.ElementIndex := CategoryIndex; Hit.Location := Info.CenterPoint; Hit.XValue := Info.XValue; Hit.YValue := Info.RawValue; Hit.Text := Info.ToolTipText; SetSelected(Hit); Exit;
  end;
end;

procedure TThemedStreamGraphChart.ClearStreamSelection;
begin ClearSelection end;

procedure TThemedStreamGraphChart.StopInteraction;
begin
  FRangeCandidate := False; FRangeDragging := False; FPanning := False;
  if FStreamRenderer <> nil then FStreamRenderer.SetRangePreview(False, 0, 0);
  if HandleAllocated then MouseCapture := False; Cursor := crDefault;
end;

procedure TThemedStreamGraphChart.SetParent(AParent: TWinControl);
begin if AParent = nil then StopInteraction; inherited SetParent(AParent) end;

procedure TThemedStreamGraphChart.DestroyWnd;
begin StopInteraction; inherited DestroyWnd end;

procedure TThemedStreamGraphChart.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if ((Message.Msg = WM_CAPTURECHANGED) and (FRangeDragging or FRangeCandidate or FPanning)) or ((Message.Msg = CM_ENABLEDCHANGED) and not Enabled) then begin StopInteraction; Invalidate end;
end;

procedure TThemedStreamGraphChart.ZoomToRange(const StartIndex, EndIndex: Integer);
var Count, First, Last: Integer;
begin
  Count := Length(FStreamRenderer.Categories(Model)); if Count <= 1 then Exit;
  First := EnsureRange(Min(StartIndex, EndIndex), 0, Count - 1); Last := EnsureRange(Max(StartIndex, EndIndex), 0, Count - 1); if Last <= First then Exit;
  if (First = 0) and (Last = Count - 1) then StreamGraphOptions.ResetZoom else StreamGraphOptions.SetZoomRange(First, Last);
  Invalidate; if Assigned(FOnStreamZoomChanged) then FOnStreamZoomChanged(Self);
end;

procedure TThemedStreamGraphChart.ResetStreamZoom;
begin StopInteraction; StreamGraphOptions.ResetZoom; Invalidate; if Assigned(FOnStreamZoomChanged) then FOnStreamZoomChanged(Self) end;

procedure TThemedStreamGraphChart.ResetView;
begin StopInteraction; inherited; if ChartType = nctStreamGraph then ResetStreamZoom end;

procedure TThemedStreamGraphChart.ZoomAroundIndex(const Index: Integer; ZoomIn: Boolean);
var Count, First, Last, Anchor, Width, NewWidth: Integer; Ratio: Double;
begin
  Count := Length(FStreamRenderer.Categories(Model)); if Count <= 2 then Exit; First := 0; Last := Count - 1;
  if IsStreamZoomed then begin First := EnsureRange(StreamGraphOptions.ZoomStartIndex, 0, Count - 1); Last := EnsureRange(StreamGraphOptions.ZoomEndIndex, First, Count - 1) end;
  Width := Last - First + 1; if ZoomIn then NewWidth := Max(2, Round(Width * StreamGraphOptions.MouseWheelZoomFactor)) else NewWidth := Min(Count, Round(Width / StreamGraphOptions.MouseWheelZoomFactor));
  if NewWidth >= Count then begin ResetStreamZoom; Exit end; Anchor := EnsureRange(Index, 0, Count - 1);
  Ratio := EnsureRange((Anchor - First) / Max(1, Width - 1), 0.0, 1.0); First := EnsureRange(Anchor - Round((NewWidth - 1) * Ratio), 0, Count - NewWidth); ZoomToRange(First, First + NewWidth - 1);
end;

procedure TThemedStreamGraphChart.ZoomInAt(const Index: Integer);
begin ZoomAroundIndex(Index, True) end;

procedure TThemedStreamGraphChart.ZoomOutAt(const Index: Integer);
begin ZoomAroundIndex(Index, False) end;

procedure TThemedStreamGraphChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var C: TNimbusChartRenderContext; L: TNimbusChartLayout;
begin
  if (ChartType <> nctStreamGraph) or not Enabled then begin inherited; Exit end;
  C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FStreamRenderer.Arrange(C); FDragStart := Point(X, Y); FDragCurrent := FDragStart;
  if L.PlotArea.Contains(FDragStart) and StreamGraphOptions.EnableRangeZoom then
  begin
    if StreamGraphOptions.EnablePan and IsStreamZoomed and (Button in [mbRight, mbMiddle]) then
    begin
      if CanFocus then SetFocus; FPanning := True; FPanFirst := StreamGraphOptions.ZoomStartIndex; FPanLast := StreamGraphOptions.ZoomEndIndex; MouseCapture := True; Cursor := crSizeWE; Exit;
    end;
    FRangeCandidate := StreamGraphOptions.EnableDragRangeZoom and (Button = mbLeft) and (Length(FStreamRenderer.Categories(Model)) > 2);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TThemedStreamGraphChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var C: TNimbusChartRenderContext; L: TNimbusChartLayout; Before: TNimbusChartHit; Count, Span, Delta, First: Integer;
begin
  if ChartType <> nctStreamGraph then begin inherited; Exit end;
  if not Enabled then begin StopInteraction; Exit end;
  if not StreamGraphOptions.EnableRangeZoom or (FPanning and not StreamGraphOptions.EnablePan) or (FRangeCandidate and not StreamGraphOptions.EnableDragRangeZoom) then StopInteraction;
  FDragCurrent := Point(X, Y);
  if FPanning then
  begin
    C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FStreamRenderer.Arrange(C); Count := Length(FStreamRenderer.Categories(Model)); Span := FPanLast - FPanFirst;
    Delta := Round(-(X - FDragStart.X) / Max(1, L.PlotArea.Width) * (Span + 1)); First := EnsureRange(FPanFirst + Delta, 0, Max(0, Count - Span - 1));
    if (First <> StreamGraphOptions.ZoomStartIndex) then ZoomToRange(First, First + Span); Exit;
  end;
  if FRangeCandidate then
  begin
    if not FRangeDragging and (Abs(X - FDragStart.X) >= ScaleValue(6)) then
    begin CancelPendingInteraction; FRangeDragging := True; MouseCapture := True; Cursor := crCross end;
    if FRangeDragging then begin FStreamRenderer.SetRangePreview(True, FDragStart.X, X); Invalidate; Exit end;
  end;
  Before := HoverResult; inherited MouseMove(Shift, X, Y); if not Before.SameElement(HoverResult) then EmitBand(HoverResult, FOnBandHovered);
end;

procedure TThemedStreamGraphChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var C: TNimbusChartRenderContext; First, Last: Integer; Hit: TNimbusChartHit;
begin
  if ChartType <> nctStreamGraph then begin inherited; Exit end;
  if FPanning then begin CancelPendingInteraction; StopInteraction; Invalidate; Exit end;
  if FRangeDragging then
  begin
    C := CreateRenderContext(Rect(0, 0, Width, Height)); First := FStreamRenderer.NearestCategory(C, FDragStart.X); Last := FStreamRenderer.NearestCategory(C, X);
    CancelPendingInteraction; StopInteraction; ZoomToRange(First, Last); Invalidate; Exit;
  end;
  StopInteraction; Hit := HitTestChart(Point(X, Y)); inherited MouseUp(Button, Shift, X, Y); if Button = mbLeft then EmitBand(Hit, FOnBandClicked);
end;

function TThemedStreamGraphChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var C: TNimbusChartRenderContext; L: TNimbusChartLayout; P: TPoint; Index: Integer;
begin
  if (ChartType <> nctStreamGraph) or not Enabled or not StreamGraphOptions.EnableRangeZoom or not StreamGraphOptions.EnableMouseWheelZoom then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  Result := False; P := ScreenToClient(MousePos); C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FStreamRenderer.Arrange(C); if not L.PlotArea.Contains(P) then Exit;
  Index := FStreamRenderer.NearestCategory(C, P.X); ZoomAroundIndex(Index, WheelDelta > 0); Result := True;
end;

procedure TThemedStreamGraphChart.DblClick;
var Index, Radius: Integer;
begin
  if ChartType = nctStreamGraph then if IsStreamZoomed then ResetStreamZoom else
  begin Index := HoverResult.ElementIndex; if Index >= 0 then begin Radius := Max(2, Min(6, Length(FStreamRenderer.Categories(Model)) div 5)); ZoomToRange(Index - Radius, Index + Radius) end end;
  inherited DblClick;
end;

procedure TThemedStreamGraphChart.KeyDown(var Key: Word; Shift: TShiftState);
var G: TNimbusStreamGeometry; I, Row, Index: Integer;
begin
  if ChartType = nctStreamGraph then
  begin
    if Key in [VK_ESCAPE, VK_BACK] then begin ResetStreamZoom; ClearSelection; Key := 0; Exit end;
    if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
    begin
      G := Geometry; if Length(G.Bands) = 0 then Exit; Row := 0; Index := Max(G.FirstIndex, SelectedResult.ElementIndex);
      for I := 0 to High(G.Bands) do if G.Bands[I].SeriesIndex = SelectedResult.SeriesIndex then begin Row := I; Break end;
      case Key of VK_LEFT: Dec(Index); VK_RIGHT: Inc(Index); VK_UP: Dec(Row); VK_DOWN: Inc(Row) end;
      Row := EnsureRange(Row, 0, High(G.Bands)); Index := EnsureRange(Index, G.FirstIndex, G.LastIndex); SelectBand(G.Bands[Row].SeriesIndex, Index); Key := 0; Exit;
    end;
  end;
  inherited KeyDown(Key, Shift);
end;

function TThemedStreamGraphChart.GetBaselineMode: TNimbusStreamBaselineMode;
begin Result := StreamGraphOptions.BaselineMode end;

procedure TThemedStreamGraphChart.SetBaselineMode(const Value: TNimbusStreamBaselineMode);
begin StreamGraphOptions.BaselineMode := Value end;

function TThemedStreamGraphChart.GetCurveMode: TNimbusStreamCurveMode;
begin Result := StreamGraphOptions.CurveMode end;

procedure TThemedStreamGraphChart.SetCurveMode(const Value: TNimbusStreamCurveMode);
begin StreamGraphOptions.CurveMode := Value end;

function TThemedStreamGraphChart.GetShowStreamGraphGrid: Boolean;
begin Result := StreamGraphOptions.ShowGrid end;

procedure TThemedStreamGraphChart.SetShowStreamGraphGrid(const Value: Boolean);
begin StreamGraphOptions.ShowGrid := Value end;

function TThemedStreamGraphChart.GetShowStreamGraphAxes: Boolean;
begin Result := StreamGraphOptions.ShowAxes end;

procedure TThemedStreamGraphChart.SetShowStreamGraphAxes(const Value: Boolean);
begin StreamGraphOptions.ShowAxes := Value end;

function TThemedStreamGraphChart.GetShowStreamGraphLegend: Boolean;
begin Result := StreamGraphOptions.ShowLegend end;

procedure TThemedStreamGraphChart.SetShowStreamGraphLegend(const Value: Boolean);
begin StreamGraphOptions.ShowLegend := Value; ShowLegend := Value end;

function TThemedStreamGraphChart.GetShowBandLabels: Boolean;
begin Result := StreamGraphOptions.ShowBandLabels end;

procedure TThemedStreamGraphChart.SetShowBandLabels(const Value: Boolean);
begin StreamGraphOptions.ShowBandLabels := Value end;

function TThemedStreamGraphChart.GetShowEndLabels: Boolean;
begin Result := StreamGraphOptions.ShowEndLabels end;

procedure TThemedStreamGraphChart.SetShowEndLabels(const Value: Boolean);
begin StreamGraphOptions.ShowEndLabels := Value end;

function TThemedStreamGraphChart.GetNormalizeToPercent: Boolean;
begin Result := StreamGraphOptions.NormalizeToPercent end;

procedure TThemedStreamGraphChart.SetNormalizeToPercent(const Value: Boolean);
begin StreamGraphOptions.NormalizeToPercent := Value end;

function TThemedStreamGraphChart.GetEnableStreamGraphSelection: Boolean;
begin Result := StreamGraphOptions.EnableSelection end;

procedure TThemedStreamGraphChart.SetEnableStreamGraphSelection(const Value: Boolean);
begin StreamGraphOptions.EnableSelection := Value end;

function TThemedStreamGraphChart.GetEnableRangeZoom: Boolean;
begin Result := StreamGraphOptions.EnableRangeZoom end;

procedure TThemedStreamGraphChart.SetEnableRangeZoom(const Value: Boolean);
begin StreamGraphOptions.EnableRangeZoom := Value end;

function TThemedStreamGraphChart.GetEnableDragRangeZoom: Boolean;
begin Result := StreamGraphOptions.EnableDragRangeZoom end;

procedure TThemedStreamGraphChart.SetEnableDragRangeZoom(const Value: Boolean);
begin StreamGraphOptions.EnableDragRangeZoom := Value end;

function TThemedStreamGraphChart.GetEnableMouseWheelZoom: Boolean;
begin Result := StreamGraphOptions.EnableMouseWheelZoom end;

procedure TThemedStreamGraphChart.SetEnableMouseWheelZoom(const Value: Boolean);
begin StreamGraphOptions.EnableMouseWheelZoom := Value end;

function TThemedStreamGraphChart.GetEnableStreamGraphPan: Boolean;
begin Result := StreamGraphOptions.EnablePan end;

procedure TThemedStreamGraphChart.SetEnableStreamGraphPan(const Value: Boolean);
begin StreamGraphOptions.EnablePan := Value end;

function TThemedStreamGraphChart.GetShowZoomNavigator: Boolean;
begin Result := StreamGraphOptions.ShowZoomNavigator end;

procedure TThemedStreamGraphChart.SetShowZoomNavigator(const Value: Boolean);
begin StreamGraphOptions.ShowZoomNavigator := Value end;

function TThemedStreamGraphChart.GetShowZoomBadge: Boolean;
begin Result := StreamGraphOptions.ShowZoomBadge end;

procedure TThemedStreamGraphChart.SetShowZoomBadge(const Value: Boolean);
begin StreamGraphOptions.ShowZoomBadge := Value end;

function TThemedStreamGraphChart.GetEnableStreamGraphRichToolTip: Boolean;
begin Result := ShowToolTip end;

procedure TThemedStreamGraphChart.SetEnableStreamGraphRichToolTip(const Value: Boolean);
begin ShowToolTip := Value end;

function TThemedStreamGraphChart.GetFillOpacity: Single;
begin Result := StreamGraphOptions.FillOpacity end;

procedure TThemedStreamGraphChart.SetFillOpacity(const Value: Single);
begin StreamGraphOptions.FillOpacity := Value end;

function TThemedStreamGraphChart.GetBandGap: Single;
begin Result := StreamGraphOptions.BandGap end;

procedure TThemedStreamGraphChart.SetBandGap(const Value: Single);
begin StreamGraphOptions.BandGap := Value end;

initialization
  RegisterClass(TThemedStreamGraphChart);

end.

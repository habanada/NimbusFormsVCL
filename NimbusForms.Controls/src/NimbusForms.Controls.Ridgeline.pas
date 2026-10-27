{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Ridgeline;

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.Types, Vcl.Controls, NimbusForms.Controls.Chart,
  NimbusForms.Charts.Ridgeline.Types, NimbusForms.Rendering.Charts, NimbusForms.Rendering.Ridgeline;

type
  TNimbusRidgelineEvent = procedure(Sender: TObject; const Ridge: TNimbusRidgelineRidgeInfo; const PointInfo: TNimbusRidgelinePointInfo; HasPoint: Boolean; const Location: TPointF) of object;

  TThemedRidgelineChart = class(TThemedChart)
  private
    FRenderer: INimbusChartRenderer;
    FRidgelineRenderer: TNimbusRidgelineChartRenderer;
    FRangeDragging, FPanning: Boolean;
    FDragStart, FDragCurrent, FPanAnchor, FPanFirst, FPanLast: Integer;
    FMouseDownLocation: TPoint;
    FOnRidgeHovered, FOnRidgeClicked, FOnRidgeSelected: TNimbusRidgelineEvent;
    FOnRidgelineZoomChanged: TNotifyEvent;
    function GetOptions: TNimbusRidgelineOptions;
    procedure SetOptions(const Value: TNimbusRidgelineOptions);
    procedure StopInteraction;
    procedure EmitRidge(const Hit: TNimbusChartHit; const Event: TNimbusRidgelineEvent);
    function GetScaleMode: TNimbusRidgelineScaleMode;
    procedure SetScaleMode(const Value: TNimbusRidgelineScaleMode);
    function GetCurveMode: TNimbusRidgelineCurveMode;
    procedure SetCurveMode(const Value: TNimbusRidgelineCurveMode);
    function GetOverlap: Single;
    procedure SetOverlap(const Value: Single);
    function GetRangeZoom: Boolean;
    procedure SetRangeZoom(const Value: Boolean);
    function GetWheelZoom: Boolean;
    procedure SetWheelZoom(const Value: Boolean);
    function GetRichToolTip: Boolean;
    procedure SetRichToolTip(const Value: Boolean);
    function GetRidgePan: Boolean;
    procedure SetRidgePan(const Value: Boolean);
    function GetRidgeSelection: Boolean;
    procedure SetRidgeSelection(const Value: Boolean);
    function GetZoomStart: Integer;
    procedure SetZoomStart(const Value: Integer);
    function GetZoomEnd: Integer;
    procedure SetZoomEnd(const Value: Integer);
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
    procedure ResetRidgelineZoom;
    procedure SelectRidge(const SeriesIndex: Integer; const PointIndex: Integer = -1);
    procedure ClearRidgelineSelection;
    procedure ResetView; override;
    procedure ClearSelection; override;
    function GetRidges: TArray<TNimbusRidgelineRidgeInfo>;
  published
    property RidgelineOptions: TNimbusRidgelineOptions read GetOptions write SetOptions;
    property ScaleMode: TNimbusRidgelineScaleMode read GetScaleMode write SetScaleMode default nrsGlobal;
    property CurveMode: TNimbusRidgelineCurveMode read GetCurveMode write SetCurveMode default nrcSmooth;
    property Overlap: Single read GetOverlap write SetOverlap;
    property EnableRangeZoom: Boolean read GetRangeZoom write SetRangeZoom default True;
    property EnableMouseWheelZoom: Boolean read GetWheelZoom write SetWheelZoom default True;
    property EnableRidgelineRichToolTip: Boolean read GetRichToolTip write SetRichToolTip default True;
    property EnablePan: Boolean read GetRidgePan write SetRidgePan default True;
    property EnableRidgeSelection: Boolean read GetRidgeSelection write SetRidgeSelection default True;
    property ZoomStartIndex: Integer read GetZoomStart write SetZoomStart default -1;
    property ZoomEndIndex: Integer read GetZoomEnd write SetZoomEnd default -1;
    property OnRidgeHovered: TNimbusRidgelineEvent read FOnRidgeHovered write FOnRidgeHovered;
    property OnRidgeClicked: TNimbusRidgelineEvent read FOnRidgeClicked write FOnRidgeClicked;
    property OnRidgeSelected: TNimbusRidgelineEvent read FOnRidgeSelected write FOnRidgeSelected;
    property OnRidgelineZoomChanged: TNotifyEvent read FOnRidgelineZoomChanged write FOnRidgelineZoomChanged;
  end;

implementation

uses System.Math, System.SysUtils, NimbusForms.Charts.Types;

constructor TThemedRidgelineChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); FRidgelineRenderer := TNimbusRidgelineChartRenderer.Create; FRenderer := FRidgelineRenderer;
  RendererFactory.RegisterFirst(FRenderer); ChartType := nctRidgeline; ShowToolTip := True; TabStop := True;
  FDragStart := -1; FDragCurrent := -1; FPanAnchor := -1;
end;

function TThemedRidgelineChart.GetOptions: TNimbusRidgelineOptions;
begin Result := Model.RidgelineOptions end;

procedure TThemedRidgelineChart.SetOptions(const Value: TNimbusRidgelineOptions);
begin if Value <> nil then Model.RidgelineOptions.Assign(Value) end;

procedure TThemedRidgelineChart.StopInteraction;
begin
  FRangeDragging := False; FPanning := False; FDragStart := -1; FDragCurrent := -1; FPanAnchor := -1;
  if HandleAllocated then MouseCapture := False;
end;

procedure TThemedRidgelineChart.SetParent(AParent: TWinControl);
begin if AParent = nil then StopInteraction; inherited SetParent(AParent) end;

procedure TThemedRidgelineChart.DestroyWnd;
begin StopInteraction; inherited DestroyWnd end;

procedure TThemedRidgelineChart.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if ((Message.Msg = WM_CAPTURECHANGED) and (FRangeDragging or FPanning)) or ((Message.Msg = CM_ENABLEDCHANGED) and not Enabled) then
  begin FRangeDragging := False; FPanning := False; FDragStart := -1; FDragCurrent := -1; FPanAnchor := -1; Invalidate end;
end;

function TThemedRidgelineChart.GetRidges: TArray<TNimbusRidgelineRidgeInfo>;
var C: TNimbusChartRenderContext; Layout: TNimbusChartLayout;
begin C := CreateRenderContext(Rect(0, 0, Width, Height)); Layout := FRidgelineRenderer.Arrange(C); Result := FRidgelineRenderer.GetRidges(C, Layout.PlotArea) end;

procedure TThemedRidgelineChart.EmitRidge(const Hit: TNimbusChartHit; const Event: TNimbusRidgelineEvent);
var Ridge: TNimbusRidgelineRidgeInfo; Info: TNimbusRidgelinePointInfo; HasPoint: Boolean;
begin
  if not Assigned(Event) or not (Hit.Area in [nchaSeries, nchaPoint]) then Exit;
  for Ridge in GetRidges do
    if Ridge.SeriesIndex = Hit.SeriesIndex then
    begin
      Info := Default(TNimbusRidgelinePointInfo); HasPoint := False;
      if Hit.PointIndex >= 0 then for Info in Ridge.Points do if Info.PointIndex = Hit.PointIndex then begin HasPoint := True; Break end;
      Event(Self, Ridge, Info, HasPoint, Hit.Location); Exit;
    end;
end;

function TThemedRidgelineChart.KeepSelectionOnModelChange: Boolean;
var Hit: TNimbusChartHit;
begin
  Result := False; if (FRidgelineRenderer = nil) or (ChartType <> nctRidgeline) then Exit; Hit := SelectedResult;
  if not (Hit.Area in [nchaSeries, nchaPoint]) or (Hit.SeriesIndex < 0) or (Hit.SeriesIndex >= Model.Series.Count) then Exit;
  if not Model.Series[Hit.SeriesIndex].Visible or (RidgelineOptions.SelectedSeriesIndex <> Hit.SeriesIndex) or (RidgelineOptions.SelectedPointIndex <> Hit.PointIndex) then Exit;
  if Hit.PointIndex >= 0 then
    if (Hit.PointIndex >= Model.Series[Hit.SeriesIndex].Points.Count) or not Model.Series[Hit.SeriesIndex].Points[Hit.PointIndex].Visible then Exit;
  Result := True;
end;

procedure TThemedRidgelineChart.SetSelected(const AHit: TNimbusChartHit);
var Changed: Boolean;
begin
  if ChartType <> nctRidgeline then begin inherited SetSelected(AHit); Exit end;
  if (AHit.Area <> nchaNone) and not RidgelineOptions.EnableSelection then Exit;
  Changed := not SelectedResult.SameElement(AHit); Model.BeginUpdate;
  try
    RidgelineOptions.SelectedSeriesIndex := AHit.SeriesIndex; RidgelineOptions.SelectedPointIndex := AHit.PointIndex;
    inherited SetSelected(AHit);
  finally Model.EndUpdate end;
  if Changed then EmitRidge(AHit, FOnRidgeSelected);
end;

procedure TThemedRidgelineChart.ZoomToRange(const StartIndex, EndIndex: Integer);
var First, Last, Maximum: Integer;
begin
  Maximum := FRidgelineRenderer.MaximumPointIndex(Model); if Maximum < 0 then begin ResetRidgelineZoom; Exit end;
  First := EnsureRange(Min(StartIndex, EndIndex), 0, Maximum); Last := EnsureRange(Max(StartIndex, EndIndex), 0, Maximum);
  if First = Last then if Last < Maximum then Inc(Last) else if First > 0 then Dec(First);
  RidgelineOptions.SetZoomRange(First, Last); if Assigned(FOnRidgelineZoomChanged) then FOnRidgelineZoomChanged(Self);
end;

procedure TThemedRidgelineChart.ResetRidgelineZoom;
begin StopInteraction; RidgelineOptions.ResetZoom; if Assigned(FOnRidgelineZoomChanged) then FOnRidgelineZoomChanged(Self) end;

procedure TThemedRidgelineChart.ResetView;
begin StopInteraction; inherited ResetView; if ChartType = nctRidgeline then ResetRidgelineZoom end;

procedure TThemedRidgelineChart.ClearSelection;
begin inherited ClearSelection; if ChartType = nctRidgeline then begin RidgelineOptions.SelectedSeriesIndex := -1; RidgelineOptions.SelectedPointIndex := -1 end end;

procedure TThemedRidgelineChart.ClearRidgelineSelection;
begin ClearSelection end;

procedure TThemedRidgelineChart.SelectRidge(const SeriesIndex, PointIndex: Integer);
var Ridge: TNimbusRidgelineRidgeInfo; Info: TNimbusRidgelinePointInfo; Hit: TNimbusChartHit;
begin
  if not RidgelineOptions.EnableSelection then Exit;
  for Ridge in GetRidges do
    if Ridge.SeriesIndex = SeriesIndex then
    begin
      Hit := TNimbusChartHit.None; Hit.Area := nchaSeries; Hit.SeriesIndex := SeriesIndex; Hit.Text := Ridge.SeriesName;
      Hit.Location := TPointF.Create(Ridge.Bounds.CenterPoint.X, Ridge.Bounds.CenterPoint.Y);
      if PointIndex >= 0 then for Info in Ridge.Points do if Info.PointIndex = PointIndex then
      begin Hit.Area := nchaPoint; Hit.PointIndex := PointIndex; Hit.Location := Info.Location; Hit.XValue := Info.XValue; Hit.YValue := Info.YValue; Hit.Text := Info.LabelText; Break end;
      SetSelected(Hit); Exit;
    end;
end;

procedure TThemedRidgelineChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var C: TNimbusChartRenderContext; L: TNimbusChartLayout;
begin
  inherited MouseDown(Button, Shift, X, Y); if (ChartType <> nctRidgeline) or not Enabled then Exit;
  FMouseDownLocation := Point(X, Y); C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FRidgelineRenderer.Arrange(C);
  if not L.PlotArea.Contains(Point(X, Y)) then Exit;
  if RidgelineOptions.EnableRangeZoom and (Button = mbLeft) then
  begin
    FDragStart := FRidgelineRenderer.NearestPointIndex(C, TPointF.Create(X, Y)); FDragCurrent := FDragStart; FRangeDragging := FDragStart >= 0; MouseCapture := FRangeDragging;
  end
  else if RidgelineOptions.EnableRangeZoom and RidgelineOptions.EnablePan and (Button in [mbRight, mbMiddle]) and FRidgelineRenderer.HasZoom(Model) then
  begin
    FPanAnchor := FRidgelineRenderer.NearestPointIndex(C, TPointF.Create(X, Y)); FPanFirst := RidgelineOptions.ZoomStartIndex; FPanLast := RidgelineOptions.ZoomEndIndex;
    FPanning := FPanAnchor >= 0; MouseCapture := FPanning;
  end;
end;

procedure TThemedRidgelineChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var C: TNimbusChartRenderContext; Layout: TNimbusChartLayout; Before: TNimbusChartHit; Current, Maximum, First, Last, Span: Integer; Ratio: Double;
begin
  if ChartType <> nctRidgeline then begin inherited; Exit end;
  if not Enabled then begin StopInteraction; Exit end;
  if FRangeDragging and not RidgelineOptions.EnableRangeZoom then StopInteraction;
  if FPanning and not RidgelineOptions.EnablePan then StopInteraction;
  if FRangeDragging then
  begin C := CreateRenderContext(Rect(0, 0, Width, Height)); FDragCurrent := FRidgelineRenderer.NearestPointIndex(C, TPointF.Create(X, Y)); Invalidate; Exit end;
  if FPanning then
  begin
    C := CreateRenderContext(Rect(0, 0, Width, Height)); Layout := FRidgelineRenderer.Arrange(C);
    Ratio := EnsureRange((X - Layout.PlotArea.Left) / Max(1, Layout.PlotArea.Width), 0.0, 1.0);
    Current := FPanFirst + Round(Ratio * (FPanLast - FPanFirst)); Maximum := FRidgelineRenderer.MaximumPointIndex(Model);
    Span := FPanLast - FPanFirst; First := EnsureRange(FPanFirst + FPanAnchor - Current, 0, Max(0, Maximum - Span)); Last := First + Span;
    if (RidgelineOptions.ZoomStartIndex <> First) or (RidgelineOptions.ZoomEndIndex <> Last) then ZoomToRange(First, Last); Exit;
  end;
  Before := HoverResult; inherited MouseMove(Shift, X, Y); if not Before.SameElement(HoverResult) then EmitRidge(HoverResult, FOnRidgeHovered);
end;

procedure TThemedRidgelineChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var First, Last: Integer; Hit: TNimbusChartHit; Dragged: Boolean;
begin
  if ChartType <> nctRidgeline then begin inherited; Exit end;
  Dragged := False;
  if FRangeDragging then
  begin
    First := FDragStart; Last := FDragCurrent; Dragged := (First >= 0) and (Last >= 0) and (Abs(First - Last) >= 1) and (Abs(X - FMouseDownLocation.X) > ScaleValue(6));
    FRangeDragging := False; if Dragged then begin CancelPendingInteraction; ZoomToRange(First, Last) end;
  end;
  if FPanning then begin FPanning := False; Dragged := True; CancelPendingInteraction end;
  Hit := HitTestChart(Point(X, Y)); inherited MouseUp(Button, Shift, X, Y); StopInteraction;
  if not Dragged and (Button = mbLeft) then EmitRidge(Hit, FOnRidgeClicked);
end;

function TThemedRidgelineChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var C: TNimbusChartRenderContext; Layout: TNimbusChartLayout; P: TPoint; Anchor, Maximum, First, Last, Span, NewSpan: Integer;
begin
  if (ChartType <> nctRidgeline) or not Enabled or not RidgelineOptions.EnableRangeZoom or not RidgelineOptions.EnableMouseWheelZoom then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  Result := False; Maximum := FRidgelineRenderer.MaximumPointIndex(Model); if Maximum <= 1 then Exit;
  P := ScreenToClient(MousePos); C := CreateRenderContext(Rect(0, 0, Width, Height)); Layout := FRidgelineRenderer.Arrange(C); if not Layout.PlotArea.Contains(P) then Exit;
  Anchor := FRidgelineRenderer.NearestPointIndex(C, TPointF.Create(P.X, P.Y)); First := 0; Last := Maximum;
  if FRidgelineRenderer.HasZoom(Model) then begin First := RidgelineOptions.ZoomStartIndex; Last := RidgelineOptions.ZoomEndIndex end;
  Span := Max(1, Last - First); if WheelDelta > 0 then NewSpan := Max(1, Round(Span * 0.72)) else NewSpan := Max(1, Round(Span * 1.35));
  if NewSpan >= Maximum then ResetRidgelineZoom
  else begin First := EnsureRange(Anchor - NewSpan div 2, 0, Maximum - NewSpan); ZoomToRange(First, First + NewSpan) end; Result := True;
end;

procedure TThemedRidgelineChart.DblClick;
var Index: Integer;
begin
  if ChartType = nctRidgeline then
  begin
    if FRidgelineRenderer.HasZoom(Model) then ResetRidgelineZoom
    else begin Index := HoverResult.PointIndex; if Index >= 0 then ZoomToRange(Index - 3, Index + 3) end;
  end;
  inherited DblClick;
end;

procedure TThemedRidgelineChart.KeyDown(var Key: Word; Shift: TShiftState);
var Ridges: TArray<TNimbusRidgelineRidgeInfo>; I, Index, Delta: Integer;
begin
  if ChartType = nctRidgeline then
  begin
    if Key in [VK_ESCAPE, VK_BACK] then begin ResetRidgelineZoom; ClearSelection; Key := 0; Exit end;
    if Key in [VK_UP, VK_DOWN] then
    begin
      Ridges := GetRidges; if Length(Ridges) = 0 then Exit; Index := -1;
      for I := 0 to High(Ridges) do if Ridges[I].SeriesIndex = SelectedResult.SeriesIndex then begin Index := I; Break end;
      Delta := 1; if Key = VK_UP then Delta := -1; Index := Index + Delta; if Index < 0 then Index := 0;
      if Index <= High(Ridges) then SelectRidge(Ridges[Index].SeriesIndex); Key := 0; Exit;
    end;
  end;
  inherited KeyDown(Key, Shift);
end;

function TThemedRidgelineChart.GetScaleMode: TNimbusRidgelineScaleMode;
begin Result := RidgelineOptions.ScaleMode end;

procedure TThemedRidgelineChart.SetScaleMode(const Value: TNimbusRidgelineScaleMode);
begin RidgelineOptions.ScaleMode := Value end;

function TThemedRidgelineChart.GetCurveMode: TNimbusRidgelineCurveMode;
begin Result := RidgelineOptions.CurveMode end;

procedure TThemedRidgelineChart.SetCurveMode(const Value: TNimbusRidgelineCurveMode);
begin RidgelineOptions.CurveMode := Value end;

function TThemedRidgelineChart.GetOverlap: Single;
begin Result := RidgelineOptions.Overlap end;

procedure TThemedRidgelineChart.SetOverlap(const Value: Single);
begin RidgelineOptions.Overlap := Value end;

function TThemedRidgelineChart.GetRangeZoom: Boolean;
begin Result := RidgelineOptions.EnableRangeZoom end;

procedure TThemedRidgelineChart.SetRangeZoom(const Value: Boolean);
begin RidgelineOptions.EnableRangeZoom := Value end;

function TThemedRidgelineChart.GetWheelZoom: Boolean;
begin Result := RidgelineOptions.EnableMouseWheelZoom end;

procedure TThemedRidgelineChart.SetWheelZoom(const Value: Boolean);
begin RidgelineOptions.EnableMouseWheelZoom := Value end;

function TThemedRidgelineChart.GetRidgeSelection: Boolean;
begin Result := RidgelineOptions.EnableSelection end;

procedure TThemedRidgelineChart.SetRidgeSelection(const Value: Boolean);
begin RidgelineOptions.EnableSelection := Value end;

function TThemedRidgelineChart.GetZoomStart: Integer;
begin Result := RidgelineOptions.ZoomStartIndex end;

procedure TThemedRidgelineChart.SetZoomStart(const Value: Integer);
begin RidgelineOptions.ZoomStartIndex := Value end;

function TThemedRidgelineChart.GetZoomEnd: Integer;
begin Result := RidgelineOptions.ZoomEndIndex end;

procedure TThemedRidgelineChart.SetZoomEnd(const Value: Integer);
begin RidgelineOptions.ZoomEndIndex := Value end;

function TThemedRidgelineChart.GetRichToolTip: Boolean;
begin Result := ShowToolTip end;

procedure TThemedRidgelineChart.SetRichToolTip(const Value: Boolean);
begin ShowToolTip := Value end;

function TThemedRidgelineChart.GetRidgePan: Boolean;
begin Result := RidgelineOptions.EnablePan end;

procedure TThemedRidgelineChart.SetRidgePan(const Value: Boolean);
begin RidgelineOptions.EnablePan := Value; TThemedChart(Self).EnablePan := Value end;

initialization
  RegisterClass(TThemedRidgelineChart);

end.

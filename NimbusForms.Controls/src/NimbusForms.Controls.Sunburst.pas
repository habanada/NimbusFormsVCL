{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Sunburst;

interface

uses Winapi.Windows, System.Classes, System.Types, Vcl.Controls, NimbusForms.Controls.Chart,
  NimbusForms.Charts.Sunburst.Types, NimbusForms.Rendering.Charts, NimbusForms.Rendering.Sunburst;

type
  TNimbusSunburstSegmentEvent = procedure(Sender: TObject; const Segment: TNimbusSunburstSegmentInfo; const Location: TPointF) of object;

  TThemedSunburstChart = class(TThemedChart)
  private
    FRenderer: INimbusChartRenderer;
    FSelectedPath: string;
    FSunburstRenderer: TNimbusSunburstChartRenderer;
    FOnSegmentHovered, FOnSegmentClicked, FOnSegmentSelected: TNimbusSunburstSegmentEvent;
    FOnZoomChanged, FOnMarkingChanged: TNotifyEvent;
    function GetOptions: TNimbusSunburstOptions;
    procedure SetOptions(const Value: TNimbusSunburstOptions);
    function GetEnableSunburstRichToolTip: Boolean;
    procedure SetEnableSunburstRichToolTip(const Value: Boolean);
    function GetEnableSunburstZoom: Boolean;
    procedure SetEnableSunburstZoom(const Value: Boolean);
    function GetZoomOnDoubleClick: Boolean;
    procedure SetZoomOnDoubleClick(const Value: Boolean);
    function GetZoomWithMouseWheel: Boolean;
    procedure SetZoomWithMouseWheel(const Value: Boolean);
    function GetEnableSunburstMarking: Boolean;
    procedure SetEnableSunburstMarking(const Value: Boolean);
    function GetMarkingMode: TNimbusSunburstMarkingMode;
    procedure SetMarkingMode(const Value: TNimbusSunburstMarkingMode);
    function GetZoomPath: string;
    procedure SetZoomPath(const Value: string);
    function GetMarkedPath: string;
    procedure SetMarkedPath(const Value: string);
    procedure EmitSegment(const Hit: TNimbusChartHit; const Event: TNimbusSunburstSegmentEvent);
    function SegmentForHit(const Hit: TNimbusChartHit; out Segment: TNimbusSunburstSegmentInfo): Boolean;
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
    function GetSegments: TArray<TNimbusSunburstSegmentInfo>;
    procedure ZoomToPath(const Path: string);
    procedure ZoomToParent;
    procedure ResetSunburstZoom;
    procedure MarkPath(const Path: string);
    procedure ClearMarking;
    procedure ResetView; override;
  published
    property EnableSunburstRichToolTip: Boolean read GetEnableSunburstRichToolTip write SetEnableSunburstRichToolTip default True;
    property EnableSunburstZoom: Boolean read GetEnableSunburstZoom write SetEnableSunburstZoom default True;
    property ZoomOnDoubleClick: Boolean read GetZoomOnDoubleClick write SetZoomOnDoubleClick default True;
    property ZoomWithMouseWheel: Boolean read GetZoomWithMouseWheel write SetZoomWithMouseWheel default True;
    property EnableSunburstMarking: Boolean read GetEnableSunburstMarking write SetEnableSunburstMarking default True;
    property MarkingMode: TNimbusSunburstMarkingMode read GetMarkingMode write SetMarkingMode default nsmBranch;
    property ZoomPath: string read GetZoomPath write SetZoomPath;
    property MarkedPath: string read GetMarkedPath write SetMarkedPath;
    property SunburstOptions: TNimbusSunburstOptions read GetOptions write SetOptions;
    property OnSunburstSegmentHovered: TNimbusSunburstSegmentEvent read FOnSegmentHovered write FOnSegmentHovered;
    property OnSunburstSegmentClicked: TNimbusSunburstSegmentEvent read FOnSegmentClicked write FOnSegmentClicked;
    property OnSunburstSegmentSelected: TNimbusSunburstSegmentEvent read FOnSegmentSelected write FOnSegmentSelected;
    property OnSunburstZoomChanged: TNotifyEvent read FOnZoomChanged write FOnZoomChanged;
    property OnSunburstMarkingChanged: TNotifyEvent read FOnMarkingChanged write FOnMarkingChanged;
  end;

implementation

uses System.SysUtils, System.Math, NimbusForms.Charts.Types;

constructor TThemedSunburstChart.Create(AOwner: TComponent);
begin inherited; FSunburstRenderer := TNimbusSunburstChartRenderer.Create; FRenderer := FSunburstRenderer; RendererFactory.RegisterFirst(FRenderer); ChartType := nctSunburst; ShowToolTip := True; TabStop := True end;

function TThemedSunburstChart.GetOptions: TNimbusSunburstOptions;
begin Result := Model.SunburstOptions end;

procedure TThemedSunburstChart.SetOptions(const Value: TNimbusSunburstOptions);
begin if Value <> nil then Model.SunburstOptions.Assign(Value) end;

function TThemedSunburstChart.GetSegments: TArray<TNimbusSunburstSegmentInfo>;
var C: TNimbusChartRenderContext; L: TNimbusChartLayout; G: TNimbusSunburstGeometry;
begin C := CreateRenderContext(Rect(0, 0, Width, Height)); L := FSunburstRenderer.Arrange(C); G := FSunburstRenderer.GetGeometry(C, L.PlotArea); Result := G.Segments end;

function TThemedSunburstChart.SegmentForHit(const Hit: TNimbusChartHit; out Segment: TNimbusSunburstSegmentInfo): Boolean;
var Segments: TArray<TNimbusSunburstSegmentInfo>;
begin Result := False; Segment := Default(TNimbusSunburstSegmentInfo); if Hit.Area <> nchaSegment then Exit; Segments := GetSegments; if (Hit.ElementIndex >= 0) and (Hit.ElementIndex < Length(Segments)) then begin Segment := Segments[Hit.ElementIndex]; Result := True end end;

procedure TThemedSunburstChart.EmitSegment(const Hit: TNimbusChartHit; const Event: TNimbusSunburstSegmentEvent);
var Segment: TNimbusSunburstSegmentInfo;
begin if Assigned(Event) and SegmentForHit(Hit, Segment) then Event(Self, Segment, Hit.Location) end;

procedure TThemedSunburstChart.SetSelected(const AHit: TNimbusChartHit);
var Changed: Boolean; Segment: TNimbusSunburstSegmentInfo;
begin
  if ChartType <> nctSunburst then begin inherited; Exit end; if (AHit.Area <> nchaNone) and not SunburstOptions.EnableSelection then Exit;
  Changed := not SelectedResult.SameElement(AHit); FSelectedPath := ''; if SegmentForHit(AHit, Segment) then FSelectedPath := Segment.Path; inherited; if Changed then EmitSegment(AHit, FOnSegmentSelected);
end;

function TThemedSunburstChart.KeepSelectionOnModelChange: Boolean;
var Segment: TNimbusSunburstSegmentInfo;
begin Result := (FSunburstRenderer <> nil) and (ChartType = nctSunburst) and (FSelectedPath <> '') and SunburstOptions.EnableSelection; if Result then Result := SegmentForHit(SelectedResult, Segment) and SameText(Segment.Path, FSelectedPath) end;

procedure TThemedSunburstChart.ZoomToPath(const Path: string);
begin if not SunburstOptions.EnableZoom then Exit; ClearSelection; SunburstOptions.ZoomPath := Path; if Assigned(FOnZoomChanged) then FOnZoomChanged(Self) end;

procedure TThemedSunburstChart.ZoomToParent;
var Path: string; Index: Integer;
begin Path := SunburstOptions.ZoomPath; Index := LastDelimiter('/', Path); if Index <= 0 then Path := '' else Path := Copy(Path, 1, Index - 1); ZoomToPath(Path) end;

procedure TThemedSunburstChart.ResetSunburstZoom;
begin ClearSelection; SunburstOptions.ZoomPath := ''; if Assigned(FOnZoomChanged) then FOnZoomChanged(Self) end;

procedure TThemedSunburstChart.MarkPath(const Path: string);
begin if not SunburstOptions.EnableMarking then Exit; SunburstOptions.MarkedPath := Path; if Assigned(FOnMarkingChanged) then FOnMarkingChanged(Self) end;

procedure TThemedSunburstChart.ClearMarking;
begin SunburstOptions.MarkedPath := ''; if Assigned(FOnMarkingChanged) then FOnMarkingChanged(Self) end;

procedure TThemedSunburstChart.ResetView;
begin inherited; if ChartType = nctSunburst then begin ResetSunburstZoom; ClearMarking end end;

procedure TThemedSunburstChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var Before: TNimbusChartHit;
begin Before := HoverResult; inherited; if (ChartType = nctSunburst) and not Before.SameElement(HoverResult) then EmitSegment(HoverResult, FOnSegmentHovered) end;

procedure TThemedSunburstChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Hit: TNimbusChartHit; Segment: TNimbusSunburstSegmentInfo;
begin
  Hit := HitTestChart(Point(X, Y)); inherited;
  if (ChartType = nctSunburst) and Enabled and (Button = mbLeft) and SegmentForHit(Hit, Segment) then
  begin EmitSegment(Hit, FOnSegmentClicked); if SunburstOptions.EnableMarking then MarkPath(Segment.Path) end;
end;

function TThemedSunburstChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var P: TPoint; Hit: TNimbusChartHit; Segment: TNimbusSunburstSegmentInfo;
begin
  if (ChartType <> nctSunburst) or not Enabled or not SunburstOptions.EnableZoom or not SunburstOptions.ZoomWithMouseWheel then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  Result := False; if WheelDelta < 0 then begin if SunburstOptions.ZoomPath <> '' then begin ZoomToParent; Result := True end; Exit end;
  P := ScreenToClient(MousePos); Hit := HitTestChart(P); if SegmentForHit(Hit, Segment) then begin ZoomToPath(Segment.Path); Result := True end;
end;

procedure TThemedSunburstChart.DblClick;
var Segment: TNimbusSunburstSegmentInfo;
begin
  if (ChartType = nctSunburst) and SunburstOptions.EnableZoom and SunburstOptions.ZoomOnDoubleClick then
    if SegmentForHit(HoverResult, Segment) then if SameText(SunburstOptions.ZoomPath, Segment.Path) then ZoomToParent else ZoomToPath(Segment.Path) else ResetSunburstZoom;
  inherited;
end;

procedure TThemedSunburstChart.KeyDown(var Key: Word; Shift: TShiftState);
var Segments: TArray<TNimbusSunburstSegmentInfo>; Index, Delta: Integer; Segment: TNimbusSunburstSegmentInfo; Hit: TNimbusChartHit;
begin
  if ChartType = nctSunburst then
  begin
    if Key in [VK_ESCAPE, VK_BACK] then begin ResetSunburstZoom; ClearMarking; Key := 0; Exit end;
    if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
    begin
      Segments := GetSegments; Index := SelectedResult.ElementIndex; Delta := 1; if Key in [VK_LEFT, VK_UP] then Delta := -1; Inc(Index, Delta);
      if Index < 0 then Index := 0;
      if (Index >= 0) and (Index < Length(Segments)) then
      begin
        Segment := Segments[Index]; Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.ElementIndex := Index; Hit.SeriesIndex := Segment.SeriesIndex; Hit.PointIndex := Segment.PointIndex;
        Hit.XValue := Segment.ShareOfTotal; Hit.YValue := Segment.Value; Hit.Text := Segment.ToolTipText;
        Hit.Location := TPointF.Create(Segment.Center.X + Cos(DegToRad(Segment.StartAngle + Segment.SweepAngle / 2)) * (Segment.InnerRadius + Segment.OuterRadius) / 2, Segment.Center.Y + Sin(DegToRad(Segment.StartAngle + Segment.SweepAngle / 2)) * (Segment.InnerRadius + Segment.OuterRadius) / 2); SetSelected(Hit);
      end;
      Key := 0; Exit;
    end;
  end;
  inherited;
end;

function TThemedSunburstChart.GetEnableSunburstRichToolTip: Boolean;
begin Result := ShowToolTip end;

procedure TThemedSunburstChart.SetEnableSunburstRichToolTip(const Value: Boolean);
begin ShowToolTip := Value end;

function TThemedSunburstChart.GetEnableSunburstZoom: Boolean;
begin Result := SunburstOptions.EnableZoom end;

procedure TThemedSunburstChart.SetEnableSunburstZoom(const Value: Boolean);
begin SunburstOptions.EnableZoom := Value end;

function TThemedSunburstChart.GetZoomOnDoubleClick: Boolean;
begin Result := SunburstOptions.ZoomOnDoubleClick end;

procedure TThemedSunburstChart.SetZoomOnDoubleClick(const Value: Boolean);
begin SunburstOptions.ZoomOnDoubleClick := Value end;

function TThemedSunburstChart.GetZoomWithMouseWheel: Boolean;
begin Result := SunburstOptions.ZoomWithMouseWheel end;

procedure TThemedSunburstChart.SetZoomWithMouseWheel(const Value: Boolean);
begin SunburstOptions.ZoomWithMouseWheel := Value end;

function TThemedSunburstChart.GetEnableSunburstMarking: Boolean;
begin Result := SunburstOptions.EnableMarking end;

procedure TThemedSunburstChart.SetEnableSunburstMarking(const Value: Boolean);
begin SunburstOptions.EnableMarking := Value end;

function TThemedSunburstChart.GetMarkingMode: TNimbusSunburstMarkingMode;
begin Result := SunburstOptions.MarkingMode end;

procedure TThemedSunburstChart.SetMarkingMode(const Value: TNimbusSunburstMarkingMode);
begin SunburstOptions.MarkingMode := Value end;


function TThemedSunburstChart.GetZoomPath: string;
begin Result := SunburstOptions.ZoomPath end;

procedure TThemedSunburstChart.SetZoomPath(const Value: string);
begin SunburstOptions.ZoomPath := Value end;

function TThemedSunburstChart.GetMarkedPath: string;
begin Result := SunburstOptions.MarkedPath end;

procedure TThemedSunburstChart.SetMarkedPath(const Value: string);
begin SunburstOptions.MarkedPath := Value end;

initialization
  RegisterClass(TThemedSunburstChart);

end.

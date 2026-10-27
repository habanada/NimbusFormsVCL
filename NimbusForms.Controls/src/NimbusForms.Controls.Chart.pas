{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Chart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.SysUtils, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, NimbusForms.Controls.Base, NimbusForms.Controls.ToolTip,
  NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas, NimbusForms.Rendering.Types,
  NimbusForms.Charts.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Charts.ProgressRingGrid.Types, NimbusForms.Rendering.Charts;

type
  TNimbusChartElementEvent = procedure(Sender: TObject; const AHit: TNimbusChartHit) of object;

  TCustomThemedChart = class(TCustomNimbusControl)
  private
    FModel: TNimbusChartModel;
    FFactory: TNimbusChartRendererFactory;
    FToolTip: NimbusForms.Controls.ToolTip.TThemedToolTip;
    FTimer: TTimer;
    FHovered, FSelected: TNimbusChartHit;
    FXView, FYView: TNimbusChartRange;
    FEnableZoom, FEnablePan, FEnableDragPan, FShowCrosshair, FShowSelectionPanel: Boolean;
    FDragging, FDragCandidate, FDragMoved, FPendingClick: Boolean;
    FColorMode: TNimbusChartColorMode;
    FThemeInfluence: Integer;
    FShowGlow: Boolean;
    FAdaptivePalette: TNimbusChartPalette;
    FPressedHit: TNimbusChartHit;
    FDragOrigin: TPoint;
    FDragXRange, FDragYRange: TNimbusChartRange;
    FDragMapX, FDragMapY: Single;
    FAnimationStart: UInt64;
    FAnimationProgress: Double;
    FOnPointHovered, FOnPointClicked, FOnChartClicked, FOnSelectionChanged: TNimbusChartElementEvent;
    FOnElementHovered, FOnElementClicked, FOnElementRightClicked, FOnElementDoubleClicked, FOnElementSelected: TNimbusChartElementEvent;
    function IsCartesian: Boolean;
    function NeedsContinuousAnimation: Boolean;
    function HorizontalAxis: TNimbusChartAxis;
    function VerticalAxis: TNimbusChartAxis;
    procedure SetUseThemePaletteForChart(const AValue: Boolean);
    function GetUseThemePaletteForChart: Boolean;
    procedure SetColorMode(const AValue: TNimbusChartColorMode);
    procedure SetThemeInfluence(const AValue: Integer);
    procedure SetShowGlow(const AValue: Boolean);
    procedure ModelChanged(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure SetModel(const AValue: TNimbusChartModel);
    procedure SetShowCrosshair(const AValue: Boolean);
    procedure SetShowSelectionPanel(const AValue: Boolean);
    procedure SetEnablePan(const AValue: Boolean);
    procedure SetEnableDragPan(const AValue: Boolean);
    procedure StopDrag;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    function GetChartType: TNimbusChartType;
    procedure SetChartType(const AValue: TNimbusChartType);
    function GetTitle: string;
    procedure SetTitle(const AValue: string);
    function GetSubtitle: string;
    procedure SetSubtitle(const AValue: string);
    function GetShowLegend: Boolean;
    procedure SetShowLegend(const AValue: Boolean);
    function GetShowToolTip: Boolean;
    procedure SetShowToolTip(const AValue: Boolean);
    function GetShowBorder: Boolean;
    procedure SetShowBorder(const AValue: Boolean);
    function GetShowGrid: Boolean;
    procedure SetShowGrid(const AValue: Boolean);
    function GetShowAxes: Boolean;
    procedure SetShowAxes(const AValue: Boolean);
    function GetShowValues: Boolean;
    procedure SetShowValues(const AValue: Boolean);
    function GetShowAnimation: Boolean;
    procedure SetShowAnimation(const AValue: Boolean);
    function GetShowSecondaryYAxis: Boolean;
    procedure SetShowSecondaryYAxis(const AValue: Boolean);
    function GetXAxisScale: TNimbusChartAxisScale;
    procedure SetXAxisScale(const AValue: TNimbusChartAxisScale);
    function GetXAxisPowerExponent: Double;
    procedure SetXAxisPowerExponent(const AValue: Double);
    function GetXAxisSymmetricLogThreshold: Double;
    procedure SetXAxisSymmetricLogThreshold(const AValue: Double);
    function GetXAxisShowMinorGridLines: Boolean;
    procedure SetXAxisShowMinorGridLines(const AValue: Boolean);
    function GetXAxisMinorTickMode: TNimbusChartLogarithmicMinorTickMode;
    procedure SetXAxisMinorTickMode(const AValue: TNimbusChartLogarithmicMinorTickMode);
    function GetXAxisLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode;
    procedure SetXAxisLogarithmicLabelMode(const AValue: TNimbusChartLogarithmicLabelMode);
    function GetXAxisLogarithmicBase: Double;
    procedure SetXAxisLogarithmicBase(const AValue: Double);
    function GetXAxisAutomaticLogarithmicThreshold: Double;
    procedure SetXAxisAutomaticLogarithmicThreshold(const AValue: Double);
    function GetXAxisInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior;
    procedure SetXAxisInvalidLogValueBehavior(const AValue: TNimbusChartInvalidLogValueBehavior);
    function GetXAxisValueType: TNimbusChartAxisValueType;
    procedure SetXAxisValueType(const AValue: TNimbusChartAxisValueType);
    function GetXAxisDateTimeLabelFormat: string;
    procedure SetXAxisDateTimeLabelFormat(const AValue: string);
    function GetYAxisScale: TNimbusChartAxisScale;
    procedure SetYAxisScale(const AValue: TNimbusChartAxisScale);
    function GetYAxisPowerExponent: Double;
    procedure SetYAxisPowerExponent(const AValue: Double);
    function GetYAxisSymmetricLogThreshold: Double;
    procedure SetYAxisSymmetricLogThreshold(const AValue: Double);
    function GetYAxisShowMinorGridLines: Boolean;
    procedure SetYAxisShowMinorGridLines(const AValue: Boolean);
    function GetYAxisMinorTickMode: TNimbusChartLogarithmicMinorTickMode;
    procedure SetYAxisMinorTickMode(const AValue: TNimbusChartLogarithmicMinorTickMode);
    function GetYAxisLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode;
    procedure SetYAxisLogarithmicLabelMode(const AValue: TNimbusChartLogarithmicLabelMode);
    function GetYAxisLogarithmicBase: Double;
    procedure SetYAxisLogarithmicBase(const AValue: Double);
    function GetYAxisAutomaticLogarithmicThreshold: Double;
    procedure SetYAxisAutomaticLogarithmicThreshold(const AValue: Double);
    function GetYAxisInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior;
    procedure SetYAxisInvalidLogValueBehavior(const AValue: TNimbusChartInvalidLogValueBehavior);
    function GetYAxisValueType: TNimbusChartAxisValueType;
    procedure SetYAxisValueType(const AValue: TNimbusChartAxisValueType);
    function GetYAxisDateTimeLabelFormat: string;
    procedure SetYAxisDateTimeLabelFormat(const AValue: string);
  protected
    procedure SetSelected(const AHit: TNimbusChartHit); virtual;
    function KeepSelectionOnModelChange: Boolean; virtual;
    procedure CancelPendingInteraction;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure Click; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DestroyWnd; override;
    procedure CreateWnd; override;
    function CreateRenderContext(const ABounds: TRect): TNimbusChartRenderContext; virtual;
    procedure RenderChart(const ACanvas: INimbusRenderCanvas; const ABounds: TRect);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure ApplyAppearance(const AAppearance: TNimbusChartAppearance);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ResetView; virtual;
    procedure ClearSelection; virtual;
    procedure PanChartBy(const AHorizontalRatio, AVerticalRatio: Double);
    function HitTestChart(const ALocation: TPoint): TNimbusChartHit;
    function RenderToBitmap(const AWidth, AHeight: Integer): TBitmap; overload;
    function RenderToBitmap: TBitmap; overload;
    procedure ExportPng(const AFileName: string; const AWidth, AHeight: Integer); overload;
    procedure ExportPng(const AFileName: string); overload;
    function ExportSvg(const AWidth, AHeight: Integer): string; overload;
    procedure ExportSvg(const AFileName: string; const AWidth, AHeight: Integer); overload;
    property RendererFactory: TNimbusChartRendererFactory read FFactory;
    property HoverResult: TNimbusChartHit read FHovered;
    property SelectedResult: TNimbusChartHit read FSelected;
    property UseThemePaletteForChart: Boolean read GetUseThemePaletteForChart write SetUseThemePaletteForChart default True;
    property ColorMode: TNimbusChartColorMode read FColorMode write SetColorMode default nccTheme;
    property ThemeInfluence: Integer read FThemeInfluence write SetThemeInfluence default 12;
    property ShowGlow: Boolean read FShowGlow write SetShowGlow default False;
    property Model: TNimbusChartModel read FModel write SetModel;
    property EnableZoom: Boolean read FEnableZoom write FEnableZoom default True;
    property EnablePan: Boolean read FEnablePan write SetEnablePan default True;
    property EnableDragPan: Boolean read FEnableDragPan write SetEnableDragPan default True;
    property ShowCrosshair: Boolean read FShowCrosshair write SetShowCrosshair default False;
    property ShowSelectionPanel: Boolean read FShowSelectionPanel write SetShowSelectionPanel default True;
    property ChartType: TNimbusChartType read GetChartType write SetChartType;
    property Title: string read GetTitle write SetTitle;
    property Subtitle: string read GetSubtitle write SetSubtitle;
    property ShowLegend: Boolean read GetShowLegend write SetShowLegend;
    property ShowToolTip: Boolean read GetShowToolTip write SetShowToolTip;
    property ShowBorder: Boolean read GetShowBorder write SetShowBorder;
    property ShowGrid: Boolean read GetShowGrid write SetShowGrid;
    property ShowAxes: Boolean read GetShowAxes write SetShowAxes;
    property ShowValues: Boolean read GetShowValues write SetShowValues;
    property ShowAnimation: Boolean read GetShowAnimation write SetShowAnimation;
    property ShowSecondaryYAxis: Boolean read GetShowSecondaryYAxis write SetShowSecondaryYAxis;
    property XAxisScale: TNimbusChartAxisScale read GetXAxisScale write SetXAxisScale;
    property XAxisPowerExponent: Double read GetXAxisPowerExponent write SetXAxisPowerExponent;
    property XAxisSymmetricLogThreshold: Double read GetXAxisSymmetricLogThreshold write SetXAxisSymmetricLogThreshold;
    property XAxisShowMinorGridLines: Boolean read GetXAxisShowMinorGridLines write SetXAxisShowMinorGridLines;
    property XAxisMinorTickMode: TNimbusChartLogarithmicMinorTickMode read GetXAxisMinorTickMode write SetXAxisMinorTickMode;
    property XAxisLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode read GetXAxisLogarithmicLabelMode write SetXAxisLogarithmicLabelMode;
    property XAxisLogarithmicBase: Double read GetXAxisLogarithmicBase write SetXAxisLogarithmicBase;
    property XAxisAutomaticLogarithmicThreshold: Double read GetXAxisAutomaticLogarithmicThreshold write SetXAxisAutomaticLogarithmicThreshold;
    property XAxisInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior read GetXAxisInvalidLogValueBehavior write SetXAxisInvalidLogValueBehavior;
    property XAxisValueType: TNimbusChartAxisValueType read GetXAxisValueType write SetXAxisValueType;
    property XAxisDateTimeLabelFormat: string read GetXAxisDateTimeLabelFormat write SetXAxisDateTimeLabelFormat;
    property YAxisScale: TNimbusChartAxisScale read GetYAxisScale write SetYAxisScale;
    property YAxisPowerExponent: Double read GetYAxisPowerExponent write SetYAxisPowerExponent;
    property YAxisSymmetricLogThreshold: Double read GetYAxisSymmetricLogThreshold write SetYAxisSymmetricLogThreshold;
    property YAxisShowMinorGridLines: Boolean read GetYAxisShowMinorGridLines write SetYAxisShowMinorGridLines;
    property YAxisMinorTickMode: TNimbusChartLogarithmicMinorTickMode read GetYAxisMinorTickMode write SetYAxisMinorTickMode;
    property YAxisLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode read GetYAxisLogarithmicLabelMode write SetYAxisLogarithmicLabelMode;
    property YAxisLogarithmicBase: Double read GetYAxisLogarithmicBase write SetYAxisLogarithmicBase;
    property YAxisAutomaticLogarithmicThreshold: Double read GetYAxisAutomaticLogarithmicThreshold write SetYAxisAutomaticLogarithmicThreshold;
    property YAxisInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior read GetYAxisInvalidLogValueBehavior write SetYAxisInvalidLogValueBehavior;
    property YAxisValueType: TNimbusChartAxisValueType read GetYAxisValueType write SetYAxisValueType;
    property YAxisDateTimeLabelFormat: string read GetYAxisDateTimeLabelFormat write SetYAxisDateTimeLabelFormat;
    property OnPointHovered: TNimbusChartElementEvent read FOnPointHovered write FOnPointHovered;
    property OnPointClicked: TNimbusChartElementEvent read FOnPointClicked write FOnPointClicked;
    property OnChartClicked: TNimbusChartElementEvent read FOnChartClicked write FOnChartClicked;
    property OnSelectionChanged: TNimbusChartElementEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnChartElementHovered: TNimbusChartElementEvent read FOnElementHovered write FOnElementHovered;
    property OnChartElementClicked: TNimbusChartElementEvent read FOnElementClicked write FOnElementClicked;
    property OnChartElementRightClicked: TNimbusChartElementEvent read FOnElementRightClicked write FOnElementRightClicked;
    property OnChartElementDoubleClicked: TNimbusChartElementEvent read FOnElementDoubleClicked write FOnElementDoubleClicked;
    property OnChartElementSelected: TNimbusChartElementEvent read FOnElementSelected write FOnElementSelected;
  end;

  TThemedChart = class(TCustomThemedChart)
  published
    property Align;
    property Anchors;
    property Action;
    property Constraints;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Enabled;
    property Visible;
    property PopupMenu;
    property Model;
    property UseThemePaletteForChart;
    property ColorMode;
    property ThemeInfluence;
    property ShowGlow;
    property EnableZoom;
    property EnablePan;
    property EnableDragPan;
    property ShowCrosshair;
    property ShowSelectionPanel;
    property ChartType;
    property Title;
    property Subtitle;
    property ShowLegend;
    property ShowToolTip;
    property ShowBorder;
    property ShowGrid;
    property ShowAxes;
    property ShowValues;
    property ShowAnimation;
    property ShowSecondaryYAxis;
    property XAxisScale;
    property XAxisPowerExponent;
    property XAxisSymmetricLogThreshold;
    property XAxisShowMinorGridLines;
    property XAxisMinorTickMode;
    property XAxisLogarithmicLabelMode;
    property XAxisLogarithmicBase;
    property XAxisAutomaticLogarithmicThreshold;
    property XAxisInvalidLogValueBehavior;
    property XAxisValueType;
    property XAxisDateTimeLabelFormat;
    property YAxisScale;
    property YAxisPowerExponent;
    property YAxisSymmetricLogThreshold;
    property YAxisShowMinorGridLines;
    property YAxisMinorTickMode;
    property YAxisLogarithmicLabelMode;
    property YAxisLogarithmicBase;
    property YAxisAutomaticLogarithmicThreshold;
    property YAxisInvalidLogValueBehavior;
    property YAxisValueType;
    property YAxisDateTimeLabelFormat;
    property OnPointHovered;
    property OnPointClicked;
    property OnChartClicked;
    property OnSelectionChanged;
    property OnChartElementHovered;
    property OnChartElementClicked;
    property OnChartElementRightClicked;
    property OnChartElementDoubleClicked;
    property OnChartElementSelected;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
  end;

implementation

uses Vcl.Imaging.pngimage, NimbusForms.Charts.Violin.Types;

constructor TCustomThemedChart.Create(AOwner: TComponent);
begin
  inherited;
  Width := 520; Height := 320; TabStop := True;
  FModel := TNimbusChartModel.Create; FModel.OnChange := ModelChanged;
  FFactory := TNimbusChartRendererFactory.Create;
  FToolTip := NimbusForms.Controls.ToolTip.TThemedToolTip.Create(Self);
  FTimer := TTimer.Create(Self); FTimer.Enabled := False; FTimer.Interval := 15; FTimer.OnTimer := TimerTick;
  FHovered := TNimbusChartHit.None; FSelected := TNimbusChartHit.None;
  FXView := TNimbusChartRange.Empty; FYView := TNimbusChartRange.Empty;
  FEnableZoom := True; FEnablePan := True; FEnableDragPan := True; FShowSelectionPanel := True;
  FAnimationProgress := 1; FColorMode := nccTheme; FThemeInfluence := 12; FAdaptivePalette := TNimbusChartPalette.Create;
end;

destructor TCustomThemedChart.Destroy;
begin
  FTimer.Enabled := False; StopDrag;
  FToolTip.Free; FToolTip := nil;
  FModel.OnChange := nil; FModel.Free; FModel := nil;
  FAdaptivePalette.Free; FFactory.Free; inherited;
end;

procedure TCustomThemedChart.SetShowGlow(const AValue: Boolean);
begin if FShowGlow = AValue then Exit; FShowGlow := AValue; Invalidate end;

procedure TCustomThemedChart.ApplyAppearance(const AAppearance: TNimbusChartAppearance);
begin
  BeginUpdate;
  try
    case AAppearance of
      ncaVsIdeLight: FModel.Palette.ApplyLightDefaults;
      ncaVsIdeDark: FModel.Palette.ApplyDarkDefaults;
      ncaGlowing: FModel.Palette.ApplyGlowingDefaults;
    end;
    ShowGlow := AAppearance = ncaGlowing;
    ColorMode := nccCustom;
  finally EndUpdate end;
end;

procedure TCustomThemedChart.ApplyTheme(const APalette: TThemePalette);
begin
  inherited; if FToolTip <> nil then FToolTip.ApplyTheme(APalette);
end;

function TCustomThemedChart.GetUseThemePaletteForChart: Boolean;
begin Result := FColorMode = nccTheme end;

procedure TCustomThemedChart.SetUseThemePaletteForChart(const AValue: Boolean);
begin if AValue then SetColorMode(nccTheme) else if FColorMode = nccTheme then SetColorMode(nccCustom) end;

procedure TCustomThemedChart.SetColorMode(const AValue: TNimbusChartColorMode);
begin if FColorMode = AValue then Exit; FColorMode := AValue; Invalidate end;

procedure TCustomThemedChart.SetThemeInfluence(const AValue: Integer);
var V: Integer;
begin V := EnsureRange(AValue, 0, 100); if FThemeInfluence = V then Exit; FThemeInfluence := V; Invalidate end;

procedure TCustomThemedChart.SetModel(const AValue: TNimbusChartModel);
begin
  if AValue <> nil then FModel.Assign(AValue);
end;

function TCustomThemedChart.KeepSelectionOnModelChange: Boolean;
begin Result := False end;

procedure TCustomThemedChart.ModelChanged(Sender: TObject);
begin
  if csDestroying in ComponentState then Exit;
  FHovered := TNimbusChartHit.None; if not KeepSelectionOnModelChange then FSelected := TNimbusChartHit.None;
  FToolTip.ClearInfo(Self);
  if NeedsContinuousAnimation and HandleAllocated and Enabled and not (csDesigning in ComponentState) then FTimer.Enabled := True
  else if FModel.Options.ShowAnimation and HandleAllocated and Enabled and not (csDesigning in ComponentState) then
  begin FAnimationProgress := 0; FAnimationStart := GetTickCount64; FTimer.Enabled := True end
  else begin FAnimationProgress := 1; FTimer.Enabled := False end;
  Invalidate;
end;

procedure TCustomThemedChart.TimerTick(Sender: TObject);
var T: Double;
begin
  if NeedsContinuousAnimation then begin FAnimationProgress := (GetTickCount64 mod 2000) / 2000; Invalidate; Exit end;
  T := Min(1.0, (GetTickCount64 - FAnimationStart) / 220);
  FAnimationProgress := 1 - Power(1 - T, 3);
  if T >= 1 then FTimer.Enabled := False;
  Invalidate;
end;

function TCustomThemedChart.NeedsContinuousAnimation: Boolean;
var I, J: Integer;
begin
  Result := False; if (FModel = nil) or (FModel.ChartType <> nctProgressRingGrid) then Exit;
  for I := 0 to FModel.ProgressRingGrid.Items.Count - 1 do if FModel.ProgressRingGrid.Items[I].Visible then
  begin
    if FModel.ProgressRingGrid.Items[I].IsIndeterminate or (FModel.ProgressRingGrid.Items[I].RenderStyle = nprsIndeterminate) or (FModel.ProgressRingGrid.RenderStyle = nprsIndeterminate) then Exit(True);
    for J := 0 to FModel.ProgressRingGrid.Items[I].Layers.Count - 1 do if FModel.ProgressRingGrid.Items[I].Layers[J].Visible and (FModel.ProgressRingGrid.Items[I].Layers[J].RenderStyle = nprsIndeterminate) then Exit(True);
  end;
end;

procedure TCustomThemedChart.CreateWnd;
begin inherited; if NeedsContinuousAnimation and Enabled and not (csDesigning in ComponentState) then FTimer.Enabled := True end;

procedure TCustomThemedChart.BeginUpdate;
begin FModel.BeginUpdate end;

procedure TCustomThemedChart.EndUpdate;
begin FModel.EndUpdate end;

procedure TCustomThemedChart.SetShowCrosshair(const AValue: Boolean);
begin if FShowCrosshair <> AValue then begin FShowCrosshair := AValue; Invalidate end end;

procedure TCustomThemedChart.SetShowSelectionPanel(const AValue: Boolean);
begin if FShowSelectionPanel <> AValue then begin FShowSelectionPanel := AValue; Invalidate end end;

procedure TCustomThemedChart.SetEnablePan(const AValue: Boolean);
begin FEnablePan := AValue; if not AValue then StopDrag end;

procedure TCustomThemedChart.SetEnableDragPan(const AValue: Boolean);
begin FEnableDragPan := AValue; if not AValue then StopDrag end;

procedure TCustomThemedChart.StopDrag;
begin
  FDragging := False; FDragCandidate := False; FPendingClick := False; if HandleAllocated and MouseCapture then MouseCapture := False;
end;

procedure TCustomThemedChart.DestroyWnd;
begin
  StopDrag; FTimer.Enabled := False; FAnimationProgress := 1;
  FHovered := TNimbusChartHit.None; if FToolTip <> nil then FToolTip.ClearInfo(Self);
  inherited;
end;

function TCustomThemedChart.CreateRenderContext(const ABounds: TRect): TNimbusChartRenderContext;
begin
  Result := Default(TNimbusChartRenderContext); Result.Model := FModel;
  Result.ShowGlow := FShowGlow;
  if FColorMode = nccTheme then
  begin if Palette = nil then FAdaptivePalette.ApplyLightDefaults else FAdaptivePalette.ApplyTheme(Palette); Result.ChartPalette := FAdaptivePalette end;
  if FColorMode = nccCustom then Result.ChartPalette := FModel.Palette;
  if FColorMode = nccAdaptiveCustom then
  begin
    FAdaptivePalette.Assign(FModel.Palette); FAdaptivePalette.ApplyThemeBlend(Palette, FThemeInfluence);
    Result.ChartPalette := FAdaptivePalette; Result.ColorInfluence := FThemeInfluence;
  end;
  Result.Palette := Palette; Result.Font := Font; Result.Bounds := ABounds;
  Result.PPI := CurrentPPI; Result.Enabled := Enabled; Result.Hovered := FHovered; Result.Selected := FSelected;
  Result.XView := FXView; Result.YView := FYView; Result.AnimationProgress := FAnimationProgress;
end;

procedure TCustomThemedChart.RenderChart(const ACanvas: INimbusRenderCanvas; const ABounds: TRect);
var R: INimbusChartRenderer; C: TNimbusChartRenderContext; L: TNimbusChartLayout; B: TRect; P: TPoint; Col: TThemeColor;
begin
  C := CreateRenderContext(ABounds); R := FFactory.GetRenderer(FModel.ChartType);
  if R = nil then raise EArgumentException.Create('No renderer is registered for this chart type');
  R.Render(ACanvas, C); L := R.Arrange(C);
  if FShowCrosshair and (FHovered.Area <> nchaNone) then
  begin
    P := Point(Round(FHovered.Location.X), Round(FHovered.Location.Y));
    if L.PlotArea.Contains(P) then
    begin
      Col := NimbusColorWithAlpha(NimbusControlForeColor(Palette), 120);
      ACanvas.DrawDashedLine(Col, P.X, L.PlotArea.Top, P.X, L.PlotArea.Bottom, 1, 2);
      ACanvas.DrawDashedLine(Col, L.PlotArea.Left, P.Y, L.PlotArea.Right, P.Y, 1, 2);
    end;
  end;
  if FShowSelectionPanel and (FSelected.Text <> '') then
  begin
    B := Rect(L.PlotArea.Left + ScaleValue(8), L.PlotArea.Top + ScaleValue(8),
      Min(L.PlotArea.Right, L.PlotArea.Left + ScaleValue(260)), L.PlotArea.Top + ScaleValue(48));
    ACanvas.FillRoundedRectangle(NimbusControlBackColor(Palette), B, ScaleValue(4));
    ACanvas.DrawRoundedRectangle(NimbusControlBorderColor(Palette), B, ScaleValue(4));
    B.Inflate(-ScaleValue(6), -ScaleValue(4));
    ACanvas.DrawText(FSelected.Text, Font, NimbusControlForeColor(Palette), B, [ntfWordWrap, ntfEndEllipsis, ntfNoPrefix]);
  end;
end;

procedure TCustomThemedChart.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try RenderChart(RenderCanvas, Rect(0, 0, Width, Height)) finally RenderCanvas.EndRender end;
end;

function TCustomThemedChart.HitTestChart(const ALocation: TPoint): TNimbusChartHit;
var R: INimbusChartRenderer;
begin
  R := FFactory.GetRenderer(FModel.ChartType); Result := TNimbusChartHit.None;
  if R <> nil then Result := R.HitTest(CreateRenderContext(Rect(0, 0, Width, Height)), TPointF.Create(ALocation.X, ALocation.Y));
end;

procedure TCustomThemedChart.SetSelected(const AHit: TNimbusChartHit);
begin
  if FSelected.SameElement(AHit) then Exit;
  FSelected := AHit; Invalidate;
  if Assigned(FOnSelectionChanged) then FOnSelectionChanged(Self, AHit);
  if Assigned(FOnElementSelected) then FOnElementSelected(Self, AHit);
end;

procedure TCustomThemedChart.CancelPendingInteraction;
begin FPendingClick := False; FDragCandidate := False; FDragMoved := True; StopDrag end;

procedure TCustomThemedChart.ClearSelection;
begin SetSelected(TNimbusChartHit.None) end;

procedure TCustomThemedChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var H: TNimbusChartHit; Changed: Boolean; R: INimbusChartRenderer; L: TNimbusChartLayout; DX, DY: Double;
begin
  inherited; if not Enabled then Exit;
  if FDragCandidate and ((Abs(X - FDragOrigin.X) >= ScaleValue(4)) or (Abs(Y - FDragOrigin.Y) >= ScaleValue(4))) then
  begin FDragging := True; FDragCandidate := False; FDragMoved := True; MouseCapture := True; FToolTip.ClearInfo(Self) end;
  if FDragging then
  begin
    R := FFactory.GetRenderer(FModel.ChartType); if R = nil then Exit;
    L := R.Arrange(CreateRenderContext(Rect(0, 0, Width, Height)));
    if FModel.ChartType in [nctChoroplethMap, nctCountryMap] then
    begin
      FModel.BeginUpdate;
      try FModel.Options.MapOffsetX := FDragMapX + (X - FDragOrigin.X) / Max(1, L.PlotArea.Width);
        FModel.Options.MapOffsetY := FDragMapY + (Y - FDragOrigin.Y) / Max(1, L.PlotArea.Height)
      finally FModel.EndUpdate end; Exit;
    end;
    DX := (FDragOrigin.X - X) / Max(1, L.PlotArea.Width); DY := (Y - FDragOrigin.Y) / Max(1, L.PlotArea.Height);
    FXView := TNimbusChartRange.Create(HorizontalAxis.DenormalizeWithinRange(DX, FDragXRange), HorizontalAxis.DenormalizeWithinRange(1 + DX, FDragXRange));
    FYView := TNimbusChartRange.Create(VerticalAxis.DenormalizeWithinRange(DY, FDragYRange), VerticalAxis.DenormalizeWithinRange(1 + DY, FDragYRange));
    Invalidate; Exit;
  end;
  H := HitTestChart(Point(X, Y)); Changed := not H.SameElement(FHovered); FHovered := H;
  if FModel.Options.ShowToolTips and (H.Text <> '') then FToolTip.SetToolTip(Self, H.Text) else FToolTip.ClearInfo(Self);
  if Changed then
  begin
    if Assigned(FOnElementHovered) then FOnElementHovered(Self, H);
    if (H.PointIndex >= 0) and Assigned(FOnPointHovered) then FOnPointHovered(Self, H);
  end;
  if Changed or FShowCrosshair then Invalidate;
end;

function TCustomThemedChart.HorizontalAxis: TNimbusChartAxis;
begin
  Result := FModel.XAxis;
  if (FModel.ChartType = nctViolinPlot) and (FModel.ViolinOptions.Orientation = nvoHorizontal) then Result := FModel.YAxis;
end;

function TCustomThemedChart.VerticalAxis: TNimbusChartAxis;
begin
  Result := FModel.YAxis;
  if (FModel.ChartType = nctViolinPlot) and (FModel.ViolinOptions.Orientation = nvoHorizontal) then Result := FModel.XAxis;
end;

function TCustomThemedChart.IsCartesian: Boolean;
begin Result := FModel.ChartType in [nctLine, nctArea, nctLineScatter, nctBar, nctColumn, nctScatter, nctBubble, nctBoxPlot, nctViolinPlot, nctCandlestick, nctOhlc] end;

procedure TCustomThemedChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var H: TNimbusChartHit; R: INimbusChartRenderer; L: TNimbusChartLayout;
begin
  inherited; if not Enabled then Exit; if CanFocus then SetFocus;
  H := HitTestChart(Point(X, Y)); FDragMoved := False;
  if Button = mbRight then begin if Assigned(FOnElementRightClicked) then FOnElementRightClicked(Self, H); Exit end;
  if Button = mbLeft then begin FPressedHit := H; FPendingClick := True end;
  if FEnablePan and (IsCartesian or ((FModel.ChartType in [nctChoroplethMap, nctCountryMap]) and FModel.Options.EnableMapPan)) and ((Button = mbMiddle) or ((Button = mbLeft) and FEnableDragPan)) and (H.Area <> nchaLegend) then
  begin
    R := FFactory.GetRenderer(FModel.ChartType); if R = nil then Exit;
    L := R.Arrange(CreateRenderContext(Rect(0, 0, Width, Height))); if not L.PlotArea.Contains(Point(X, Y)) then Exit;
    FDragOrigin := Point(X, Y); FDragXRange := L.XRange; FDragYRange := L.YRange;
    FDragMapX := FModel.Options.MapOffsetX; FDragMapY := FModel.Options.MapOffsetY;
    if (Button = mbMiddle) or (ssShift in Shift) then
    begin FDragging := True; FDragMoved := True; MouseCapture := True; FToolTip.ClearInfo(Self) end
    else FDragCandidate := True;
  end;
end;

procedure TCustomThemedChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var H: TNimbusChartHit; ClickPending: Boolean;
begin
  ClickPending := FPendingClick and not FDragMoved and (Button = mbLeft) and Enabled;
  H := FPressedHit; FPendingClick := False; FDragCandidate := False;
  if FDragging then StopDrag;
  inherited;
  if not ClickPending or not H.SameElement(HitTestChart(Point(X, Y))) then Exit;
  if (H.Area = nchaLegend) and (H.SeriesIndex >= 0) and (H.SeriesIndex < FModel.Series.Count) then
  begin
    if (H.PointIndex >= 0) and (H.PointIndex < FModel.Series[H.SeriesIndex].Points.Count) then
      FModel.Series[H.SeriesIndex].Points[H.PointIndex].Visible := not FModel.Series[H.SeriesIndex].Points[H.PointIndex].Visible
    else FModel.Series[H.SeriesIndex].Visible := not FModel.Series[H.SeriesIndex].Visible;
  end
  else SetSelected(H);
  if Assigned(FOnChartClicked) then FOnChartClicked(Self, H);
  if Assigned(FOnElementClicked) then FOnElementClicked(Self, H);
  if (H.PointIndex >= 0) and Assigned(FOnPointClicked) then FOnPointClicked(Self, H);
end;

procedure TCustomThemedChart.Click;
begin if not FDragMoved then inherited end;

procedure TCustomThemedChart.DblClick;
begin
  inherited; if Assigned(FOnElementDoubleClicked) then FOnElementDoubleClicked(Self, FHovered);
  if FHovered.Area = nchaPlotArea then ResetView;
end;

procedure TCustomThemedChart.CMMouseLeave(var Message: TMessage);
begin
  inherited; if FDragging then Exit;
  FHovered := TNimbusChartHit.None; FToolTip.ClearInfo(Self); Invalidate;
end;

procedure TCustomThemedChart.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if (not Enabled) and (FTimer <> nil) then
  begin StopDrag; FTimer.Enabled := False; FAnimationProgress := 1; FHovered := TNimbusChartHit.None; FToolTip.ClearInfo(Self) end;
  if Enabled and HandleAllocated and NeedsContinuousAnimation and not (csDesigning in ComponentState) then FTimer.Enabled := True;
end;

procedure TCustomThemedChart.WMCaptureChanged(var Message: TMessage);
begin inherited; FDragging := False; FDragCandidate := False; FPendingClick := False end;

procedure TCustomThemedChart.ResetView;
begin
  StopDrag; FXView := TNimbusChartRange.Empty; FYView := TNimbusChartRange.Empty;
  if FModel.ChartType in [nctChoroplethMap, nctCountryMap] then
  begin FModel.BeginUpdate; try FModel.Options.MapZoom := 1; FModel.Options.MapOffsetX := 0; FModel.Options.MapOffsetY := 0 finally FModel.EndUpdate end end;
  Invalidate;
end;

procedure TCustomThemedChart.PanChartBy(const AHorizontalRatio, AVerticalRatio: Double);
var R: INimbusChartRenderer; L: TNimbusChartLayout;
begin
  if not FEnablePan then Exit;
  if FModel.ChartType in [nctChoroplethMap, nctCountryMap] then
  begin
    if not FModel.Options.EnableMapPan then Exit; FModel.BeginUpdate;
    try FModel.Options.MapOffsetX := FModel.Options.MapOffsetX - AHorizontalRatio; FModel.Options.MapOffsetY := FModel.Options.MapOffsetY + AVerticalRatio finally FModel.EndUpdate end; Exit;
  end;
  if not IsCartesian then Exit;
  R := FFactory.GetRenderer(FModel.ChartType); if R = nil then Exit;
  L := R.Arrange(CreateRenderContext(Rect(0, 0, Width, Height)));
  FXView := TNimbusChartRange.Create(HorizontalAxis.DenormalizeWithinRange(AHorizontalRatio, L.XRange), HorizontalAxis.DenormalizeWithinRange(1 + AHorizontalRatio, L.XRange));
  FYView := TNimbusChartRange.Create(VerticalAxis.DenormalizeWithinRange(AVerticalRatio, L.YRange), VerticalAxis.DenormalizeWithinRange(1 + AVerticalRatio, L.YRange)); Invalidate;
end;

function TCustomThemedChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var R: INimbusChartRenderer; L: TNimbusChartLayout; P: TPoint; Factor, RX, RY: Double;
begin
  Result := inherited; if not FEnableZoom or not Enabled then Exit;
  if (FModel.ChartType in [nctChoroplethMap, nctCountryMap]) and FModel.Options.EnableMapZoom then
  begin
    R := FFactory.GetRenderer(FModel.ChartType); if R = nil then Exit; P := ScreenToClient(MousePos);
    L := R.Arrange(CreateRenderContext(Rect(0, 0, Width, Height))); if not L.PlotArea.Contains(P) then Exit;
    RX := (P.X - L.PlotArea.CenterPoint.X) / Max(1, L.PlotArea.Width); RY := (P.Y - L.PlotArea.CenterPoint.Y) / Max(1, L.PlotArea.Height);
    Factor := EnsureRange(FModel.Options.MapZoom * Power(1.2, EnsureRange(WheelDelta / 120, -20.0, 20.0)), 0.1, 20.0) / Max(0.1, FModel.Options.MapZoom);
    FModel.BeginUpdate;
    try FModel.Options.MapZoom := FModel.Options.MapZoom * Factor;
      FModel.Options.MapOffsetX := RX + (FModel.Options.MapOffsetX - RX) * Factor;
      FModel.Options.MapOffsetY := RY + (FModel.Options.MapOffsetY - RY) * Factor
    finally FModel.EndUpdate end; Result := True; Exit;
  end;
  if not IsCartesian then Exit;
  R := FFactory.GetRenderer(FModel.ChartType); if R = nil then Exit;
  P := ScreenToClient(MousePos); L := R.Arrange(CreateRenderContext(Rect(0, 0, Width, Height)));
  if not L.PlotArea.Contains(P) then Exit;
  Factor := Power(1.2, EnsureRange(-WheelDelta / 120, -20.0, 20.0)); RX := (P.X - L.PlotArea.Left) / Max(1, L.PlotArea.Width); RY := (L.PlotArea.Bottom - P.Y) / Max(1, L.PlotArea.Height);
  if not (ssShift in Shift) then FXView := TNimbusChartRange.Create(HorizontalAxis.DenormalizeWithinRange(RX * (1 - Factor), L.XRange), HorizontalAxis.DenormalizeWithinRange(RX + (1 - RX) * Factor, L.XRange));
  if not (ssCtrl in Shift) then FYView := TNimbusChartRange.Create(VerticalAxis.DenormalizeWithinRange(RY * (1 - Factor), L.YRange), VerticalAxis.DenormalizeWithinRange(RY + (1 - RY) * Factor, L.YRange));
  Result := True; Invalidate;
end;

procedure TCustomThemedChart.KeyDown(var Key: Word; Shift: TShiftState);
var I, J, Delta: Integer; H: TNimbusChartHit; S: TNimbusChartSeries; Renderer: INimbusChartRenderer; Navigator: INimbusChartSeriesNavigator; Elements: INimbusChartElementNavigator;
begin
  inherited; if not Enabled then Exit;
  if Key = VK_ESCAPE then begin StopDrag; ClearSelection; Key := 0; Exit end;
  if Key = VK_HOME then begin ResetView; Key := 0; Exit end;
  if (ssCtrl in Shift) and (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN]) then
  begin
    case Key of VK_LEFT: PanChartBy(-0.1, 0); VK_RIGHT: PanChartBy(0.1, 0); VK_UP: PanChartBy(0, 0.1); VK_DOWN: PanChartBy(0, -0.1) end;
    Key := 0; Exit;
  end;
  if Key in [VK_RETURN, VK_SPACE] then
  begin if Assigned(FOnElementClicked) then FOnElementClicked(Self, FSelected); if Assigned(FOnPointClicked) and (FSelected.PointIndex >= 0) then FOnPointClicked(Self, FSelected); Key := 0; Exit end;
  if (FModel.ChartType in [nctSankey, nctProgressRingGrid, nctHierarchicalEdgeBundling, nctChoroplethMap, nctCountryMap, nctCandlestick, nctOhlc]) and (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN]) then
  begin
    Renderer := FFactory.GetRenderer(FModel.ChartType); if not Supports(Renderer, INimbusChartElementNavigator, Elements) then Exit;
    Delta := 1; if Key in [VK_LEFT, VK_UP] then Delta := -1;
    H := Elements.FindAdjacentHit(CreateRenderContext(Rect(0, 0, Width, Height)), FSelected, Delta);
    if H.Area <> nchaNone then SetSelected(H); Key := 0; Exit;
  end;
  if (FModel.ChartType = nctViolinPlot) and (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN]) then
  begin
    Renderer := FFactory.GetRenderer(FModel.ChartType); if not Supports(Renderer, INimbusChartSeriesNavigator, Navigator) then Exit;
    Delta := 1; if Key in [VK_LEFT, VK_UP] then Delta := -1;
    I := FSelected.SeriesIndex + Delta; if FSelected.SeriesIndex < 0 then begin I := 0; if Delta < 0 then I := FModel.Series.Count - 1 end;
    while (I >= 0) and (I < FModel.Series.Count) do
    begin
      H := Navigator.FindSeriesHit(CreateRenderContext(Rect(0, 0, Width, Height)), I);
      if H.Area = nchaSeries then begin SetSelected(H); Key := 0; Exit end; Inc(I, Delta);
    end;
    Exit;
  end;
  if not (Key in [VK_LEFT, VK_RIGHT]) then Exit;
  Delta := 1; if Key = VK_LEFT then Delta := -1;
  I := FSelected.SeriesIndex; if (I < 0) or (I >= FModel.Series.Count) then I := 0;
  while (I < FModel.Series.Count) and not FModel.Series[I].Visible do Inc(I);
  if I >= FModel.Series.Count then Exit;
  S := FModel.Series[I]; J := FSelected.PointIndex + Delta;
  if FSelected.PointIndex < 0 then J := 0;
  while (J >= 0) and (J < S.Points.Count) do
  begin
    if S.Points[J].Visible and SparklineFinite(S.Points[J].XValue) and SparklineFinite(S.Points[J].YValue) then Break;
    Inc(J, Delta);
  end;
  if (J < 0) or (J >= S.Points.Count) then Exit;
  H := TNimbusChartHit.None; H.Area := nchaPoint; H.SeriesIndex := I; H.PointIndex := J;
  H.XValue := S.Points[J].XValue; H.YValue := S.Points[J].YValue;
  H.Text := S.Name + ': ' + SparklineFormatValue(H.YValue, S.ValueFormat); SetSelected(H); Key := 0;
end;

function TCustomThemedChart.RenderToBitmap(const AWidth, AHeight: Integer): TBitmap;
var RC: INimbusRenderCanvas; R: INimbusChartRenderer; C: TNimbusChartRenderContext;
begin
  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf32bit; Result.SetSize(Max(1, AWidth), Max(1, AHeight));
    RC := TNimbusRenderCanvas.Create; RC.BeginRender(Result.Canvas);
    try
      C := CreateRenderContext(Rect(0, 0, Result.Width, Result.Height)); C.AnimationProgress := 1;
      C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
      R := FFactory.GetRenderer(FModel.ChartType); if R = nil then raise EArgumentException.Create('No renderer is registered for this chart type');
      R.Render(RC, C);
    finally RC.EndRender end;
  except Result.Free; raise end;
end;

function TCustomThemedChart.RenderToBitmap: TBitmap;
begin Result := RenderToBitmap(Width, Height) end;

procedure TCustomThemedChart.ExportPng(const AFileName: string; const AWidth, AHeight: Integer);
var B: TBitmap; P: TPngImage;
begin
  B := RenderToBitmap(AWidth, AHeight);
  try P := TPngImage.Create; try P.Assign(B); P.SaveToFile(AFileName) finally P.Free end finally B.Free end;
end;

procedure TCustomThemedChart.ExportPng(const AFileName: string);
begin ExportPng(AFileName, Width, Height) end;

function TCustomThemedChart.ExportSvg(const AWidth, AHeight: Integer): string;
var R: INimbusChartRenderer; C: TNimbusChartRenderContext;
begin
  C := CreateRenderContext(Rect(0, 0, Max(1, AWidth), Max(1, AHeight))); C.AnimationProgress := 1;
  C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
  R := FFactory.GetRenderer(FModel.ChartType); if R = nil then raise EArgumentException.Create('No renderer is registered for this chart type');
  Result := R.ExportSvg(C);
end;

procedure TCustomThemedChart.ExportSvg(const AFileName: string; const AWidth, AHeight: Integer);
var Stream: TFileStream; Bytes: TBytes;
begin
  Bytes := TEncoding.UTF8.GetBytes(ExportSvg(AWidth, AHeight)); Stream := TFileStream.Create(AFileName, fmCreate);
  try if Length(Bytes) > 0 then Stream.WriteBuffer(Bytes[0], Length(Bytes)) finally Stream.Free end;
end;

function TCustomThemedChart.GetChartType: TNimbusChartType;
begin Result := FModel.ChartType end;

procedure TCustomThemedChart.SetChartType(const AValue: TNimbusChartType);
begin FModel.ChartType := AValue end;

function TCustomThemedChart.GetTitle: string;
begin Result := FModel.Title end;

procedure TCustomThemedChart.SetTitle(const AValue: string);
begin FModel.Title := AValue end;

function TCustomThemedChart.GetSubtitle: string;
begin Result := FModel.Subtitle end;

procedure TCustomThemedChart.SetSubtitle(const AValue: string);
begin FModel.Subtitle := AValue end;

function TCustomThemedChart.GetShowLegend: Boolean;
begin Result := FModel.Legend.Visible end;

procedure TCustomThemedChart.SetShowLegend(const AValue: Boolean);
begin FModel.Legend.Visible := AValue end;

function TCustomThemedChart.GetShowToolTip: Boolean;
begin Result := FModel.Options.ShowToolTips end;

procedure TCustomThemedChart.SetShowToolTip(const AValue: Boolean);
begin FModel.Options.ShowToolTips := AValue end;

function TCustomThemedChart.GetShowBorder: Boolean;
begin Result := FModel.Options.ShowBorder end;

procedure TCustomThemedChart.SetShowBorder(const AValue: Boolean);
begin FModel.Options.ShowBorder := AValue end;

function TCustomThemedChart.GetShowGrid: Boolean;
begin Result := FModel.Options.ShowGrid end;

procedure TCustomThemedChart.SetShowGrid(const AValue: Boolean);
begin FModel.Options.ShowGrid := AValue end;

function TCustomThemedChart.GetShowAxes: Boolean;
begin Result := FModel.Options.ShowAxes end;

procedure TCustomThemedChart.SetShowAxes(const AValue: Boolean);
begin FModel.Options.ShowAxes := AValue end;

function TCustomThemedChart.GetShowValues: Boolean;
begin Result := FModel.Options.ShowValues end;

procedure TCustomThemedChart.SetShowValues(const AValue: Boolean);
begin FModel.Options.ShowValues := AValue end;

function TCustomThemedChart.GetShowAnimation: Boolean;
begin Result := FModel.Options.ShowAnimation end;

procedure TCustomThemedChart.SetShowAnimation(const AValue: Boolean);
begin FModel.Options.ShowAnimation := AValue end;

function TCustomThemedChart.GetShowSecondaryYAxis: Boolean;
begin Result := FModel.SecondaryYAxis.Visible end;

procedure TCustomThemedChart.SetShowSecondaryYAxis(const AValue: Boolean);
begin FModel.SecondaryYAxis.Visible := AValue end;

function TCustomThemedChart.GetXAxisScale: TNimbusChartAxisScale;
begin Result := FModel.XAxis.Scale end;

procedure TCustomThemedChart.SetXAxisScale(const AValue: TNimbusChartAxisScale);
begin FModel.XAxis.Scale := AValue end;

function TCustomThemedChart.GetXAxisPowerExponent: Double;
begin Result := FModel.XAxis.PowerExponent end;

procedure TCustomThemedChart.SetXAxisPowerExponent(const AValue: Double);
begin FModel.XAxis.PowerExponent := AValue end;

function TCustomThemedChart.GetXAxisSymmetricLogThreshold: Double;
begin Result := FModel.XAxis.SymmetricLogThreshold end;

procedure TCustomThemedChart.SetXAxisSymmetricLogThreshold(const AValue: Double);
begin FModel.XAxis.SymmetricLogThreshold := AValue end;

function TCustomThemedChart.GetXAxisShowMinorGridLines: Boolean;
begin Result := FModel.XAxis.ShowMinorGridLines end;

procedure TCustomThemedChart.SetXAxisShowMinorGridLines(const AValue: Boolean);
begin FModel.XAxis.ShowMinorGridLines := AValue end;

function TCustomThemedChart.GetXAxisMinorTickMode: TNimbusChartLogarithmicMinorTickMode;
begin Result := FModel.XAxis.MinorTickMode end;

procedure TCustomThemedChart.SetXAxisMinorTickMode(const AValue: TNimbusChartLogarithmicMinorTickMode);
begin FModel.XAxis.MinorTickMode := AValue end;

function TCustomThemedChart.GetXAxisLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode;
begin Result := FModel.XAxis.LogarithmicLabelMode end;

procedure TCustomThemedChart.SetXAxisLogarithmicLabelMode(const AValue: TNimbusChartLogarithmicLabelMode);
begin FModel.XAxis.LogarithmicLabelMode := AValue end;

function TCustomThemedChart.GetXAxisLogarithmicBase: Double;
begin Result := FModel.XAxis.LogarithmicBase end;

procedure TCustomThemedChart.SetXAxisLogarithmicBase(const AValue: Double);
begin FModel.XAxis.LogarithmicBase := AValue end;

function TCustomThemedChart.GetXAxisAutomaticLogarithmicThreshold: Double;
begin Result := FModel.XAxis.AutomaticLogarithmicThreshold end;

procedure TCustomThemedChart.SetXAxisAutomaticLogarithmicThreshold(const AValue: Double);
begin FModel.XAxis.AutomaticLogarithmicThreshold := AValue end;

function TCustomThemedChart.GetXAxisInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior;
begin Result := FModel.XAxis.InvalidLogValueBehavior end;

procedure TCustomThemedChart.SetXAxisInvalidLogValueBehavior(const AValue: TNimbusChartInvalidLogValueBehavior);
begin FModel.XAxis.InvalidLogValueBehavior := AValue end;

function TCustomThemedChart.GetXAxisValueType: TNimbusChartAxisValueType;
begin Result := FModel.XAxis.ValueType end;

procedure TCustomThemedChart.SetXAxisValueType(const AValue: TNimbusChartAxisValueType);
begin FModel.XAxis.ValueType := AValue end;

function TCustomThemedChart.GetXAxisDateTimeLabelFormat: string;
begin Result := FModel.XAxis.DateTimeLabelFormat end;

procedure TCustomThemedChart.SetXAxisDateTimeLabelFormat(const AValue: string);
begin FModel.XAxis.DateTimeLabelFormat := AValue end;

function TCustomThemedChart.GetYAxisScale: TNimbusChartAxisScale;
begin Result := FModel.YAxis.Scale end;

procedure TCustomThemedChart.SetYAxisScale(const AValue: TNimbusChartAxisScale);
begin FModel.YAxis.Scale := AValue end;

function TCustomThemedChart.GetYAxisPowerExponent: Double;
begin Result := FModel.YAxis.PowerExponent end;

procedure TCustomThemedChart.SetYAxisPowerExponent(const AValue: Double);
begin FModel.YAxis.PowerExponent := AValue end;

function TCustomThemedChart.GetYAxisSymmetricLogThreshold: Double;
begin Result := FModel.YAxis.SymmetricLogThreshold end;

procedure TCustomThemedChart.SetYAxisSymmetricLogThreshold(const AValue: Double);
begin FModel.YAxis.SymmetricLogThreshold := AValue end;

function TCustomThemedChart.GetYAxisShowMinorGridLines: Boolean;
begin Result := FModel.YAxis.ShowMinorGridLines end;

procedure TCustomThemedChart.SetYAxisShowMinorGridLines(const AValue: Boolean);
begin FModel.YAxis.ShowMinorGridLines := AValue end;

function TCustomThemedChart.GetYAxisMinorTickMode: TNimbusChartLogarithmicMinorTickMode;
begin Result := FModel.YAxis.MinorTickMode end;

procedure TCustomThemedChart.SetYAxisMinorTickMode(const AValue: TNimbusChartLogarithmicMinorTickMode);
begin FModel.YAxis.MinorTickMode := AValue end;

function TCustomThemedChart.GetYAxisLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode;
begin Result := FModel.YAxis.LogarithmicLabelMode end;

procedure TCustomThemedChart.SetYAxisLogarithmicLabelMode(const AValue: TNimbusChartLogarithmicLabelMode);
begin FModel.YAxis.LogarithmicLabelMode := AValue end;

function TCustomThemedChart.GetYAxisLogarithmicBase: Double;
begin Result := FModel.YAxis.LogarithmicBase end;

procedure TCustomThemedChart.SetYAxisLogarithmicBase(const AValue: Double);
begin FModel.YAxis.LogarithmicBase := AValue end;

function TCustomThemedChart.GetYAxisAutomaticLogarithmicThreshold: Double;
begin Result := FModel.YAxis.AutomaticLogarithmicThreshold end;

procedure TCustomThemedChart.SetYAxisAutomaticLogarithmicThreshold(const AValue: Double);
begin FModel.YAxis.AutomaticLogarithmicThreshold := AValue end;

function TCustomThemedChart.GetYAxisInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior;
begin Result := FModel.YAxis.InvalidLogValueBehavior end;

procedure TCustomThemedChart.SetYAxisInvalidLogValueBehavior(const AValue: TNimbusChartInvalidLogValueBehavior);
begin FModel.YAxis.InvalidLogValueBehavior := AValue end;

function TCustomThemedChart.GetYAxisValueType: TNimbusChartAxisValueType;
begin Result := FModel.YAxis.ValueType end;

procedure TCustomThemedChart.SetYAxisValueType(const AValue: TNimbusChartAxisValueType);
begin FModel.YAxis.ValueType := AValue end;

function TCustomThemedChart.GetYAxisDateTimeLabelFormat: string;
begin Result := FModel.YAxis.DateTimeLabelFormat end;

procedure TCustomThemedChart.SetYAxisDateTimeLabelFormat(const AValue: string);
begin FModel.YAxis.DateTimeLabelFormat := AValue end;

initialization
  RegisterClass(TThemedChart);

end.

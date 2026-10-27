{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Sparkline;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.SysUtils, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, NimbusForms.Controls.Base, NimbusForms.Controls.ToolTip,
  NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.Sparkline, NimbusForms.Charts.Sparkline.Types;

type
  TSparklinePointEvent = procedure(Sender: TObject; APointIndex: Integer; AValue: Double; const ALocation: TPoint) of object;

  TCustomThemedSparkline = class(TCustomNimbusControl)
  private
    FOptions: TSparklineOptions;
    FSeries: TSparklineSeries;
    FValues, FAnimationStart, FAnimationTarget: TSparklineValues;
    FAnimationTimer: TTimer;
    FAnimationStarted: UInt64;
    FRenderer: TSparklineRenderer;
    FReferenceLines: TSparklineReferenceLineCollection;
    FThresholdBands: TSparklineThresholdBandCollection;
    FMarkers: TSparklineMarkerCollection;
    FToolTip: NimbusForms.Controls.ToolTip.TThemedToolTip;
    FHoveredIndex, FSelectedIndex, FUpdateLock: Integer;
    FPendingInvalidate, FSettingSeries: Boolean;
    FLastRangeMode: TSparklineRangeMode;
    FLastRange: TSparklineValueRange;
    FOnValuesChanged, FOnRangeChanged, FOnSelectedIndexChanged: TNotifyEvent;
    FOnPointClicked, FOnPointHovered: TSparklinePointEvent;
    procedure OptionsChanged(Sender: TObject);
    procedure SeriesChanged(Sender: TObject);
    procedure VisualChanged(Sender: TObject);
    procedure AnimationTick(Sender: TObject);
    procedure RequestInvalidate;
    procedure SetValuesProperty(const AValue: TSparklineValues);
    procedure SetSeries(const AValue: TSparklineSeries);
    procedure SetOptions(const AValue: TSparklineOptions);
    procedure SetReferenceLines(const AValue: TSparklineReferenceLineCollection);
    procedure SetThresholdBands(const AValue: TSparklineThresholdBandCollection);
    procedure SetMarkers(const AValue: TSparklineMarkerCollection);
    procedure SetSelectedIndex(const AValue: Integer);
    function GetValues: TSparklineValues;
    function GetThemePalette: TThemePalette;
    procedure SetThemePalette(const AValue: TThemePalette);
    procedure ReadFixedRange(Reader: TReader);
    procedure WriteFixedRange(Writer: TWriter);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    function GetStyle: TSparklineRenderStyle;
    procedure SetStyle(const AValue: TSparklineRenderStyle);
    function GetRangeMode: TSparklineRangeMode;
    procedure SetRangeMode(const AValue: TSparklineRangeMode);
    function GetPerformanceMode: TSparklinePerformanceMode;
    procedure SetPerformanceMode(const AValue: TSparklinePerformanceMode);
    function GetFixedRange: TSparklineValueRange;
    procedure SetFixedRange(const AValue: TSparklineValueRange);
    function GetThemeMode: TSparklineThemeMode;
    function GetThemeInfluence: Integer;
    procedure SetThemeInfluence(const AValue: Integer);
    function GetBarGap: Integer;
    procedure SetBarGap(const AValue: Integer);
    procedure SetThemeMode(const AValue: TSparklineThemeMode);
    function GetAutoThemeFromParent: Boolean;
    procedure SetAutoThemeFromParent(const AValue: Boolean);
    function GetPaintBackground: Boolean;
    procedure SetPaintBackground(const AValue: Boolean);
    function GetShowBorder: Boolean;
    procedure SetShowBorder(const AValue: Boolean);
    function GetShowArea: Boolean;
    procedure SetShowArea(const AValue: Boolean);
    function GetShowLastPoint: Boolean;
    procedure SetShowLastPoint(const AValue: Boolean);
    function GetShowStartPoint: Boolean;
    procedure SetShowStartPoint(const AValue: Boolean);
    function GetShowMinMaxPoints: Boolean;
    procedure SetShowMinMaxPoints(const AValue: Boolean);
    function GetShowMinMaxValueLabels: Boolean;
    procedure SetShowMinMaxValueLabels(const AValue: Boolean);
    function GetShowZeroLine: Boolean;
    procedure SetShowZeroLine(const AValue: Boolean);
    function GetShowEmptyState: Boolean;
    procedure SetShowEmptyState(const AValue: Boolean);
    function GetEmptyLineVisible: Boolean;
    procedure SetEmptyLineVisible(const AValue: Boolean);
    function GetEmptyText: string;
    procedure SetEmptyText(const AValue: string);
    function GetShowTargetLine: Boolean;
    procedure SetShowTargetLine(const AValue: Boolean);
    function GetTargetValue: Double;
    procedure SetTargetValue(const AValue: Double);
    function GetShowAverageLine: Boolean;
    procedure SetShowAverageLine(const AValue: Boolean);
    function GetShowRangeBand: Boolean;
    procedure SetShowRangeBand(const AValue: Boolean);
    function GetBandMinimum: Double;
    procedure SetBandMinimum(const AValue: Double);
    function GetBandMaximum: Double;
    procedure SetBandMaximum(const AValue: Double);
    function GetColorizeRisingFallingSegments: Boolean;
    procedure SetColorizeRisingFallingSegments(const AValue: Boolean);
    function GetColorizeNegativeSegments: Boolean;
    procedure SetColorizeNegativeSegments(const AValue: Boolean);
    function GetShowEndValueLabel: Boolean;
    procedure SetShowEndValueLabel(const AValue: Boolean);
    function GetValueLabelWidth: Integer;
    procedure SetValueLabelWidth(const AValue: Integer);
    function GetShowHoverLine: Boolean;
    procedure SetShowHoverLine(const AValue: Boolean);
    function GetShowSelection: Boolean;
    procedure SetShowSelection(const AValue: Boolean);
    function GetUltraFastRendering: Boolean;
    procedure SetUltraFastRendering(const AValue: Boolean);
    function GetUseGradientArea: Boolean;
    procedure SetUseGradientArea(const AValue: Boolean);
    function GetAreaGradientAlphaTop: Integer;
    procedure SetAreaGradientAlphaTop(const AValue: Integer);
    function GetAreaGradientAlphaBottom: Integer;
    procedure SetAreaGradientAlphaBottom(const AValue: Integer);
    function GetSplitAreaByZero: Boolean;
    procedure SetSplitAreaByZero(const AValue: Boolean);
    function GetUseRoundedBars: Boolean;
    procedure SetUseRoundedBars(const AValue: Boolean);
    function GetBarCornerRadius: Integer;
    procedure SetBarCornerRadius(const AValue: Integer);
    function GetShowToolTip: Boolean;
    procedure SetShowToolTip(const AValue: Boolean);
    function GetValueFormat: string;
    procedure SetValueFormat(const AValue: string);
    function GetAnimateValueChanges: Boolean;
    procedure SetAnimateValueChanges(const AValue: Boolean);
    function GetAnimationDuration: Integer;
    procedure SetAnimationDuration(const AValue: Integer);
    function GetSparklinePadding: Integer;
    procedure SetSparklinePadding(const AValue: Integer);
    function GetStrokeWidth: Single;
    procedure SetStrokeWidth(const AValue: Single);
    function GetAccentColor: TColor;
    procedure SetAccentColor(const AValue: TColor);
    function GetMutedColor: TColor;
    procedure SetMutedColor(const AValue: TColor);
    function GetBorderColor: TColor;
    procedure SetBorderColor(const AValue: TColor);
    function GetLineColor: TColor;
    procedure SetLineColor(const AValue: TColor);
    function GetFillColor: TColor;
    procedure SetFillColor(const AValue: TColor);
    function GetNegativeColor: TColor;
    procedure SetNegativeColor(const AValue: TColor);
    function GetZeroLineColor: TColor;
    procedure SetZeroLineColor(const AValue: TColor);
    function GetLastPointColor: TColor;
    procedure SetLastPointColor(const AValue: TColor);
    function GetMinPointColor: TColor;
    procedure SetMinPointColor(const AValue: TColor);
    function GetMaxPointColor: TColor;
    procedure SetMaxPointColor(const AValue: TColor);
    function GetTargetLineColor: TColor;
    procedure SetTargetLineColor(const AValue: TColor);
    function GetAverageLineColor: TColor;
    procedure SetAverageLineColor(const AValue: TColor);
    function GetRangeBandColor: TColor;
    procedure SetRangeBandColor(const AValue: TColor);
    function GetStartPointColor: TColor;
    procedure SetStartPointColor(const AValue: TColor);
    function GetRisingColor: TColor;
    procedure SetRisingColor(const AValue: TColor);
    function GetFallingColor: TColor;
    procedure SetFallingColor(const AValue: TColor);
    function GetHoverLineColor: TColor;
    procedure SetHoverLineColor(const AValue: TColor);
    function GetSelectionColor: TColor;
    procedure SetSelectionColor(const AValue: TColor);
    function GetMarkerColor: TColor;
    procedure SetMarkerColor(const AValue: TColor);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DestroyWnd; override;
    function CreateRenderContext(const ABounds: TRect): TSparklineRenderContext; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure ApplyDarkTheme;
    procedure ApplyLightTheme;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure SetValues(const AValues: TSparklineValues; const ACopy: Boolean); overload;
    procedure SetValues(const AValues: array of Double); overload;
    procedure ClearSparklineCache;
    function HitTestIndex(const ALocation: TPoint): Integer;
    function RenderToBitmap(const ASize: TSize): TBitmap;
    property Values: TSparklineValues read GetValues write SetValuesProperty;
    property Series: TSparklineSeries read FSeries write SetSeries;
    property Options: TSparklineOptions read FOptions write SetOptions;
    property ThemePalette: TThemePalette read GetThemePalette write SetThemePalette;
    property HoveredIndex: Integer read FHoveredIndex;
    property FixedRange: TSparklineValueRange read GetFixedRange write SetFixedRange;
    property Style: TSparklineRenderStyle read GetStyle write SetStyle;
    property RangeMode: TSparklineRangeMode read GetRangeMode write SetRangeMode;
    property PerformanceMode: TSparklinePerformanceMode read GetPerformanceMode write SetPerformanceMode;
    property ThemeMode: TSparklineThemeMode read GetThemeMode write SetThemeMode;
    property ThemeInfluence: Integer read GetThemeInfluence write SetThemeInfluence default 12;
    property BarGap: Integer read GetBarGap write SetBarGap default 2;
    property AutoThemeFromParent: Boolean read GetAutoThemeFromParent write SetAutoThemeFromParent;
    property PaintBackground: Boolean read GetPaintBackground write SetPaintBackground;
    property ShowBorder: Boolean read GetShowBorder write SetShowBorder;
    property ShowArea: Boolean read GetShowArea write SetShowArea;
    property ShowLastPoint: Boolean read GetShowLastPoint write SetShowLastPoint;
    property ShowStartPoint: Boolean read GetShowStartPoint write SetShowStartPoint;
    property ShowMinMaxPoints: Boolean read GetShowMinMaxPoints write SetShowMinMaxPoints;
    property ShowMinMaxValueLabels: Boolean read GetShowMinMaxValueLabels write SetShowMinMaxValueLabels;
    property ShowZeroLine: Boolean read GetShowZeroLine write SetShowZeroLine;
    property ShowEmptyState: Boolean read GetShowEmptyState write SetShowEmptyState;
    property EmptyLineVisible: Boolean read GetEmptyLineVisible write SetEmptyLineVisible;
    property EmptyText: string read GetEmptyText write SetEmptyText;
    property ShowTargetLine: Boolean read GetShowTargetLine write SetShowTargetLine;
    property TargetValue: Double read GetTargetValue write SetTargetValue;
    property ShowAverageLine: Boolean read GetShowAverageLine write SetShowAverageLine;
    property ShowRangeBand: Boolean read GetShowRangeBand write SetShowRangeBand;
    property BandMinimum: Double read GetBandMinimum write SetBandMinimum;
    property BandMaximum: Double read GetBandMaximum write SetBandMaximum;
    property ColorizeRisingFallingSegments: Boolean read GetColorizeRisingFallingSegments write SetColorizeRisingFallingSegments;
    property ColorizeNegativeSegments: Boolean read GetColorizeNegativeSegments write SetColorizeNegativeSegments;
    property ShowEndValueLabel: Boolean read GetShowEndValueLabel write SetShowEndValueLabel;
    property ValueLabelWidth: Integer read GetValueLabelWidth write SetValueLabelWidth;
    property ShowHoverLine: Boolean read GetShowHoverLine write SetShowHoverLine;
    property ShowSelection: Boolean read GetShowSelection write SetShowSelection;
    property UltraFastRendering: Boolean read GetUltraFastRendering write SetUltraFastRendering;
    property UseGradientArea: Boolean read GetUseGradientArea write SetUseGradientArea;
    property AreaGradientAlphaTop: Integer read GetAreaGradientAlphaTop write SetAreaGradientAlphaTop;
    property AreaGradientAlphaBottom: Integer read GetAreaGradientAlphaBottom write SetAreaGradientAlphaBottom;
    property SplitAreaByZero: Boolean read GetSplitAreaByZero write SetSplitAreaByZero;
    property UseRoundedBars: Boolean read GetUseRoundedBars write SetUseRoundedBars;
    property BarCornerRadius: Integer read GetBarCornerRadius write SetBarCornerRadius;
    property ShowToolTip: Boolean read GetShowToolTip write SetShowToolTip;
    property ValueFormat: string read GetValueFormat write SetValueFormat;
    property AnimateValueChanges: Boolean read GetAnimateValueChanges write SetAnimateValueChanges;
    property AnimationDuration: Integer read GetAnimationDuration write SetAnimationDuration;
    property SparklinePadding: Integer read GetSparklinePadding write SetSparklinePadding;
    property StrokeWidth: Single read GetStrokeWidth write SetStrokeWidth;
    property AccentColor: TColor read GetAccentColor write SetAccentColor;
    property MutedColor: TColor read GetMutedColor write SetMutedColor;
    property BorderColor: TColor read GetBorderColor write SetBorderColor;
    property LineColor: TColor read GetLineColor write SetLineColor;
    property FillColor: TColor read GetFillColor write SetFillColor;
    property NegativeColor: TColor read GetNegativeColor write SetNegativeColor;
    property ZeroLineColor: TColor read GetZeroLineColor write SetZeroLineColor;
    property LastPointColor: TColor read GetLastPointColor write SetLastPointColor;
    property MinPointColor: TColor read GetMinPointColor write SetMinPointColor;
    property MaxPointColor: TColor read GetMaxPointColor write SetMaxPointColor;
    property TargetLineColor: TColor read GetTargetLineColor write SetTargetLineColor;
    property AverageLineColor: TColor read GetAverageLineColor write SetAverageLineColor;
    property RangeBandColor: TColor read GetRangeBandColor write SetRangeBandColor;
    property StartPointColor: TColor read GetStartPointColor write SetStartPointColor;
    property RisingColor: TColor read GetRisingColor write SetRisingColor;
    property FallingColor: TColor read GetFallingColor write SetFallingColor;
    property HoverLineColor: TColor read GetHoverLineColor write SetHoverLineColor;
    property SelectionColor: TColor read GetSelectionColor write SetSelectionColor;
    property MarkerColor: TColor read GetMarkerColor write SetMarkerColor;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
    property ReferenceLines: TSparklineReferenceLineCollection read FReferenceLines write SetReferenceLines;
    property ThresholdBands: TSparklineThresholdBandCollection read FThresholdBands write SetThresholdBands;
    property Markers: TSparklineMarkerCollection read FMarkers write SetMarkers;
    property OnValuesChanged: TNotifyEvent read FOnValuesChanged write FOnValuesChanged;
    property OnRangeChanged: TNotifyEvent read FOnRangeChanged write FOnRangeChanged;
    property OnSelectedIndexChanged: TNotifyEvent read FOnSelectedIndexChanged write FOnSelectedIndexChanged;
    property OnPointClicked: TSparklinePointEvent read FOnPointClicked write FOnPointClicked;
    property OnPointHovered: TSparklinePointEvent read FOnPointHovered write FOnPointHovered;
  end;

  TThemedSparkline = class(TCustomThemedSparkline)
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property PopupMenu;
    property Action;
    property Style;
    property RangeMode;
    property PerformanceMode;
    property ThemeMode;
    property ThemeInfluence;
    property BarGap;
    property AutoThemeFromParent;
    property PaintBackground;
    property ShowBorder;
    property ShowArea;
    property ShowLastPoint;
    property ShowStartPoint;
    property ShowMinMaxPoints;
    property ShowMinMaxValueLabels;
    property ShowZeroLine;
    property ShowEmptyState;
    property EmptyLineVisible;
    property EmptyText;
    property ShowTargetLine;
    property TargetValue;
    property ShowAverageLine;
    property ShowRangeBand;
    property BandMinimum;
    property BandMaximum;
    property ColorizeRisingFallingSegments;
    property ColorizeNegativeSegments;
    property ShowEndValueLabel;
    property ValueLabelWidth;
    property ShowHoverLine;
    property ShowSelection;
    property UltraFastRendering;
    property UseGradientArea;
    property AreaGradientAlphaTop;
    property AreaGradientAlphaBottom;
    property SplitAreaByZero;
    property UseRoundedBars;
    property BarCornerRadius;
    property ShowToolTip;
    property ValueFormat;
    property AnimateValueChanges;
    property AnimationDuration;
    property SparklinePadding;
    property StrokeWidth;
    property AccentColor;
    property MutedColor;
    property BorderColor;
    property LineColor;
    property FillColor;
    property NegativeColor;
    property ZeroLineColor;
    property LastPointColor;
    property MinPointColor;
    property MaxPointColor;
    property TargetLineColor;
    property AverageLineColor;
    property RangeBandColor;
    property StartPointColor;
    property RisingColor;
    property FallingColor;
    property HoverLineColor;
    property SelectionColor;
    property MarkerColor;
    property SelectedIndex;
    property ReferenceLines;
    property ThresholdBands;
    property Markers;
    property OnValuesChanged;
    property OnRangeChanged;
    property OnSelectedIndexChanged;
    property OnPointClicked;
    property OnPointHovered;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
  end;

implementation

uses
  Vcl.Themes, NimbusForms.Rendering.Types;

constructor TCustomThemedSparkline.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 96; Height := 28; TabStop := True;
  FHoveredIndex := -1; FSelectedIndex := -1;
  FOptions := TSparklineOptions.Create;
  FLastRange := TSparklineValueRange.Empty;
  FOptions.OnChange := OptionsChanged;
  FSeries := TSparklineSeries.Create; FSeries.OnChange := SeriesChanged;
  FRenderer := TSparklineRenderer.Create;
  FReferenceLines := TSparklineReferenceLineCollection.Create(Self); FReferenceLines.OnChange := VisualChanged;
  FThresholdBands := TSparklineThresholdBandCollection.Create(Self); FThresholdBands.OnChange := VisualChanged;
  FMarkers := TSparklineMarkerCollection.Create(Self); FMarkers.OnChange := VisualChanged;
  FAnimationTimer := TTimer.Create(Self); FAnimationTimer.Enabled := False;
  FAnimationTimer.Interval := 15; FAnimationTimer.OnTimer := AnimationTick;
  FToolTip := NimbusForms.Controls.ToolTip.TThemedToolTip.Create(Self);
end;

destructor TCustomThemedSparkline.Destroy;
begin
  FAnimationTimer.Enabled := False;
  FToolTip.Free;
  FReferenceLines.Free; FThresholdBands.Free; FMarkers.Free;
  FRenderer.Free; FSeries.Free; FOptions.Free;
  inherited;
end;

procedure TCustomThemedSparkline.DestroyWnd;
begin
  FAnimationTimer.Enabled := False;
  if Length(FAnimationTarget) > 0 then FValues := Copy(FAnimationTarget);
  FAnimationTarget := nil; FAnimationStart := nil; FHoveredIndex := -1;
  inherited;
end;

procedure TCustomThemedSparkline.RequestInvalidate;
begin
  if csDestroying in ComponentState then Exit;
  if FUpdateLock > 0 then FPendingInvalidate := True else Invalidate;
end;

procedure TCustomThemedSparkline.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TCustomThemedSparkline.EndUpdate;
begin
  if FUpdateLock > 0 then Dec(FUpdateLock);
  if (FUpdateLock = 0) and FPendingInvalidate then begin FPendingInvalidate := False; RequestInvalidate end;
end;

procedure TCustomThemedSparkline.OptionsChanged(Sender: TObject);
var RangeChanged: Boolean;
begin
  RangeChanged := (FLastRangeMode <> FOptions.RangeMode) or (FLastRange.IsValid <> FOptions.FixedRange.IsValid);
  if FLastRange.IsValid and FOptions.FixedRange.IsValid then
    RangeChanged := RangeChanged or (FLastRange.Minimum <> FOptions.FixedRange.Minimum) or (FLastRange.Maximum <> FOptions.FixedRange.Maximum);
  FLastRangeMode := FOptions.RangeMode; FLastRange := FOptions.FixedRange;
  if FOptions.PaintBackground then ControlStyle := ControlStyle + [csOpaque] else ControlStyle := ControlStyle - [csOpaque];
  if not FOptions.AnimateValueChanges and FAnimationTimer.Enabled then
  begin
    FAnimationTimer.Enabled := False; FValues := Copy(FAnimationTarget);
    FAnimationStart := nil; FAnimationTarget := nil;
  end;
  if not FOptions.ShowToolTip then FToolTip.ClearInfo(Self);
  ClearSparklineCache; RequestInvalidate;
  if RangeChanged and Assigned(FOnRangeChanged) then FOnRangeChanged(Self);
end;

procedure TCustomThemedSparkline.VisualChanged(Sender: TObject);
begin
  RequestInvalidate;
end;

procedure TCustomThemedSparkline.SeriesChanged(Sender: TObject);
begin
  if FSettingSeries then Exit;
  if FSeries.RangeMode <> srmAuto then FOptions.RangeMode := FSeries.RangeMode;
  if FSeries.Range.IsValid then FOptions.FixedRange := FSeries.Range;
  SetValues(FSeries.Values);
end;

procedure TCustomThemedSparkline.SetSeries(const AValue: TSparklineSeries);
begin
  if AValue = nil then begin SetValues([]); Exit end;
  FSeries.Assign(AValue);
end;

procedure TCustomThemedSparkline.SetOptions(const AValue: TSparklineOptions);
begin
  if AValue <> nil then FOptions.Assign(AValue);
end;

procedure TCustomThemedSparkline.SetReferenceLines(const AValue: TSparklineReferenceLineCollection);
begin
  FReferenceLines.Assign(AValue);
end;

procedure TCustomThemedSparkline.SetThresholdBands(const AValue: TSparklineThresholdBandCollection);
begin
  FThresholdBands.Assign(AValue);
end;

procedure TCustomThemedSparkline.SetMarkers(const AValue: TSparklineMarkerCollection);
begin
  FMarkers.Assign(AValue);
end;

function TCustomThemedSparkline.GetValues: TSparklineValues;
begin
  Result := Copy(FValues);
end;

procedure TCustomThemedSparkline.SetValuesProperty(const AValue: TSparklineValues);
begin
  SetValues(AValue, True);
end;

procedure TCustomThemedSparkline.SetValues(const AValues: array of Double);
var V: TSparklineValues; I: Integer;
begin
  SetLength(V, Length(AValues));
  for I := 0 to High(V) do V[I] := AValues[I];
  SetValues(V, False);
end;

procedure TCustomThemedSparkline.SetValues(const AValues: TSparklineValues; const ACopy: Boolean);
var I: Integer; CanAnimate: Boolean;
begin
  FSettingSeries := True;
  try FSeries.Values := AValues finally FSettingSeries := False end;
  CanAnimate := FOptions.AnimateValueChanges and HandleAllocated and Enabled and
    not (csDesigning in ComponentState) and (Length(AValues) > 0) and (Length(AValues) = Length(FValues));
  if CanAnimate then for I := 0 to High(AValues) do
    if not SparklineFinite(AValues[I]) or not SparklineFinite(FValues[I]) then begin CanAnimate := False; Break end;
  FAnimationTimer.Enabled := False;
  if CanAnimate then
  begin
    FAnimationStart := Copy(FValues); FAnimationTarget := Copy(AValues);
    FAnimationStarted := GetTickCount64; FAnimationTimer.Enabled := True;
  end
  else
  begin
    if ACopy then FValues := Copy(AValues) else FValues := AValues;
    FAnimationStart := nil; FAnimationTarget := nil;
  end;
  FHoveredIndex := -1;
  if FSelectedIndex >= Length(AValues) then SetSelectedIndex(-1);
  ClearSparklineCache; RequestInvalidate;
  if Assigned(FOnValuesChanged) then FOnValuesChanged(Self);
end;

procedure TCustomThemedSparkline.AnimationTick(Sender: TObject);
var P: Double; I: Integer;
begin
  if not Enabled or (csDestroying in ComponentState) then begin FAnimationTimer.Enabled := False; Exit end;
  P := Min(1.0, (GetTickCount64 - FAnimationStarted) / Max(1, FOptions.AnimationDuration));
  if P >= 1 then
  begin
    FValues := Copy(FAnimationTarget); FAnimationTimer.Enabled := False;
    FAnimationStart := nil; FAnimationTarget := nil;
  end
  else
  begin
    P := 1 - Power(1 - P, 3);
    for I := 0 to High(FValues) do FValues[I] := FAnimationStart[I] + (FAnimationTarget[I] - FAnimationStart[I]) * P;
  end;
  ClearSparklineCache; RequestInvalidate;
end;

procedure TCustomThemedSparkline.ClearSparklineCache;
begin
  FRenderer.ClearCache;
end;

function TCustomThemedSparkline.CreateRenderContext(const ABounds: TRect): TSparklineRenderContext;
begin
  Result := Default(TSparklineRenderContext);
  Result.Bounds := ABounds; Result.Font := Font; Result.Palette := Palette;
  if not FOptions.AutoThemeFromParent and (FOptions.ThemeMode = stmAuto) then Result.Palette := nil;
  Result.Options := FOptions; Result.Values := FValues;
  Result.ReferenceLines := FReferenceLines; Result.ThresholdBands := FThresholdBands; Result.Markers := FMarkers;
  Result.PPI := CurrentPPI; Result.Enabled := Enabled;
  Result.HoveredIndex := FHoveredIndex; Result.SelectedIndex := FSelectedIndex;
end;

procedure TCustomThemedSparkline.Paint;
begin
  if not FOptions.PaintBackground then StyleServices.DrawParentBackground(Handle, Canvas.Handle, nil, False);
  RenderCanvas.BeginRender(Canvas);
  try FRenderer.Render(RenderCanvas, CreateRenderContext(ClientRect)) finally RenderCanvas.EndRender end;
end;

function TCustomThemedSparkline.RenderToBitmap(const ASize: TSize): TBitmap;
var C: INimbusRenderCanvas;
begin
  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf32bit; Result.SetSize(Max(1, ASize.cx), Max(1, ASize.cy));
    Result.Canvas.Brush.Color := Color; Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));
    C := TNimbusRenderCanvas.Create; C.BeginRender(Result.Canvas);
    try FRenderer.Render(C, CreateRenderContext(Rect(0, 0, Result.Width, Result.Height))) finally C.EndRender end;
  except Result.Free; raise end;
end;

function TCustomThemedSparkline.HitTestIndex(const ALocation: TPoint): Integer;
var G: TSparklineGeometry;
begin
  G := FRenderer.BuildGeometry(CreateRenderContext(Rect(0, 0, Width, Height)));
  Result := G.HitTest(ALocation, Max(8, ScaleValue(6)));
end;

procedure TCustomThemedSparkline.MouseMove(Shift: TShiftState; X, Y: Integer);
var I: Integer; Text: string;
begin
  inherited;
  if not Enabled then Exit;
  I := HitTestIndex(Point(X, Y));
  if I = FHoveredIndex then Exit;
  FHoveredIndex := I; RequestInvalidate;
  if I >= 0 then
  begin
    if Assigned(FOnPointHovered) then FOnPointHovered(Self, I, FValues[I], Point(X, Y));
    if FOptions.ShowToolTip then
    begin
      Text := SparklineFormatValue(FValues[I], FOptions.ValueFormat);
      FToolTip.SetToolTip(Self, 'Point ' + IntToStr(I + 1) + ': ' + Text);
    end;
  end
  else if FOptions.ShowToolTip then FToolTip.ClearInfo(Self);
end;

procedure TCustomThemedSparkline.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHoveredIndex := -1; FToolTip.ClearInfo(Self); RequestInvalidate;
end;

procedure TCustomThemedSparkline.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FAnimationTimer.Enabled := False;
    if Length(FAnimationTarget) > 0 then FValues := Copy(FAnimationTarget);
    FAnimationStart := nil; FAnimationTarget := nil; FHoveredIndex := -1;
    FToolTip.ClearInfo(Self);
  end;
end;

procedure TCustomThemedSparkline.SetSelectedIndex(const AValue: Integer);
var I: Integer;
begin
  I := EnsureRange(AValue, -1, Length(FValues) - 1);
  if I = FSelectedIndex then Exit;
  FSelectedIndex := I; RequestInvalidate;
  if Assigned(FOnSelectedIndexChanged) then FOnSelectedIndexChanged(Self);
end;

procedure TCustomThemedSparkline.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var I: Integer;
begin
  inherited;
  if not Enabled or (Button <> mbLeft) then Exit;
  if CanFocus then SetFocus;
  I := HitTestIndex(Point(X, Y));
  if I < 0 then Exit;
  SetSelectedIndex(I);
  if Assigned(FOnPointClicked) then FOnPointClicked(Self, I, FValues[I], Point(X, Y));
end;

procedure TCustomThemedSparkline.KeyDown(var Key: Word; Shift: TShiftState);
var I, Step: Integer;
begin
  inherited;
  if not Enabled then Exit;
  I := FSelectedIndex; Step := 0;
  case Key of
    VK_LEFT: Step := -1;
    VK_RIGHT: Step := 1;
    VK_HOME: begin I := 0; while (I < Length(FValues)) and not SparklineFinite(FValues[I]) do Inc(I) end;
    VK_END: begin I := Length(FValues) - 1; while (I >= 0) and not SparklineFinite(FValues[I]) do Dec(I) end;
    VK_ESCAPE: I := -1;
    VK_RETURN, VK_SPACE:
      begin
        if (I >= 0) and Assigned(FOnPointClicked) then FOnPointClicked(Self, I, FValues[I], Point(-1, -1));
        Key := 0; Exit;
      end;
    else Exit;
  end;
  if Step <> 0 then
  begin
    if I < 0 then I := 0 else Inc(I, Step);
    while (I >= 0) and (I < Length(FValues)) and not SparklineFinite(FValues[I]) do Inc(I, Step);
  end;
  SetSelectedIndex(I); Key := 0;
end;

procedure TCustomThemedSparkline.ApplyTheme(const APalette: TThemePalette);
begin
  inherited;
  if FToolTip <> nil then FToolTip.ApplyTheme(APalette);
  RequestInvalidate;
end;

procedure TCustomThemedSparkline.ApplyDarkTheme;
begin
  FOptions.ThemeMode := stmDark;
end;

procedure TCustomThemedSparkline.ApplyLightTheme;
begin
  FOptions.ThemeMode := stmLight;
end;

function TCustomThemedSparkline.GetThemePalette: TThemePalette;
begin
  Result := Palette;
end;

procedure TCustomThemedSparkline.SetThemePalette(const AValue: TThemePalette);
begin
  if AValue <> nil then begin ApplyTheme(AValue); FOptions.ThemeMode := stmCustom end
  else FOptions.ThemeMode := stmAuto;
end;

function TCustomThemedSparkline.GetStyle: TSparklineRenderStyle;
begin
  Result := FOptions.Style;
end;

procedure TCustomThemedSparkline.SetStyle(const AValue: TSparklineRenderStyle);
begin
  FOptions.Style := AValue;
end;

function TCustomThemedSparkline.GetRangeMode: TSparklineRangeMode;
begin
  Result := FOptions.RangeMode;
end;

procedure TCustomThemedSparkline.SetRangeMode(const AValue: TSparklineRangeMode);
begin
  FOptions.RangeMode := AValue;
end;

function TCustomThemedSparkline.GetPerformanceMode: TSparklinePerformanceMode;
begin
  Result := FOptions.PerformanceMode;
end;

procedure TCustomThemedSparkline.SetPerformanceMode(const AValue: TSparklinePerformanceMode);
begin
  FOptions.PerformanceMode := AValue;
end;

function TCustomThemedSparkline.GetFixedRange: TSparklineValueRange;
begin
  Result := FOptions.FixedRange;
end;

procedure TCustomThemedSparkline.SetFixedRange(const AValue: TSparklineValueRange);
begin
  FOptions.FixedRange := AValue;
end;

function TCustomThemedSparkline.GetThemeInfluence: Integer;
begin Result := FOptions.ThemeInfluence end;

procedure TCustomThemedSparkline.SetThemeInfluence(const AValue: Integer);
begin FOptions.ThemeInfluence := AValue end;

function TCustomThemedSparkline.GetBarGap: Integer;
begin Result := FOptions.BarGap end;

procedure TCustomThemedSparkline.SetBarGap(const AValue: Integer);
begin FOptions.BarGap := AValue end;

function TCustomThemedSparkline.GetThemeMode: TSparklineThemeMode;
begin
  Result := FOptions.ThemeMode;
end;

procedure TCustomThemedSparkline.SetThemeMode(const AValue: TSparklineThemeMode);
begin
  FOptions.ThemeMode := AValue;
end;

function TCustomThemedSparkline.GetAutoThemeFromParent: Boolean;
begin
  Result := FOptions.AutoThemeFromParent;
end;

procedure TCustomThemedSparkline.SetAutoThemeFromParent(const AValue: Boolean);
begin
  FOptions.AutoThemeFromParent := AValue;
end;

function TCustomThemedSparkline.GetPaintBackground: Boolean;
begin
  Result := FOptions.PaintBackground;
end;

procedure TCustomThemedSparkline.SetPaintBackground(const AValue: Boolean);
begin
  FOptions.PaintBackground := AValue;
end;

function TCustomThemedSparkline.GetShowBorder: Boolean;
begin
  Result := FOptions.ShowBorder;
end;

procedure TCustomThemedSparkline.SetShowBorder(const AValue: Boolean);
begin
  FOptions.ShowBorder := AValue;
end;

function TCustomThemedSparkline.GetShowArea: Boolean;
begin
  Result := FOptions.ShowArea;
end;

procedure TCustomThemedSparkline.SetShowArea(const AValue: Boolean);
begin
  FOptions.ShowArea := AValue;
end;

function TCustomThemedSparkline.GetShowLastPoint: Boolean;
begin
  Result := FOptions.ShowLastPoint;
end;

procedure TCustomThemedSparkline.SetShowLastPoint(const AValue: Boolean);
begin
  FOptions.ShowLastPoint := AValue;
end;

function TCustomThemedSparkline.GetShowStartPoint: Boolean;
begin
  Result := FOptions.ShowStartPoint;
end;

procedure TCustomThemedSparkline.SetShowStartPoint(const AValue: Boolean);
begin
  FOptions.ShowStartPoint := AValue;
end;

function TCustomThemedSparkline.GetShowMinMaxPoints: Boolean;
begin
  Result := FOptions.ShowMinMaxPoints;
end;

procedure TCustomThemedSparkline.SetShowMinMaxPoints(const AValue: Boolean);
begin
  FOptions.ShowMinMaxPoints := AValue;
end;

function TCustomThemedSparkline.GetShowMinMaxValueLabels: Boolean;
begin
  Result := FOptions.ShowMinMaxValueLabels;
end;

procedure TCustomThemedSparkline.SetShowMinMaxValueLabels(const AValue: Boolean);
begin
  FOptions.ShowMinMaxValueLabels := AValue;
end;

function TCustomThemedSparkline.GetShowZeroLine: Boolean;
begin
  Result := FOptions.ShowZeroLine;
end;

procedure TCustomThemedSparkline.SetShowZeroLine(const AValue: Boolean);
begin
  FOptions.ShowZeroLine := AValue;
end;

function TCustomThemedSparkline.GetShowEmptyState: Boolean;
begin
  Result := FOptions.ShowEmptyState;
end;

procedure TCustomThemedSparkline.SetShowEmptyState(const AValue: Boolean);
begin
  FOptions.ShowEmptyState := AValue;
end;

function TCustomThemedSparkline.GetEmptyLineVisible: Boolean;
begin
  Result := FOptions.EmptyLineVisible;
end;

procedure TCustomThemedSparkline.SetEmptyLineVisible(const AValue: Boolean);
begin
  FOptions.EmptyLineVisible := AValue;
end;

function TCustomThemedSparkline.GetEmptyText: string;
begin
  Result := FOptions.EmptyText;
end;

procedure TCustomThemedSparkline.SetEmptyText(const AValue: string);
begin
  FOptions.EmptyText := AValue;
end;

function TCustomThemedSparkline.GetShowTargetLine: Boolean;
begin
  Result := FOptions.ShowTargetLine;
end;

procedure TCustomThemedSparkline.SetShowTargetLine(const AValue: Boolean);
begin
  FOptions.ShowTargetLine := AValue;
end;

function TCustomThemedSparkline.GetTargetValue: Double;
begin
  Result := FOptions.TargetValue;
end;

procedure TCustomThemedSparkline.SetTargetValue(const AValue: Double);
begin
  FOptions.TargetValue := AValue;
end;

function TCustomThemedSparkline.GetShowAverageLine: Boolean;
begin
  Result := FOptions.ShowAverageLine;
end;

procedure TCustomThemedSparkline.SetShowAverageLine(const AValue: Boolean);
begin
  FOptions.ShowAverageLine := AValue;
end;

function TCustomThemedSparkline.GetShowRangeBand: Boolean;
begin
  Result := FOptions.ShowRangeBand;
end;

procedure TCustomThemedSparkline.SetShowRangeBand(const AValue: Boolean);
begin
  FOptions.ShowRangeBand := AValue;
end;

function TCustomThemedSparkline.GetBandMinimum: Double;
begin
  Result := FOptions.BandMinimum;
end;

procedure TCustomThemedSparkline.SetBandMinimum(const AValue: Double);
begin
  FOptions.BandMinimum := AValue;
end;

function TCustomThemedSparkline.GetBandMaximum: Double;
begin
  Result := FOptions.BandMaximum;
end;

procedure TCustomThemedSparkline.SetBandMaximum(const AValue: Double);
begin
  FOptions.BandMaximum := AValue;
end;

function TCustomThemedSparkline.GetColorizeRisingFallingSegments: Boolean;
begin
  Result := FOptions.ColorizeRisingFallingSegments;
end;

procedure TCustomThemedSparkline.SetColorizeRisingFallingSegments(const AValue: Boolean);
begin
  FOptions.ColorizeRisingFallingSegments := AValue;
end;

function TCustomThemedSparkline.GetColorizeNegativeSegments: Boolean;
begin
  Result := FOptions.ColorizeNegativeSegments;
end;

procedure TCustomThemedSparkline.SetColorizeNegativeSegments(const AValue: Boolean);
begin
  FOptions.ColorizeNegativeSegments := AValue;
end;

function TCustomThemedSparkline.GetShowEndValueLabel: Boolean;
begin
  Result := FOptions.ShowEndValueLabel;
end;

procedure TCustomThemedSparkline.SetShowEndValueLabel(const AValue: Boolean);
begin
  FOptions.ShowEndValueLabel := AValue;
end;

function TCustomThemedSparkline.GetValueLabelWidth: Integer;
begin
  Result := FOptions.ValueLabelWidth;
end;

procedure TCustomThemedSparkline.SetValueLabelWidth(const AValue: Integer);
begin
  FOptions.ValueLabelWidth := AValue;
end;

function TCustomThemedSparkline.GetShowHoverLine: Boolean;
begin
  Result := FOptions.ShowHoverLine;
end;

procedure TCustomThemedSparkline.SetShowHoverLine(const AValue: Boolean);
begin
  FOptions.ShowHoverLine := AValue;
end;

function TCustomThemedSparkline.GetShowSelection: Boolean;
begin
  Result := FOptions.ShowSelection;
end;

procedure TCustomThemedSparkline.SetShowSelection(const AValue: Boolean);
begin
  FOptions.ShowSelection := AValue;
end;

function TCustomThemedSparkline.GetUltraFastRendering: Boolean;
begin
  Result := FOptions.UltraFastRendering;
end;

procedure TCustomThemedSparkline.SetUltraFastRendering(const AValue: Boolean);
begin
  FOptions.UltraFastRendering := AValue;
end;

function TCustomThemedSparkline.GetUseGradientArea: Boolean;
begin
  Result := FOptions.UseGradientArea;
end;

procedure TCustomThemedSparkline.SetUseGradientArea(const AValue: Boolean);
begin
  FOptions.UseGradientArea := AValue;
end;

function TCustomThemedSparkline.GetAreaGradientAlphaTop: Integer;
begin
  Result := FOptions.AreaGradientAlphaTop;
end;

procedure TCustomThemedSparkline.SetAreaGradientAlphaTop(const AValue: Integer);
begin
  FOptions.AreaGradientAlphaTop := AValue;
end;

function TCustomThemedSparkline.GetAreaGradientAlphaBottom: Integer;
begin
  Result := FOptions.AreaGradientAlphaBottom;
end;

procedure TCustomThemedSparkline.SetAreaGradientAlphaBottom(const AValue: Integer);
begin
  FOptions.AreaGradientAlphaBottom := AValue;
end;

function TCustomThemedSparkline.GetSplitAreaByZero: Boolean;
begin
  Result := FOptions.SplitAreaByZero;
end;

procedure TCustomThemedSparkline.SetSplitAreaByZero(const AValue: Boolean);
begin
  FOptions.SplitAreaByZero := AValue;
end;

function TCustomThemedSparkline.GetUseRoundedBars: Boolean;
begin
  Result := FOptions.UseRoundedBars;
end;

procedure TCustomThemedSparkline.SetUseRoundedBars(const AValue: Boolean);
begin
  FOptions.UseRoundedBars := AValue;
end;

function TCustomThemedSparkline.GetBarCornerRadius: Integer;
begin
  Result := FOptions.BarCornerRadius;
end;

procedure TCustomThemedSparkline.SetBarCornerRadius(const AValue: Integer);
begin
  FOptions.BarCornerRadius := AValue;
end;

function TCustomThemedSparkline.GetShowToolTip: Boolean;
begin
  Result := FOptions.ShowToolTip;
end;

procedure TCustomThemedSparkline.SetShowToolTip(const AValue: Boolean);
begin
  FOptions.ShowToolTip := AValue;
end;

function TCustomThemedSparkline.GetValueFormat: string;
begin
  Result := FOptions.ValueFormat;
end;

procedure TCustomThemedSparkline.SetValueFormat(const AValue: string);
begin
  FOptions.ValueFormat := AValue;
end;

function TCustomThemedSparkline.GetAnimateValueChanges: Boolean;
begin
  Result := FOptions.AnimateValueChanges;
end;

procedure TCustomThemedSparkline.SetAnimateValueChanges(const AValue: Boolean);
begin
  FOptions.AnimateValueChanges := AValue;
end;

function TCustomThemedSparkline.GetAnimationDuration: Integer;
begin
  Result := FOptions.AnimationDuration;
end;

procedure TCustomThemedSparkline.SetAnimationDuration(const AValue: Integer);
begin
  FOptions.AnimationDuration := AValue;
end;

function TCustomThemedSparkline.GetSparklinePadding: Integer;
begin
  Result := FOptions.SparklinePadding;
end;

procedure TCustomThemedSparkline.SetSparklinePadding(const AValue: Integer);
begin
  FOptions.SparklinePadding := AValue;
end;

function TCustomThemedSparkline.GetStrokeWidth: Single;
begin
  Result := FOptions.StrokeWidth;
end;

procedure TCustomThemedSparkline.SetStrokeWidth(const AValue: Single);
begin
  FOptions.StrokeWidth := AValue;
end;

function TCustomThemedSparkline.GetAccentColor: TColor;
begin
  Result := FOptions.AccentColor;
end;

procedure TCustomThemedSparkline.SetAccentColor(const AValue: TColor);
begin
  FOptions.AccentColor := AValue;
end;

function TCustomThemedSparkline.GetMutedColor: TColor;
begin
  Result := FOptions.MutedColor;
end;

procedure TCustomThemedSparkline.SetMutedColor(const AValue: TColor);
begin
  FOptions.MutedColor := AValue;
end;

function TCustomThemedSparkline.GetBorderColor: TColor;
begin
  Result := FOptions.BorderColor;
end;

procedure TCustomThemedSparkline.SetBorderColor(const AValue: TColor);
begin
  FOptions.BorderColor := AValue;
end;

function TCustomThemedSparkline.GetLineColor: TColor;
begin
  Result := FOptions.LineColor;
end;

procedure TCustomThemedSparkline.SetLineColor(const AValue: TColor);
begin
  FOptions.LineColor := AValue;
end;

function TCustomThemedSparkline.GetFillColor: TColor;
begin
  Result := FOptions.FillColor;
end;

procedure TCustomThemedSparkline.SetFillColor(const AValue: TColor);
begin
  FOptions.FillColor := AValue;
end;

function TCustomThemedSparkline.GetNegativeColor: TColor;
begin
  Result := FOptions.NegativeColor;
end;

procedure TCustomThemedSparkline.SetNegativeColor(const AValue: TColor);
begin
  FOptions.NegativeColor := AValue;
end;

function TCustomThemedSparkline.GetZeroLineColor: TColor;
begin
  Result := FOptions.ZeroLineColor;
end;

procedure TCustomThemedSparkline.SetZeroLineColor(const AValue: TColor);
begin
  FOptions.ZeroLineColor := AValue;
end;

function TCustomThemedSparkline.GetLastPointColor: TColor;
begin
  Result := FOptions.LastPointColor;
end;

procedure TCustomThemedSparkline.SetLastPointColor(const AValue: TColor);
begin
  FOptions.LastPointColor := AValue;
end;

function TCustomThemedSparkline.GetMinPointColor: TColor;
begin
  Result := FOptions.MinPointColor;
end;

procedure TCustomThemedSparkline.SetMinPointColor(const AValue: TColor);
begin
  FOptions.MinPointColor := AValue;
end;

function TCustomThemedSparkline.GetMaxPointColor: TColor;
begin
  Result := FOptions.MaxPointColor;
end;

procedure TCustomThemedSparkline.SetMaxPointColor(const AValue: TColor);
begin
  FOptions.MaxPointColor := AValue;
end;

function TCustomThemedSparkline.GetTargetLineColor: TColor;
begin
  Result := FOptions.TargetLineColor;
end;

procedure TCustomThemedSparkline.SetTargetLineColor(const AValue: TColor);
begin
  FOptions.TargetLineColor := AValue;
end;

function TCustomThemedSparkline.GetAverageLineColor: TColor;
begin
  Result := FOptions.AverageLineColor;
end;

procedure TCustomThemedSparkline.SetAverageLineColor(const AValue: TColor);
begin
  FOptions.AverageLineColor := AValue;
end;

function TCustomThemedSparkline.GetRangeBandColor: TColor;
begin
  Result := FOptions.RangeBandColor;
end;

procedure TCustomThemedSparkline.SetRangeBandColor(const AValue: TColor);
begin
  FOptions.RangeBandColor := AValue;
end;

function TCustomThemedSparkline.GetStartPointColor: TColor;
begin
  Result := FOptions.StartPointColor;
end;

procedure TCustomThemedSparkline.SetStartPointColor(const AValue: TColor);
begin
  FOptions.StartPointColor := AValue;
end;

function TCustomThemedSparkline.GetRisingColor: TColor;
begin
  Result := FOptions.RisingColor;
end;

procedure TCustomThemedSparkline.SetRisingColor(const AValue: TColor);
begin
  FOptions.RisingColor := AValue;
end;

function TCustomThemedSparkline.GetFallingColor: TColor;
begin
  Result := FOptions.FallingColor;
end;

procedure TCustomThemedSparkline.SetFallingColor(const AValue: TColor);
begin
  FOptions.FallingColor := AValue;
end;

function TCustomThemedSparkline.GetHoverLineColor: TColor;
begin
  Result := FOptions.HoverLineColor;
end;

procedure TCustomThemedSparkline.SetHoverLineColor(const AValue: TColor);
begin
  FOptions.HoverLineColor := AValue;
end;

function TCustomThemedSparkline.GetSelectionColor: TColor;
begin
  Result := FOptions.SelectionColor;
end;

procedure TCustomThemedSparkline.SetSelectionColor(const AValue: TColor);
begin
  FOptions.SelectionColor := AValue;
end;

function TCustomThemedSparkline.GetMarkerColor: TColor;
begin
  Result := FOptions.MarkerColor;
end;

procedure TCustomThemedSparkline.SetMarkerColor(const AValue: TColor);
begin
  FOptions.MarkerColor := AValue;
end;

procedure TCustomThemedSparkline.DefineProperties(Filer: TFiler);
begin inherited; Filer.DefineProperty('FixedRange', ReadFixedRange, WriteFixedRange, FOptions.FixedRange.IsValid) end;

procedure TCustomThemedSparkline.ReadFixedRange(Reader: TReader);
var L, H: Double;
begin Reader.ReadListBegin; L := Reader.ReadFloat; H := Reader.ReadFloat; Reader.ReadListEnd; FixedRange := TSparklineValueRange.Create(L, H) end;

procedure TCustomThemedSparkline.WriteFixedRange(Writer: TWriter);
begin Writer.WriteListBegin; Writer.WriteFloat(FOptions.FixedRange.Minimum); Writer.WriteFloat(FOptions.FixedRange.Maximum); Writer.WriteListEnd end;

initialization
  RegisterClass(TThemedSparkline);

end.

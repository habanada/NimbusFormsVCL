{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.DashboardWidgets;

interface

uses System.Classes, System.Types, Vcl.Graphics, Vcl.Themes, NimbusForms.Controls.Base,
  NimbusForms.Rendering.DashboardWidgets;

type
  TCustomThemedDashboardWidget = class(TCustomNimbusControl)
  private
    FKind: TDashboardWidgetKind;
    FValues: TDashboardWidgetValues;
    FTarget: Double;
    FCaption: string;
    FDetail: string;
    FRenderer: TDashboardWidgetRenderer;
    procedure SetTarget(const Value: Double);
    procedure SetCaption(const Value: string);
    procedure SetDetail(const Value: string);
  protected
    procedure Paint; override;
    constructor CreateWidget(AOwner: TComponent; AKind: TDashboardWidgetKind);
  public
    destructor Destroy; override;
    procedure SetData(const AValues: array of Double);
    property Kind: TDashboardWidgetKind read FKind;
  published
    property Target: Double read FTarget write SetTarget;
    property Caption: string read FCaption write SetCaption;
    property Detail: string read FDetail write SetDetail;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property Hint;
    property ShowHint;
    property PopupMenu;
    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
    property OnMouseLeave;
  end;
  TThemedKpiTile = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedDeltaTile = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedProgressMeter = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedSegmentMeter = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedStatusMatrix = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedTrendArrow = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedComparisonBars = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedRadialScore = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedActivityDots = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TThemedCapacityBars = class(TCustomThemedDashboardWidget)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TCustomThemedDashboardWidget.CreateWidget(AOwner: TComponent; AKind: TDashboardWidgetKind);
begin
  inherited Create(AOwner);
  FKind := AKind; FTarget := 100; Width := 180; Height := 114;
  FRenderer := TDashboardWidgetRenderer.Create;
end;

destructor TCustomThemedDashboardWidget.Destroy;
begin FRenderer.Free; inherited Destroy end;

procedure TCustomThemedDashboardWidget.SetTarget(const Value: Double);
begin if FTarget = Value then Exit; FTarget := Value; Invalidate end;

procedure TCustomThemedDashboardWidget.SetCaption(const Value: string);
begin if FCaption = Value then Exit; FCaption := Value; Invalidate end;

procedure TCustomThemedDashboardWidget.SetDetail(const Value: string);
begin if FDetail = Value then Exit; FDetail := Value; Invalidate end;

procedure TCustomThemedDashboardWidget.SetData(const AValues: array of Double);
var I: Integer;
begin
  SetLength(FValues, Length(AValues));
  for I := 0 to High(AValues) do FValues[I] := AValues[I];
  Invalidate;
end;

procedure TCustomThemedDashboardWidget.Paint;
var C: TDashboardWidgetContext;
begin
  inherited;
  StyleServices.DrawParentBackground(Handle, Canvas.Handle, nil, False);
  C := Default(TDashboardWidgetContext); C.Bounds := ClientRect; C.Kind := FKind;
  C.Values := FValues; C.Target := FTarget; C.Caption := FCaption; C.Detail := FDetail;
  C.PPI := CurrentPPI; C.Palette := Palette; C.Enabled := Enabled; C.Font := Font;
  RenderCanvas.BeginRender(Canvas);
  try FRenderer.Render(RenderCanvas, C) finally RenderCanvas.EndRender end;
end;

constructor TThemedKpiTile.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwKpiTile) end;

constructor TThemedDeltaTile.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwDeltaTile) end;

constructor TThemedProgressMeter.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwProgressMeter) end;

constructor TThemedSegmentMeter.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwSegmentMeter) end;

constructor TThemedStatusMatrix.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwStatusMatrix) end;

constructor TThemedTrendArrow.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwTrendArrow) end;

constructor TThemedComparisonBars.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwComparisonBars) end;

constructor TThemedRadialScore.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwRadialScore) end;

constructor TThemedActivityDots.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwActivityDots) end;

constructor TThemedCapacityBars.Create(AOwner: TComponent);
begin inherited CreateWidget(AOwner, dwCapacityBars) end;

initialization
  RegisterClass(TThemedKpiTile);
  RegisterClass(TThemedDeltaTile);
  RegisterClass(TThemedProgressMeter);
  RegisterClass(TThemedSegmentMeter);
  RegisterClass(TThemedStatusMatrix);
  RegisterClass(TThemedTrendArrow);
  RegisterClass(TThemedComparisonBars);
  RegisterClass(TThemedRadialScore);
  RegisterClass(TThemedActivityDots);
  RegisterClass(TThemedCapacityBars);

end.

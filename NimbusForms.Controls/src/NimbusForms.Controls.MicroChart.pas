{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.MicroChart;

interface

uses System.Classes, System.Types, System.Math, Vcl.Graphics, Vcl.Themes, NimbusForms.Controls.Base,
  NimbusForms.Rendering.MicroChart;

type
  TCustomThemedMicroChart = class(TCustomNimbusControl)
  private
    FKind: TMicroChartKind;
    FValues: TMicroChartValues;
    FTarget: Double;
    FRenderer: TMicroChartRenderer;
    procedure SetKind(const Value: TMicroChartKind);
    procedure SetTarget(const Value: Double);
    procedure SetValues(const Value: TMicroChartValues);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetData(const AValues: array of Double);
    property Values: TMicroChartValues read FValues write SetValues;
  published
    property Kind: TMicroChartKind read FKind write SetKind default mckBullet;
    property Target: Double read FTarget write SetTarget;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property ShowHint;
    property Hint;
    property PopupMenu;
    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
    property OnMouseLeave;
  end;
  TThemedMicroChart = class(TCustomThemedMicroChart);

implementation

constructor TCustomThemedMicroChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); Width := 120; Height := 38; FTarget := 100;
  FRenderer := TMicroChartRenderer.Create;
end;

destructor TCustomThemedMicroChart.Destroy;
begin FRenderer.Free; inherited Destroy end;

procedure TCustomThemedMicroChart.SetKind(const Value: TMicroChartKind);
begin if FKind = Value then Exit; FKind := Value; Invalidate end;

procedure TCustomThemedMicroChart.SetTarget(const Value: Double);
begin if FTarget = Value then Exit; FTarget := Value; Invalidate end;

procedure TCustomThemedMicroChart.SetValues(const Value: TMicroChartValues);
begin FValues := Copy(Value); Invalidate end;

procedure TCustomThemedMicroChart.SetData(const AValues: array of Double);
var I: Integer;
begin SetLength(FValues,Length(AValues)); for I := 0 to High(AValues) do FValues[I] := AValues[I]; Invalidate end;

procedure TCustomThemedMicroChart.Paint;
var C: TMicroChartRenderContext;
begin
  inherited;
  StyleServices.DrawParentBackground(Handle, Canvas.Handle, nil, False);
  C := Default(TMicroChartRenderContext); C.Bounds := ClientRect; C.Kind := FKind; C.Values := FValues;
  C.Target := FTarget; C.PPI := CurrentPPI; C.Palette := Palette; C.Enabled := Enabled;
  RenderCanvas.BeginRender(Canvas);
  try FRenderer.Render(RenderCanvas,C) finally RenderCanvas.EndRender end;
end;

initialization
  RegisterClass(TThemedMicroChart);

end.

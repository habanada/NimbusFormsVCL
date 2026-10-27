{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ProgressBar;

interface

uses
  System.Classes,
  Vcl.Controls,
  NimbusForms.Controls.Base;

type
  TCustomThemedProgressBar = class(TCustomNimbusControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FPosition: Integer;
    FShowPercentage: Boolean;
    FCornerRadius: Integer;
    FOnChange: TNotifyEvent;
    procedure SetMinimum(const AValue: Integer);
    procedure SetMaximum(const AValue: Integer);
    procedure SetPosition(const AValue: Integer);
    procedure SetShowPercentage(const AValue: Boolean);
    procedure SetCornerRadius(const AValue: Integer);
  protected
    procedure StyleModeChanged; override;
    procedure DoChange; virtual;
    procedure Paint; override;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property ShowPercentage: Boolean read FShowPercentage write SetShowPercentage default False;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AOwner: TComponent); override;
    procedure StepBy(const ADelta: Integer);
  end;

  TThemedProgressBar = class(TCustomThemedProgressBar)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius;
    property Enabled;
    property Font;
    property Maximum;
    property Minimum;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Position;
    property ShowHint;
    property ShowPercentage;
    property Visible;
    property OnChange;
    property OnContextPopup;
  end;

implementation

uses
  NimbusForms.Rendering.ProgressBar;

constructor TCustomThemedProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 150;
  Height := 23;
  TabStop := False;
  FMinimum := 0;
  FMaximum := 100;
  FPosition := 0;
  FShowPercentage := False;
  FCornerRadius := 0;
end;

procedure TCustomThemedProgressBar.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(23, 17);
end;

procedure TCustomThemedProgressBar.SetMinimum(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue >= FMaximum then LValue := FMaximum - 1;
  if FMinimum = LValue then
    Exit;
  FMinimum := LValue;
  if FPosition < FMinimum then FPosition := FMinimum;
  Invalidate;
  DoChange;
end;

procedure TCustomThemedProgressBar.SetMaximum(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue <= FMinimum then LValue := FMinimum + 1;
  if FMaximum = LValue then
    Exit;
  FMaximum := LValue;
  if FPosition > FMaximum then FPosition := FMaximum;
  Invalidate;
  DoChange;
end;

procedure TCustomThemedProgressBar.SetPosition(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > FMaximum then LValue := FMaximum;
  if FPosition = LValue then
    Exit;
  FPosition := LValue;
  Invalidate;
  DoChange;
end;

procedure TCustomThemedProgressBar.SetShowPercentage(const AValue: Boolean);
begin
  if FShowPercentage = AValue then
    Exit;
  FShowPercentage := AValue;
  Invalidate;
end;

procedure TCustomThemedProgressBar.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FCornerRadius = LValue then
    Exit;
  FCornerRadius := LValue;
  Invalidate;
end;

procedure TCustomThemedProgressBar.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCustomThemedProgressBar.StepBy(const ADelta: Integer);
var
  LValue: Int64;
begin
  LValue := Int64(FPosition) + Int64(ADelta);
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > FMaximum then LValue := FMaximum;
  Position := Integer(LValue);
end;

procedure TCustomThemedProgressBar.Paint;
var
  LContext: TThemedProgressBarRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Font := Font;
    LContext.Palette := Palette;
    LContext.Minimum := FMinimum;
    LContext.Maximum := FMaximum;
    LContext.Position := FPosition;
    LContext.ShowPercentage := FShowPercentage;
    LContext.CornerRadius := ScaleValue(FCornerRadius);
    LContext.Enabled := Enabled;
    TThemedProgressBarRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

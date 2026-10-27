{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Panel;

interface

uses
  System.Classes,
  Vcl.Controls,
  NimbusForms.Controls.Base;

type
  TCustomThemedPanel = class(TCustomNimbusControl)
  private
    FShowBorder: Boolean;
    FCornerRadius: Integer;
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetCornerRadius(const AValue: Integer);
  protected
    procedure Paint; override;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 0;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThemedPanel = class(TCustomThemedPanel)
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property CornerRadius;
    property Enabled;
    property Font;
    property Padding;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowBorder;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

uses
  NimbusForms.Rendering.Panel;

constructor TCustomThemedPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  Width := 185;
  Height := 120;
  FShowBorder := True;
  FCornerRadius := 0;
end;

procedure TCustomThemedPanel.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then
    Exit;
  FShowBorder := AValue;
  Invalidate;
end;

procedure TCustomThemedPanel.SetCornerRadius(const AValue: Integer);
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

procedure TCustomThemedPanel.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedPanelRenderer.Render(RenderCanvas, ClientRect, Palette, FShowBorder,
      ScaleValue(FCornerRadius));
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

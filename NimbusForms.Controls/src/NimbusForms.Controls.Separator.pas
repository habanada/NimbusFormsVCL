{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Separator;

interface

uses
  System.Classes,
  Vcl.Controls,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base;

type
  TCustomThemedSeparator = class(TCustomNimbusControl)
  private
    FOrientation: TThemedSeparatorOrientation;
    FThickness: Integer;
    procedure SetOrientation(const AValue: TThemedSeparatorOrientation);
    procedure SetThickness(const AValue: Integer);
  protected
    procedure Paint; override;
    property Orientation: TThemedSeparatorOrientation read FOrientation write SetOrientation default tsoHorizontal;
    property Thickness: Integer read FThickness write SetThickness default 1;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThemedSeparator = class(TCustomThemedSeparator)
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Orientation;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Thickness;
    property Visible;
    property OnContextPopup;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  NimbusForms.Rendering.Separator;

constructor TCustomThemedSeparator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 10;
  TabStop := False;
  FOrientation := tsoHorizontal;
  FThickness := 1;
end;

procedure TCustomThemedSeparator.SetOrientation(const AValue: TThemedSeparatorOrientation);
begin
  if FOrientation = AValue then
    Exit;
  FOrientation := AValue;
  Invalidate;
end;

procedure TCustomThemedSeparator.SetThickness(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if FThickness = LValue then
    Exit;
  FThickness := LValue;
  Invalidate;
end;

procedure TCustomThemedSeparator.Paint;
var
  LContext: TThemedSeparatorRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Palette := Palette;
    LContext.Orientation := FOrientation;
    LContext.Thickness := ScaleValue(FThickness);
    TThemedSeparatorRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

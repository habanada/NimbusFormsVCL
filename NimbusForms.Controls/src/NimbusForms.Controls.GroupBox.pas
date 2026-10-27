{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.GroupBox;

interface

uses
  Winapi.Messages,
  System.Classes,
  Vcl.Controls,
  Vcl.StdCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas;

type
  TCustomThemedGroupBox = class(TCustomGroupBox, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FThemeRegistered: Boolean;
    FStyleMode: TThemedControlStyleMode;
    procedure SetStyleMode(const AValue: TThemedControlStyleMode);
    procedure RegisterThemeAware;
  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
    property StyleMode: TThemedControlStyleMode read FStyleMode write SetStyleMode default stNormal;
    property Palette: TThemePalette read FPalette;
    property RenderCanvas: INimbusRenderCanvas read FRenderCanvas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
  end;

  TThemedGroupBox = class(TCustomThemedGroupBox)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property Padding;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  Winapi.Windows,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Theming.Manager,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.GroupBox;

constructor TCustomThemedGroupBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  ParentColor := False;
  FRenderCanvas := TNimbusRenderCanvas.Create;
end;

destructor TCustomThemedGroupBox.Destroy;
begin
  if FThemeRegistered then
  begin
    ThemeManager.UnregisterAware(Self);
    FThemeRegistered := False;
  end;
  FPalette.Free;
  FRenderCanvas := nil;
  inherited Destroy;
end;

procedure TCustomThemedGroupBox.RegisterThemeAware;
begin
  if FThemeRegistered or (csLoading in ComponentState) or (csReading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedGroupBox.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
end;

procedure TCustomThemedGroupBox.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    CM_SHOWINGCHANGED: if Showing then RegisterThemeAware;
    CM_ENABLEDCHANGED: Invalidate;
  end;
end;

procedure TCustomThemedGroupBox.SetStyleMode(const AValue: TThemedControlStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  Invalidate;
end;

procedure TCustomThemedGroupBox.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  if FPalette = nil then
    FPalette := APalette.Clone
  else
    FPalette.Assign(APalette);
  Color := ThemeColorToColor(FPalette.PanelBackColor);
  Font.Color := ThemeColorToColor(FPalette.ForeColor);
  if not (csDestroying in ComponentState) then Invalidate;
end;

procedure TCustomThemedGroupBox.Paint;
var
  LContext: TThemedGroupBoxRenderContext;
begin
  FRenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Caption := Caption;
    LContext.Font := Font;
    LContext.Palette := FPalette;
    LContext.TextLeft := NimbusScaleValue(10 - Ord(FStyleMode = stCompact) * 2, CurrentPPI);
    LContext.LineTextSpacing := NimbusScaleValue(3 - Ord(FStyleMode = stCompact), CurrentPPI);
    LContext.LeftLineWidth := NimbusScaleValue(7 - Ord(FStyleMode = stCompact) * 2, CurrentPPI);
    LContext.BorderThickness := NimbusScaleValue(1, CurrentPPI);
    LContext.RightToLeft := UseRightToLeftReading;
    TThemedGroupBoxRenderer.Render(FRenderCanvas, LContext);
  finally
    FRenderCanvas.EndRender;
  end;
end;

end.

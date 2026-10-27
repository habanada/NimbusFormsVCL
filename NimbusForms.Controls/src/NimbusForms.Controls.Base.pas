{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Base;

interface

uses
  Winapi.Messages,
  System.Classes,
  Vcl.Controls,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas;

type
  TCustomNimbusControl = class(TCustomControl, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FThemeRegistered: Boolean;
    FStyleMode: TThemedControlStyleMode;
    procedure SetStyleMode(const AValue: TThemedControlStyleMode);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  protected
    procedure Loaded; override;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure RegisterThemeAware;
    function ScaleValue(const AValue: Integer): Integer;
    procedure StyleModeChanged; virtual;
    procedure UpdateStyleHeight(const ANormalHeight, ACompactHeight: Integer);
    property StyleMode: TThemedControlStyleMode read FStyleMode write SetStyleMode default stNormal;
    property Palette: TThemePalette read FPalette;
    property RenderCanvas: INimbusRenderCanvas read FRenderCanvas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
  end;

implementation

uses
  Winapi.Windows,
  NimbusForms.Theming.Manager,
  NimbusForms.Rendering.Types;

constructor TCustomNimbusControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csClickEvents];
  DoubleBuffered := True;
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FStyleMode := stNormal;
end;

destructor TCustomNimbusControl.Destroy;
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

procedure TCustomNimbusControl.RegisterThemeAware;
begin
  if FThemeRegistered or (csLoading in ComponentState) or (csReading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomNimbusControl.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
end;

procedure TCustomNimbusControl.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then RegisterThemeAware;
end;

procedure TCustomNimbusControl.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  if FPalette = nil then
    FPalette := APalette.Clone
  else
    FPalette.Assign(APalette);
  if not (csDestroying in ComponentState) then
    Invalidate;
end;

function TCustomNimbusControl.ScaleValue(const AValue: Integer): Integer;
begin
  Result := NimbusScaleValue(AValue, CurrentPPI);
end;

procedure TCustomNimbusControl.SetStyleMode(const AValue: TThemedControlStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  StyleModeChanged;
end;

procedure TCustomNimbusControl.StyleModeChanged;
begin
  Invalidate;
end;

procedure TCustomNimbusControl.UpdateStyleHeight(const ANormalHeight, ACompactHeight: Integer);
var
  LNormal, LCompact: Integer;
begin
  if Align <> alNone then Exit;
  LNormal := ScaleValue(ANormalHeight);
  LCompact := ScaleValue(ACompactHeight);
  if StyleMode = stCompact then
  begin
    if (Height = ANormalHeight) or (Height = LNormal) then Height := LCompact;
  end
  else if (Height = ACompactHeight) or (Height = LCompact) then Height := LNormal;
end;

procedure TCustomNimbusControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TCustomNimbusControl.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomNimbusControl.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

end.

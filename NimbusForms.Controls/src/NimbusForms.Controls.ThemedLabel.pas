{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ThemedLabel;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TCustomThemedLabel = class(TCustomLabel, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FMeasureCanvas: INimbusRenderCanvas;
    FMeasureBitmap: TBitmap;
    FUseMutedForeColor: Boolean;
    FThemeRegistered: Boolean;
    procedure SetUseMutedForeColor(const AValue: Boolean);
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure RegisterThemeAware;
    procedure Paint; override;
    procedure DoDrawText(var Rect: TRect; Flags: Longint); override;
    property UseMutedForeColor: Boolean read FUseMutedForeColor write SetUseMutedForeColor default False;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
  end;

  TThemedLabel = class(TCustomThemedLabel)
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize default True;
    property BiDiMode;
    property Caption;
    property Constraints;
    property Enabled;
    property FocusControl;
    property Font;
    property Layout;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent default True;
    property UseMutedForeColor;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  NimbusForms.Rendering.Types,
  NimbusForms.Theming.Manager,
  NimbusForms.Rendering.ThemedLabel;

constructor TCustomThemedLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FMeasureCanvas := TNimbusRenderCanvas.Create;
  FMeasureBitmap := TBitmap.Create;
  FMeasureBitmap.SetSize(1, 1);
  AutoSize := True;
  Transparent := True;
  AdjustBounds;
end;

destructor TCustomThemedLabel.Destroy;
begin
  if FThemeRegistered then ThemeManager.UnregisterAware(Self);
  FPalette.Free;
  FRenderCanvas := nil;
  FMeasureCanvas := nil;
  FreeAndNil(FMeasureBitmap);
  inherited Destroy;
end;

procedure TCustomThemedLabel.RegisterThemeAware;
begin
  if FThemeRegistered or (csDestroying in ComponentState) then
    Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedLabel.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
end;

procedure TCustomThemedLabel.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not (csLoading in ComponentState) then RegisterThemeAware;
end;

procedure TCustomThemedLabel.ApplyTheme(const APalette: TThemePalette);
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

procedure TCustomThemedLabel.SetUseMutedForeColor(const AValue: Boolean);
begin
  if FUseMutedForeColor = AValue then
    Exit;
  FUseMutedForeColor := AValue;
  Invalidate;
end;

procedure TCustomThemedLabel.DoDrawText(var Rect: TRect; Flags: Longint);
var
  LFlags: TNimbusTextFlags;
  LSize: TSize;
  LText: string;
  LWidth: Integer;
begin
  if (Flags and DT_CALCRECT = 0) or (FMeasureCanvas = nil) or (FMeasureBitmap = nil) then
  begin
    inherited DoDrawText(Rect, Flags);
    Exit;
  end;
  LFlags := [];
  LWidth := 0;
  if WordWrap then
  begin
    Include(LFlags, ntfWordWrap);
    LWidth := Max(1, Rect.Width);
  end
  else Include(LFlags, ntfSingleLine);
  if not ShowAccelChar then Include(LFlags, ntfNoPrefix);
  if UseRightToLeftAlignment then Include(LFlags, ntfRightToLeft);
  LText := Caption;
  if (LText = '') or (ShowAccelChar and (LText = '&')) then LText := LText + ' ';
  FMeasureCanvas.BeginRender(FMeasureBitmap.Canvas);
  try
    LSize := FMeasureCanvas.MeasureText(LText, Font, LWidth, LFlags);
  finally
    FMeasureCanvas.EndRender;
  end;
  Rect.Right := Rect.Left + LSize.cx;
  Rect.Bottom := Rect.Top + LSize.cy;
end;

procedure TCustomThemedLabel.Paint;
begin
  FRenderCanvas.BeginRender(Canvas);
  try
    TThemedLabelRenderer.Render(FRenderCanvas, ClientRect, Caption, Font, FPalette,
      Alignment, Layout, WordWrap, ShowAccelChar, Enabled, FUseMutedForeColor, UseRightToLeftAlignment);
  finally
    FRenderCanvas.EndRender;
  end;
end;

end.

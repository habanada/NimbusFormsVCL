{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.StyledLabel;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.Markup;

type
  TThemedStyledLabelVariant = (tslvNormal, tslvHeading, tslvMuted, tslvAccent, tslvSuccess, tslvWarning, tslvError, tslvCustom);
  TThemedStyledLabelLinkClickEvent = procedure(Sender: TObject; const ATarget: string) of object;

  TCustomThemedStyledLabel = class(TCustomLabel, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FMeasureCanvas: INimbusRenderCanvas;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
    FRenderer: TThemedMarkupRenderer;
    FTextPadding: TPadding;
    FVariant: TThemedStyledLabelVariant;
    FUseMarkup: Boolean;
    FAutoHeight: Boolean;
    FMaxLines: Integer;
    FLineSpacing: Integer;
    FCustomForeColor: TColor;
    FThemeRegistered: Boolean;
    FAdjustingBounds: Boolean;
    FInitialized: Boolean;
    FHoveredLink: string;
    FPressedLink: string;
    FCursorBeforeLink: TCursor;
    FLinkCursorActive: Boolean;
    FOnLinkClick: TThemedStyledLabelLinkClickEvent;
    procedure SetVariant(const AValue: TThemedStyledLabelVariant);
    procedure SetUseMarkup(const AValue: Boolean);
    procedure SetAutoHeight(const AValue: Boolean);
    procedure SetMaxLines(const AValue: Integer);
    procedure SetLineSpacing(const AValue: Integer);
    procedure SetCustomForeColor(const AValue: TColor);
    procedure SetTextPadding(const AValue: TPadding);
    procedure TextPaddingChanged(Sender: TObject);
    function ScaledPaddingRect(const ARect: TRect): TRect;
    function ScaledHorizontalPadding: Integer;
    function ScaledVerticalPadding: Integer;
    function ScaledLineSpacing: Integer;
    function MarkupVariant: TNimbusMarkupVariant;
    procedure PrepareRenderer(const ACanvas: INimbusRenderCanvas; const AWidth: Integer);
    procedure EnsureRendererLayout(const AWidth: Integer);
    function MeasureContent(const AWidth: Integer): TSize;
    function LinkAt(const X, Y: Integer): string;
    procedure SetHoveredLink(const AValue: string);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure AdjustBounds; override;
    procedure Resize; override;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoLinkClick(const ATarget: string); virtual;
    procedure RegisterThemeAware;
    property Variant: TThemedStyledLabelVariant read FVariant write SetVariant default tslvNormal;
    property UseMarkup: Boolean read FUseMarkup write SetUseMarkup default True;
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight default False;
    property MaxLines: Integer read FMaxLines write SetMaxLines default 0;
    property LineSpacing: Integer read FLineSpacing write SetLineSpacing default 2;
    property CustomForeColor: TColor read FCustomForeColor write SetCustomForeColor default clNone;
    property TextPadding: TPadding read FTextPadding write SetTextPadding;
    property OnLinkClick: TThemedStyledLabelLinkClickEvent read FOnLinkClick write FOnLinkClick;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    procedure Click; override;
    property HoveredLink: string read FHoveredLink;
  end;

  TThemedStyledLabel = class(TCustomThemedStyledLabel)
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoHeight;
    property AutoSize default False;
    property BiDiMode;
    property Caption;
    property Constraints;
    property CustomForeColor;
    property EllipsisPosition;
    property Enabled;
    property FocusControl;
    property Font;
    property Layout;
    property LineSpacing;
    property MaxLines;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property TextPadding;
    property Transparent default True;
    property UseMarkup;
    property Variant;
    property Visible;
    property WordWrap default True;
    property OnLinkClick;
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
  Winapi.Windows,
  System.Math,
  NimbusForms.Theming.Manager,
  NimbusForms.Rendering.Types;

constructor TCustomThemedStyledLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FMeasureCanvas := TNimbusRenderCanvas.Create;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.PixelFormat := pf32bit;
  FMeasureBitmap.SetSize(1, 1);
  FRenderer := TThemedMarkupRenderer.Create;
  FTextPadding := TPadding.Create(Self);
  FTextPadding.OnChange := TextPaddingChanged;
  FVariant := tslvNormal;
  FUseMarkup := True;
  FAutoHeight := False;
  FMaxLines := 0;
  FLineSpacing := 2;
  FCustomForeColor := clNone;
  FCursorBeforeLink := crDefault;
  FInitialized := True;
  AutoSize := False;
  Transparent := True;
  WordWrap := True;
  SetBounds(Left, Top, 260, 48);
end;

destructor TCustomThemedStyledLabel.Destroy;
begin
  FInitialized := False;
  if FThemeRegistered then ThemeManager.UnregisterAware(Self);
  FTextPadding.Free;
  FRenderer.Free;
  FMeasureBitmap.Free;
  FMeasureCanvas := nil;
  FRenderCanvas := nil;
  FPalette.Free;
  inherited Destroy;
end;

procedure TCustomThemedStyledLabel.RegisterThemeAware;
begin
  if FThemeRegistered or (csDestroying in ComponentState) then Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedStyledLabel.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
  AdjustBounds;
end;

procedure TCustomThemedStyledLabel.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not (csLoading in ComponentState) then RegisterThemeAware;
end;

procedure TCustomThemedStyledLabel.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  if FPalette = nil then FPalette := APalette.Clone else FPalette.Assign(APalette);
  if not (csDestroying in ComponentState) then Invalidate;
end;

procedure TCustomThemedStyledLabel.SetVariant(const AValue: TThemedStyledLabelVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  AdjustBounds;
  Invalidate;
end;

procedure TCustomThemedStyledLabel.SetUseMarkup(const AValue: Boolean);
begin
  if FUseMarkup = AValue then Exit;
  FUseMarkup := AValue;
  if not FUseMarkup then
  begin
    FPressedLink := '';
    SetHoveredLink('');
  end;
  AdjustBounds;
  Invalidate;
end;

procedure TCustomThemedStyledLabel.SetAutoHeight(const AValue: Boolean);
begin
  if FAutoHeight = AValue then Exit;
  FAutoHeight := AValue;
  AdjustBounds;
end;

procedure TCustomThemedStyledLabel.SetMaxLines(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FMaxLines = LValue then Exit;
  FMaxLines := LValue;
  AdjustBounds;
  Invalidate;
end;

procedure TCustomThemedStyledLabel.SetLineSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FLineSpacing = LValue then Exit;
  FLineSpacing := LValue;
  AdjustBounds;
  Invalidate;
end;

procedure TCustomThemedStyledLabel.SetCustomForeColor(const AValue: TColor);
begin
  if FCustomForeColor = AValue then Exit;
  FCustomForeColor := AValue;
  Invalidate;
end;

procedure TCustomThemedStyledLabel.SetTextPadding(const AValue: TPadding);
begin
  if AValue <> nil then FTextPadding.Assign(AValue);
end;

procedure TCustomThemedStyledLabel.TextPaddingChanged(Sender: TObject);
begin
  AdjustBounds;
  Invalidate;
end;

function TCustomThemedStyledLabel.ScaledHorizontalPadding: Integer;
begin
  Result := NimbusScaleValue(FTextPadding.Left + FTextPadding.Right, CurrentPPI);
end;

function TCustomThemedStyledLabel.ScaledVerticalPadding: Integer;
begin
  Result := NimbusScaleValue(FTextPadding.Top + FTextPadding.Bottom, CurrentPPI);
end;

function TCustomThemedStyledLabel.ScaledLineSpacing: Integer;
begin
  Result := NimbusScaleValue(FLineSpacing, CurrentPPI);
end;

function TCustomThemedStyledLabel.ScaledPaddingRect(const ARect: TRect): TRect;
begin
  Result := ARect;
  Inc(Result.Left, NimbusScaleValue(FTextPadding.Left, CurrentPPI));
  Inc(Result.Top, NimbusScaleValue(FTextPadding.Top, CurrentPPI));
  Dec(Result.Right, NimbusScaleValue(FTextPadding.Right, CurrentPPI));
  Dec(Result.Bottom, NimbusScaleValue(FTextPadding.Bottom, CurrentPPI));
  if Result.Right < Result.Left then Result.Right := Result.Left;
  if Result.Bottom < Result.Top then Result.Bottom := Result.Top;
end;

function TCustomThemedStyledLabel.MarkupVariant: TNimbusMarkupVariant;
begin
  Result := TNimbusMarkupVariant(Ord(FVariant));
end;

procedure TCustomThemedStyledLabel.PrepareRenderer(const ACanvas: INimbusRenderCanvas; const AWidth: Integer);
begin
  FRenderer.SetText(Caption, FUseMarkup);
  FRenderer.SetFont(Font);
  FRenderer.PrepareLayout(ACanvas, Max(1, AWidth), WordWrap, FMaxLines, ScaledLineSpacing,
    ShowAccelChar, UseRightToLeftAlignment, EllipsisPosition, MarkupVariant);
end;

procedure TCustomThemedStyledLabel.EnsureRendererLayout(const AWidth: Integer);
begin
  FRenderer.SetText(Caption, FUseMarkup);
  FRenderer.SetFont(Font);
  if FRenderer.LayoutValid then Exit;
  FMeasureCanvas.BeginRender(FMeasureBitmap.Canvas);
  try
    FRenderer.PrepareLayout(FMeasureCanvas, Max(1, AWidth), WordWrap, FMaxLines, ScaledLineSpacing,
      ShowAccelChar, UseRightToLeftAlignment, EllipsisPosition, MarkupVariant);
  finally
    FMeasureCanvas.EndRender;
  end;
end;

function TCustomThemedStyledLabel.MeasureContent(const AWidth: Integer): TSize;
begin
  FMeasureCanvas.BeginRender(FMeasureBitmap.Canvas);
  try
    PrepareRenderer(FMeasureCanvas, AWidth);
    Result := FRenderer.Measure;
  finally
    FMeasureCanvas.EndRender;
  end;
end;

function TCustomThemedStyledLabel.LinkAt(const X, Y: Integer): string;
var
  LRect: TRect;
begin
  Result := '';
  if not FUseMarkup or not Enabled then Exit;
  LRect := ScaledPaddingRect(Rect(0, 0, Width, Height));
  EnsureRendererLayout(Max(1, LRect.Width));
  Result := FRenderer.HitTestLink(Point(X, Y), LRect, Alignment, Layout, ScaledLineSpacing, UseRightToLeftAlignment);
end;

procedure TCustomThemedStyledLabel.SetHoveredLink(const AValue: string);
begin
  if FHoveredLink = AValue then Exit;
  FHoveredLink := AValue;
  if FHoveredLink <> '' then
  begin
    if not FLinkCursorActive then
    begin
      FCursorBeforeLink := Cursor;
      FLinkCursorActive := True;
    end;
    Cursor := crHandPoint;
  end
  else if FLinkCursorActive then
  begin
    Cursor := FCursorBeforeLink;
    FLinkCursorActive := False;
  end;
  Invalidate;
end;

procedure TCustomThemedStyledLabel.CMMouseLeave(var Message: TMessage);
begin
  FPressedLink := '';
  SetHoveredLink('');
  inherited;
end;

procedure TCustomThemedStyledLabel.CMEnabledChanged(var Message: TMessage);
begin
  if not Enabled then
  begin
    FPressedLink := '';
    SetHoveredLink('');
  end;
  Invalidate;
  inherited;
end;

procedure TCustomThemedStyledLabel.AdjustBounds;
var
  LContentWidth, LDesiredWidth, LDesiredHeight, LX: Integer;
  LSize: TSize;
  LAlignment: TAlignment;
begin
  if not FInitialized then
  begin
    inherited AdjustBounds;
    Exit;
  end;
  if FAdjustingBounds or (csReading in ComponentState) then Exit;
  FAdjustingBounds := True;
  try
    if WordWrap then
      LContentWidth := Max(1, Width - ScaledHorizontalPadding)
    else if AutoSize then
      LContentWidth := 1000000
    else
      LContentWidth := Max(1, Width - ScaledHorizontalPadding);
    LSize := MeasureContent(LContentWidth);
    if AutoSize then
    begin
      if WordWrap then LDesiredWidth := Width else LDesiredWidth := LSize.cx + ScaledHorizontalPadding;
      LDesiredHeight := LSize.cy + ScaledVerticalPadding;
      if LDesiredWidth < 1 then LDesiredWidth := 1;
      if LDesiredHeight < 1 then LDesiredHeight := 1;
      LX := Left;
      LAlignment := Alignment;
      if UseRightToLeftAlignment then
        case LAlignment of
          taLeftJustify: LAlignment := taRightJustify;
          taRightJustify: LAlignment := taLeftJustify;
        end;
      if LAlignment = taRightJustify then Inc(LX, Width - LDesiredWidth);
      SetBounds(LX, Top, LDesiredWidth, LDesiredHeight);
    end
    else if FAutoHeight then
    begin
      LDesiredHeight := LSize.cy + ScaledVerticalPadding;
      if LDesiredHeight < 1 then LDesiredHeight := 1;
      if Height <> LDesiredHeight then SetBounds(Left, Top, Width, LDesiredHeight);
    end;
  finally
    FAdjustingBounds := False;
  end;
end;

procedure TCustomThemedStyledLabel.Resize;
begin
  inherited Resize;
  if not FAdjustingBounds then AdjustBounds;
end;

procedure TCustomThemedStyledLabel.Paint;
var
  LRect: TRect;
begin
  FRenderCanvas.BeginRender(Canvas);
  try
    LRect := ScaledPaddingRect(Rect(0, 0, Width, Height));
    PrepareRenderer(FRenderCanvas, Max(1, LRect.Width));
    FRenderer.Render(FRenderCanvas, LRect, Alignment, Layout, WordWrap, FMaxLines, ScaledLineSpacing,
      ShowAccelChar, Enabled, UseRightToLeftAlignment, EllipsisPosition, MarkupVariant, FPalette, FCustomForeColor, FHoveredLink);
  finally
    FRenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedStyledLabel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Enabled then SetHoveredLink(LinkAt(X, Y)) else SetHoveredLink('');
  inherited MouseMove(Shift, X, Y);
end;

procedure TCustomThemedStyledLabel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and Enabled then
  begin
    SetHoveredLink(LinkAt(X, Y));
    FPressedLink := FHoveredLink;
  end
  else
    FPressedLink := '';
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomThemedStyledLabel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then FPressedLink := '';
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCustomThemedStyledLabel.DoLinkClick(const ATarget: string);
begin
  if Assigned(FOnLinkClick) then FOnLinkClick(Self, ATarget);
end;

procedure TCustomThemedStyledLabel.Click;
var
  LTarget: string;
begin
  LTarget := '';
  if Enabled and (FPressedLink <> '') and (FPressedLink = FHoveredLink) then LTarget := FPressedLink;
  FPressedLink := '';
  if LTarget <> '' then
  begin
    DoLinkClick(LTarget);
    Exit;
  end;
  inherited Click;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.VirtualList;

interface

uses
  System.Classes,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedVirtualListBadgeInlineAnchor = (vlibaTopRight, vlibaTopLeft, vlibaBottomRight, vlibaBottomLeft, vlibaCenterRight, vlibaCenterLeft, vlibaCenter);
  TThemedVirtualListBadgeInlineClipMode = (vlibcNone, vlibcClipToTarget, vlibcSkipIfOutsideTarget, vlibcSkipIfTargetTooSmall);

  TThemedVirtualListBadgeRenderOptions = class(TPersistent)
  private
    FAnchor: TThemedVirtualListBadgeInlineAnchor;
    FClipMode: TThemedVirtualListBadgeInlineClipMode;
    FOffsetX: Integer;
    FOffsetY: Integer;
    FPaddingLeft: Integer;
    FPaddingTop: Integer;
    FPaddingRight: Integer;
    FPaddingBottom: Integer;
    FScale: Single;
    FOpacity: Single;
    FDrawHalo: Boolean;
    FDrawShadow: Boolean;
    FDrawBorder: Boolean;
    FUseTargetBackColorAsHalo: Boolean;
    FHaloColor: TColor;
    FMinTargetWidth: Integer;
    FMinTargetHeight: Integer;
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetAnchor(const AValue: TThemedVirtualListBadgeInlineAnchor);
    procedure SetClipMode(const AValue: TThemedVirtualListBadgeInlineClipMode);
    procedure SetOffsetX(const AValue: Integer);
    procedure SetOffsetY(const AValue: Integer);
    procedure SetPaddingLeft(const AValue: Integer);
    procedure SetPaddingTop(const AValue: Integer);
    procedure SetPaddingRight(const AValue: Integer);
    procedure SetPaddingBottom(const AValue: Integer);
    procedure SetScale(const AValue: Single);
    procedure SetOpacity(const AValue: Single);
    procedure SetDrawHalo(const AValue: Boolean);
    procedure SetDrawShadow(const AValue: Boolean);
    procedure SetDrawBorder(const AValue: Boolean);
    procedure SetUseTargetBackColorAsHalo(const AValue: Boolean);
    procedure SetHaloColor(const AValue: TColor);
    procedure SetMinTargetWidth(const AValue: Integer);
    procedure SetMinTargetHeight(const AValue: Integer);
    function GetOffset: TPoint;
    procedure SetOffset(const AValue: TPoint);
    function GetMinTargetSize: TSize;
    procedure SetMinTargetSize(const AValue: TSize);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetDefaultValues;
    procedure SetCellDefaults;
    procedure SetRowDefaults;
    property Offset: TPoint read GetOffset write SetOffset;
    property MinTargetSize: TSize read GetMinTargetSize write SetMinTargetSize;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Anchor: TThemedVirtualListBadgeInlineAnchor read FAnchor write SetAnchor default vlibaTopRight;
    property ClipMode: TThemedVirtualListBadgeInlineClipMode read FClipMode write SetClipMode default vlibcNone;
    property OffsetX: Integer read FOffsetX write SetOffsetX default 0;
    property OffsetY: Integer read FOffsetY write SetOffsetY default 0;
    property PaddingLeft: Integer read FPaddingLeft write SetPaddingLeft default 0;
    property PaddingTop: Integer read FPaddingTop write SetPaddingTop default 0;
    property PaddingRight: Integer read FPaddingRight write SetPaddingRight default 0;
    property PaddingBottom: Integer read FPaddingBottom write SetPaddingBottom default 0;
    property Scale: Single read FScale write SetScale;
    property Opacity: Single read FOpacity write SetOpacity;
    property DrawHalo: Boolean read FDrawHalo write SetDrawHalo default True;
    property DrawShadow: Boolean read FDrawShadow write SetDrawShadow default True;
    property DrawBorder: Boolean read FDrawBorder write SetDrawBorder default True;
    property UseTargetBackColorAsHalo: Boolean read FUseTargetBackColorAsHalo write SetUseTargetBackColorAsHalo default True;
    property HaloColor: TColor read FHaloColor write SetHaloColor default clNone;
    property MinTargetWidth: Integer read FMinTargetWidth write SetMinTargetWidth default 8;
    property MinTargetHeight: Integer read FMinTargetHeight write SetMinTargetHeight default 8;
  end;

  TThemedVirtualListItemMetrics = record
    HorizontalPadding: Integer;
    VerticalPadding: Integer;
    Spacing: Integer;
    ImageSize: Integer;
    CheckSize: Integer;
    StatusSize: Integer;
    BadgeHeight: Integer;
    BadgePadding: Integer;
    ProgressHeight: Integer;
    SelectionRadius: Integer;
    BorderInset: Integer;
  end;

  TThemedVirtualListItemLayout = record
    RowRect: TRect;
    SelectionRect: TRect;
    StatusRect: TRect;
    CheckRect: TRect;
    ImageRect: TRect;
    TextRect: TRect;
    TitleRect: TRect;
    SubtitleRect: TRect;
    DetailRect: TRect;
    BadgeRect: TRect;
    ProgressRect: TRect;
  end;

  TThemedVirtualListItemRenderContext = record
    Bounds: TRect;
    ClientWidth: Integer;
    Text: string;
    Subtitle: string;
    DetailText: string;
    BadgeText: string;
    Font: TFont;
    Image: Vcl.Graphics.TBitmap;
    Palette: TThemePalette;
    BackColor: TColor;
    ForeColor: TColor;
    AccentColor: TColor;
    StatusColor: TColor;
    ProgressValue: Integer;
    CheckState: Integer;
    Metrics: TThemedVirtualListItemMetrics;
    Selected: Boolean;
    Hovered: Boolean;
    Pressed: Boolean;
    Focused: Boolean;
    Disabled: Boolean;
    ShowCheckBox: Boolean;
    ShowSubtitle: Boolean;
    ShowDetail: Boolean;
    ShowProgress: Boolean;
    Placeholder: Boolean;
    RoundedSelection: Boolean;
    AlternatingRow: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedVirtualListRenderer = class
  private
    class function ResolveBackColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor; static;
    class function ResolveForeColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor; static;
    class function ResolveMutedColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor; static;
    class function ResolveAccentColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor; static;
    class function MirrorRect(const ARect: TRect; const ALeft, ARight: Integer): TRect; static;
    class procedure DrawCheckBox(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AContext: TThemedVirtualListItemRenderContext); static;
  public
    class function CalculateCheckRect(const ABounds: TRect; const AMetrics: TThemedVirtualListItemMetrics; const AHasStatus, ARightToLeft: Boolean): TRect; static;
    class function CalculateLayout(const ACanvas: INimbusRenderCanvas; const AContext: TThemedVirtualListItemRenderContext): TThemedVirtualListItemLayout; static;
    class procedure RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedVirtualListItemRenderContext; out ALayout: TThemedVirtualListItemLayout); static;
    class procedure RenderEmpty(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const ABackColor, AForeColor: TColor; const ARightToLeft: Boolean); static;
    class procedure RenderSearchBox(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor; const AFocused: Boolean); static;
    class procedure RenderFilterBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor); static;
    class procedure RenderFilterCell(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette); static;
    class procedure RenderHeaderBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor); static;
    class procedure RenderHeaderCell(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAlignment: TAlignment; const ASortDirection: Integer; const AHot, ADragging, ARightToLeft: Boolean); static;
    class procedure RenderTableRowBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor; const ASelected, AHovered, APressed, AAlternate, AFocused, ADisabled: Boolean); static;
    class procedure RenderTableRowBorder(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette); static;
    class procedure RenderCellText(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AForeColor: TColor; const AAlignment: TAlignment; const ASelected, AEnabled, ARightToLeft: Boolean); static;
    class procedure RenderCheckBox(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AState: Integer; const AEnabled: Boolean; const APalette: TThemePalette; const AAccentColor: TColor); static;
    class procedure RenderStatusIndicator(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AColor: TColor; const AEnabled: Boolean; const APalette: TThemePalette); static;
    class procedure RenderBadge(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled: Boolean); static;
    class procedure RenderInlineBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOffset: Integer); overload; static;
    class procedure RenderInlineBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions); overload; static;
    class procedure RenderInlineBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions; const ABadgeScale, ABadgeOpacity: Single); overload; static;
    class procedure RenderInlineDotBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions); overload; static;
    class procedure RenderInlineDotBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions; const ABadgeScale, ABadgeOpacity: Single); overload; static;
    class procedure RenderInlineImageBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const ABitmap: Vcl.Graphics.TBitmap; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions); overload; static;
    class procedure RenderInlineImageBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const ABitmap: Vcl.Graphics.TBitmap; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions; const ABadgeScale, ABadgeOpacity: Single); overload; static;
    class procedure RenderProgress(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AValue: Integer; const APalette: TThemePalette; const AAccentColor: TColor; const AEnabled, ARightToLeft: Boolean); static;
    class procedure RenderPlaceholderRow(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor); static;
    class procedure RenderColumnSeparator(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette); static;
    class procedure RenderDropIndicator(const ACanvas: INimbusRenderCanvas; const AX, ATop, ABottom: Integer; const APalette: TThemePalette); static;
    class procedure RenderGroupHeader(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const ABackColor: TColor; const ARightToLeft: Boolean); static;
    class procedure RenderSeparator(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette); static;
    class procedure RenderDetailsBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor); static;
    class procedure RenderDetailsGlyph(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AExpanded: Boolean; const APalette: TThemePalette; const AForeColor: TColor; const ARightToLeft: Boolean); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  System.UITypes,
  NimbusForms.Rendering.Types;

constructor TThemedVirtualListBadgeRenderOptions.Create;
begin
  inherited Create;
  SetDefaultValues;
end;

procedure TThemedVirtualListBadgeRenderOptions.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedVirtualListBadgeRenderOptions.Assign(Source: TPersistent);
var
  LSource: TThemedVirtualListBadgeRenderOptions;
begin
  if Source is TThemedVirtualListBadgeRenderOptions then
  begin
    LSource := TThemedVirtualListBadgeRenderOptions(Source);
    FAnchor := LSource.FAnchor;
    FClipMode := LSource.FClipMode;
    FOffsetX := LSource.FOffsetX;
    FOffsetY := LSource.FOffsetY;
    FPaddingLeft := LSource.FPaddingLeft;
    FPaddingTop := LSource.FPaddingTop;
    FPaddingRight := LSource.FPaddingRight;
    FPaddingBottom := LSource.FPaddingBottom;
    FScale := LSource.FScale;
    FOpacity := LSource.FOpacity;
    FDrawHalo := LSource.FDrawHalo;
    FDrawShadow := LSource.FDrawShadow;
    FDrawBorder := LSource.FDrawBorder;
    FUseTargetBackColorAsHalo := LSource.FUseTargetBackColorAsHalo;
    FHaloColor := LSource.FHaloColor;
    FMinTargetWidth := LSource.FMinTargetWidth;
    FMinTargetHeight := LSource.FMinTargetHeight;
    Changed;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TThemedVirtualListBadgeRenderOptions.SetDefaultValues;
begin
  FAnchor := vlibaTopRight;
  FClipMode := vlibcNone;
  FOffsetX := 0;
  FOffsetY := 0;
  FPaddingLeft := 0;
  FPaddingTop := 0;
  FPaddingRight := 0;
  FPaddingBottom := 0;
  FScale := 1.0;
  FOpacity := 1.0;
  FDrawHalo := True;
  FDrawShadow := True;
  FDrawBorder := True;
  FUseTargetBackColorAsHalo := True;
  FHaloColor := clNone;
  FMinTargetWidth := 8;
  FMinTargetHeight := 8;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetCellDefaults;
begin
  SetDefaultValues;
  FAnchor := vlibaCenterRight;
  FClipMode := vlibcClipToTarget;
  FOffsetX := -4;
  FDrawShadow := False;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetRowDefaults;
begin
  SetDefaultValues;
  FAnchor := vlibaCenterRight;
  FClipMode := vlibcClipToTarget;
  FOffsetX := -8;
  FDrawShadow := False;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetAnchor(const AValue: TThemedVirtualListBadgeInlineAnchor);
begin
  if FAnchor = AValue then Exit;
  FAnchor := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetClipMode(const AValue: TThemedVirtualListBadgeInlineClipMode);
begin
  if FClipMode = AValue then Exit;
  FClipMode := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetOffsetX(const AValue: Integer);
begin
  if FOffsetX = AValue then Exit;
  FOffsetX := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetOffsetY(const AValue: Integer);
begin
  if FOffsetY = AValue then Exit;
  FOffsetY := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetPaddingLeft(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FPaddingLeft = LValue then Exit;
  FPaddingLeft := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetPaddingTop(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FPaddingTop = LValue then Exit;
  FPaddingTop := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetPaddingRight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FPaddingRight = LValue then Exit;
  FPaddingRight := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetPaddingBottom(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FPaddingBottom = LValue then Exit;
  FPaddingBottom := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetScale(const AValue: Single);
var
  LValue: Single;
begin
  LValue := AValue;
  if LValue < 0.05 then LValue := 0.05 else if LValue > 4.0 then LValue := 4.0;
  if SameValue(FScale, LValue, 0.0001) then Exit;
  FScale := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetOpacity(const AValue: Single);
var
  LValue: Single;
begin
  LValue := AValue;
  if LValue < 0.0 then LValue := 0.0 else if LValue > 1.0 then LValue := 1.0;
  if SameValue(FOpacity, LValue, 0.0001) then Exit;
  FOpacity := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetDrawHalo(const AValue: Boolean);
begin
  if FDrawHalo = AValue then Exit;
  FDrawHalo := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetDrawShadow(const AValue: Boolean);
begin
  if FDrawShadow = AValue then Exit;
  FDrawShadow := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetDrawBorder(const AValue: Boolean);
begin
  if FDrawBorder = AValue then Exit;
  FDrawBorder := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetUseTargetBackColorAsHalo(const AValue: Boolean);
begin
  if FUseTargetBackColorAsHalo = AValue then Exit;
  FUseTargetBackColorAsHalo := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetHaloColor(const AValue: TColor);
begin
  if FHaloColor = AValue then Exit;
  FHaloColor := AValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetMinTargetWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FMinTargetWidth = LValue then Exit;
  FMinTargetWidth := LValue;
  Changed;
end;

procedure TThemedVirtualListBadgeRenderOptions.SetMinTargetHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FMinTargetHeight = LValue then Exit;
  FMinTargetHeight := LValue;
  Changed;
end;

function TThemedVirtualListBadgeRenderOptions.GetOffset: TPoint;
begin
  Result := Point(FOffsetX, FOffsetY);
end;

procedure TThemedVirtualListBadgeRenderOptions.SetOffset(const AValue: TPoint);
begin
  if (FOffsetX = AValue.X) and (FOffsetY = AValue.Y) then Exit;
  FOffsetX := AValue.X;
  FOffsetY := AValue.Y;
  Changed;
end;

function TThemedVirtualListBadgeRenderOptions.GetMinTargetSize: TSize;
begin
  Result := TSize.Create(FMinTargetWidth, FMinTargetHeight);
end;

procedure TThemedVirtualListBadgeRenderOptions.SetMinTargetSize(const AValue: TSize);
var
  LWidth, LHeight: Integer;
begin
  LWidth := Max(0, AValue.cx);
  LHeight := Max(0, AValue.cy);
  if (FMinTargetWidth = LWidth) and (FMinTargetHeight = LHeight) then Exit;
  FMinTargetWidth := LWidth;
  FMinTargetHeight := LHeight;
  Changed;
end;

class function TThemedVirtualListRenderer.ResolveBackColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.InputBackColor else Result := ColorToThemeColor(AContext.BackColor);
end;

class function TThemedVirtualListRenderer.ResolveForeColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.InputForeColor else Result := ColorToThemeColor(AContext.ForeColor);
end;

class function TThemedVirtualListRenderer.ResolveMutedColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then Result := AContext.Palette.MutedForeColor else Result := ColorToThemeColor(clGrayText);
end;

class function TThemedVirtualListRenderer.ResolveAccentColor(const AContext: TThemedVirtualListItemRenderContext): TThemeColor;
begin
  if AContext.AccentColor <> clNone then Result := ColorToThemeColor(AContext.AccentColor)
  else if AContext.Palette <> nil then Result := AContext.Palette.AccentColor
  else Result := ColorToThemeColor(clHighlight);
end;

class function TThemedVirtualListRenderer.MirrorRect(const ARect: TRect; const ALeft, ARight: Integer): TRect;
begin
  Result := Rect(ALeft + ARight - ARect.Right, ARect.Top, ALeft + ARight - ARect.Left, ARect.Bottom);
end;

class procedure TThemedVirtualListRenderer.DrawCheckBox(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AContext: TThemedVirtualListItemRenderContext);
var
  LBorder, LBack, LAccent, LMark: TThemeColor;
  LCX, LCY, LInset: Integer;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  if AContext.Palette <> nil then
  begin
    LBorder := AContext.Palette.ControlBorderColor;
    LBack := AContext.Palette.InputBackColor;
    LAccent := ResolveAccentColor(AContext);
    LMark := AContext.Palette.SelectedForeColor;
    if AContext.Disabled then
    begin
      LBack := AContext.Palette.DisabledBackColor;
      LBorder := AContext.Palette.DisabledForeColor;
      LAccent := LBorder;
    end;
  end
  else
  begin
    LBorder := ColorToThemeColor(clBtnShadow);
    LBack := ColorToThemeColor(clWindow);
    LAccent := ColorToThemeColor(clHighlight);
    LMark := ColorToThemeColor(clHighlightText);
    if AContext.Disabled then
    begin
      LBack := ColorToThemeColor(clBtnFace);
      LBorder := ColorToThemeColor(clGrayText);
      LAccent := LBorder;
    end;
  end;
  if AContext.CheckState = 0 then ACanvas.FillRoundedRectangle(LBack, ARect, Max(2, ARect.Height div 5)) else ACanvas.FillRoundedRectangle(LAccent, ARect, Max(2, ARect.Height div 5));
  ACanvas.DrawRoundedRectangle(LBorder, ARect, Max(2, ARect.Height div 5), 1.0);
  LCX := (ARect.Left + ARect.Right) div 2;
  LCY := (ARect.Top + ARect.Bottom) div 2;
  LInset := Max(3, ARect.Width div 4);
  if AContext.CheckState = 1 then
  begin
    ACanvas.DrawLine(LMark, ARect.Left + LInset, LCY, LCX - 1, ARect.Bottom - LInset, 2.0);
    ACanvas.DrawLine(LMark, LCX - 1, ARect.Bottom - LInset, ARect.Right - LInset, ARect.Top + LInset, 2.0);
  end
  else if AContext.CheckState = 2 then
    ACanvas.FillRoundedRectangle(LMark, Rect(ARect.Left + LInset, LCY - 1, ARect.Right - LInset, LCY + 2), 1);
end;

class function TThemedVirtualListRenderer.CalculateCheckRect(const ABounds: TRect; const AMetrics: TThemedVirtualListItemMetrics; const AHasStatus, ARightToLeft: Boolean): TRect;
var
  LLeft: Integer;
begin
  LLeft := ABounds.Left + AMetrics.HorizontalPadding;
  if AHasStatus then Inc(LLeft, AMetrics.StatusSize + AMetrics.Spacing);
  Result := Rect(LLeft, ABounds.Top + (ABounds.Height - AMetrics.CheckSize) div 2, LLeft + AMetrics.CheckSize, ABounds.Top + (ABounds.Height + AMetrics.CheckSize) div 2);
  if ARightToLeft then Result := MirrorRect(Result, ABounds.Left, ABounds.Right);
end;

class function TThemedVirtualListRenderer.CalculateLayout(const ACanvas: INimbusRenderCanvas; const AContext: TThemedVirtualListItemRenderContext): TThemedVirtualListItemLayout;
var
  LLeft, LRight, LBadgeWidth, LDetailWidth, LTextHeight: Integer;
  LSize: TSize;
begin
  Result := Default(TThemedVirtualListItemLayout);
  Result.RowRect := AContext.Bounds;
  Result.SelectionRect := Rect(Result.RowRect.Left + AContext.Metrics.BorderInset, Result.RowRect.Top + AContext.Metrics.BorderInset, Max(Result.RowRect.Left + AContext.Metrics.BorderInset + 1, Result.RowRect.Right - AContext.Metrics.BorderInset), Result.RowRect.Bottom - AContext.Metrics.BorderInset);
  LLeft := Result.RowRect.Left + AContext.Metrics.HorizontalPadding;
  LRight := Result.RowRect.Right - AContext.Metrics.HorizontalPadding;
  if AContext.StatusColor <> clNone then
  begin
    Result.StatusRect := Rect(LLeft, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.StatusSize) div 2, LLeft + AContext.Metrics.StatusSize, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.StatusSize) div 2);
    LLeft := Result.StatusRect.Right + AContext.Metrics.Spacing;
  end;
  if AContext.ShowCheckBox then
  begin
    Result.CheckRect := CalculateCheckRect(AContext.Bounds, AContext.Metrics, AContext.StatusColor <> clNone, False);
    LLeft := Result.CheckRect.Right + AContext.Metrics.Spacing;
  end;
  if (AContext.Image <> nil) and not AContext.Image.Empty then
  begin
    Result.ImageRect := Rect(LLeft, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.ImageSize) div 2, LLeft + AContext.Metrics.ImageSize, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.ImageSize) div 2);
    LLeft := Result.ImageRect.Right + AContext.Metrics.Spacing;
  end;
  if AContext.BadgeText <> '' then
  begin
    LSize := ACanvas.MeasureText(AContext.BadgeText, AContext.Font, 0, [ntfSingleLine, ntfNoPrefix]);
    LBadgeWidth := Max(AContext.Metrics.BadgeHeight, LSize.cx + AContext.Metrics.BadgePadding * 2);
    Result.BadgeRect := Rect(LRight - LBadgeWidth, AContext.Bounds.Top + (AContext.Bounds.Height - AContext.Metrics.BadgeHeight) div 2, LRight, AContext.Bounds.Top + (AContext.Bounds.Height + AContext.Metrics.BadgeHeight) div 2);
    LRight := Result.BadgeRect.Left - AContext.Metrics.Spacing;
  end;
  if AContext.ShowDetail and (AContext.DetailText <> '') then
  begin
    LSize := ACanvas.MeasureText(AContext.DetailText, AContext.Font, Max(1, AContext.ClientWidth div 3), [ntfSingleLine, ntfNoPrefix, ntfEndEllipsis]);
    LDetailWidth := Min(Max(LSize.cx, AContext.Metrics.ImageSize * 2), Max(1, AContext.ClientWidth div 3));
    Result.DetailRect := Rect(Max(LLeft, LRight - LDetailWidth), AContext.Bounds.Top, LRight, AContext.Bounds.Bottom);
    LRight := Result.DetailRect.Left - AContext.Metrics.Spacing;
  end;
  Result.TextRect := Rect(LLeft, AContext.Bounds.Top + AContext.Metrics.VerticalPadding, Max(LLeft + 1, LRight), AContext.Bounds.Bottom - AContext.Metrics.VerticalPadding);
  if AContext.ShowSubtitle and (AContext.Subtitle <> '') then
  begin
    LTextHeight := Result.TextRect.Height;
    Result.TitleRect := Rect(Result.TextRect.Left, Result.TextRect.Top, Result.TextRect.Right, Result.TextRect.Top + Max(1, LTextHeight div 2 + 1));
    Result.SubtitleRect := Rect(Result.TextRect.Left, Result.TextRect.Top + LTextHeight div 2, Result.TextRect.Right, Result.TextRect.Bottom);
  end
  else
    Result.TitleRect := Result.TextRect;
  if AContext.ShowProgress then
    Result.ProgressRect := Rect(LLeft, AContext.Bounds.Bottom - AContext.Metrics.ProgressHeight - AContext.Metrics.BorderInset, Max(LLeft + 1, Result.RowRect.Right - AContext.Metrics.HorizontalPadding), AContext.Bounds.Bottom - AContext.Metrics.BorderInset);
  if AContext.RightToLeft then
  begin
    Result.StatusRect := MirrorRect(Result.StatusRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.CheckRect := MirrorRect(Result.CheckRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.ImageRect := MirrorRect(Result.ImageRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.TextRect := MirrorRect(Result.TextRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.TitleRect := MirrorRect(Result.TitleRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.SubtitleRect := MirrorRect(Result.SubtitleRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.DetailRect := MirrorRect(Result.DetailRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.BadgeRect := MirrorRect(Result.BadgeRect, Result.RowRect.Left, Result.RowRect.Right);
    Result.ProgressRect := MirrorRect(Result.ProgressRect, Result.RowRect.Left, Result.RowRect.Right);
  end;
end;

class procedure TThemedVirtualListRenderer.RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedVirtualListItemRenderContext; out ALayout: TThemedVirtualListItemLayout);
var
  LBack, LFore, LMuted, LAccent, LSelectedBack, LSelectedFore, LDisabled, LRowBack, LPressedBack, LBadgeBack, LBadgeFore, LProgressBack: TThemeColor;
  LFlags, LDetailFlags: TNimbusTextFlags;
  LProgressRect, LFocusRect: TRect;
  LValue: Integer;
begin
  ALayout := CalculateLayout(ACanvas, AContext);
  if AContext.Placeholder then
  begin
    RenderPlaceholderRow(ACanvas, AContext.Bounds, AContext.Palette, AContext.BackColor);
    Exit;
  end;
  LBack := ResolveBackColor(AContext);
  LFore := ResolveForeColor(AContext);
  LMuted := ResolveMutedColor(AContext);
  LAccent := ResolveAccentColor(AContext);
  if AContext.Palette <> nil then
  begin
    LSelectedBack := AContext.Palette.SelectedBackColor;
    LSelectedFore := AContext.Palette.SelectedForeColor;
    LPressedBack := AContext.Palette.PressedBackColor;
    LDisabled := AContext.Palette.DisabledForeColor;
    LProgressBack := AContext.Palette.ProgressBackColor;
  end
  else
  begin
    LSelectedBack := ColorToThemeColor(clHighlight);
    LSelectedFore := ColorToThemeColor(clHighlightText);
    LPressedBack := NimbusBlendColor(LBack, LAccent, 48);
    LDisabled := ColorToThemeColor(clGrayText);
    LProgressBack := ColorToThemeColor(clBtnFace);
  end;
  LRowBack := LBack;
  if AContext.AlternatingRow and not AContext.Selected and not AContext.Hovered then LRowBack := NimbusBlendColor(LBack, LMuted, 12);
  ACanvas.FillRectangle(LRowBack, ALayout.RowRect);
  if AContext.Selected then
  begin
    if AContext.Pressed and not AContext.Disabled then LRowBack := NimbusBlendColor(LSelectedBack, LPressedBack, 72) else LRowBack := LSelectedBack;
    if AContext.RoundedSelection then ACanvas.FillRoundedRectangle(LRowBack, ALayout.SelectionRect, AContext.Metrics.SelectionRadius) else ACanvas.FillRectangle(LRowBack, ALayout.SelectionRect);
    LFore := LSelectedFore;
    LMuted := NimbusColorWithAlpha(LSelectedFore, 190);
  end
  else if AContext.Pressed and not AContext.Disabled then
  begin
    if AContext.RoundedSelection then ACanvas.FillRoundedRectangle(LPressedBack, ALayout.SelectionRect, AContext.Metrics.SelectionRadius) else ACanvas.FillRectangle(LPressedBack, ALayout.SelectionRect);
  end
  else if AContext.Hovered and not AContext.Disabled then
  begin
    if AContext.Palette <> nil then LRowBack := AContext.Palette.HoverBackColor else LRowBack := NimbusBlendColor(LBack, LAccent, 28);
    if AContext.RoundedSelection then ACanvas.FillRoundedRectangle(LRowBack, ALayout.SelectionRect, AContext.Metrics.SelectionRadius) else ACanvas.FillRectangle(LRowBack, ALayout.SelectionRect);
  end;
  if AContext.Disabled then
  begin
    LFore := LDisabled;
    LMuted := LDisabled;
  end;
  if not NimbusRectIsEmpty(ALayout.StatusRect) then ACanvas.FillEllipse(ColorToThemeColor(AContext.StatusColor), ALayout.StatusRect);
  if AContext.ShowCheckBox then DrawCheckBox(ACanvas, ALayout.CheckRect, AContext);
  if (AContext.Image <> nil) and not AContext.Image.Empty and not NimbusRectIsEmpty(ALayout.ImageRect) then ACanvas.DrawBitmap(AContext.Image, ALayout.ImageRect);
  LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  LDetailFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix, ntfRight];
  if AContext.RightToLeft then
  begin
    Include(LFlags, ntfRightToLeft);
    Include(LFlags, ntfRight);
    Include(LDetailFlags, ntfRightToLeft);
    Exclude(LDetailFlags, ntfRight);
  end;
  ACanvas.DrawText(AContext.Text, AContext.Font, LFore, ALayout.TitleRect, LFlags);
  if AContext.ShowSubtitle and (AContext.Subtitle <> '') then ACanvas.DrawText(AContext.Subtitle, AContext.Font, LMuted, ALayout.SubtitleRect, LFlags);
  if AContext.ShowDetail and (AContext.DetailText <> '') then ACanvas.DrawText(AContext.DetailText, AContext.Font, LMuted, ALayout.DetailRect, LDetailFlags);
  if not NimbusRectIsEmpty(ALayout.BadgeRect) then
  begin
    LBadgeBack := LAccent;
    if AContext.Palette <> nil then LBadgeFore := AContext.Palette.SelectedForeColor else LBadgeFore := ColorToThemeColor(clHighlightText);
    ACanvas.FillRoundedRectangle(LBadgeBack, ALayout.BadgeRect, ALayout.BadgeRect.Height div 2);
    ACanvas.DrawText(AContext.BadgeText, AContext.Font, LBadgeFore, ALayout.BadgeRect, [ntfSingleLine, ntfCenter, ntfVCenter, ntfNoPrefix]);
  end;
  if AContext.ShowProgress and not NimbusRectIsEmpty(ALayout.ProgressRect) then
  begin
    ACanvas.FillRoundedRectangle(LProgressBack, ALayout.ProgressRect, Max(1, ALayout.ProgressRect.Height div 2));
    LValue := EnsureRange(AContext.ProgressValue, 0, 100);
    LProgressRect := ALayout.ProgressRect;
    if AContext.RightToLeft then LProgressRect.Left := LProgressRect.Right - MulDiv(LProgressRect.Width, LValue, 100)
    else LProgressRect.Right := LProgressRect.Left + MulDiv(LProgressRect.Width, LValue, 100);
    if LProgressRect.Width > 0 then ACanvas.FillRoundedRectangle(LAccent, LProgressRect, Max(1, ALayout.ProgressRect.Height div 2));
  end;
  if AContext.Focused then
  begin
    LFocusRect := ALayout.SelectionRect;
    InflateRect(LFocusRect, -1, -1);
    if AContext.Palette <> nil then ACanvas.DrawFocusRectangle(AContext.Palette.FocusBorderColor, LFocusRect) else ACanvas.DrawFocusRectangle(ColorToThemeColor(clHighlight), LFocusRect);
  end;
end;

class procedure TThemedVirtualListRenderer.RenderEmpty(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const ABackColor, AForeColor: TColor; const ARightToLeft: Boolean);
var
  LBack, LFore: TThemeColor;
  LFlags: TNimbusTextFlags;
begin
  if APalette <> nil then
  begin
    LBack := APalette.InputBackColor;
    LFore := APalette.MutedForeColor;
  end
  else
  begin
    LBack := ColorToThemeColor(ABackColor);
    LFore := ColorToThemeColor(AForeColor);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if AText = '' then Exit;
  LFlags := [ntfCenter, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  ACanvas.DrawText(AText, AFont, LFore, ABounds, LFlags);
end;

class procedure TThemedVirtualListRenderer.RenderSearchBox(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor; const AFocused: Boolean);
var
  LBack, LBorder: TThemeColor;
begin
  if APalette <> nil then
  begin
    LBack := APalette.InputBackColor;
    if AFocused then LBorder := APalette.FocusBorderColor else LBorder := APalette.InputBorderColor;
  end
  else
  begin
    LBack := ColorToThemeColor(ABackColor);
    if AFocused then LBorder := ColorToThemeColor(clHighlight) else LBorder := ColorToThemeColor(clBtnShadow);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if (ABounds.Width > 0) and (ABounds.Height > 0) then ACanvas.DrawRectangle(LBorder, Rect(ABounds.Left, ABounds.Top, ABounds.Right - 1, ABounds.Bottom - 1), 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderFilterBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor);
var
  LBack: TThemeColor;
begin
  if APalette <> nil then LBack := APalette.ControlBackColor else LBack := ColorToThemeColor(ABackColor);
  ACanvas.FillRectangle(LBack, ABounds);
end;

class procedure TThemedVirtualListRenderer.RenderFilterCell(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette);
var
  LBack, LBorder: TThemeColor;
begin
  if APalette <> nil then
  begin
    LBack := APalette.InputBackColor;
    LBorder := APalette.InputBorderColor;
  end
  else
  begin
    LBack := ColorToThemeColor(clWindow);
    LBorder := ColorToThemeColor(clBtnShadow);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if (ABounds.Width > 0) and (ABounds.Height > 0) then ACanvas.DrawRectangle(LBorder, Rect(ABounds.Left, ABounds.Top, ABounds.Right - 1, ABounds.Bottom - 1), 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderHeaderBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor);
var
  LBack, LBorder: TThemeColor;
begin
  if APalette <> nil then
  begin
    LBack := APalette.InputBackColor;
    LBorder := APalette.ControlBorderColor;
  end
  else
  begin
    LBack := ColorToThemeColor(ABackColor);
    LBorder := ColorToThemeColor(clBtnShadow);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if ABounds.Height > 0 then ACanvas.DrawLine(LBorder, ABounds.Left, ABounds.Bottom - 1, ABounds.Right, ABounds.Bottom - 1, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderHeaderCell(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAlignment: TAlignment; const ASortDirection: Integer; const AHot, ADragging, ARightToLeft: Boolean);
var
  LBack, LHover, LBorder, LFore, LAccent: TThemeColor;
  LTextRect, LArrowRect: TRect;
  LFlags: TNimbusTextFlags;
  LPoints: TNimbusPointBuffer;
  LCenterX, LCenterY, LHalf: Integer;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then
  begin
    LBack := APalette.InputBackColor;
    LHover := APalette.HoverBackColor;
    LBorder := APalette.ControlBorderColor;
    LFore := APalette.ControlForeColor;
    LAccent := APalette.AccentColor;
  end
  else
  begin
    LBack := ColorToThemeColor(clBtnFace);
    LHover := ColorToThemeColor(clBtnHighlight);
    LBorder := ColorToThemeColor(clBtnShadow);
    LFore := ColorToThemeColor(clBtnText);
    LAccent := ColorToThemeColor(clHighlight);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if AHot or ADragging then
  begin
    if ADragging then LHover := NimbusDarkenColor(LHover, 8);
    ACanvas.FillRectangle(LHover, ABounds);
  end;
  ACanvas.DrawLine(LBorder, ABounds.Right - 1, ABounds.Top + 4, ABounds.Right - 1, ABounds.Bottom - 4, 1.0);
  LTextRect := Rect(ABounds.Left + 8, ABounds.Top, ABounds.Right - 8, ABounds.Bottom);
  if ASortDirection <> 0 then
  begin
    if ARightToLeft then
    begin
      LArrowRect := Rect(ABounds.Left + 4, ABounds.Top, ABounds.Left + 20, ABounds.Bottom);
      LTextRect.Left := LArrowRect.Right + 2;
    end
    else
    begin
      LArrowRect := Rect(ABounds.Right - 20, ABounds.Top, ABounds.Right - 4, ABounds.Bottom);
      LTextRect.Right := LArrowRect.Left - 2;
    end;
    LCenterX := (LArrowRect.Left + LArrowRect.Right) div 2;
    LCenterY := (LArrowRect.Top + LArrowRect.Bottom) div 2;
    LHalf := Max(2, Min(LArrowRect.Width, LArrowRect.Height) div 5);
    if ASortDirection = 1 then
    begin
      LPoints[0] := Point(LCenterX - LHalf, LCenterY + LHalf div 2);
      LPoints[1] := Point(LCenterX + LHalf, LCenterY + LHalf div 2);
      LPoints[2] := Point(LCenterX, LCenterY - LHalf);
    end
    else
    begin
      LPoints[0] := Point(LCenterX - LHalf, LCenterY - LHalf div 2);
      LPoints[1] := Point(LCenterX + LHalf, LCenterY - LHalf div 2);
      LPoints[2] := Point(LCenterX, LCenterY + LHalf);
    end;
    ACanvas.FillPolygon(LAccent, @LPoints, 3);
  end;
  LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  case AAlignment of
    taRightJustify: Include(LFlags, ntfRight);
    taCenter: Include(LFlags, ntfCenter);
  end;
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  ACanvas.DrawText(AText, AFont, LFore, LTextRect, LFlags);
end;

class procedure TThemedVirtualListRenderer.RenderTableRowBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor; const ASelected, AHovered, APressed, AAlternate, AFocused, ADisabled: Boolean);
var
  LBack: TThemeColor;
begin
  if APalette <> nil then
  begin
    LBack := APalette.ControlBackColor;
    if ASelected then LBack := APalette.AccentColor
    else if APressed and not ADisabled then LBack := APalette.PressedBackColor
    else if AHovered and not ADisabled then LBack := APalette.HoverBackColor
    else if AAlternate then LBack := NimbusBlendColor(LBack, APalette.MutedForeColor, 10);
  end
  else
  begin
    LBack := ColorToThemeColor(ABackColor);
    if ASelected then LBack := ColorToThemeColor(clHighlight)
    else if APressed and not ADisabled then LBack := ColorToThemeColor(clBtnShadow)
    else if AHovered and not ADisabled then LBack := ColorToThemeColor(clBtnHighlight);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if AFocused and not ADisabled then ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(APalette), Rect(ABounds.Left + 1, ABounds.Top + 1, ABounds.Right - 1, ABounds.Bottom - 1));
end;

class procedure TThemedVirtualListRenderer.RenderTableRowBorder(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette);
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  ACanvas.DrawLine(NimbusControlBorderColor(APalette), ABounds.Left, ABounds.Bottom - 1, ABounds.Right, ABounds.Bottom - 1, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderCellText(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AForeColor: TColor; const AAlignment: TAlignment; const ASelected, AEnabled, ARightToLeft: Boolean);
var
  LFore: TThemeColor;
  LFlags: TNimbusTextFlags;
begin
  if not AEnabled then LFore := NimbusDisabledForeColor(APalette)
  else if ASelected then LFore := NimbusSelectedForeColor(APalette)
  else if APalette <> nil then LFore := APalette.ControlForeColor
  else LFore := ColorToThemeColor(AForeColor);
  LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  case AAlignment of
    taRightJustify: Include(LFlags, ntfRight);
    taCenter: Include(LFlags, ntfCenter);
  end;
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  ACanvas.DrawText(AText, AFont, LFore, ABounds, LFlags);
end;

class procedure TThemedVirtualListRenderer.RenderCheckBox(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AState: Integer; const AEnabled: Boolean; const APalette: TThemePalette; const AAccentColor: TColor);
var
  LBorder, LFill, LGlyph: TThemeColor;
  LPoints: TNimbusPointBuffer;
  LPad, LCenterY: Integer;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if AEnabled then
  begin
    LBorder := NimbusInputBorderColor(APalette);
    LFill := NimbusInputBackColor(APalette);
    if AAccentColor <> clNone then LGlyph := ColorToThemeColor(AAccentColor) else LGlyph := NimbusAccentColor(APalette);
  end
  else
  begin
    LBorder := NimbusDisabledForeColor(APalette);
    LFill := NimbusDisabledBackColor(APalette);
    LGlyph := NimbusDisabledForeColor(APalette);
  end;
  ACanvas.FillRoundedRectangle(LFill, ABounds, Max(2, ABounds.Height div 5));
  ACanvas.DrawRoundedRectangle(LBorder, ABounds, Max(2, ABounds.Height div 5), 1.0);
  LPad := Max(3, ABounds.Width div 5);
  if AState = 1 then
  begin
    LPoints[0] := Point(ABounds.Left + LPad, (ABounds.Top + ABounds.Bottom) div 2);
    LPoints[1] := Point(ABounds.Left + ABounds.Width div 2 - 1, ABounds.Bottom - LPad);
    LPoints[2] := Point(ABounds.Right - LPad, ABounds.Top + LPad);
    ACanvas.DrawLine(LGlyph, LPoints[0].X, LPoints[0].Y, LPoints[1].X, LPoints[1].Y, 1.8);
    ACanvas.DrawLine(LGlyph, LPoints[1].X, LPoints[1].Y, LPoints[2].X, LPoints[2].Y, 1.8);
  end
  else if AState = 2 then
  begin
    LCenterY := (ABounds.Top + ABounds.Bottom) div 2;
    ACanvas.DrawLine(LGlyph, ABounds.Left + LPad, LCenterY, ABounds.Right - LPad, LCenterY, 1.8);
  end;
end;

class procedure TThemedVirtualListRenderer.RenderStatusIndicator(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AColor: TColor; const AEnabled: Boolean; const APalette: TThemePalette);
var
  LColor: TThemeColor;
begin
  if NimbusRectIsEmpty(ABounds) or (AColor = clNone) then Exit;
  LColor := ColorToThemeColor(AColor);
  if not AEnabled then LColor := NimbusBlendColor(LColor, NimbusDisabledForeColor(APalette), 150);
  ACanvas.FillEllipse(LColor, ABounds);
end;

class procedure TThemedVirtualListRenderer.RenderBadge(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled: Boolean);
var
  LBack, LFore: TThemeColor;
begin
  if NimbusRectIsEmpty(ABounds) or (AText = '') then Exit;
  if AAccentColor <> clNone then LBack := ColorToThemeColor(AAccentColor) else LBack := NimbusAccentColor(APalette);
  if not AEnabled then
  begin
    LBack := NimbusBlendColor(LBack, NimbusDisabledBackColor(APalette), 170);
    LFore := NimbusDisabledForeColor(APalette);
  end
  else if ASelected then LFore := NimbusSelectedForeColor(APalette)
  else if APalette <> nil then LFore := APalette.SelectedForeColor
  else LFore := ColorToThemeColor(clHighlightText);
  ACanvas.FillRoundedRectangle(LBack, ABounds, Max(2, ABounds.Height div 2));
  ACanvas.DrawText(AText, AFont, LFore, ABounds, [ntfSingleLine, ntfCenter, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]);
end;

class procedure TThemedVirtualListRenderer.RenderInlineBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOffset: Integer);
var
  LSize: TSize;
  LRect: TRect;
  LHeight, LWidth, LOffset, LVerticalPadding, LHorizontalPadding, LInset: Integer;
begin
  if (AText = '') or NimbusRectIsEmpty(ATarget) then Exit;
  LSize := ACanvas.MeasureText(AText, AFont, Max(1, ATarget.Width), [ntfSingleLine, ntfNoPrefix]);
  LVerticalPadding := Max(2, ATarget.Height div 10);
  LHorizontalPadding := Max(6, ATarget.Height div 2);
  LInset := Max(2, ATarget.Height div 10);
  LHeight := Min(Max(ATarget.Height div 2, LSize.cy + LVerticalPadding * 2), Max(1, ATarget.Height - LInset * 2));
  LWidth := Min(Max(LHeight, LSize.cx + LHorizontalPadding), Max(1, ATarget.Width - LInset * 2));
  LOffset := Max(0, AOffset);
  if ARightToLeft then
    LRect := Rect(ATarget.Left + LOffset, ATarget.Top + (ATarget.Height - LHeight) div 2, ATarget.Left + LOffset + LWidth, ATarget.Top + (ATarget.Height + LHeight) div 2)
  else
    LRect := Rect(ATarget.Right - LOffset - LWidth, ATarget.Top + (ATarget.Height - LHeight) div 2, ATarget.Right - LOffset, ATarget.Top + (ATarget.Height + LHeight) div 2);
  LRect.Left := Max(LRect.Left, ATarget.Left + LInset);
  LRect.Right := Min(LRect.Right, ATarget.Right - LInset);
  LRect.Top := Max(LRect.Top, ATarget.Top + LInset div 2);
  LRect.Bottom := Min(LRect.Bottom, ATarget.Bottom - LInset div 2);
  if NimbusRectIsEmpty(LRect) then Exit;
  RenderBadge(ACanvas, LRect, AText, AFont, APalette, AAccentColor, ASelected, AEnabled);
end;


class procedure TThemedVirtualListRenderer.RenderInlineBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions);
begin
  RenderInlineBadge(ACanvas, ATarget, AText, AFont, APalette, AAccentColor, ASelected, AEnabled, ARightToLeft, AOptions, 1.0, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderInlineBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions; const ABadgeScale, ABadgeOpacity: Single);
var
  LSize: TSize;
  LAvailable, LRect, LHaloRect, LShadowRect, LIntersection: TRect;
  LHeight, LWidth, LVerticalPadding, LHorizontalPadding, LInset, LX, LY, LOffsetX, LOffsetY: Integer;
  LAnchor: TThemedVirtualListBadgeInlineAnchor;
  LOpacity: Byte;
  LScale, LOpacityFactor: Single;
  LBack, LFore, LBorder, LHalo, LShadow: TThemeColor;
begin
  if (ACanvas = nil) or (AOptions = nil) or (AFont = nil) or (AText = '') or NimbusRectIsEmpty(ATarget) then Exit;
  LScale := ABadgeScale;
  if LScale < 0.05 then LScale := 0.05 else if LScale > 1.5 then LScale := 1.5;
  LOpacityFactor := ABadgeOpacity;
  if LOpacityFactor < 0.0 then LOpacityFactor := 0.0 else if LOpacityFactor > 1.0 then LOpacityFactor := 1.0;
  if (AOptions.ClipMode = vlibcSkipIfTargetTooSmall) and ((ATarget.Width < AOptions.MinTargetWidth) or (ATarget.Height < AOptions.MinTargetHeight)) then Exit;
  LAvailable := Rect(ATarget.Left + AOptions.PaddingLeft, ATarget.Top + AOptions.PaddingTop, ATarget.Right - AOptions.PaddingRight, ATarget.Bottom - AOptions.PaddingBottom);
  if NimbusRectIsEmpty(LAvailable) then Exit;
  LSize := ACanvas.MeasureText(AText, AFont, Max(1, LAvailable.Width), [ntfSingleLine, ntfNoPrefix]);
  LVerticalPadding := Max(2, LAvailable.Height div 10);
  LHorizontalPadding := Max(6, LAvailable.Height div 2);
  LInset := Max(2, LAvailable.Height div 10);
  LHeight := Min(Max(LAvailable.Height div 2, LSize.cy + LVerticalPadding * 2), Max(1, LAvailable.Height - LInset * 2));
  LWidth := Min(Max(LHeight, LSize.cx + LHorizontalPadding), Max(1, LAvailable.Width - LInset * 2));
  LHeight := Max(1, Round(LHeight * AOptions.Scale * LScale));
  LWidth := Max(1, Round(LWidth * AOptions.Scale * LScale));
  LAnchor := AOptions.Anchor;
  LOffsetX := AOptions.OffsetX;
  LOffsetY := AOptions.OffsetY;
  if ARightToLeft then
  begin
    case LAnchor of
      vlibaTopRight: LAnchor := vlibaTopLeft;
      vlibaTopLeft: LAnchor := vlibaTopRight;
      vlibaBottomRight: LAnchor := vlibaBottomLeft;
      vlibaBottomLeft: LAnchor := vlibaBottomRight;
      vlibaCenterRight: LAnchor := vlibaCenterLeft;
      vlibaCenterLeft: LAnchor := vlibaCenterRight;
    end;
    LOffsetX := -LOffsetX;
  end;
  case LAnchor of
    vlibaTopLeft:
      begin
        LX := LAvailable.Left;
        LY := LAvailable.Top;
      end;
    vlibaBottomRight:
      begin
        LX := LAvailable.Right - LWidth;
        LY := LAvailable.Bottom - LHeight;
      end;
    vlibaBottomLeft:
      begin
        LX := LAvailable.Left;
        LY := LAvailable.Bottom - LHeight;
      end;
    vlibaCenterRight:
      begin
        LX := LAvailable.Right - LWidth;
        LY := LAvailable.Top + (LAvailable.Height - LHeight) div 2;
      end;
    vlibaCenterLeft:
      begin
        LX := LAvailable.Left;
        LY := LAvailable.Top + (LAvailable.Height - LHeight) div 2;
      end;
    vlibaCenter:
      begin
        LX := LAvailable.Left + (LAvailable.Width - LWidth) div 2;
        LY := LAvailable.Top + (LAvailable.Height - LHeight) div 2;
      end;
  else
    begin
      LX := LAvailable.Right - LWidth;
      LY := LAvailable.Top;
    end;
  end;
  LRect := Rect(LX + LOffsetX, LY + LOffsetY, LX + LOffsetX + LWidth, LY + LOffsetY + LHeight);
  if AOptions.ClipMode = vlibcSkipIfOutsideTarget then
  begin
    if not IntersectRect(LIntersection, LRect, ATarget) then Exit;
  end
  else if AOptions.ClipMode = vlibcClipToTarget then
  begin
    if not IntersectRect(LIntersection, LRect, ATarget) then Exit;
    LRect := LIntersection;
  end;
  if NimbusRectIsEmpty(LRect) then Exit;
  LOpacity := EnsureRange(Round(AOptions.Opacity * LOpacityFactor * 255), 0, 255);
  if AAccentColor <> clNone then LBack := ColorToThemeColor(AAccentColor)
  else if APalette <> nil then LBack := APalette.AccentColor
  else LBack := ColorToThemeColor(clHighlight);
  if not AEnabled then LBack := NimbusBlendColor(LBack, NimbusDisabledBackColor(APalette), 170);
  LBack := NimbusColorWithAlpha(LBack, LOpacity);
  if not AEnabled then LFore := NimbusDisabledForeColor(APalette)
  else if ASelected then LFore := NimbusSelectedForeColor(APalette)
  else if APalette <> nil then LFore := APalette.SelectedForeColor
  else LFore := ColorToThemeColor(clHighlightText);
  LFore := NimbusColorWithAlpha(LFore, LOpacity);
  LBorder := NimbusColorWithAlpha(NimbusBlendColor(LBack, ColorToThemeColor(clBlack), 48), LOpacity);
  if AOptions.HaloColor <> clNone then LHalo := ColorToThemeColor(AOptions.HaloColor)
  else if AOptions.UseTargetBackColorAsHalo then
  begin
    if ASelected and (APalette <> nil) then LHalo := APalette.SelectedBackColor
    else if APalette <> nil then LHalo := APalette.InputBackColor
    else LHalo := ColorToThemeColor(clWindow);
  end
  else LHalo := ColorToThemeColor(clWindow);
  LHalo := NimbusColorWithAlpha(LHalo, Byte(Min(Integer(LOpacity), 220)));
  LShadow := NimbusColorWithAlpha(ColorToThemeColor(clBlack), Byte(MulDiv(70, LOpacity, 255)));
  if AOptions.DrawShadow then
  begin
    LShadowRect := LRect;
    OffsetRect(LShadowRect, Max(1, LRect.Height div 14), Max(1, LRect.Height div 12));
    if AOptions.ClipMode = vlibcClipToTarget then
    begin
      if IntersectRect(LIntersection, LShadowRect, ATarget) then LShadowRect := LIntersection else LShadowRect := Rect(0, 0, 0, 0);
    end;
    if not NimbusRectIsEmpty(LShadowRect) then ACanvas.FillRoundedRectangle(LShadow, LShadowRect, Max(1, LShadowRect.Height div 2));
  end;
  if AOptions.DrawHalo then
  begin
    LHaloRect := LRect;
    InflateRect(LHaloRect, Max(1, LRect.Height div 10), Max(1, LRect.Height div 10));
    if AOptions.ClipMode = vlibcClipToTarget then
    begin
      if IntersectRect(LIntersection, LHaloRect, ATarget) then LHaloRect := LIntersection else LHaloRect := Rect(0, 0, 0, 0);
    end;
    if not NimbusRectIsEmpty(LHaloRect) then ACanvas.FillRoundedRectangle(LHalo, LHaloRect, Max(1, LHaloRect.Height div 2));
  end;
  ACanvas.FillRoundedRectangle(LBack, LRect, Max(1, LRect.Height div 2));
  if AOptions.DrawBorder then ACanvas.DrawRoundedRectangle(LBorder, LRect, Max(1, LRect.Height div 2), 1.0);
  ACanvas.DrawText(AText, AFont, LFore, LRect, [ntfSingleLine, ntfCenter, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]);
end;

class procedure TThemedVirtualListRenderer.RenderInlineDotBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions);
begin
  RenderInlineDotBadge(ACanvas, ATarget, APalette, AAccentColor, ASelected, AEnabled, ARightToLeft, AOptions, 1.0, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderInlineDotBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions; const ABadgeScale, ABadgeOpacity: Single);
var
  LAvailable, LRect, LHaloRect, LShadowRect, LIntersection: TRect;
  LSize, LX, LY, LOffsetX: Integer;
  LAnchor: TThemedVirtualListBadgeInlineAnchor;
  LOpacity: Byte;
  LScale, LOpacityFactor: Single;
  LBack, LBorder, LHalo, LShadow: TThemeColor;
begin
  if (ACanvas = nil) or (AOptions = nil) or NimbusRectIsEmpty(ATarget) then Exit;
  LScale := ABadgeScale;
  if LScale < 0.05 then LScale := 0.05 else if LScale > 1.5 then LScale := 1.5;
  LOpacityFactor := ABadgeOpacity;
  if LOpacityFactor < 0.0 then LOpacityFactor := 0.0 else if LOpacityFactor > 1.0 then LOpacityFactor := 1.0;
  if (AOptions.ClipMode = vlibcSkipIfTargetTooSmall) and ((ATarget.Width < AOptions.MinTargetWidth) or (ATarget.Height < AOptions.MinTargetHeight)) then Exit;
  LAvailable := Rect(ATarget.Left + AOptions.PaddingLeft, ATarget.Top + AOptions.PaddingTop, ATarget.Right - AOptions.PaddingRight, ATarget.Bottom - AOptions.PaddingBottom);
  if NimbusRectIsEmpty(LAvailable) then Exit;
  LSize := Max(6, Min(14, LAvailable.Height div 2));
  LSize := Max(1, Round(LSize * AOptions.Scale * LScale));
  LAnchor := AOptions.Anchor;
  LOffsetX := AOptions.OffsetX;
  if ARightToLeft then
  begin
    case LAnchor of
      vlibaTopRight: LAnchor := vlibaTopLeft;
      vlibaTopLeft: LAnchor := vlibaTopRight;
      vlibaBottomRight: LAnchor := vlibaBottomLeft;
      vlibaBottomLeft: LAnchor := vlibaBottomRight;
      vlibaCenterRight: LAnchor := vlibaCenterLeft;
      vlibaCenterLeft: LAnchor := vlibaCenterRight;
    end;
    LOffsetX := -LOffsetX;
  end;
  case LAnchor of
    vlibaTopLeft: begin LX := LAvailable.Left; LY := LAvailable.Top; end;
    vlibaBottomRight: begin LX := LAvailable.Right - LSize; LY := LAvailable.Bottom - LSize; end;
    vlibaBottomLeft: begin LX := LAvailable.Left; LY := LAvailable.Bottom - LSize; end;
    vlibaCenterRight: begin LX := LAvailable.Right - LSize; LY := LAvailable.Top + (LAvailable.Height - LSize) div 2; end;
    vlibaCenterLeft: begin LX := LAvailable.Left; LY := LAvailable.Top + (LAvailable.Height - LSize) div 2; end;
    vlibaCenter: begin LX := LAvailable.Left + (LAvailable.Width - LSize) div 2; LY := LAvailable.Top + (LAvailable.Height - LSize) div 2; end;
  else
    begin LX := LAvailable.Right - LSize; LY := LAvailable.Top; end;
  end;
  LRect := Rect(LX + LOffsetX, LY + AOptions.OffsetY, LX + LOffsetX + LSize, LY + AOptions.OffsetY + LSize);
  if AOptions.ClipMode = vlibcSkipIfOutsideTarget then
  begin
    if not IntersectRect(LIntersection, LRect, ATarget) then Exit;
  end
  else if AOptions.ClipMode = vlibcClipToTarget then
  begin
    if not IntersectRect(LIntersection, LRect, ATarget) then Exit;
    LRect := LIntersection;
  end;
  if NimbusRectIsEmpty(LRect) then Exit;
  LOpacity := EnsureRange(Round(AOptions.Opacity * LOpacityFactor * 255), 0, 255);
  if AAccentColor <> clNone then LBack := ColorToThemeColor(AAccentColor) else LBack := NimbusAccentColor(APalette);
  if not AEnabled then LBack := NimbusBlendColor(LBack, NimbusDisabledBackColor(APalette), 170);
  LBack := NimbusColorWithAlpha(LBack, LOpacity);
  LBorder := NimbusColorWithAlpha(NimbusBlendColor(LBack, ColorToThemeColor(clBlack), 48), LOpacity);
  if AOptions.HaloColor <> clNone then LHalo := ColorToThemeColor(AOptions.HaloColor)
  else if AOptions.UseTargetBackColorAsHalo and ASelected and (APalette <> nil) then LHalo := APalette.SelectedBackColor
  else if AOptions.UseTargetBackColorAsHalo and (APalette <> nil) then LHalo := APalette.InputBackColor
  else LHalo := ColorToThemeColor(clWindow);
  LHalo := NimbusColorWithAlpha(LHalo, Byte(Min(Integer(LOpacity), 220)));
  LShadow := NimbusColorWithAlpha(ColorToThemeColor(clBlack), Byte(MulDiv(70, LOpacity, 255)));
  if AOptions.DrawShadow then
  begin
    LShadowRect := LRect;
    OffsetRect(LShadowRect, Max(1, LRect.Width div 8), Max(1, LRect.Height div 8));
    if AOptions.ClipMode = vlibcClipToTarget then
    begin
      if IntersectRect(LIntersection, LShadowRect, ATarget) then LShadowRect := LIntersection else LShadowRect := Rect(0, 0, 0, 0);
    end;
    if not NimbusRectIsEmpty(LShadowRect) then ACanvas.FillEllipse(LShadow, LShadowRect);
  end;
  if AOptions.DrawHalo then
  begin
    LHaloRect := LRect;
    InflateRect(LHaloRect, Max(1, LRect.Width div 5), Max(1, LRect.Height div 5));
    if AOptions.ClipMode = vlibcClipToTarget then
    begin
      if IntersectRect(LIntersection, LHaloRect, ATarget) then LHaloRect := LIntersection else LHaloRect := Rect(0, 0, 0, 0);
    end;
    if not NimbusRectIsEmpty(LHaloRect) then ACanvas.FillEllipse(LHalo, LHaloRect);
  end;
  ACanvas.FillEllipse(LBack, LRect);
  if AOptions.DrawBorder then ACanvas.DrawEllipse(LBorder, LRect, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderInlineImageBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const ABitmap: Vcl.Graphics.TBitmap; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions);
begin
  RenderInlineImageBadge(ACanvas, ATarget, ABitmap, APalette, AAccentColor, ASelected, AEnabled, ARightToLeft, AOptions, 1.0, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderInlineImageBadge(const ACanvas: INimbusRenderCanvas; const ATarget: TRect; const ABitmap: Vcl.Graphics.TBitmap; const APalette: TThemePalette; const AAccentColor: TColor; const ASelected, AEnabled, ARightToLeft: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions; const ABadgeScale, ABadgeOpacity: Single);
var
  LAvailable, LRect, LImageRect, LHaloRect, LShadowRect, LIntersection: TRect;
  LSize, LX, LY, LOffsetX, LInset: Integer;
  LAnchor: TThemedVirtualListBadgeInlineAnchor;
  LOpacity: Byte;
  LScale, LOpacityFactor: Single;
  LBack, LBorder, LHalo, LShadow: TThemeColor;
begin
  if (ACanvas = nil) or (AOptions = nil) or (ABitmap = nil) or ABitmap.Empty or NimbusRectIsEmpty(ATarget) then Exit;
  LScale := ABadgeScale;
  if LScale < 0.05 then LScale := 0.05 else if LScale > 1.5 then LScale := 1.5;
  LOpacityFactor := ABadgeOpacity;
  if LOpacityFactor < 0.0 then LOpacityFactor := 0.0 else if LOpacityFactor > 1.0 then LOpacityFactor := 1.0;
  if (AOptions.ClipMode = vlibcSkipIfTargetTooSmall) and ((ATarget.Width < AOptions.MinTargetWidth) or (ATarget.Height < AOptions.MinTargetHeight)) then Exit;
  LAvailable := Rect(ATarget.Left + AOptions.PaddingLeft, ATarget.Top + AOptions.PaddingTop, ATarget.Right - AOptions.PaddingRight, ATarget.Bottom - AOptions.PaddingBottom);
  if NimbusRectIsEmpty(LAvailable) then Exit;
  LSize := Max(12, Min(24, LAvailable.Height - Max(2, LAvailable.Height div 8) * 2));
  LSize := Max(1, Round(LSize * AOptions.Scale * LScale));
  LAnchor := AOptions.Anchor;
  LOffsetX := AOptions.OffsetX;
  if ARightToLeft then
  begin
    case LAnchor of
      vlibaTopRight: LAnchor := vlibaTopLeft;
      vlibaTopLeft: LAnchor := vlibaTopRight;
      vlibaBottomRight: LAnchor := vlibaBottomLeft;
      vlibaBottomLeft: LAnchor := vlibaBottomRight;
      vlibaCenterRight: LAnchor := vlibaCenterLeft;
      vlibaCenterLeft: LAnchor := vlibaCenterRight;
    end;
    LOffsetX := -LOffsetX;
  end;
  case LAnchor of
    vlibaTopLeft: begin LX := LAvailable.Left; LY := LAvailable.Top; end;
    vlibaBottomRight: begin LX := LAvailable.Right - LSize; LY := LAvailable.Bottom - LSize; end;
    vlibaBottomLeft: begin LX := LAvailable.Left; LY := LAvailable.Bottom - LSize; end;
    vlibaCenterRight: begin LX := LAvailable.Right - LSize; LY := LAvailable.Top + (LAvailable.Height - LSize) div 2; end;
    vlibaCenterLeft: begin LX := LAvailable.Left; LY := LAvailable.Top + (LAvailable.Height - LSize) div 2; end;
    vlibaCenter: begin LX := LAvailable.Left + (LAvailable.Width - LSize) div 2; LY := LAvailable.Top + (LAvailable.Height - LSize) div 2; end;
  else
    begin LX := LAvailable.Right - LSize; LY := LAvailable.Top; end;
  end;
  LRect := Rect(LX + LOffsetX, LY + AOptions.OffsetY, LX + LOffsetX + LSize, LY + AOptions.OffsetY + LSize);
  if AOptions.ClipMode = vlibcSkipIfOutsideTarget then
  begin
    if not IntersectRect(LIntersection, LRect, ATarget) then Exit;
  end
  else if AOptions.ClipMode = vlibcClipToTarget then
  begin
    if not IntersectRect(LIntersection, LRect, ATarget) then Exit;
    LRect := LIntersection;
  end;
  if NimbusRectIsEmpty(LRect) then Exit;
  LOpacity := EnsureRange(Round(AOptions.Opacity * LOpacityFactor * 255), 0, 255);
  if AAccentColor <> clNone then LBack := ColorToThemeColor(AAccentColor) else LBack := NimbusAccentColor(APalette);
  if not AEnabled then LBack := NimbusBlendColor(LBack, NimbusDisabledBackColor(APalette), 170);
  LBack := NimbusColorWithAlpha(LBack, Byte(MulDiv(72, LOpacity, 255)));
  LBorder := NimbusColorWithAlpha(NimbusBlendColor(LBack, ColorToThemeColor(clBlack), 48), LOpacity);
  if AOptions.HaloColor <> clNone then LHalo := ColorToThemeColor(AOptions.HaloColor)
  else if AOptions.UseTargetBackColorAsHalo and ASelected and (APalette <> nil) then LHalo := APalette.SelectedBackColor
  else if AOptions.UseTargetBackColorAsHalo and (APalette <> nil) then LHalo := APalette.InputBackColor
  else LHalo := ColorToThemeColor(clWindow);
  LHalo := NimbusColorWithAlpha(LHalo, Byte(Min(Integer(LOpacity), 220)));
  LShadow := NimbusColorWithAlpha(ColorToThemeColor(clBlack), Byte(MulDiv(70, LOpacity, 255)));
  if AOptions.DrawShadow then
  begin
    LShadowRect := LRect;
    OffsetRect(LShadowRect, Max(1, LRect.Width div 10), Max(1, LRect.Height div 10));
    if AOptions.ClipMode = vlibcClipToTarget then
    begin
      if IntersectRect(LIntersection, LShadowRect, ATarget) then LShadowRect := LIntersection else LShadowRect := Rect(0, 0, 0, 0);
    end;
    if not NimbusRectIsEmpty(LShadowRect) then ACanvas.FillRoundedRectangle(LShadow, LShadowRect, Max(2, LShadowRect.Height div 4));
  end;
  if AOptions.DrawHalo then
  begin
    LHaloRect := LRect;
    InflateRect(LHaloRect, Max(1, LRect.Width div 10), Max(1, LRect.Height div 10));
    if AOptions.ClipMode = vlibcClipToTarget then
    begin
      if IntersectRect(LIntersection, LHaloRect, ATarget) then LHaloRect := LIntersection else LHaloRect := Rect(0, 0, 0, 0);
    end;
    if not NimbusRectIsEmpty(LHaloRect) then ACanvas.FillRoundedRectangle(LHalo, LHaloRect, Max(2, LHaloRect.Height div 4));
  end;
  ACanvas.FillRoundedRectangle(LBack, LRect, Max(2, LRect.Height div 4));
  if AOptions.DrawBorder then ACanvas.DrawRoundedRectangle(LBorder, LRect, Max(2, LRect.Height div 4), 1.0);
  LInset := Max(2, LRect.Height div 8);
  LImageRect := Rect(LRect.Left + LInset, LRect.Top + LInset, LRect.Right - LInset, LRect.Bottom - LInset);
  if not NimbusRectIsEmpty(LImageRect) then ACanvas.DrawBitmap(ABitmap, LImageRect);
end;

class procedure TThemedVirtualListRenderer.RenderProgress(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AValue: Integer; const APalette: TThemePalette; const AAccentColor: TColor; const AEnabled, ARightToLeft: Boolean);
var
  LTrack, LFill: TThemeColor;
  LRect: TRect;
  LValue: Integer;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then LTrack := APalette.ProgressBackColor else LTrack := ColorToThemeColor(clBtnFace);
  if AAccentColor <> clNone then LFill := ColorToThemeColor(AAccentColor) else LFill := NimbusAccentColor(APalette);
  if not AEnabled then LFill := NimbusDisabledForeColor(APalette);
  ACanvas.FillRoundedRectangle(LTrack, ABounds, Max(1, ABounds.Height div 2));
  LValue := EnsureRange(AValue, 0, 100);
  LRect := ABounds;
  if ARightToLeft then LRect.Left := LRect.Right - MulDiv(LRect.Width, LValue, 100)
  else LRect.Right := LRect.Left + MulDiv(LRect.Width, LValue, 100);
  if LRect.Width > 0 then ACanvas.FillRoundedRectangle(LFill, LRect, Max(1, ABounds.Height div 2));
end;

class procedure TThemedVirtualListRenderer.RenderPlaceholderRow(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor);
var
  LBack, LBar: TThemeColor;
  LHeight, LTop, LLeft, LRight: Integer;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then
  begin
    LBack := APalette.ControlBackColor;
    LBar := NimbusBlendColor(APalette.ControlBorderColor, APalette.ControlBackColor, 120);
  end
  else
  begin
    LBack := ColorToThemeColor(ABackColor);
    LBar := ColorToThemeColor(clBtnShadow);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  LHeight := Max(3, ABounds.Height div 6);
  LTop := ABounds.Top + (ABounds.Height - LHeight) div 2;
  LLeft := ABounds.Left + Max(8, ABounds.Height div 2);
  LRight := Min(ABounds.Right - 8, LLeft + Max(32, ABounds.Width div 3));
  if LRight > LLeft then ACanvas.FillRoundedRectangle(LBar, Rect(LLeft, LTop, LRight, LTop + LHeight), Max(1, LHeight div 2));
  LLeft := LRight + 12;
  LRight := Min(ABounds.Right - 8, LLeft + Max(24, ABounds.Width div 6));
  if LRight > LLeft then ACanvas.FillRoundedRectangle(LBar, Rect(LLeft, LTop, LRight, LTop + LHeight), Max(1, LHeight div 2));
end;

class procedure TThemedVirtualListRenderer.RenderColumnSeparator(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette);
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  ACanvas.DrawLine(NimbusControlBorderColor(APalette), ABounds.Right - 1, ABounds.Top + 3, ABounds.Right - 1, ABounds.Bottom - 3, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderDropIndicator(const ACanvas: INimbusRenderCanvas; const AX, ATop, ABottom: Integer; const APalette: TThemePalette);
begin
  ACanvas.DrawLine(NimbusAccentColor(APalette), AX, ATop, AX, ABottom, 2.0);
end;

class procedure TThemedVirtualListRenderer.RenderGroupHeader(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const ABackColor: TColor; const ARightToLeft: Boolean);
var
  LBack, LFore, LBorder, LAccent: TThemeColor;
  LAccentRect, LTextRect: TRect;
  LFlags: TNimbusTextFlags;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then
  begin
    LBack := APalette.InputBackColor;
    LFore := APalette.MutedForeColor;
    LBorder := APalette.ControlBorderColor;
    LAccent := APalette.AccentColor;
  end
  else
  begin
    LBack := ColorToThemeColor(ABackColor);
    LFore := ColorToThemeColor(clGrayText);
    LBorder := ColorToThemeColor(clBtnShadow);
    LAccent := ColorToThemeColor(clHighlight);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  if ARightToLeft then LAccentRect := Rect(ABounds.Right - 3, ABounds.Top, ABounds.Right, ABounds.Bottom) else LAccentRect := Rect(ABounds.Left, ABounds.Top, ABounds.Left + 3, ABounds.Bottom);
  ACanvas.FillRectangle(LAccent, LAccentRect);
  LTextRect := ABounds;
  InflateRect(LTextRect, -10, 0);
  LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  if ARightToLeft then
  begin
    Include(LFlags, ntfRightToLeft);
    Include(LFlags, ntfRight);
  end;
  ACanvas.DrawText(AText, AFont, LFore, LTextRect, LFlags);
  ACanvas.DrawLine(LBorder, ABounds.Left, ABounds.Bottom - 1, ABounds.Right, ABounds.Bottom - 1, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderSeparator(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette);
var
  LBorder: TThemeColor;
  LY: Integer;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then LBorder := APalette.ControlBorderColor else LBorder := ColorToThemeColor(clBtnShadow);
  LY := (ABounds.Top + ABounds.Bottom) div 2;
  ACanvas.DrawLine(LBorder, ABounds.Left + 8, LY, ABounds.Right - 8, LY, 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderDetailsBackground(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ABackColor: TColor);
var
  LBack, LBorder: TThemeColor;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then
  begin
    LBack := NimbusDarkenColor(APalette.ControlBackColor, 4);
    LBorder := APalette.ControlBorderColor;
  end
  else
  begin
    LBack := NimbusDarkenColor(ColorToThemeColor(ABackColor), 4);
    LBorder := ColorToThemeColor(clBtnShadow);
  end;
  ACanvas.FillRectangle(LBack, ABounds);
  ACanvas.DrawRectangle(LBorder, Rect(ABounds.Left, ABounds.Top, ABounds.Right - 1, ABounds.Bottom - 1), 1.0);
end;

class procedure TThemedVirtualListRenderer.RenderDetailsGlyph(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AExpanded: Boolean; const APalette: TThemePalette; const AForeColor: TColor; const ARightToLeft: Boolean);
var
  LColor: TThemeColor;
  LPoints: TNimbusPointBuffer;
  LCX, LCY, LSize: Integer;
begin
  if NimbusRectIsEmpty(ABounds) then Exit;
  if APalette <> nil then LColor := APalette.MutedForeColor else LColor := ColorToThemeColor(AForeColor);
  LCX := (ABounds.Left + ABounds.Right) div 2;
  LCY := (ABounds.Top + ABounds.Bottom) div 2;
  LSize := Max(3, Min(5, Min(ABounds.Width, ABounds.Height) div 4));
  if AExpanded then
  begin
    LPoints[0] := Point(LCX - LSize, LCY - LSize div 2);
    LPoints[1] := Point(LCX + LSize, LCY - LSize div 2);
    LPoints[2] := Point(LCX, LCY + LSize);
  end
  else if ARightToLeft then
  begin
    LPoints[0] := Point(LCX + LSize div 2, LCY - LSize);
    LPoints[1] := Point(LCX + LSize div 2, LCY + LSize);
    LPoints[2] := Point(LCX - LSize, LCY);
  end
  else
  begin
    LPoints[0] := Point(LCX - LSize div 2, LCY - LSize);
    LPoints[1] := Point(LCX - LSize div 2, LCY + LSize);
    LPoints[2] := Point(LCX + LSize, LCY);
  end;
  ACanvas.FillPolygon(LColor, @LPoints, 3);
end;

end.

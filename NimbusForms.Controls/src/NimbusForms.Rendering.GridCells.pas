{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.GridCells;

interface

uses
  Vcl.Controls, NimbusForms.Rendering.Canvas, NimbusForms.Controls.GridTypes,
  NimbusForms.Grid.RenderContext, NimbusForms.Grid.Cell;

type
  TNimbusGridCellRenderer = class
  public
    class procedure Draw(const ACanvasObject: TNimbusRenderCanvas; const ACanvas: INimbusRenderCanvas;
      const AControl: TWinControl; const AKind: TNimbusGridControlKind; const ADrawCallback: TNimbusGridDrawEvent;
      const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell); static;
  end;

implementation

uses
  Winapi.Windows, System.Types, System.UITypes, System.SysUtils, System.Rtti, System.Math, Vcl.Graphics, Vcl.StdCtrls,
  NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Types,
  NimbusForms.Controls.Types, NimbusForms.Controls.CheckBox, NimbusForms.Controls.ToggleBox,
  NimbusForms.Controls.Rating, NimbusForms.Controls.ComboBox, NimbusForms.Controls.Avatar,
  NimbusForms.Controls.Button, NimbusForms.Rendering.CheckBox, NimbusForms.Rendering.ToggleBox,
  NimbusForms.Rendering.Rating, NimbusForms.Rendering.ComboBox, NimbusForms.Rendering.Avatar,
  NimbusForms.Rendering.Button, NimbusForms.Grid.ValueConverter, NimbusForms.Grid.CellRendererParts;

class procedure TNimbusGridCellRenderer.Draw(const ACanvasObject: TNimbusRenderCanvas;
  const ACanvas: INimbusRenderCanvas; const AControl: TWinControl; const AKind: TNimbusGridControlKind;
  const ADrawCallback: TNimbusGridDrawEvent; const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LPalette: TThemePalette;
  LCheck: TThemedCheckBoxRenderContext;
  LToggle: TThemedToggleBoxRenderContext;
  LRating: TThemedRatingRenderContext;
  LCombo: TThemedComboBoxRenderContext;
  LButton: TThemedButtonRenderContext;
  LBounds, LBadge: TRect;
  LNumber: Extended;
  LBoolean: TValue;
  LDpi, LSize: Integer;
  LFont: TFont;
  LOwnFont: Boolean;
  function Scale(const AValue: Integer): Integer;
  begin
    Result := MulDiv(AValue, LDpi, 96);
  end;
begin
  if (AContext = nil) or (ACell = nil) or (AContext.Graphics = nil) then Exit;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  LFont := TThemedGridCellRendererParts.GetCellFont(AContext, ACell);
  LOwnFont := TThemedGridCellRendererParts.RequiresDisposableFont(AContext, ACell, LFont);
  LPalette := TThemePalette.Create;
  try
    if AContext.Palette <> nil then LPalette.Assign(AContext.Palette);
    LPalette.PanelBackColor := TThemedGridCellRendererParts.GetCellBackColor(AContext, ACell);
    LPalette.ControlBackColor := LPalette.PanelBackColor;
    LPalette.InputBackColor := LPalette.PanelBackColor;
    LPalette.InputForeColor := TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell);
    LPalette.ControlForeColor := LPalette.InputForeColor;
    LDpi := 0;
    if AContext.Font <> nil then LDpi := AContext.Font.PixelsPerInch;
    if LDpi <= 0 then LDpi := GetDeviceCaps(AContext.DC, LOGPIXELSX);
    if LDpi <= 0 then LDpi := 96;
    LBounds := ACell.Bounds;
    ACanvasObject.BeginRenderGraphics(AContext.Graphics, AContext.DC);
    try
      ACanvas.PushClip(LBounds);
      if Assigned(ADrawCallback) then ADrawCallback(ACanvas, AContext, ACell)
      else case AKind of
        ngckCheckBox:
          begin
            LCheck := Default(TThemedCheckBoxRenderContext);
            LCheck.Bounds := LBounds;
            LCheck.Font := LFont;
            LCheck.Palette := LPalette;
            LCheck.BoxSize := Scale(TThemedCheckBox(AControl).BoxSize);
            LCheck.CornerRadius := Scale(TThemedCheckBox(AControl).CornerRadius);
            LCheck.Spacing := Scale(TThemedCheckBox(AControl).Spacing);
            LBoolean := TThemedGridValueConverter.Convert(ACell.Value, TypeInfo(Boolean));
            if LBoolean.AsBoolean then LCheck.CheckState := cbChecked;
            if ACell.IsHovered then LCheck.State := nvsHot;
            TThemedCheckBoxRenderer.Render(ACanvas, LCheck);
          end;
        ngckToggle:
          begin
            LToggle := Default(TThemedToggleBoxRenderContext);
            LToggle.Bounds := LBounds;
            LToggle.Font := LFont;
            LToggle.InnerFont := LFont;
            LToggle.Palette := LPalette;
            LToggle.Enabled := True;
            LToggle.ReadOnly := ACell.IsReadOnly;
            LToggle.Hovered := ACell.IsHovered;
            LToggle.SwitchAlignment := TThemedToggleBox(AControl).SwitchAlignment;
            LToggle.LabelPosition := TThemedToggleBox(AControl).LabelPosition;
            LToggle.TextMode := TThemedToggleBox(AControl).TextMode;
            LToggle.Caption := TThemedToggleBox(AControl).Caption;
            LToggle.OnText := TThemedToggleBox(AControl).CheckedText;
            LToggle.OffText := TThemedToggleBox(AControl).UncheckedText;
            LToggle.SwitchWidth := Scale(TThemedToggleBox(AControl).TrackWidth);
            LToggle.SwitchWidthWithText := Scale(54);
            LToggle.SwitchHeight := Scale(Max(12, TThemedToggleBox(AControl).TrackHeight - Ord(TThemedToggleBox(AControl).StyleMode = stCompact) * 4));
            LToggle.ThumbInset := Scale(6);
            LToggle.PaddingSmall := Scale(3);
            LToggle.PaddingText := Scale(Max(0, TThemedToggleBox(AControl).Spacing - Ord(TThemedToggleBox(AControl).StyleMode = stCompact) * 2));
            LToggle.InnerOffset := Scale(5);
            LToggle.OnBackColor := TThemedToggleBox(AControl).OnBackColor;
            LToggle.OffBackColor := TThemedToggleBox(AControl).OffBackColor;
            LToggle.ThumbColor := TThemedToggleBox(AControl).ThumbColor;
            LToggle.BorderColor := TThemedToggleBox(AControl).BorderColor;
            LBoolean := TThemedGridValueConverter.Convert(ACell.Value, TypeInfo(Boolean));
            LToggle.Checked := LBoolean.AsBoolean;
            LToggle.AnimationValue := Ord(LToggle.Checked);
            TThemedToggleBoxRenderer.Render(ACanvas, LToggle);
          end;
        ngckRating:
          begin
            LRating := Default(TThemedRatingRenderContext);
            LRating.Bounds := LBounds;
            LRating.Font := LFont;
            LRating.Palette := LPalette;
            LRating.Enabled := True;
            LRating.ReadOnly := ACell.IsReadOnly;
            LRating.Maximum := TThemedRatingControl(AControl).Maximum;
            LRating.RatingShape := TThemedRatingControl(AControl).RatingShape;
            LSize := TThemedRatingControl(AControl).ItemSize;
            LRating.ItemSize := Max(Scale(8), Scale(LSize - Ord(TThemedRatingControl(AControl).StyleMode = stCompact) * Max(2, LSize div 4)));
            LRating.ItemSpacing := Scale(Max(0, TThemedRatingControl(AControl).StarSpacing - Ord((TThemedRatingControl(AControl).StyleMode = stCompact) and (TThemedRatingControl(AControl).StarSpacing > 0))));
            LRating.ShowOutline := TThemedRatingControl(AControl).ShowOutline;
            LRating.ActiveColor := TThemedRatingControl(AControl).ActiveColor;
            LRating.InactiveColor := TThemedRatingControl(AControl).InactiveColor;
            LRating.HoverColor := TThemedRatingControl(AControl).HoverColor;
            LRating.OutlineColor := TThemedRatingControl(AControl).OutlineColor;
            LRating.ForeColor := ThemeColorToColor(LPalette.InputForeColor);
            LRating.ActiveImage := TThemedRatingControl(AControl).ActiveImage;
            LRating.InactiveImage := TThemedRatingControl(AControl).InactiveImage;
            LRating.HoverImage := TThemedRatingControl(AControl).HoverImage;
            LRating.HoverValue := -1;
            if TThemedGridValueConverter.TryToNumber(ACell.Value, LNumber) then LRating.RatingValue := LNumber;
            TThemedRatingRenderer.Render(ACanvas, LRating);
          end;
        ngckComboBox, ngckDateTime:
          begin
            LCombo := Default(TThemedComboBoxRenderContext);
            LCombo.Bounds := LBounds;
            LCombo.Font := LFont;
            LCombo.Palette := LPalette;
            LCombo.Enabled := True;
            LCombo.Hovered := ACell.IsHovered and not ACell.IsReadOnly;
            LCombo.Text := ACell.DisplayText;
            LCombo.ButtonWidth := Scale(24);
            LCombo.TextLeft := Scale(5);
            LCombo.TextRight := Scale(10);
            LCombo.ArrowHalfWidth := Scale(3);
            LCombo.ArrowTopOffset := Scale(1);
            LCombo.ArrowBottomOffset := Scale(2);
            TThemedComboBoxRenderer.RenderControl(ACanvas, LCombo);
          end;
        ngckAvatar:
          begin
            LSize := Min(LBounds.Width, LBounds.Height);
            LBounds := Rect(LBounds.Left + (LBounds.Width - LSize) div 2, LBounds.Top,
              LBounds.Left + (LBounds.Width + LSize) div 2, LBounds.Bottom);
            TThemedAvatarRenderer.Render(ACanvas, LBounds, LPalette, LFont,
              TThemedAvatar.InitialsForText(ACell.DisplayText), TThemedAvatar(AControl).ShowInitials,
              True, TThemedAvatar(AControl).Shape, TThemedAvatar(AControl).Status,
              TThemedAvatar(AControl).ShowStatus, TThemedAvatar(AControl).Counter,
              TThemedAvatar(AControl).ShowCounter, TThemedAvatar(AControl).ShowStar,
              TThemedAvatar(AControl).CustomAvatarColor, Scale(TThemedAvatar(AControl).BorderWidth),
              TThemedAvatar(AControl).GetRenderImage(LSize), LBadge);
          end;
        ngckButton:
          begin
            LButton := Default(TThemedButtonRenderContext);
            LButton.Bounds := LBounds;
            LButton.MainBounds := LBounds;
            LButton.ContentBounds := LBounds;
            LButton.TextBounds := LBounds;
            LButton.Caption := TThemedButton(AControl).Caption;
            LButton.Font := LFont;
            LButton.Palette := LPalette;
            LButton.Style := TThemedButton(AControl).ButtonStyle;
            LButton.Kind := TThemedButton(AControl).ButtonKind;
            LButton.Shape := TThemedButton(AControl).ButtonShape;
            LButton.HighlightStyle := TThemedButton(AControl).HighlightStyle;
            LButton.TextAlign := tcaMiddleCenter;
            LButton.Enabled := not ACell.IsReadOnly;
            LButton.Hot := ACell.IsHovered;
            LButton.ShowBorder := True;
            LButton.BorderThickness := Scale(1);
            LButton.CornerRadius := Scale(TThemedButton(AControl).CornerRadius);
            LButton.PressScale := 1;
            LButton.SurfaceBackColor := LPalette.PanelBackColor;
            TThemedButtonRenderer.Render(ACanvas, LButton);
          end;
      else
        ACanvas.DrawText(ACell.DisplayText, LFont, LPalette.InputForeColor, LBounds,
          [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]);
      end;
      ACanvas.PopClip;
    finally
      ACanvasObject.EndRender;
    end;
  finally
    LPalette.Free;
    if LOwnFont then LFont.Free;
  end;
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);
  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

end.

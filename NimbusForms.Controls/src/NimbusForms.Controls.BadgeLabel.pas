{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.BadgeLabel;

interface

uses
  Winapi.Messages, System.Classes, System.Types, System.UITypes, Vcl.Controls, Vcl.Graphics, Vcl.ImgList, NimbusForms.Controls.Base, NimbusForms.Rendering.BadgeLabel;

type
  TCustomThemedBadgeLabel = class(TCustomNimbusControl)
  private
    FKind: TThemedBadgeKind;
    FShape: TThemedBadgeShape;
    FImageAlign: TThemedBadgeImageAlign;
    FImageIndex: System.UITypes.TImageIndex;
    FImages: TCustomImageList;
    FImageBuffer: Vcl.Graphics.TBitmap;
    FPicture: TPicture;
    FText: string;
    FRadius: Integer;
    FPadding: Integer;
    FImageSize: Integer;
    FImageSpacing: Integer;
    FShowBorder: Boolean;
    FBorderThickness: Integer;
    FClickable: Boolean;
    FShowCloseButton: Boolean;
    FUseValueMode: Boolean;
    FValue: Integer;
    FMaxValue: Integer;
    FMinBadgeWidth: Integer;
    FMaxBadgeWidth: Integer;
    FCustomBack: TColor;
    FCustomFore: TColor;
    FCustomBorder: TColor;
    FHovered: Boolean;
    FPressed: Boolean;
    FOnBadgeClick: TNotifyEvent;
    FOnCloseClick: TNotifyEvent;
    procedure SetText(const AValue: string);
    procedure SetKind(const AValue: TThemedBadgeKind);
    procedure SetShape(const AValue: TThemedBadgeShape);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
    procedure SetPicture(const AValue: TPicture);
    procedure PictureChanged(Sender: TObject);
    procedure SetImageAlign(const AValue: TThemedBadgeImageAlign);
    procedure SetRadius(const AValue: Integer);
    procedure SetPadding(const AValue: Integer);
    procedure SetImageSize(const AValue: Integer);
    procedure SetImageSpacing(const AValue: Integer);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetBorderThickness(const AValue: Integer);
    procedure SetClickable(const AValue: Boolean);
    procedure SetShowCloseButton(const AValue: Boolean);
    procedure SetUseValueMode(const AValue: Boolean);
    procedure SetValue(const AValue: Integer);
    procedure SetMaxValue(const AValue: Integer);
    procedure SetMinBadgeWidth(const AValue: Integer);
    procedure SetMaxBadgeWidth(const AValue: Integer);
    procedure SetCustomBack(const AValue: TColor);
    procedure SetCustomFore(const AValue: TColor);
    procedure SetCustomBorder(const AValue: TColor);
    procedure UpdateMetrics;
    function DisplayText: string;
    function HasImage: Boolean;
    function CloseBounds: TRect;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    property Text: string read FText write SetText;
    property Caption: string read FText write SetText;
    property BadgeKind: TThemedBadgeKind read FKind write SetKind default tbkAccent;
    property BadgeShape: TThemedBadgeShape read FShape write SetShape default tbsPill;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property Picture: TPicture read FPicture write SetPicture;
    property ImageAlign: TThemedBadgeImageAlign read FImageAlign write SetImageAlign default tbiaLeft;
    property ImageSize: Integer read FImageSize write SetImageSize default 14;
    property ImageSpacing: Integer read FImageSpacing write SetImageSpacing default 4;
    property BadgePadding: Integer read FPadding write SetPadding default 6;
    property Radius: Integer read FRadius write SetRadius default 8;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default False;
    property BorderThickness: Integer read FBorderThickness write SetBorderThickness default 1;
    property Clickable: Boolean read FClickable write SetClickable default False;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton default False;
    property UseValueMode: Boolean read FUseValueMode write SetUseValueMode default False;
    property Value: Integer read FValue write SetValue default 0;
    property MaxValue: Integer read FMaxValue write SetMaxValue default 99;
    property MinBadgeWidth: Integer read FMinBadgeWidth write SetMinBadgeWidth default 0;
    property MaxBadgeWidth: Integer read FMaxBadgeWidth write SetMaxBadgeWidth default 0;
    property BadgeBackColor: TColor read FCustomBack write SetCustomBack default clBlack;
    property BadgeForeColor: TColor read FCustomFore write SetCustomFore default clWhite;
    property BadgeBorderColor: TColor read FCustomBorder write SetCustomBorder default clGray;
    property OnBadgeClick: TNotifyEvent read FOnBadgeClick write FOnBadgeClick;
    property OnCloseClick: TNotifyEvent read FOnCloseClick write FOnCloseClick;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TThemedBadgeLabel = class(TCustomThemedBadgeLabel)
  published
    property Align;
    property Anchors;
    property AutoSize default True;
    property BadgeKind;
    property BadgeShape;
    property Text;
    property Caption;
    property Images;
    property ImageIndex;
    property Picture;
    property ImageAlign;
    property ImageSize;
    property ImageSpacing;
    property BadgePadding;
    property Radius;
    property ShowBorder;
    property BorderThickness;
    property Clickable;
    property ShowCloseButton;
    property UseValueMode;
    property Value;
    property MaxValue;
    property MinBadgeWidth;
    property MaxBadgeWidth;
    property BadgeBackColor;
    property BadgeForeColor;
    property BadgeBorderColor;
    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property Hint;
    property ShowHint;
    property PopupMenu;
    property OnBadgeClick;
    property OnCloseClick;
    property OnClick;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, NimbusForms.Rendering.Types;

constructor TCustomThemedBadgeLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := tbkAccent;
  FShape := tbsPill;
  FImageIndex := -1;
  FImageSize := 14;
  FImageSpacing := 4;
  FPadding := 6;
  FRadius := 8;
  FBorderThickness := 1;
  FMaxValue := 99;
  FCustomBack := clBlack;
  FCustomFore := clWhite;
  FCustomBorder := clGray;
  Font.Name := 'Segoe UI';
  Font.Size := 8;
  Font.Style := [fsBold];
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FImageBuffer := Vcl.Graphics.TBitmap.Create;
  FImageBuffer.PixelFormat := pf32bit;
  Width := 65;
  Height := 20;
  AutoSize := True;
end;

destructor TCustomThemedBadgeLabel.Destroy;
begin
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImageBuffer.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure TCustomThemedBadgeLabel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    UpdateMetrics;
  end;
end;

function TCustomThemedBadgeLabel.DisplayText: string;
begin
  if FUseValueMode then
  begin
    if FValue > FMaxValue then Result := IntToStr(FMaxValue) + '+' else Result := IntToStr(FValue);
  end
  else Result := FText;
end;

function TCustomThemedBadgeLabel.HasImage: Boolean;
begin
  Result := ((FImages <> nil) and (FImageIndex >= 0) and (FImageIndex < FImages.Count)) or ((FPicture.Graphic <> nil) and not FPicture.Graphic.Empty);
end;

function TCustomThemedBadgeLabel.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  S: TSize;
  W, H: Integer;
begin
  Result := True;
  if (FImageBuffer = nil) or (RenderCanvas = nil) then Exit;
  FImageBuffer.SetSize(1, 1);
  RenderCanvas.BeginRender(FImageBuffer.Canvas);
  try
    S := RenderCanvas.MeasureText(DisplayText, Font, 0, [ntfSingleLine, ntfVCenter, ntfNoPrefix]);
  finally
    RenderCanvas.EndRender;
  end;
  H := ScaleValue(20);
  if H < S.cy + ScaleValue(4) then H := S.cy + ScaleValue(4);
  if H < ScaleValue(16) then H := ScaleValue(16);
  W := S.cx + ScaleValue(FPadding * 2 + 6);
  if HasImage then Inc(W, ScaleValue(FImageSize + FImageSpacing));
  if FShowCloseButton then Inc(W, ScaleValue(18));
  if FShape = tbsCircle then W := H;
  if W < ScaleValue(FMinBadgeWidth) then W := ScaleValue(FMinBadgeWidth);
  if (FMaxBadgeWidth > 0) and (W > ScaleValue(FMaxBadgeWidth)) then W := ScaleValue(FMaxBadgeWidth);
  if W < ScaleValue(16) then W := ScaleValue(16);
  NewWidth := W;
  NewHeight := H;
end;

procedure TCustomThemedBadgeLabel.Loaded;
begin
  inherited Loaded;
  UpdateMetrics;
end;

procedure TCustomThemedBadgeLabel.UpdateMetrics;
begin
  if csDestroying in ComponentState then Exit;
  if AutoSize and not (csLoading in ComponentState) then AdjustSize;
  Invalidate;
end;

procedure TCustomThemedBadgeLabel.Resize;
begin
  inherited Resize;
  Invalidate;
end;

procedure TCustomThemedBadgeLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FPicture <> nil then UpdateMetrics;
end;

procedure TCustomThemedBadgeLabel.SetText(const AValue: string);
begin
  if FText <> AValue then begin FText := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetKind(const AValue: TThemedBadgeKind);
begin
  if FKind <> AValue then begin FKind := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetShape(const AValue: TThemedBadgeShape);
begin
  if FShape <> AValue then begin FShape := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetImages(const AValue: TCustomImageList);
begin
  if FImages = AValue then Exit;
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := AValue;
  if FImages <> nil then FImages.FreeNotification(Self);
  UpdateMetrics;
end;

procedure TCustomThemedBadgeLabel.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex <> AValue then begin FImageIndex := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetPicture(const AValue: TPicture);
begin
  FPicture.Assign(AValue);
end;

procedure TCustomThemedBadgeLabel.PictureChanged(Sender: TObject);
begin
  UpdateMetrics;
end;

procedure TCustomThemedBadgeLabel.SetImageAlign(const AValue: TThemedBadgeImageAlign);
begin
  if FImageAlign <> AValue then begin FImageAlign := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetRadius(const AValue: Integer);
begin
  if FRadius <> AValue then begin FRadius := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetPadding(const AValue: Integer);
begin
  if FPadding <> AValue then begin FPadding := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetImageSize(const AValue: Integer);
begin
  if FImageSize <> AValue then begin FImageSize := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetImageSpacing(const AValue: Integer);
begin
  if FImageSpacing <> AValue then begin FImageSpacing := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder <> AValue then begin FShowBorder := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetBorderThickness(const AValue: Integer);
begin
  if FBorderThickness <> AValue then begin FBorderThickness := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetClickable(const AValue: Boolean);
begin
  if FClickable <> AValue then begin FClickable := AValue; if AValue then Cursor := crHandPoint else Cursor := crDefault; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetShowCloseButton(const AValue: Boolean);
begin
  if FShowCloseButton <> AValue then begin FShowCloseButton := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetUseValueMode(const AValue: Boolean);
begin
  if FUseValueMode <> AValue then begin FUseValueMode := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetValue(const AValue: Integer);
begin
  if FValue <> AValue then begin FValue := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetMaxValue(const AValue: Integer);
begin
  if FMaxValue <> AValue then begin FMaxValue := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetMinBadgeWidth(const AValue: Integer);
begin
  if FMinBadgeWidth <> AValue then begin FMinBadgeWidth := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetMaxBadgeWidth(const AValue: Integer);
begin
  if FMaxBadgeWidth <> AValue then begin FMaxBadgeWidth := AValue; UpdateMetrics; end;
end;

procedure TCustomThemedBadgeLabel.SetCustomBack(const AValue: TColor);
begin
  if FCustomBack <> AValue then begin FCustomBack := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetCustomFore(const AValue: TColor);
begin
  if FCustomFore <> AValue then begin FCustomFore := AValue; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.SetCustomBorder(const AValue: TColor);
begin
  if FCustomBorder <> AValue then begin FCustomBorder := AValue; Invalidate; end;
end;

function TCustomThemedBadgeLabel.CloseBounds: TRect;
var
  D: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if not FShowCloseButton then Exit;
  D := ScaleValue(16);
  Result := Rect(ClientWidth - ScaleValue(FPadding) - D, (ClientHeight - D) div 2, ClientWidth - ScaleValue(FPadding), (ClientHeight + D) div 2);
end;

procedure TCustomThemedBadgeLabel.Paint;
var
  RText, RImage, RClose: TRect;
  S, Pad, Spacing: Integer;
begin
  if RenderCanvas = nil then Exit;
  RClose := CloseBounds;
  RImage := Rect(0, 0, 0, 0);
  Pad := ScaleValue(FPadding);
  Spacing := ScaleValue(FImageSpacing);
  RText := Rect(Pad, 0, ClientWidth - Pad, ClientHeight);
  if not IsRectEmpty(RClose) then RText.Right := RClose.Left - Spacing;
  if HasImage then
  begin
    S := ScaleValue(FImageSize);
    if S > ClientHeight - 2 then S := ClientHeight - 2;
    if S < 1 then S := 1;
    if FImageAlign = tbiaLeft then
    begin
      RImage := Rect(RText.Left, (ClientHeight - S) div 2, RText.Left + S, (ClientHeight + S) div 2);
      RText.Left := RImage.Right + Spacing;
    end
    else
    begin
      RImage := Rect(RText.Right - S, (ClientHeight - S) div 2, RText.Right, (ClientHeight + S) div 2);
      RText.Right := RImage.Left - Spacing;
    end;
    FImageBuffer.SetSize(S, S);
    FImageBuffer.Canvas.Brush.Color := clFuchsia;
    FImageBuffer.Canvas.FillRect(Rect(0, 0, S, S));
    if (FImages <> nil) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then FImages.GetBitmap(FImageIndex, FImageBuffer)
    else if (FPicture.Graphic <> nil) and not FPicture.Graphic.Empty then FImageBuffer.Canvas.StretchDraw(Rect(0, 0, S, S), FPicture.Graphic);
    FImageBuffer.Transparent := True;
    FImageBuffer.TransparentColor := clFuchsia;
  end;
  RenderCanvas.BeginRender(Canvas);
  try
    RenderCanvas.FillRectangle(NimbusPanelBackColor(Palette), ClientRect);
    if HasImage then TThemedBadgeLabelRenderer.Render(RenderCanvas, ClientRect, DisplayText, Font, Palette, FKind, FShape, FCustomBack, FCustomFore, FCustomBorder, FShowBorder, Enabled, FHovered, FPressed, ScaleValue(FRadius), ScaleValue(FBorderThickness), FImageBuffer, RImage, RText, RClose)
    else TThemedBadgeLabelRenderer.Render(RenderCanvas, ClientRect, DisplayText, Font, Palette, FKind, FShape, FCustomBack, FCustomFore, FCustomBorder, FShowBorder, Enabled, FHovered, FPressed, ScaleValue(FRadius), ScaleValue(FBorderThickness), nil, RImage, RText, RClose);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedBadgeLabel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if not FHovered then begin FHovered := True; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHovered := False;
  FPressed := False;
  Invalidate;
end;

procedure TCustomThemedBadgeLabel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and (FClickable or FShowCloseButton) then begin FPressed := True; Invalidate; end;
end;

procedure TCustomThemedBadgeLabel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  WasPressed: Boolean;
begin
  WasPressed := FPressed;
  FPressed := False;
  inherited MouseUp(Button, Shift, X, Y);
  if WasPressed and (Button = mbLeft) and PtInRect(ClientRect, Point(X, Y)) then
  begin
    if FShowCloseButton and PtInRect(CloseBounds, Point(X, Y)) then
    begin
      if Assigned(FOnCloseClick) then FOnCloseClick(Self);
    end
    else if FClickable and Assigned(FOnBadgeClick) then FOnBadgeClick(Self);
  end;
  Invalidate;
end;

end.

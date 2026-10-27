{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ListBox;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas;

type
  TCustomThemedListBox = class(TCustomListBox, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FThemeRegistered: Boolean;
    FStyleMode: TThemedControlStyleMode;
    FCompactItemHeight: Boolean;
    procedure SetStyleMode(const AValue: TThemedControlStyleMode);
    procedure RegisterThemeAware;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
  protected
    procedure Loaded; override;
    procedure WndProc(var Message: TMessage); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    property StyleMode: TThemedControlStyleMode read FStyleMode write SetStyleMode default stNormal;
    property Palette: TThemePalette read FPalette;
    property RenderCanvas: INimbusRenderCanvas read FRenderCanvas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
  end;

  TThemedListBox = class(TCustomThemedListBox)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property AutoComplete;
    property AutoCompleteDelay;
    property BiDiMode;
    property BorderStyle default bsSingle;
    property Color;
    property Columns;
    property Constraints;
    property Enabled;
    property ExtendedSelect;
    property Font;
    property IntegralHeight default False;
    property ItemHeight default 18;
    property MultiSelect;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollWidth;
    property ShowHint;
    property Sorted;
    property Style default lbOwnerDrawFixed;
    property TabOrder;
    property TabStop default True;
    property TabWidth;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
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
    property OnStartDrag;
    property Items;
  end;

implementation

uses
  System.UITypes,
  NimbusForms.Theming.Manager,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.ListBox;

constructor TCustomThemedListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  DoubleBuffered := True;
  Style := lbOwnerDrawFixed;
  BorderStyle := bsSingle;
  IntegralHeight := False;
  ItemHeight := 18;
  FStyleMode := stNormal;
  FRenderCanvas := TNimbusRenderCanvas.Create;
end;

destructor TCustomThemedListBox.Destroy;
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

procedure TCustomThemedListBox.SetStyleMode(const AValue: TThemedControlStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  if FStyleMode = stCompact then
  begin
    FCompactItemHeight := ItemHeight = 18;
    if FCompactItemHeight then ItemHeight := 16;
  end
  else
  begin
    if FCompactItemHeight and (ItemHeight = 16) then ItemHeight := 18;
    FCompactItemHeight := False;
  end;
  Invalidate;
end;

procedure TCustomThemedListBox.CNDrawItem(var Message: TWMDrawItem);
var
  LState: TOwnerDrawState;
  LIndex: Integer;
  LBackColor: TThemeColor;
begin
  if csDestroying in ComponentState then
    Exit;
  with Message.DrawItemStruct^ do
  begin
    LState := TOwnerDrawState(LoWord(itemState));
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    try
      LIndex := Integer(itemID);
      if LIndex >= 0 then
        DrawItem(LIndex, rcItem, LState)
      else
      begin
        if FPalette <> nil then
          LBackColor := FPalette.InputBackColor
        else
          LBackColor := ColorToThemeColor(Color);
        FRenderCanvas.BeginRender(Canvas);
        try
          FRenderCanvas.FillRectangle(LBackColor, rcItem);
        finally
          FRenderCanvas.EndRender;
        end;
      end;
    finally
      Canvas.Handle := 0;
    end;
  end;
  Message.Result := 1;
end;

procedure TCustomThemedListBox.RegisterThemeAware;
begin
  if FThemeRegistered or (csLoading in ComponentState) or (csReading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedListBox.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
end;

procedure TCustomThemedListBox.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  if FPalette = nil then
    FPalette := APalette.Clone
  else
    FPalette.Assign(APalette);
  Color := ThemeColorToColor(FPalette.InputBackColor);
  Font.Color := ThemeColorToColor(FPalette.InputForeColor);
  if not (csDestroying in ComponentState) then
    Invalidate;
end;

procedure TCustomThemedListBox.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  if not (csDestroying in ComponentState) then
    Invalidate;
end;

procedure TCustomThemedListBox.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    CM_SHOWINGCHANGED:
      if Showing then RegisterThemeAware;
    CM_ENABLEDCHANGED, CM_FONTCHANGED, CM_COLORCHANGED:
      if not (csDestroying in ComponentState) then Invalidate;
  end;
end;

procedure TCustomThemedListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LContext: TThemedListBoxItemRenderContext;
begin
  if (Index < 0) or (Index >= Items.Count) then
    Exit;
  LContext.Bounds := Rect;
  LContext.Text := Items[Index];
  LContext.Font := Font;
  LContext.Palette := FPalette;
  LContext.BackColor := Color;
  LContext.ForeColor := Font.Color;
  LContext.Selected := odSelected in State;
  LContext.Disabled := (not Enabled) or (odDisabled in State) or (odGrayed in State);
  LContext.Focused := odFocused in State;
  LContext.TextPadding := NimbusScaleValue(4, CurrentPPI);
  LContext.RightToLeft := UseRightToLeftReading;
  FRenderCanvas.BeginRender(Canvas);
  try
    TThemedListBoxRenderer.RenderItem(FRenderCanvas, LContext);
  finally
    FRenderCanvas.EndRender;
  end;
end;

end.

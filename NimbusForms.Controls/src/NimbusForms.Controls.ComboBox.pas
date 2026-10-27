{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ComboBox;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas;

type
  TCustomThemedComboBox = class(TCustomComboBox, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FThemeRegistered: Boolean;
    FHovered: Boolean;
    FDroppedDown: Boolean;
    FStyleMode: TThemedControlStyleMode;
    FCompactItemHeight: Boolean;
    FNormalHeight: Integer;
    procedure SetStyleMode(const AValue: TThemedControlStyleMode);
    procedure RegisterThemeAware;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure RenderControl;
  protected
    procedure Loaded; override;
    procedure WndProc(var Message: TMessage); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure DropDown; override;
    procedure CloseUp; override;
    property StyleMode: TThemedControlStyleMode read FStyleMode write SetStyleMode default stNormal;
    property Palette: TThemePalette read FPalette;
    property RenderCanvas: INimbusRenderCanvas read FRenderCanvas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
  end;

  TThemedComboBox = class(TCustomThemedComboBox)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property AutoComplete;
    property AutoCompleteDelay;
    property AutoDropDown;
    property AutoDropDownWidth;
    property AutoCloseUp;
    property BiDiMode;
    property CharCase;
    property Color;
    property Constraints;
    property DropDownCount;
    property DropDownWidth;
    property Enabled;
    property ExtendedUI;
    property Font;
    property ItemHeight default 18;
    property ItemIndex default -1;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property Style default csOwnerDrawFixed;
    property TabOrder;
    property TabStop default True;
    property Text;
    property TextHint;
    property Visible;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnSelect;
    property OnStartDrag;
    property Items;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Manager,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.ComboBox;

constructor TCustomThemedComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  DoubleBuffered := True;
  Style := csOwnerDrawFixed;
  ItemHeight := 18;
  FStyleMode := stNormal;
  FNormalHeight := Height;
  FRenderCanvas := TNimbusRenderCanvas.Create;
end;

destructor TCustomThemedComboBox.Destroy;
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

procedure TCustomThemedComboBox.CNDrawItem(var Message: TWMDrawItem);
var
  LState: TOwnerDrawState;
  LIndex: Integer;
begin
  if csDestroying in ComponentState then
    Exit;
  with Message.DrawItemStruct^ do
  begin
    LState := TOwnerDrawState(LoWord(itemState));
    if itemState and ODS_COMBOBOXEDIT <> 0 then Include(LState, odComboBoxEdit);
    if itemState and ODS_DEFAULT <> 0 then Include(LState, odDefault);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    try
      LIndex := Integer(itemID);
      if LIndex >= 0 then
        DrawItem(LIndex, rcItem, LState)
      else
      begin
        FRenderCanvas.BeginRender(Canvas);
        try
          FRenderCanvas.FillRectangle(NimbusInputBackColor(FPalette), rcItem);
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

procedure TCustomThemedComboBox.RegisterThemeAware;
begin
  if FThemeRegistered or (csLoading in ComponentState) or (csReading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedComboBox.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
end;

procedure TCustomThemedComboBox.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  if FPalette = nil then
    FPalette := APalette.Clone
  else
    FPalette.Assign(APalette);
  Color := ThemeColorToColor(FPalette.InputBackColor);
  Font.Color := ThemeColorToColor(FPalette.InputForeColor);
  if not (csDestroying in ComponentState) then Invalidate;
end;

procedure TCustomThemedComboBox.SetStyleMode(const AValue: TThemedControlStyleMode);
var
  LResize: Boolean;
begin
  if FStyleMode = AValue then Exit;
  if AValue = stCompact then
    LResize := (Align = alNone) and (Height = FNormalHeight)
  else
    LResize := (Align = alNone) and (Height = NimbusScaleValue(23, CurrentPPI));
  FStyleMode := AValue;
  if FStyleMode = stCompact then
  begin
    FCompactItemHeight := ItemHeight = 18;
    if FCompactItemHeight then ItemHeight := 16;
    if LResize then Height := NimbusScaleValue(23, CurrentPPI);
  end
  else
  begin
    if FCompactItemHeight and (ItemHeight = 16) then ItemHeight := 18;
    FCompactItemHeight := False;
    if LResize then Height := FNormalHeight;
  end;
  Invalidate;
end;

procedure TCustomThemedComboBox.DropDown;
begin
  FDroppedDown := True;
  Invalidate;
  inherited DropDown;
end;

procedure TCustomThemedComboBox.CloseUp;
begin
  FDroppedDown := False;
  Invalidate;
  inherited CloseUp;
end;

procedure TCustomThemedComboBox.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    CM_SHOWINGCHANGED:
      if Showing then RegisterThemeAware;
    CM_ENABLEDCHANGED, CM_FONTCHANGED:
      Invalidate;
    CM_MOUSEENTER:
      begin
        if not FHovered then
        begin
          FHovered := True;
          Invalidate;
        end;
      end;
    CM_MOUSELEAVE:
      begin
        if FHovered then
        begin
          FHovered := False;
          Invalidate;
        end;
      end;
    WM_PAINT:
      if not (csDestroying in ComponentState) then RenderControl;
  end;
end;

procedure TCustomThemedComboBox.RenderControl;
var
  LContext: TThemedComboBoxRenderContext;
  LText: string;
  LScrollWidth: Integer;
begin
  if not HandleAllocated then
    Exit;
  if (ItemIndex >= 0) and (ItemIndex < Items.Count) then
    LText := Items[ItemIndex]
  else
    LText := Text;
  LScrollWidth := GetSystemMetrics(SM_CXVSCROLL);
  LContext.Bounds := ClientRect;
  LContext.Text := LText;
  LContext.Font := Font;
  LContext.Palette := FPalette;
  LContext.Enabled := Enabled;
  LContext.Hovered := FHovered;
  LContext.DroppedDown := FDroppedDown;
  LContext.ButtonWidth := Max(NimbusScaleValue(18, CurrentPPI), LScrollWidth);
  LContext.TextLeft := NimbusScaleValue(4 - Ord(FStyleMode = stCompact), CurrentPPI);
  LContext.TextTop := NimbusScaleValue(2, CurrentPPI);
  LContext.TextRight := NimbusScaleValue(8 - Ord(FStyleMode = stCompact) * 3, CurrentPPI);
  LContext.TextBottom := NimbusScaleValue(4 - Ord(FStyleMode = stCompact) * 2, CurrentPPI);
  LContext.ArrowHalfWidth := NimbusScaleValue(4, CurrentPPI);
  LContext.ArrowTopOffset := NimbusScaleValue(2, CurrentPPI);
  LContext.ArrowBottomOffset := NimbusScaleValue(2, CurrentPPI);
  LContext.RightToLeft := UseRightToLeftReading;
  FRenderCanvas.BeginRender(Canvas);
  try
    TThemedComboBoxRenderer.RenderControl(FRenderCanvas, LContext);
  finally
    FRenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LContext: TThemedComboBoxItemRenderContext;
begin
  if (Index < 0) or (Index >= Items.Count) then
    Exit;
  LContext.Bounds := Rect;
  LContext.Text := Items[Index];
  LContext.Font := Font;
  LContext.Palette := FPalette;
  LContext.Selected := odSelected in State;
  LContext.Disabled := (not Enabled) or (odDisabled in State) or (odGrayed in State);
  LContext.Focused := odFocused in State;
  LContext.TextInset := NimbusScaleValue(4 - Ord(FStyleMode = stCompact), CurrentPPI);
  LContext.RightToLeft := UseRightToLeftReading;
  FRenderCanvas.BeginRender(Canvas);
  try
    TThemedComboBoxRenderer.RenderItem(FRenderCanvas, LContext);
  finally
    FRenderCanvas.EndRender;
  end;
end;

end.

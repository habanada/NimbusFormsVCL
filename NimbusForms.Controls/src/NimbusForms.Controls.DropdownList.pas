{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.DropdownList;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Dropdown.Types,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.Dropdown;

type
  TThemedDropdownList = class(TCustomControl)
  private
    FItems: TList<TThemedDropdownItem>;
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FGroupFont: TFont;
    FStyleMode: TThemedDropdownStyleMode;
    FHoveredIndex: Integer;
    FSelectedIndex: Integer;
    FLogicalItemHeight: Integer;
    FItemHeight: Integer;
    FMaxVisibleItems: Integer;
    FShowCheckboxes: Boolean;
    FLogicalCheckBoxSize: Integer;
    FCheckBoxSize: Integer;
    FTopIndex: Integer;
    FOnItemInvoked: TThemedDropdownItemEvent;
    FOnSelectedIndexChanged: TNotifyEvent;
    FOnCheckedItemsChanged: TNotifyEvent;
    procedure SetStyleMode(const AValue: TThemedDropdownStyleMode);
    procedure SetItemHeight(const AValue: Integer);
    procedure SetMaxVisibleItems(const AValue: Integer);
    procedure SetShowCheckboxes(const AValue: Boolean);
    procedure SetSelectedIndex(const AValue: Integer);
    function GetSelectedItem: TThemedDropdownItem;
    procedure UpdateMetrics;
    procedure UpdateControlSize;
    procedure EnsureSelectedVisible;
    function HitTestIndex(const X, Y: Integer): Integer;
    function ItemRect(const AIndex: Integer): TRect;
    function CoerceSelectableIndex(const AValue: Integer): Integer;
    function VisibleItemCount: Integer;
    function GetPreferredHeight: Integer;
    procedure DoItemInvoked(const AItem: TThemedDropdownItem);
    procedure DoSelectedIndexChanged;
    procedure DoCheckedItemsChanged;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure SetItems(const AItems: TList<TThemedDropdownItem>);
    procedure MoveSelection(const ADelta: Integer);
    procedure InvokeSelectedItem;
    procedure ToggleSelectedCheckState;
    function GetIndexOfItem(const AItem: TThemedDropdownItem): Integer;
    property Items: TList<TThemedDropdownItem> read FItems;
    property PreferredHeight: Integer read GetPreferredHeight;
    property SelectedItem: TThemedDropdownItem read GetSelectedItem;
    property OnItemInvoked: TThemedDropdownItemEvent read FOnItemInvoked write FOnItemInvoked;
    property OnSelectedIndexChanged: TNotifyEvent read FOnSelectedIndexChanged write FOnSelectedIndexChanged;
    property OnCheckedItemsChanged: TNotifyEvent read FOnCheckedItemsChanged write FOnCheckedItemsChanged;
  published
    property StyleMode: TThemedDropdownStyleMode read FStyleMode write SetStyleMode default tdsNormal;
    property ItemHeight: Integer read FLogicalItemHeight write SetItemHeight default 28;
    property MaxVisibleItems: Integer read FMaxVisibleItems write SetMaxVisibleItems default 8;
    property ShowCheckboxes: Boolean read FShowCheckboxes write SetShowCheckboxes default False;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  System.UITypes,
  NimbusForms.Rendering.Types;

constructor TThemedDropdownList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque] - [csCaptureMouse, csClickEvents];
  DoubleBuffered := True;
  TabStop := False;
  FItems := TList<TThemedDropdownItem>.Create;
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FGroupFont := TFont.Create;
  FGroupFont.Assign(Font);
  FGroupFont.Style := FGroupFont.Style + [fsBold];
  FStyleMode := tdsNormal;
  FHoveredIndex := -1;
  FSelectedIndex := -1;
  FLogicalItemHeight := 28;
  FItemHeight := 28;
  FMaxVisibleItems := 8;
  FLogicalCheckBoxSize := 14;
  FCheckBoxSize := 14;
  FTopIndex := 0;
  Width := 180;
  UpdateMetrics;
  UpdateControlSize;
end;

destructor TThemedDropdownList.Destroy;
begin
  FGroupFont.Free;
  FPalette.Free;
  FRenderCanvas := nil;
  FItems.Free;
  inherited Destroy;
end;

procedure TThemedDropdownList.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  if FPalette = nil then FPalette := APalette.Clone else FPalette.Assign(APalette);
  Invalidate;
end;

procedure TThemedDropdownList.SetItems(const AItems: TList<TThemedDropdownItem>);
var
  I: Integer;
begin
  FItems.Clear;
  if AItems <> nil then
    for I := 0 to AItems.Count - 1 do FItems.Add(AItems[I]);
  FHoveredIndex := -1;
  FSelectedIndex := CoerceSelectableIndex(FSelectedIndex);
  FTopIndex := 0;
  EnsureSelectedVisible;
  UpdateControlSize;
  Invalidate;
end;

procedure TThemedDropdownList.SetStyleMode(const AValue: TThemedDropdownStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  if FStyleMode = tdsIdeCompact then FLogicalItemHeight := 22 else FLogicalItemHeight := 28;
  UpdateMetrics;
  UpdateControlSize;
  Invalidate;
end;

procedure TThemedDropdownList.SetItemHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(18, AValue);
  if FLogicalItemHeight = LValue then Exit;
  FLogicalItemHeight := LValue;
  UpdateMetrics;
  UpdateControlSize;
  Invalidate;
end;

procedure TThemedDropdownList.SetMaxVisibleItems(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FMaxVisibleItems = LValue then Exit;
  FMaxVisibleItems := LValue;
  EnsureSelectedVisible;
  UpdateControlSize;
  Invalidate;
end;

procedure TThemedDropdownList.SetShowCheckboxes(const AValue: Boolean);
begin
  if FShowCheckboxes = AValue then Exit;
  FShowCheckboxes := AValue;
  Invalidate;
end;

procedure TThemedDropdownList.SetSelectedIndex(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := CoerceSelectableIndex(AValue);
  if FSelectedIndex = LValue then Exit;
  FSelectedIndex := LValue;
  EnsureSelectedVisible;
  DoSelectedIndexChanged;
  Invalidate;
end;

function TThemedDropdownList.GetSelectedItem: TThemedDropdownItem;
begin
  if (FSelectedIndex >= 0) and (FSelectedIndex < FItems.Count) then Result := FItems[FSelectedIndex] else Result := nil;
end;

procedure TThemedDropdownList.UpdateMetrics;
begin
  FItemHeight := Max(NimbusScaleValue(FLogicalItemHeight, CurrentPPI), NimbusScaleValue(18, CurrentPPI));
  FCheckBoxSize := Max(NimbusScaleValue(FLogicalCheckBoxSize, CurrentPPI), NimbusScaleValue(10, CurrentPPI));
end;

function TThemedDropdownList.VisibleItemCount: Integer;
begin
  Result := FItems.Count;
  if Result > FMaxVisibleItems then Result := FMaxVisibleItems;
  if Result < 1 then Result := 1;
end;

function TThemedDropdownList.GetPreferredHeight: Integer;
begin
  Result := VisibleItemCount * FItemHeight + NimbusScaleValue(2, CurrentPPI);
end;

procedure TThemedDropdownList.UpdateControlSize;
begin
  if Align = alNone then Height := GetPreferredHeight;
end;

procedure TThemedDropdownList.EnsureSelectedVisible;
var
  LVisible: Integer;
begin
  LVisible := Max(1, FMaxVisibleItems);
  if FSelectedIndex < 0 then Exit;
  if FSelectedIndex < FTopIndex then FTopIndex := FSelectedIndex
  else if FSelectedIndex >= FTopIndex + LVisible then FTopIndex := FSelectedIndex - LVisible + 1;
  if FTopIndex < 0 then FTopIndex := 0;
  if FTopIndex > Max(0, FItems.Count - LVisible) then FTopIndex := Max(0, FItems.Count - LVisible);
end;

function TThemedDropdownList.HitTestIndex(const X, Y: Integer): Integer;
var
  LInset, LIndex: Integer;
begin
  LInset := NimbusScaleValue(1, CurrentPPI);
  if (X < LInset) or (X >= Width - LInset) or (Y < LInset) then Exit(-1);
  LIndex := FTopIndex + (Y - LInset) div FItemHeight;
  if (LIndex < 0) or (LIndex >= FItems.Count) or (LIndex >= FTopIndex + FMaxVisibleItems) then Exit(-1);
  Result := LIndex;
end;

function TThemedDropdownList.ItemRect(const AIndex: Integer): TRect;
var
  LInset, LVisibleIndex: Integer;
begin
  LInset := NimbusScaleValue(1, CurrentPPI);
  LVisibleIndex := AIndex - FTopIndex;
  Result := Rect(LInset, LInset + LVisibleIndex * FItemHeight, Width - LInset, LInset + (LVisibleIndex + 1) * FItemHeight);
end;

function TThemedDropdownList.CoerceSelectableIndex(const AValue: Integer): Integer;
var
  I, LValue: Integer;
  LItem: TThemedDropdownItem;
begin
  if FItems.Count = 0 then Exit(-1);
  LValue := AValue;
  if LValue < -1 then LValue := -1;
  if LValue >= FItems.Count then LValue := FItems.Count - 1;
  if LValue = -1 then Exit(-1);
  LItem := FItems[LValue];
  if (LItem <> nil) and LItem.Selectable then Exit(LValue);
  for I := LValue + 1 to FItems.Count - 1 do
    if (FItems[I] <> nil) and FItems[I].Selectable then Exit(I);
  for I := LValue - 1 downto 0 do
    if (FItems[I] <> nil) and FItems[I].Selectable then Exit(I);
  Result := -1;
end;

procedure TThemedDropdownList.MoveSelection(const ADelta: Integer);
var
  I, LIndex, LStart, LStep: Integer;
begin
  if FItems.Count = 0 then Exit;
  if ADelta >= 0 then LStep := 1 else LStep := -1;
  LStart := FSelectedIndex;
  if LStart < 0 then
  begin
    if LStep > 0 then LStart := -1 else LStart := FItems.Count;
  end;
  LIndex := LStart;
  for I := 0 to FItems.Count - 1 do
  begin
    Inc(LIndex, LStep);
    if LIndex < 0 then LIndex := FItems.Count - 1 else if LIndex >= FItems.Count then LIndex := 0;
    if (FItems[LIndex] <> nil) and FItems[LIndex].Selectable then
    begin
      SelectedIndex := LIndex;
      Exit;
    end;
  end;
end;

procedure TThemedDropdownList.InvokeSelectedItem;
var
  LItem: TThemedDropdownItem;
begin
  LItem := SelectedItem;
  if (LItem = nil) or not LItem.Selectable then Exit;
  if FShowCheckboxes then
  begin
    LItem.Checked := not LItem.Checked;
    DoCheckedItemsChanged;
    Invalidate;
    Exit;
  end;
  DoItemInvoked(LItem);
end;

procedure TThemedDropdownList.ToggleSelectedCheckState;
begin
  if not FShowCheckboxes then Exit;
  InvokeSelectedItem;
end;

function TThemedDropdownList.GetIndexOfItem(const AItem: TThemedDropdownItem): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

procedure TThemedDropdownList.DoItemInvoked(const AItem: TThemedDropdownItem);
begin
  if Assigned(FOnItemInvoked) then FOnItemInvoked(Self, AItem);
end;

procedure TThemedDropdownList.DoSelectedIndexChanged;
begin
  if Assigned(FOnSelectedIndexChanged) then FOnSelectedIndexChanged(Self);
end;

procedure TThemedDropdownList.DoCheckedItemsChanged;
begin
  if Assigned(FOnCheckedItemsChanged) then FOnCheckedItemsChanged(Self);
end;

procedure TThemedDropdownList.Paint;
var
  LContext: TThemedDropdownListRenderContext;
  I, LLast: Integer;
begin
  LContext.Bounds := ClientRect;
  LContext.Palette := FPalette;
  LContext.StyleMode := FStyleMode;
  LContext.Enabled := Enabled;
  LContext.ShowCheckboxes := FShowCheckboxes;
  LContext.SelectedIndex := FSelectedIndex;
  LContext.HoveredIndex := FHoveredIndex;
  LContext.CheckBoxSize := FCheckBoxSize;
  LContext.PPI := CurrentPPI;
  LContext.Font := Font;
  LContext.GroupFont := FGroupFont;
  FRenderCanvas.BeginRender(Canvas);
  try
    TThemedDropdownRenderer.RenderListBackground(FRenderCanvas, LContext);
    LLast := Min(FItems.Count - 1, FTopIndex + FMaxVisibleItems - 1);
    for I := FTopIndex to LLast do
      TThemedDropdownRenderer.RenderListItem(FRenderCanvas, LContext, FItems[I], I, ItemRect(I));
    TThemedDropdownRenderer.RenderListBorder(FRenderCanvas, LContext);
  finally
    FRenderCanvas.EndRender;
  end;
end;

procedure TThemedDropdownList.Resize;
begin
  inherited Resize;
  UpdateMetrics;
  Invalidate;
end;

procedure TThemedDropdownList.CMFontChanged(var Message: TMessage);
begin
  inherited;
  FGroupFont.Assign(Font);
  FGroupFont.Style := FGroupFont.Style + [fsBold];
  UpdateMetrics;
  UpdateControlSize;
  Invalidate;
end;

procedure TThemedDropdownList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  LIndex := HitTestIndex(X, Y);
  if FHoveredIndex = LIndex then Exit;
  FHoveredIndex := LIndex;
  Invalidate;
end;

procedure TThemedDropdownList.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoveredIndex = -1 then Exit;
  FHoveredIndex := -1;
  Invalidate;
end;

procedure TThemedDropdownList.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
  LItem: TThemedDropdownItem;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  LIndex := HitTestIndex(X, Y);
  if (LIndex < 0) or (LIndex >= FItems.Count) then Exit;
  LItem := FItems[LIndex];
  if (LItem = nil) or not LItem.Selectable then Exit;
  SelectedIndex := LIndex;
  if FShowCheckboxes then
  begin
    LItem.Checked := not LItem.Checked;
    DoCheckedItemsChanged;
    Invalidate;
  end
  else
    DoItemInvoked(LItem);
end;

procedure TThemedDropdownList.MouseWheelHandler(var Message: TMessage);
var
  LDelta: SmallInt;
begin
  inherited MouseWheelHandler(Message);
  LDelta := SmallInt(HiWord(Message.WParam));
  if LDelta < 0 then MoveSelection(1) else if LDelta > 0 then MoveSelection(-1);
end;

end.

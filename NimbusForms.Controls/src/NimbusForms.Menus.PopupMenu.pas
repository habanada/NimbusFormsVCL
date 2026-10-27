{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Menus.PopupMenu;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Menus,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TMenuHookState = record
    Item: TMenuItem;
    AdvancedDrawItem: TAdvancedMenuDrawItemEvent;
    MeasureItem: TMenuMeasureItemEvent;
  end;

  TThemedPopupMenu = class(TPopupMenu, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FHooks: TList<TMenuHookState>;
    FMenuBrush: HBRUSH;
    FThemeRegistered: Boolean;
    procedure HookItems(const AParent: TMenuItem);
    procedure RestoreHooks;
    procedure AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    procedure MeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure RebuildMenuBrush;
    procedure ApplyMenuBackground;
    function FindHook(const AItem: TMenuItem; out AHook: TMenuHookState): Boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    procedure Popup(X, Y: Integer); override;
  end;

implementation

uses
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Manager,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.PopupMenu;

constructor TThemedPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OwnerDraw := True;
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FHooks := TList<TMenuHookState>.Create;
  RebuildMenuBrush;
end;

destructor TThemedPopupMenu.Destroy;
begin
  if FThemeRegistered then ThemeManager.UnregisterAware(Self);
  RestoreHooks;
  if FMenuBrush <> 0 then DeleteObject(FMenuBrush);
  FHooks.Free;
  FPalette.Free;
  FRenderCanvas := nil;
  inherited Destroy;
end;

procedure TThemedPopupMenu.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  if FPalette = nil then
    FPalette := APalette.Clone
  else
    FPalette.Assign(APalette);
  RebuildMenuBrush;
end;

procedure TThemedPopupMenu.RebuildMenuBrush;
begin
  if FMenuBrush <> 0 then DeleteObject(FMenuBrush);
  FMenuBrush := CreateSolidBrush(ThemeColorToColorRef(NimbusMenuBackColor(FPalette)));
end;

procedure TThemedPopupMenu.ApplyMenuBackground;
var
  LInfo: TMenuInfo;
begin
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.cbSize := SizeOf(LInfo);
  LInfo.fMask := MIM_BACKGROUND;
  LInfo.hbrBack := FMenuBrush;
  SetMenuInfo(MenuHandle, LInfo);
end;

procedure TThemedPopupMenu.HookItems(const AParent: TMenuItem);
var
  I: Integer;
  LItem: TMenuItem;
  LHook: TMenuHookState;
begin
  if AParent = nil then
    Exit;
  for I := 0 to AParent.Count - 1 do
  begin
    LItem := AParent[I];
    LHook.Item := LItem;
    LHook.AdvancedDrawItem := LItem.OnAdvancedDrawItem;
    LHook.MeasureItem := LItem.OnMeasureItem;
    FHooks.Add(LHook);
    LItem.FreeNotification(Self);
    LItem.OnAdvancedDrawItem := AdvancedDrawItem;
    LItem.OnMeasureItem := MeasureItem;
    HookItems(LItem);
  end;
end;

procedure TThemedPopupMenu.RestoreHooks;
var
  I: Integer;
begin
  for I := FHooks.Count - 1 downto 0 do
    if FHooks[I].Item <> nil then
    begin
      FHooks[I].Item.OnAdvancedDrawItem := FHooks[I].AdvancedDrawItem;
      FHooks[I].Item.OnMeasureItem := FHooks[I].MeasureItem;
      FHooks[I].Item.RemoveFreeNotification(Self);
    end;
  FHooks.Clear;
end;

procedure TThemedPopupMenu.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then
    Exit;
  for I := FHooks.Count - 1 downto 0 do
    if FHooks[I].Item = AComponent then
      FHooks.Delete(I);
end;

function TThemedPopupMenu.FindHook(const AItem: TMenuItem; out AHook: TMenuHookState): Boolean;
var
  I: Integer;
begin
  for I := 0 to FHooks.Count - 1 do
    if FHooks[I].Item = AItem then
    begin
      AHook := FHooks[I];
      Exit(True);
    end;
  Result := False;
end;

procedure TThemedPopupMenu.AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
  State: TOwnerDrawState);
var
  LItem: TMenuItem;
  LHook: TMenuHookState;
  LPPI: Integer;
begin
  if not (Sender is TMenuItem) then
    Exit;
  LItem := TMenuItem(Sender);
  LPPI := GetDeviceCaps(ACanvas.Handle, LOGPIXELSX);
  if LPPI <= 0 then LPPI := 96;
  FRenderCanvas.BeginRender(ACanvas);
  try
    TThemedPopupMenuRenderer.RenderItem(FRenderCanvas, LItem, ACanvas.Font, ARect, State, FPalette, LPPI);
  finally
    FRenderCanvas.EndRender;
  end;
  if FindHook(LItem, LHook) and Assigned(LHook.AdvancedDrawItem) then
    LHook.AdvancedDrawItem(LItem, ACanvas, ARect, State);
end;

procedure TThemedPopupMenu.MeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
  LItem: TMenuItem;
  LHook: TMenuHookState;
  LPPI: Integer;
begin
  if not (Sender is TMenuItem) then
    Exit;
  LItem := TMenuItem(Sender);
  LPPI := GetDeviceCaps(ACanvas.Handle, LOGPIXELSX);
  if LPPI <= 0 then LPPI := 96;
  FRenderCanvas.BeginRender(ACanvas);
  try
    TThemedPopupMenuRenderer.MeasureItem(FRenderCanvas, ACanvas.Font, LItem, LPPI, Width, Height);
  finally
    FRenderCanvas.EndRender;
  end;
  if FindHook(LItem, LHook) and Assigned(LHook.MeasureItem) then
    LHook.MeasureItem(LItem, ACanvas, Width, Height);
end;

procedure TThemedPopupMenu.Popup(X, Y: Integer);
begin
  if not FThemeRegistered then
  begin
    ThemeManager.RegisterAware(Self);
    FThemeRegistered := True;
  end;
  RestoreHooks;
  OwnerDraw := True;
  HookItems(Items);
  ApplyMenuBackground;
  try
    inherited Popup(X, Y);
  finally
    RestoreHooks;
  end;
end;

end.

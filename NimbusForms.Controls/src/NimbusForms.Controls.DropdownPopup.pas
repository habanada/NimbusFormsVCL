{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.DropdownPopup;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.Forms,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Dropdown.Types,
  NimbusForms.Controls.DropdownList;

type
  TThemedDropdownPopupForm = class(TForm)
  private
    FListControl: TThemedDropdownList;
    FPopupVisible: Boolean;
    FChangingVisibility, FClosePending: Boolean;
    FLogicalMinWidth: Integer;
    FOnItemSelected: TThemedDropdownItemEvent;
    FOnCheckedItemsChanged: TNotifyEvent;
    procedure ListItemInvoked(Sender: TObject; Item: TThemedDropdownItem);
    procedure ListCheckedItemsChanged(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure SyncSize(const AWidth: Integer);
    procedure ShowPopup(AOwnerControl: TControl; const ABounds: TRect);
    procedure ClosePopup;
    property ListControl: TThemedDropdownList read FListControl;
    property PopupVisible: Boolean read FPopupVisible;
    property OnItemSelected: TThemedDropdownItemEvent read FOnItemSelected write FOnItemSelected;
    property OnCheckedItemsChanged: TNotifyEvent read FOnCheckedItemsChanged write FOnCheckedItemsChanged;
  end;

implementation

uses
  System.Math,
  System.UITypes,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

constructor TThemedDropdownPopupForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BorderStyle := Vcl.Forms.bsNone;
  ShowInTaskbar := False;
  PopupMode := pmExplicit;
  Position := poDesigned;
  AutoScroll := False;
  KeyPreview := False;
  FLogicalMinWidth := 40;
  FListControl := TThemedDropdownList.Create(Self);
  FListControl.Parent := Self;
  FListControl.Align := alClient;
  FListControl.TabStop := False;
  FListControl.OnItemInvoked := ListItemInvoked;
  FListControl.OnCheckedItemsChanged := ListCheckedItemsChanged;
end;

procedure TThemedDropdownPopupForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE or WS_EX_TOOLWINDOW;
  Params.Style := Params.Style and not WS_CAPTION;
end;

procedure TThemedDropdownPopupForm.WndProc(var Message: TMessage);
begin
  if Message.Msg = CM_SHOWINGCHANGED then
  begin
    FPopupVisible := Showing;
    if HandleAllocated then
      if Showing then ShowWindow(Handle, SW_SHOWNOACTIVATE) else ShowWindow(Handle, SW_HIDE);
    if Showing then DoShow else DoHide;
    Message.Result := 0;
    Exit;
  end;
  if Message.Msg = WM_MOUSEACTIVATE then
  begin
    Message.Result := MA_NOACTIVATE;
    Exit;
  end;
  inherited WndProc(Message);
end;

procedure TThemedDropdownPopupForm.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  Color := ThemeColorToColor(NimbusMenuBackColor(APalette));
  FListControl.ApplyTheme(APalette);
end;

procedure TThemedDropdownPopupForm.SyncSize(const AWidth: Integer);
var
  LWidth, LHeight: Integer;
begin
  LWidth := Max(AWidth, NimbusScaleValue(FLogicalMinWidth, FListControl.CurrentPPI));
  LHeight := FListControl.PreferredHeight;
  ClientWidth := LWidth;
  ClientHeight := LHeight;
end;

procedure TThemedDropdownPopupForm.ShowPopup(AOwnerControl: TControl; const ABounds: TRect);
begin
  if FChangingVisibility or (csDestroying in ComponentState) then Exit;
  if AOwnerControl <> nil then PopupParent := GetParentForm(AOwnerControl);
  SetBounds(ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  FClosePending := False;
  FChangingVisibility := True;
  try
    if not Visible then Visible := True;
    if HandleAllocated and not FClosePending then
      SetWindowPos(Handle, HWND_TOP, ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height, SWP_NOACTIVATE or SWP_SHOWWINDOW);
    FPopupVisible := Showing;
  finally
    FChangingVisibility := False;
    if FClosePending then ClosePopup;
  end;
end;

procedure TThemedDropdownPopupForm.ClosePopup;
begin
  if FChangingVisibility then begin FClosePending := True; Exit; end;
  FClosePending := False;
  FChangingVisibility := True;
  try
    FPopupVisible := False;
    if Visible then Visible := False;
  finally FChangingVisibility := False; end;
end;

procedure TThemedDropdownPopupForm.ListItemInvoked(Sender: TObject; Item: TThemedDropdownItem);
begin
  if Assigned(FOnItemSelected) then FOnItemSelected(Self, Item);
end;

procedure TThemedDropdownPopupForm.ListCheckedItemsChanged(Sender: TObject);
begin
  if Assigned(FOnCheckedItemsChanged) then FOnCheckedItemsChanged(Self);
end;

end.

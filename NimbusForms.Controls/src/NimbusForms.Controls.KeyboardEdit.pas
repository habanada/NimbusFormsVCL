{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.KeyboardEdit;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Vcl.StdCtrls;

type
  TNimbusKeyboardEdit = class(TEdit)
  protected
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
  end;

implementation

procedure TNimbusKeyboardEdit.WMGetDlgCode(var Message: TMessage);
var
  LKeyMessage: PMsg;
begin
  inherited;
  if Message.LParam = 0 then Exit;
  LKeyMessage := PMsg(Message.LParam);
  if (LKeyMessage.message = WM_KEYDOWN) and ((LKeyMessage.wParam = VK_RETURN) or (LKeyMessage.wParam = VK_ESCAPE)) then
    Message.Result := Message.Result or DLGC_WANTALLKEYS;
end;

end.

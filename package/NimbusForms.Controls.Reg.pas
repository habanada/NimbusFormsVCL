{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Reg;

interface

procedure Register;

implementation

uses
  System.Classes,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.ToolBar,
  NimbusForms.Controls.MenuBar,
  NimbusForms.Controls.SplitButton,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.ToggleBox,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.StyledLabel,
  NimbusForms.Controls.RadioButton,
  NimbusForms.Controls.ProgressBar,
  NimbusForms.Controls.RichEdit,
  NimbusForms.Menus.PopupMenu;

procedure Register;
begin
  RegisterComponents('NimbusForms', [TThemedButton, TThemedToolButton, TThemedToolBar, TThemedToolBarSpacer, TThemedMenuBar, TThemedSplitButton, TThemedPanel, TThemedCheckBox,
    TThemedToggleBox, TThemedLabel, TThemedStyledLabel, TThemedRadioButton, TThemedProgressBar,
    TThemedRichEdit, TThemedPopupMenu]);
end;

end.

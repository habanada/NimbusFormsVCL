{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Strings;

interface

type
  ThemeStrings = class
  public
  const
    JsonName = 'Name';
    JsonIsDark = 'IsDark';
    JsonBackColor = 'BackColor';
    JsonForeColor = 'ForeColor';
    JsonControlBackColor = 'ControlBackColor';
    JsonControlForeColor = 'ControlForeColor';
    JsonControlBorderColor = 'ControlBorderColor';
    JsonAccentColor = 'AccentColor';
    JsonMutedForeColor = 'MutedForeColor';
    JsonDisabledForeColor = 'DisabledForeColor';
    JsonDisabledBackColor = 'DisabledBackColor';
    JsonHoverBackColor = 'HoverBackColor';
    JsonPressedBackColor = 'PressedBackColor';
    JsonSelectedBackColor = 'SelectedBackColor';
    JsonSelectedForeColor = 'SelectedForeColor';
    JsonFocusBorderColor = 'FocusBorderColor';
    JsonInputBackColor = 'InputBackColor';
    JsonInputForeColor = 'InputForeColor';
    JsonInputBorderColor = 'InputBorderColor';
    JsonMenuBackColor = 'MenuBackColor';
    JsonMenuForeColor = 'MenuForeColor';
    JsonMenuBorderColor = 'MenuBorderColor';
    JsonMenuSelectedBackColor = 'MenuSelectedBackColor';
    JsonPanelBackColor = 'PanelBackColor';
    JsonGroupBoxBorderColor = 'GroupBoxBorderColor';
    JsonTabBackColor = 'TabBackColor';
    JsonTabForeColor = 'TabForeColor';
    JsonActiveTabBackColor = 'ActiveTabBackColor';
    JsonActiveTabForeColor = 'ActiveTabForeColor';
    JsonProgressBackColor = 'ProgressBackColor';
    JsonProgressFillColor = 'ProgressFillColor';
    JsonStatusBackColor = 'StatusBackColor';
    JsonStatusForeColor = 'StatusForeColor';
    JsonSeparatorColor = 'SeparatorColor';
    JsonDockHostBackColor = 'DockHostBackColor';
    JsonDockPaneBackColor = 'DockPaneBackColor';
    JsonDockPaneBorderColor = 'DockPaneBorderColor';
    JsonDockHeaderBackColor = 'DockHeaderBackColor';
    JsonDockHeaderForeColor = 'DockHeaderForeColor';
    JsonDockTabBackColor = 'DockTabBackColor';
    JsonDockTabHoverBackColor = 'DockTabHoverBackColor';
    JsonDockTabActiveBackColor = 'DockTabActiveBackColor';
    JsonDockTabBorderColor = 'DockTabBorderColor';
    JsonDockTabActiveBorderColor = 'DockTabActiveBorderColor';
    JsonDockTabForeColor = 'DockTabForeColor';
    JsonDockTabActiveForeColor = 'DockTabActiveForeColor';
    JsonDockTabMutedForeColor = 'DockTabMutedForeColor';
    JsonDockSplitterBackColor = 'DockSplitterBackColor';
    JsonDockSplitterHoverBackColor = 'DockSplitterHoverBackColor';
    JsonDockDropTargetBackColor = 'DockDropTargetBackColor';
    JsonDockDropTargetBorderColor = 'DockDropTargetBorderColor';
    JsonDockDropTargetHoverBackColor = 'DockDropTargetHoverBackColor';
    JsonDockDropTargetHoverBorderColor = 'DockDropTargetHoverBorderColor';
    JsonDockDropPreviewBackColor = 'DockDropPreviewBackColor';
    JsonDockDropPreviewBorderColor = 'DockDropPreviewBorderColor';

    DefaultThemeName = 'Dark';
    HexPrefix = '#';
    ColorHexFormat = '#%2.2x%2.2x%2.2x%2.2x';
    ThemeFilePattern = '*.json';
    FallbackThemeFileName = 'Theme';

    ErrEmptyFilePath = 'filePath';
    ErrNilPalette = 'palette';
    ErrEmptyName = 'name';
    ErrNilFactory = 'factory';
    ErrUnknownTheme = 'Unknown theme.';
    ErrInvalidColorFormat = 'Invalid color format. Expected #RRGGBB or #AARRGGBB.';
  end;

implementation

end.

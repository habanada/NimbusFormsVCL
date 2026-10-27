{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Strings;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  System.TypInfo,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  System.Types,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Imaging.jpeg,
  System.UITypes,
  System.Actions,
  NimbusForms.Theming.Manager,
  NimbusForms.Rendering.Canvas;

resourcestring
  SSplitterTab = 'Splitter';
  SSplitterDescription = 'Standalone splitters between existing controls. Drag the square grip or use arrow keys; Escape cancels.';
  SSplitterColumn = 'Files';
  SSplitterItem = 'Document %d';
  SSplitterContent = 'Content panel'#13#10'Resize the list on the left or the output panel below.';
  SSplitterOutput = 'Output panel';
  SCodeEditorFont = 'Editor Font...';
  SCodeEditorGoToLine = 'Go to Line...';
  SCodeEditorLinePrompt = 'Line number (1 to %d):';
  SCodeEditorLineRange = 'Enter a line number between 1 and %d.';
  SCodeEditorZoomStatus = '%d%% | %s %d pt';
  SDateRangeTab = 'DateRange';
  SDateRangeTitle = 'Select a date range, use presets or apply two calendar dates';
  SBadgeSuccess = 'Success';
  SBadgeWarning = 'Warning';
  SBadgeError = 'Error';
  SBadgeInformation = 'Information';
  SBadgeBeta = 'Beta';
  SBadgeNew = 'NEW';
  SBadgeClosable = 'Closable';
  SBadgeRounded = 'Rounded';
  SAppTitle = 'NimbusForms VCL Demo';
  SStandardControls = 'Standard Controls';
  SToolButtonTab = 'ToolButton';
  SToolButtonNew = 'New';
  SToolButtonOpen = 'Open';
  SToolButtonSave = 'Save';
  SToolButtonBold = 'Bold';
  SToolButtonOptions = 'Options';
  SToolButtonSplit = 'Split';
  SToolButtonStatusReady = 'ToolButton: hover, press, check and open the dropdown variants.';
  SToolButtonClickStatusFormat = 'ToolButton click: %s';
  SToolButtonCheckedStatusFormat = 'ToolButton checked: %s = %s';
  SToolButtonDropDownStatusFormat = 'ToolButton dropdown: %s / part %d';
  SToolBarTab = 'ToolBar';
  SToolBarStatusReady = 'ToolBar: hosted label, combo and search box are managed with the button groups; resize for overflow.';
  SToolBarClickStatusFormat = 'ToolBar action: %s';
  SToolBarFormat = 'Format';
  SToolBarUndo = 'Undo';
  SToolBarRedo = 'Redo';
  SToolBarBuild = 'Build';
  SToolBarRun = 'Run';
  SToolBarDebug = 'Debug';
  SToolBarConfig = 'Config';
  SToolBarSearch = 'Search commands';
  SToolBarModeDebug = 'Debug';
  SToolBarModeRelease = 'Release';
  SToolBarEmbeddedStatusFormat = 'ToolBar %s: %s';
  SIdeStatusReady = 'Ready';
  SIdeStatusNimbus = 'NimbusForms IDE';
  SIdeStatusLine = 'Ln 42, Col 8';
  SIdeStatusEncoding = 'UTF-8';
  SIdeStatusSpaces = 'Spaces: 4';
  SIdeStatusDebug = 'Debug';
  SIdeStatusMessage = 'StatusBar: %s';
  SMenuBarTab = 'MenuBar';
  SBreadcrumbTab = 'BreadcrumbBar';
  STagInputTab = 'TagInput';
  STagInputHint = 'Enter or comma adds a tag. Backspace removes the last tag. Click X to remove.';
  SBreadcrumbHint = 'Click a segment to navigate. Click its arrow for children. Press F2 to edit the path.';
  SMenuBarOverflowWidth = 'Overflow test width';
  SMenuBarOverflowWidthFormat = 'MenuBar width: %d px';
  SMenuBarStatusReady = 'MenuBar: use mouse, Tab/arrow keys or Alt+F / Alt+E / Alt+V / Alt+B / Alt+H.';
  SMenuBarItemStatusFormat = 'MenuBar item: %s';
  SMenuBarOpeningStatusFormat = 'MenuBar opening: %s';
  SMenuBarPopupStatusFormat = 'Menu command: %s';
  SMenuBarFile = '&File';
  SMenuBarEdit = '&Edit';
  SMenuBarView = '&View';
  SMenuBarBuild = '&Build';
  SMenuBarHelp = '&Help';
  SMenuBarHome = 'Home';
  SMenuBarBranch = 'MAIN';
  SMenuBarLive = 'Live';
  SMenuBarCenter = 'NimbusForms IDE';
  SMenuBarSearch = 'Search menus and commands';
  SMenuBarConfig = 'Config';
  SMenuBarModeDebug = 'Debug';
  SMenuBarModeRelease = 'Release';
  SMenuBarTextStatusFormat = 'MenuBar text: %s';
  SMenuBarSelectionStatusFormat = 'MenuBar selection: %s';
  SMenuBarNew = '&New';
  SMenuBarOpen = '&Open...';
  SMenuBarSave = '&Save';
  SMenuBarExit = 'E&xit';
  SMenuBarUndo = '&Undo';
  SMenuBarRedo = '&Redo';
  SMenuBarCut = 'Cu&t';
  SMenuBarCopy = '&Copy';
  SMenuBarPaste = '&Paste';
  SMenuBarToolBar = '&Tool Bar';
  SMenuBarStatusBar = '&Status Bar';
  SMenuBarBuildSolution = '&Build Solution';
  SMenuBarRun = '&Run';
  SMenuBarDebug = '&Debug';
  SMenuBarAbout = '&About NimbusForms';
  SStyledLabelTab = 'Styled Label';
  SStyledLabelMarkup = '<h1>NimbusForms Styled Label</h1><br>High-quality <b>GDI+</b> mini markup with <i>italic</i>, <u>underline</u> and <accent>theme accent</accent>.<br><br><muted>Semantic colors:</muted> <success>Success</success> <warning>Warning</warning> <error>Error</error>.<br><br>Renderer: <code>INimbusRenderCanvas</code> Shortcut: <kbd>Ctrl+S</kbd><br><br><link=docs>Open documentation</link> <muted>or</muted> <link=settings>Open settings</link><br><br><h2>Reusable renderer</h2><br>The parser and layout engine are separate from the control, DPI-aware and cached.';
  SStyledLabelStatus = 'Hover and click the inline links.';
  SStyledLabelLinkStatusFormat = 'StyledLabel link: %s';
  SHexEditor = 'HexEditor';
  SThemeFormat = 'Theme: %s';
  SNextTheme = 'Next Theme';
  SLightTheme = 'Light';
  SDarkTheme = 'Dark';
  SPrimaryButton = 'Advance Progress';
  SToolTipThemeTitle = 'Theme selector';
  SToolTipThemeText = 'Click the main area to advance the theme. Use the <b>arrow</b> to open the themed menu.';
  SToolTipLightTitle = 'Light theme';
  SToolTipLightText = 'Apply the light NimbusForms palette.';
  SToolTipDarkTitle = 'Dark theme';
  SToolTipDarkText = 'Apply the dark NimbusForms palette.';
  SToolTipProgressTitle = 'Progress demo';
  SToolTipProgressText = 'Advances the progress bar and updates its <code>BadgeText</code> value.';
  SProgressBadgeFormat = '%d%%';
  SCheckBox = 'Themed CheckBox';
  SToggleBox = 'Themed ToggleBox';
  SRadioOne = 'Radio option one';
  SRadioTwo = 'Radio option two';
  SOn = 'ON';
  SOff = 'OFF';
  SNextControls = 'NimbusForms C# parity';
  SComboAlpha = 'Alpha';
  SComboBeta = 'Beta';
  SComboGamma = 'Gamma';
  SListBoxTitle = 'Themed ListBox';
  SListRenderer = 'Renderer-first';
  SListGdiPlus = 'GDI+ shapes and text';
  SListDpi = 'DPI-aware metrics';
  SListTheme = 'ThemeManager integration';
  SListKeyboard = 'Keyboard and multi-selection';
  SListLong = 'Long item caption demonstrating end ellipsis rendering in the custom list box';
  SListStatusFormat = 'ListBox: %s (%d selected)';
  STrackValueFormat = 'TrackBar: %d';
  SScrollValueFormat = 'ScrollBars: H=%d V=%d';
  SDropdownGroupCore = 'Core';
  SDropdownGroupRender = 'Rendering';
  SDropdownButton = 'Button';
  SDropdownToggle = 'ToggleBox';
  SDropdownRadio = 'RadioButton';
  SDropdownGdiPlus = 'GDI+ renderer';
  SDropdownTheme = 'ThemeManager';
  SDropdownEmpty = 'Select or type...';
  SDropdownStatusFormat = 'Dropdown: %s';
  SRatingToolTipTitle = 'Themed Rating';
  SRatingToolTipText = 'Half-step rating with mouse hover preview, keyboard control and clear-on-second-click behavior.';
  SRatingStatusFormat = 'Rating: %s / %d';
  STabControlTitle = 'Themed TabControl';
  STreeViewTab = 'TreeView';
  SVirtualListTab = 'VirtualList';
  SVirtualListEmpty = 'No virtual items';
  SVirtualListItemFormat = 'Virtual item %d';
  SVirtualListSubtitle = 'Generated on demand without per-item VCL objects';
  SVirtualListDetailFormat = 'Row %d of 100,000';
  SVirtualListBadgeHot = 'HOT';
  SVirtualListBadgeSync = 'SYNC';
  SVirtualListStatusFormat = 'VirtualList: %d selected, current %d';
  SVirtualListActivateFormat = 'VirtualList activated: %d';
  SVirtualListCheckFormat = 'VirtualList check: %d = %d';
  SVirtualListColumnItem = 'Item';
  SVirtualListColumnProvider = 'Provider';
  SVirtualListColumnPosition = 'Position';
  SVirtualListColumnBadge = 'Badge';
  SVirtualListColumnProgress = 'Progress';
  SVirtualListProgressFormat = '%d%%';
  SVirtualListSortFormat = 'VirtualList sort: %s / %d';
  SVirtualListFilterFormat = 'VirtualList filter: "%s" -> %d rows';
  SVirtualListEditFormat = 'VirtualList edit: row %d, %s = "%s"';
  SVirtualListEditRejected = 'VirtualList edit rejected: value cannot be empty';
  SVirtualListGroupFormat = 'Group %d';
  SVirtualListDetailsFormat = 'VirtualList details: row %d %s';
  SVirtualListExpanded = 'expanded';
  SVirtualListCollapsed = 'collapsed';
  SDatePickerTab = 'DatePicker';
  SDatePickerTitle = 'Date only';
  SDateTimePickerTitle = 'Date and time';
  SDateCulturePickerTitle = 'Culture (en-US)';
  SDateManualPickerTitle = 'RTL / manual week';
  SDatePickerInfo = 'Full custom GDI+ calendar popup with range checks, keyboard navigation, culture-aware week layout, RTL and DPI scaling.';
  SDatePickerStatusFormat = 'DatePicker: %s';
  SDatePickerSelectedFormat = 'Date selected: %s';
  SDatePickerOpened = 'DatePicker: dropdown opened';
  SDatePickerClosed = 'DatePicker: dropdown closed';
  STreeFilterPlaceholder = 'Filter nodes...';
  STreeRoot = 'NimbusForms';
  STreeRootSubtitle = 'Renderer-first VCL control library';
  STreeControls = 'Controls';
  STreeControlsSubtitle = 'Interactive themed controls';
  STreeInput = 'Input controls';
  STreeNavigation = 'Navigation';
  STreeEditors = 'Editors';
  STreeRenderer = 'GDI+ rendering';
  STreeRendererSubtitle = 'High quality anti-aliased drawing';
  STreeDisabled = 'Disabled node';
  STreeProgress = 'Porting progress';
  STreeLazy = 'Lazy-loaded branch';
  STreeLazySubtitle = 'Expand to populate child nodes';
  STreeLazyPlaceholder = 'Loading...';
  STreeLazyChildOne = 'Lazy child one';
  STreeLazyChildTwo = 'Lazy child two';
  STreeLazyStatusFormat = 'TreeView lazy loaded: %s';
  STreeBadge = '12';
  STreeNodeStatusFormat = 'TreeView: %s';
  STreeCheckStatusFormat = 'TreeView check: %s';
  STreeRenamedStatusFormat = 'TreeView renamed: %s -> %s';
  STreeDroppedStatusFormat = 'TreeView moved: %s';
  STreeMenuRename = 'Rename';
  STreeMenuExpand = 'Expand';
  STreeMenuCollapse = 'Collapse';
  STreeMenuFavorite = 'Toggle Favorite';
  STabOverview = 'Overview';
  STabRenderer = 'Renderer';
  STabUnsaved = 'Unsaved document';
  STabPinned = 'Pinned';
  STabLong = 'Long caption with ellipsis behavior';
  STabOverviewText = 'Renderer-first GDI+ tab header with native VCL TTabSheet pages.';
  STabRendererText = 'Drag tabs to reorder them. Close buttons, hover, pressed and focus states are custom rendered.';
  STabUnsavedText = 'This page demonstrates the unsaved-state marker and badge rendering.';
  STabPinnedText = 'Pinned tabs stay open even when close buttons are enabled.';
  STabLongText = 'The maximum tab width demonstrates ellipsis trimming for long captions.';
  STabBadge = '3';
  STabChangedFormat = 'TabControl: %s';
  STabClosedFormat = 'Tab closed: %s';
  STabReorderedFormat = 'Tab moved: %s (%d -> %d)';
  SCompactMode = 'Compact UI';
  SCompactModeHint = 'Switch NimbusForms controls between normal and compact spacing.';
  STextBoxValue = 'nimbus@example.com';
  STextBoxPrefix = 'Mail';
  SStatusTextBoxValid = 'TextBox: email is valid';
  SStatusTextBoxInvalid = 'TextBox: invalid email';
  SStatusTextBoxCleared = 'TextBox: cleared';
  SRichEditTitle = 'Themed RichEdit';
  SRichEditLine1 = 'NimbusForms RichEdit uses the native VCL RichEdit as its editor surface.';
  SRichEditLine2 = 'Frame, colors, focus state and theme integration stay renderer-first.';
  SRichEditLine3 = 'Right-click here to open the themed popup menu.';
  SStatusReady = 'Ready';
  SStatusCheckOn = 'CheckBox: checked';
  SStatusCheckOff = 'CheckBox: unchecked';
  SStatusToggleOn = 'ToggleBox: on';
  SStatusToggleOff = 'ToggleBox: off';
  SStatusRadioOne = 'Radio: option one';
  SStatusRadioTwo = 'Radio: option two';
  SRightClickHint = 'Right-click the form, controls, TabControl, RichEdit or HexEditor.';
  SCursorFormat = 'Cursor: 0x%s';
  SMenuDark = 'Dark Theme';
  SMenuLight = 'Light Theme';
  SMenuNext = 'Next Theme';
  SMenuResetProgress = 'Reset Progress';
  SMenuExit = 'Exit';

const
  CMenuDark = 1;
  CMenuLight = 2;
  CMenuNext = 3;
  CMenuResetProgress = 4;
  CMenuExit = 5;
  CTreeMenuRename = 101;
  CTreeMenuExpand = 102;
  CTreeMenuCollapse = 103;
  CTreeMenuFavorite = 104;


implementation

end.

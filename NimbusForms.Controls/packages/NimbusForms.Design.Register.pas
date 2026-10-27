{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Design.Register;

interface

procedure Register;

implementation

uses System.Classes, DesignIntf, DesignEditors,
  NimbusForms.Controls.ThemeManager, NimbusForms.Theming.Presets,
  NimbusForms.Controls.LogViewer,
  NimbusForms.Controls.NotificationBar,
  NimbusForms.Controls.Chart,
  NimbusForms.Controls.FinancialBusinessChart,
  NimbusForms.Controls.Sparkline,
  NimbusForms.Controls.MicroChart,
  NimbusForms.Controls.DashboardWidgets,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.ToolBar,
  NimbusForms.Controls.MenuBar,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.TagInput,
  NimbusForms.Controls.StepIndicator,
  NimbusForms.Controls.Avatar,
  NimbusForms.Controls.BadgeLabel,
  NimbusForms.Controls.SplitContainer,
  NimbusForms.Controls.Splitter,
  NimbusForms.Controls.SplitButton,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.ToggleBox,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.StyledLabel,
  NimbusForms.Controls.RadioButton,
  NimbusForms.Controls.ProgressBar,
  NimbusForms.Controls.RichEdit,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.ListBox,
  NimbusForms.Controls.VirtualList,
  NimbusForms.Controls.PropertyGrid,
  NimbusForms.Controls.GroupBox,
  NimbusForms.Controls.TrackBar,
  NimbusForms.Controls.Separator,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.NumericUpDown,
  NimbusForms.Controls.RangeTrackBar,
  NimbusForms.Controls.HScrollBar,
  NimbusForms.Controls.VScrollBar,
  NimbusForms.Controls.IDEScrollBar,
  NimbusForms.Controls.CodeEditor,
  NimbusForms.Controls.Dropdown,
  NimbusForms.Controls.Rating,
  NimbusForms.Controls.TabControl,
  NimbusForms.Controls.TreeView,
  NimbusForms.Controls.DatePicker,
  NimbusForms.Controls.DateRange,
  NimbusForms.Controls.IdeColorPicker,
  NimbusForms.Controls.IdeDateRange,
  NimbusForms.Controls.ToolTip,
  NimbusForms.Menus.PopupMenu,
  NimbusForms.Grid.View,
  NimbusForms.HexEditor.Control,
  NimbusForms.Controls.BreadcrumbBar,
  NimbusForms.HexEditor.InspectorControl,
  NimbusForms.HexEditor.BookmarkList;

type
  TThemeNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

function TThemeNameProperty.GetAttributes: TPropertyAttributes;
begin Result := [paValueList, paSortList, paMultiSelect]; end;

procedure TThemeNameProperty.GetValues(Proc: TGetStrProc);
var Name: string;
begin for Name in TThemePresets.GetNames do Proc(Name); end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string), TThemedThemeManager, 'ThemeName', TThemeNameProperty);
  RegisterComponents('NimbusForms', [TThemedThemeManager, TThemedIdeNotificationBar, TThemedButton, TThemedToolButton, TThemedToolBar, TThemedMenuBar, TThemedIdeStatusBar, TThemedTagInput, TThemedStepIndicator, TThemedAvatar, TThemedBadgeLabel, TThemedSplitContainer, TThemedSplitter, TThemedSplitButton, TThemedPanel, TThemedCheckBox, TThemedToggleBox, TThemedLabel, TThemedStyledLabel, TThemedRadioButton, TThemedProgressBar, TThemedComboBox, TThemedListBox, TThemedVirtualList, TThemedGroupBox, TThemedTrackBar, TThemedSeparator, TThemedTextBox, TThemedNumericUpDown, TThemedRangeTrackBar, TThemedHScrollBar, TThemedVScrollBar, TThemedIDEScrollBar, TThemedDropdown, TThemedRatingControl, TThemedTabControl, TThemedTreeView, TThemedDatePicker, TThemedDateRangePicker, TThemedIdeColorPicker, TThemedIdeDateRangePicker, TThemedToolTip, TThemedPopupMenu, TThemedToolBarSpacer, TThemedBreadcrumbBar, TThemedIdeColorPickerButton]);
  RegisterComponents('NimbusForms Editors', [TThemedLogViewer, TThemedRichEdit, TThemedPropertyGrid, TThemedCodeEditor, TThemedGridView, TThemedHexEditor, TThemedHexInspector, TThemedHexBookmarkList]);
  RegisterComponents('NimbusForms Charts', [TThemedChart, TThemedFinancialBusinessChart, TThemedSparkline, TThemedMicroChart, TThemedKpiTile, TThemedDeltaTile, TThemedProgressMeter, TThemedSegmentMeter, TThemedStatusMatrix, TThemedTrendArrow, TThemedComparisonBars, TThemedRadialScore, TThemedActivityDots, TThemedCapacityBars]);
end;

end.

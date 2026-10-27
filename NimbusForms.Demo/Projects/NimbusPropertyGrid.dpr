program NimbusPropertyGrid;

{$APPTYPE GUI}

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
  NimbusForms.Theming.Types in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Palette in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.Strings in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.WinVersion in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.WinVersion.pas',
  NimbusForms.Theming.Win32 in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.PresetFactory in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Serializer in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Presets in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Manager in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Manager.pas',
  NimbusForms.Controls.Types in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Types.pas',
  NimbusForms.Controls.Base in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Base.pas',
  NimbusForms.Controls.Button in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Button.pas',
  NimbusForms.Controls.ToolButton in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ToolButton.pas',
  NimbusForms.Controls.Splitter in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Splitter.pas',
  NimbusForms.Rendering.Splitter in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Splitter.pas',
  NimbusForms.Controls.ToolTip in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ToolTip.pas',
  NimbusForms.Controls.Panel in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Panel.pas',
  NimbusForms.Controls.CheckBox in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.CheckBox.pas',
  NimbusForms.Controls.ThemedLabel in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ThemedLabel.pas',
  NimbusForms.Controls.RichEdit in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.RichEdit.pas',
  NimbusForms.Controls.ComboBox in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ComboBox.pas',
  NimbusForms.Controls.ListBox in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ListBox.pas',
  NimbusForms.Controls.PropertyGrid.Types in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.PropertyGrid.Types.pas',
  NimbusForms.Controls.PropertyGrid.Adapters in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.PropertyGrid.Adapters.pas',
  NimbusForms.Rendering.PropertyGrid in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.PropertyGrid.pas',
  NimbusForms.Controls.PropertyGrid in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.PropertyGrid.pas',
  NimbusForms.Controls.TextBox in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.TextBox.pas',
  NimbusForms.Controls.NumericUpDown in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.NumericUpDown.pas',
  NimbusForms.Controls.ScrollBarBase in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ScrollBarBase.pas',
  NimbusForms.Controls.VScrollBar in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.VScrollBar.pas',
  NimbusForms.Controls.Dropdown.Types in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Dropdown.Types.pas',
  NimbusForms.Controls.DropdownList in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.DropdownList.pas',
  NimbusForms.Controls.DropdownPopup in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.DropdownPopup.pas',
  NimbusForms.Controls.Dropdown in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Dropdown.pas',
  NimbusForms.Controls.TabControl in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.TabControl.pas',
  NimbusForms.Controls.DatePicker in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.DatePicker.pas',
  NimbusForms.Controls.IdeColorPicker in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.IdeColorPicker.pas',
  NimbusForms.Rendering.IdeColorPicker in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.IdeColorPicker.pas',
  NimbusForms.Menus.PopupMenu in '..\..\NimbusForms.Controls\src\NimbusForms.Menus.PopupMenu.pas',
  NimbusForms.Rendering.Types in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Types.pas',
  NimbusForms.Rendering.Canvas in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Canvas.pas',
  NimbusForms.Rendering.Button in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Button.pas',
  NimbusForms.Rendering.ToolButton in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ToolButton.pas',
  NimbusForms.Rendering.ToolTip in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ToolTip.pas',
  NimbusForms.Rendering.Panel in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Panel.pas',
  NimbusForms.Rendering.CheckBox in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.CheckBox.pas',
  NimbusForms.Rendering.ThemedLabel in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ThemedLabel.pas',
  NimbusForms.Rendering.RichEdit in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.RichEdit.pas',
  NimbusForms.Rendering.ComboBox in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ComboBox.pas',
  NimbusForms.Rendering.ListBox in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ListBox.pas',
  NimbusForms.Rendering.TextBox in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.TextBox.pas',
  NimbusForms.Rendering.NumericUpDown in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.NumericUpDown.pas',
  NimbusForms.Rendering.ScrollBar in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ScrollBar.pas',
  NimbusForms.Rendering.Dropdown in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Dropdown.pas',
  NimbusForms.Rendering.TabControl in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.TabControl.pas',
  NimbusForms.Rendering.DatePicker in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.DatePicker.pas',
  NimbusForms.Rendering.PopupMenu in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.PopupMenu.pas',
  NimbusForms.ColorPalettes.Catalog in '..\..\NimbusForms.Controls\src\NimbusForms.ColorPalettes.Catalog.pas',
  NimbusForms.Controls.KeyboardEdit in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.KeyboardEdit.pas',
  NimbusForms.Controls.PropertyGrid.Dialogs in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.PropertyGrid.Dialogs.pas',
  NimbusForms.Controls.Strings in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Strings.pas',
  NimbusForms.Demo.Host in 'Shared\NimbusForms.Demo.Host.pas',
  NimbusForms.Demo.Properties in 'Shared\NimbusForms.Demo.Properties.pas';

resourcestring
  SApplicationTitle = 'NimbusForms PropertyGrid';

var
  Demo: TDemoHostForm;
  Tabs: TThemedTabControl;
begin
  Application.Initialize; Application.Title := SApplicationTitle; Application.MainFormOnTaskbar := True;
  Demo := TDemoHostForm.CreateNew(nil);
  try
    Tabs := TThemedTabControl.Create(Demo); Tabs.Parent := Demo.Body; Tabs.Align := alClient; AddNimbusPropertyGridGallery(Tabs);
    ThemeManager.ApplyCurrent(Demo); Demo.ShowModal;
  finally Demo.Free; end;
end.

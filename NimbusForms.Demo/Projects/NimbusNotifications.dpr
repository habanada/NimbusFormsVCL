program NimbusNotifications;

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
  NimbusForms.Controls.NotificationBar.Types in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.NotificationBar.Types.pas',
  NimbusForms.Controls.NotificationBar in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.NotificationBar.pas',
  NimbusForms.Rendering.NotificationBar in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.NotificationBar.pas',
  NimbusForms.Rendering.Markdown in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Markdown.pas',
  NimbusForms.Controls.Button in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Button.pas',
  NimbusForms.Controls.IdeStatusBar in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.IdeStatusBar.pas',
  NimbusForms.Rendering.IdeStatusBar in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.IdeStatusBar.pas',
  NimbusForms.Controls.Panel in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.Panel.pas',
  NimbusForms.Controls.ThemedLabel in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ThemedLabel.pas',
  NimbusForms.Controls.RichEdit in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.RichEdit.pas',
  NimbusForms.Controls.ComboBox in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.ComboBox.pas',
  NimbusForms.Controls.TextBox in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.TextBox.pas',
  NimbusForms.Controls.TabControl in '..\..\NimbusForms.Controls\src\NimbusForms.Controls.TabControl.pas',
  NimbusForms.Menus.PopupMenu in '..\..\NimbusForms.Controls\src\NimbusForms.Menus.PopupMenu.pas',
  NimbusForms.Rendering.Types in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Types.pas',
  NimbusForms.Rendering.Canvas in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Canvas.pas',
  NimbusForms.Rendering.Button in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Button.pas',
  NimbusForms.Rendering.Panel in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Panel.pas',
  NimbusForms.Rendering.ThemedLabel in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ThemedLabel.pas',
  NimbusForms.Rendering.Markup in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.Markup.pas',
  NimbusForms.Rendering.RichEdit in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.RichEdit.pas',
  NimbusForms.Rendering.ComboBox in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.ComboBox.pas',
  NimbusForms.Rendering.TextBox in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.TextBox.pas',
  NimbusForms.Rendering.TabControl in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.TabControl.pas',
  NimbusForms.Rendering.PopupMenu in '..\..\NimbusForms.Controls\src\NimbusForms.Rendering.PopupMenu.pas',
  NimbusForms.Demo.Host in 'Shared\NimbusForms.Demo.Host.pas',
  NimbusForms.Demo.Notifications in 'Shared\NimbusForms.Demo.Notifications.pas',
  NimbusForms.Demo.Strings in 'Shared\NimbusForms.Demo.Strings.pas';

resourcestring
  SApplicationTitle = 'NimbusForms Notifications';

var
  Demo: TDemoHostForm;
  Panel: TNotificationBarDemo;
begin
  Application.Initialize; Application.Title := SApplicationTitle; Application.MainFormOnTaskbar := True;
  Demo := TDemoHostForm.CreateNew(nil);
  try
    Panel := TNotificationBarDemo.Create(Demo); Panel.Parent := Demo.Body; Panel.Align := alClient;
    ThemeManager.ApplyCurrent(Demo); Demo.ShowModal;
  finally Demo.Free; end;
end.

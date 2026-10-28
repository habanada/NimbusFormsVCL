program NimbusPopupMenuTests;

{$APPTYPE CONSOLE}

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Menus,
  NimbusForms.Menus.PopupMenu;

type
  EPopupInspected = class(Exception);
  TPopupProbe = class
  public
    Openings: Integer;
    FirstColor: COLORREF;
    procedure BeforePopup(Sender: TObject);
  end;

procedure Check(const Condition: Boolean; const Text: string);
begin
  if not Condition then raise Exception.Create(Text);
end;

function BackgroundColor(const Menu: HMENU): COLORREF;
var Info: TMenuInfo; Brush: TLogBrush;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := MIM_BACKGROUND;
  Check(GetMenuInfo(Menu, Info), 'menu information must be available before opening');
  Check(Info.hbrBack <> 0, 'themed background must be assigned on the first opening');
  Check(GetObject(Info.hbrBack, SizeOf(Brush), @Brush) = SizeOf(Brush), 'menu background must be a valid brush');
  Result := Brush.lbColor;
end;

procedure TPopupProbe.BeforePopup(Sender: TObject);
var Menu: TThemedPopupMenu; Color: COLORREF;
begin
  Menu := TThemedPopupMenu(Sender);
  Color := BackgroundColor(Menu.Handle);
  Check(BackgroundColor(Menu.Items[0].Handle) = Color, 'submenu must inherit the themed background');
  if Openings = 0 then FirstColor := Color
  else Check(Color = FirstColor, 'first and repeated openings must use the same background');
  Check(Assigned(Menu.Items[0].OnMeasureItem), 'measure hook must be installed before opening');
  Inc(Openings);
  raise EPopupInspected.Create('Popup inspected before entering the native menu loop');
end;

procedure PopupChecks;
var Menu: TThemedPopupMenu; Group, Item: TMenuItem; Probe: TPopupProbe; I: Integer;
begin
  Menu := TThemedPopupMenu.Create(nil);
  Probe := TPopupProbe.Create;
  try
    Group := TMenuItem.Create(Menu);
    Group.Caption := 'Submenu';
    Menu.Items.Add(Group);
    Item := TMenuItem.Create(Menu);
    Item.Caption := 'Command';
    Group.Add(Item);
    Menu.OnPopup := Probe.BeforePopup;
    for I := 1 to 3 do
    begin
      try
        Menu.Popup(0, 0);
        Check(False, 'inspection must stop before the native menu loop');
      except
        on E: EPopupInspected do ;
      end;
      Check(Probe.Openings = I, 'OnPopup must run once per opening');
      Check(not Assigned(Group.OnMeasureItem), 'measurement hook must be restored after cancellation');
      Check(not Assigned(Group.OnAdvancedDrawItem), 'drawing hook must be restored after cancellation');
      Check(not Assigned(Item.OnMeasureItem), 'submenu hook must be restored after cancellation');
    end;
  finally
    Menu.Free;
    Probe.Free;
  end;
end;

begin
  try
    Application.Initialize;
    PopupChecks;
    Writeln('Popup menu initialization checks passed');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.

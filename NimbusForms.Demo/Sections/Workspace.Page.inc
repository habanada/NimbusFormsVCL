procedure AddAdvancedNimbusHexDemo(const ATabs: TPageControl);
var
  LPage: TTabSheet;
  LDemo: TAdvancedHexDemo;
begin
  LPage := TTabSheet.Create(ATabs);
  LPage.PageControl := ATabs;
  LPage.Caption := 'HexEditor Workspace';
  LDemo := TAdvancedHexDemo.Create(LPage);
  LDemo.Parent := LPage;
  if ATabs is TThemedTabControl then TThemedTabControl(ATabs).SetTabClosable(LPage, False);
end;


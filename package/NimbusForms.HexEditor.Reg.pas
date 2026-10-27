unit NimbusForms.HexEditor.Reg;

interface

procedure Register;

implementation

uses
  System.Classes,
  NimbusForms.HexEditor.Control,
  NimbusForms.HexEditor.InspectorControl,
  NimbusForms.HexEditor.BookmarkList;

procedure Register;
begin
  RegisterComponents('NimbusForms', [TThemedHexEditor, TThemedHexInspector, TThemedHexBookmarkList]);
end;

end.

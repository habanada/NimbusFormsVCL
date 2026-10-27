unit NimbusForms.Grid.ExportIntf;

interface

uses
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions;

type
  IThemedGridDataExporter = interface
    ['{8C3A6E15-72B4-4D09-A1F8-0B5E9D2C7413}']
    function GetName: string;
    function Export(const AData: TThemedGridExportData; const AOptions: TThemedGridExportOptions): string;
    property Name: string read GetName;
  end;

implementation

end.

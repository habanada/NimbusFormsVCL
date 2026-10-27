unit NimbusForms.Grid.FormatConditionContext;

interface

uses
  System.Rtti,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.Column;

type
  TThemedGridFormatConditionContext = class
  private
    FGrid: TObject;
    FCell: TThemedGridCell;
    FColumn: TThemedGridColumn;
    FConditionColumn: TThemedGridColumn;
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FDataSourceIndex: Integer;
    FRowObject: TValue;
    FValue: TValue;
    FConditionValue: TValue;
  public
    property Grid: TObject read FGrid write FGrid;
    property Cell: TThemedGridCell read FCell write FCell;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property ConditionColumn: TThemedGridColumn read FConditionColumn write FConditionColumn;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property RowObject: TValue read FRowObject write FRowObject;
    property Value: TValue read FValue write FValue;
    property ConditionValue: TValue read FConditionValue write FConditionValue;
  end;

implementation

end.

unit NimbusForms.Grid.DataControllerIntf;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.TypInfo,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.FilterDescriptor;

type
  IThemedGridDataController = interface
    ['{2E8F5B3A-9D1C-4A67-B054-6C7D2E9F8A13}']
    function GetRowCount: Integer;
    function GetDataSource: TValue;
    function GetIsSorted: Boolean;
    function GetSortColumn: TThemedGridColumn;
    function GetSortDirection: TThemedGridSortDirection;
    function GetIsFiltered: Boolean;
    function GetFilters: TArray<TThemedGridFilterDescriptor>;
    function GetVersion: Integer;
    function GetCanMoveRows: Boolean;
    function GetCanAddRows: Boolean;
    function GetCanRemoveRows: Boolean;
    function GetRowObject(const ADataSourceIndex: Integer): TValue;
    function GetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn): TValue;
    procedure SetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn; const AValue: TValue);
    function GetValueType(const AColumn: TThemedGridColumn): PTypeInfo;
    function CanSetValue(const AColumn: TThemedGridColumn): Boolean;
    function MoveRow(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean;
    function CreateRowObject: TValue;
    function CloneRowState(const ADataSourceIndex: Integer): TValue;
    function AddRow(const AInsertBeforeDataSourceIndex: Integer; const ARowState: TValue): Integer;
    function RemoveRow(const ADataSourceIndex: Integer): Boolean;
    function GetDataSourceIndex(const AVisibleRowIndex: Integer): Integer;
    function GetVisibleRowIndex(const ADataSourceIndex: Integer): Integer;
    procedure ApplySort(const AColumn: TThemedGridColumn; const ADirection: TThemedGridSortDirection);
    procedure ClearSort;
    procedure ApplyFilter(const AFilter: TThemedGridFilterDescriptor);
    procedure ApplyFilters(const AFilters: array of TThemedGridFilterDescriptor);
    procedure ClearFilter(const AColumnName: string);
    procedure ClearFilters;
    procedure Refresh;
    property RowCount: Integer read GetRowCount;
    property DataSource: TValue read GetDataSource;
    property IsSorted: Boolean read GetIsSorted;
    property SortColumn: TThemedGridColumn read GetSortColumn;
    property SortDirection: TThemedGridSortDirection read GetSortDirection;
    property IsFiltered: Boolean read GetIsFiltered;
    property Filters: TArray<TThemedGridFilterDescriptor> read GetFilters;
    property Version: Integer read GetVersion;
    property CanMoveRows: Boolean read GetCanMoveRows;
    property CanAddRows: Boolean read GetCanAddRows;
    property CanRemoveRows: Boolean read GetCanRemoveRows;
  end;

  IThemedGridRowStateOwner = interface
    ['{B4A1D7E3-5C2F-4E98-8D06-3F7A9B1C2E54}']
    function GetOwnsRemovedRows: Boolean;
    procedure DisposeRowState(const ARowState: TValue);
    property OwnsRemovedRows: Boolean read GetOwnsRemovedRows;
  end;

implementation

end.

unit NimbusForms.Grid.Events.Rows;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  NimbusForms.Grid.Events;

type

  TThemedGridRowEventArgs = class(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FDataSourceIndex: Integer;
    FRowObject: TValue;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property RowObject: TValue read FRowObject write FRowObject;
  end;

  TThemedGridRowValidatingEventArgs = class sealed(TThemedGridRowEventArgs)
  private
    FCancel: Boolean;
    FErrorText: string;
  public
    property Cancel: Boolean read FCancel write FCancel;
    property ErrorText: string read FErrorText write FErrorText;
  end;

  TThemedGridRowAddingEventArgs = class sealed(TThemedGridEventArgs)
  private
    FInsertIndex: Integer;
    FTargetRowIndex: Integer;
    FRowObject: TValue;
    FCancel: Boolean;
  public
    property InsertIndex: Integer read FInsertIndex write FInsertIndex;
    property TargetRowIndex: Integer read FTargetRowIndex write FTargetRowIndex;
    property RowObject: TValue read FRowObject write FRowObject;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridRowAddedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FDataSourceIndex: Integer;
    FRowObject: TValue;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property RowObject: TValue read FRowObject write FRowObject;
  end;

  TThemedGridRowRemovingEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FDataSourceIndex: Integer;
    FRowObject: TValue;
    FRowCount: Integer;
    FCancel: Boolean;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property RowObject: TValue read FRowObject write FRowObject;
    property RowCount: Integer read FRowCount write FRowCount;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridRowRemovedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FDataSourceIndex: Integer;
    FRowObject: TValue;
    FRemovedRowCount: Integer;
  public
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property RowObject: TValue read FRowObject write FRowObject;
    property RemovedRowCount: Integer read FRemovedRowCount write FRemovedRowCount;
  end;

  TThemedGridRowMoveEventArgs = class(TThemedGridEventArgs)
  private
    FSourceRowIndex: Integer;
    FSourceDataSourceIndex: Integer;
    FTargetRowIndex: Integer;
    FTargetDataSourceIndex: Integer;
    FInsertIndex: Integer;
    FRowObject: TValue;
    FDropAfterTarget: Boolean;
  public
    property SourceRowIndex: Integer read FSourceRowIndex write FSourceRowIndex;
    property SourceDataSourceIndex: Integer read FSourceDataSourceIndex write FSourceDataSourceIndex;
    property TargetRowIndex: Integer read FTargetRowIndex write FTargetRowIndex;
    property TargetDataSourceIndex: Integer read FTargetDataSourceIndex write FTargetDataSourceIndex;
    property InsertIndex: Integer read FInsertIndex write FInsertIndex;
    property RowObject: TValue read FRowObject write FRowObject;
    property DropAfterTarget: Boolean read FDropAfterTarget write FDropAfterTarget;
  end;

  TThemedGridRowMovingEventArgs = class sealed(TThemedGridRowMoveEventArgs)
  private
    FCancel: Boolean;
  public
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridRowMovedEventArgs = class sealed(TThemedGridRowMoveEventArgs)
  private
    FNewDataSourceIndex: Integer;
  public
    property NewDataSourceIndex: Integer read FNewDataSourceIndex write FNewDataSourceIndex;
  end;

  TThemedGridRowEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowEventArgs) of object;
  TThemedGridRowValidatingEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowValidatingEventArgs) of object;
  TThemedGridRowAddingEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowAddingEventArgs) of object;
  TThemedGridRowAddedEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowAddedEventArgs) of object;
  TThemedGridRowRemovingEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowRemovingEventArgs) of object;
  TThemedGridRowRemovedEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowRemovedEventArgs) of object;
  TThemedGridRowMoveEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowMoveEventArgs) of object;
  TThemedGridRowMovingEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowMovingEventArgs) of object;
  TThemedGridRowMovedEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowMovedEventArgs) of object;

implementation

end.

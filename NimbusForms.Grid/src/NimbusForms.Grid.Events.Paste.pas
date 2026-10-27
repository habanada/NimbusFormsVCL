unit NimbusForms.Grid.Events.Paste;

{$SCOPEDENUMS ON}

interface

uses
  NimbusForms.Grid.Events;

type

  TThemedGridPasteEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FRowCount: Integer;
    FColumnCount: Integer;
    FText: string;
    FCancel: Boolean;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property RowCount: Integer read FRowCount write FRowCount;
    property ColumnCount: Integer read FColumnCount write FColumnCount;
    property Text: string read FText write FText;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridPasteCompletedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FAppliedCellCount: Integer;
    FSkippedCellCount: Integer;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property AppliedCellCount: Integer read FAppliedCellCount write FAppliedCellCount;
    property SkippedCellCount: Integer read FSkippedCellCount write FSkippedCellCount;
  end;

  TThemedGridPasteEvent = procedure(ASender: TObject; const AArgs: TThemedGridPasteEventArgs) of object;
  TThemedGridPasteCompletedEvent = procedure(ASender: TObject; const AArgs: TThemedGridPasteCompletedEventArgs) of object;

implementation

end.

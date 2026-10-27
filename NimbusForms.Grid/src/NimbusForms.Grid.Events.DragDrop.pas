unit NimbusForms.Grid.Events.DragDrop;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.Types,
  Winapi.ActiveX,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.Primitives;

type
  TThemedGridDragDropEffect = (Copy, Move, Link, Scroll);
  TThemedGridDragDropEffects = set of TThemedGridDragDropEffect;

  TThemedGridDragStartEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRange: TThemedGridCellRange;
    FRowCount: Integer;
    FColumnCount: Integer;
    FData: IDataObject;
    FAllowedEffects: TThemedGridDragDropEffects;
    FCancel: Boolean;
  public
    property Range: TThemedGridCellRange read FRange write FRange;
    property RowCount: Integer read FRowCount write FRowCount;
    property ColumnCount: Integer read FColumnCount write FColumnCount;
    property Data: IDataObject read FData write FData;
    property AllowedEffects: TThemedGridDragDropEffects read FAllowedEffects write FAllowedEffects;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridDragEventArgs = class(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FDataSourceIndex: Integer;
    FColumn: TThemedGridColumn;
    FRowObject: TValue;
    FLocation: TPoint;
    FData: IDataObject;
    FKeyState: Integer;
    FAllowedEffect: TThemedGridDragDropEffects;
    FEffect: TThemedGridDragDropEffects;
    FBlockRowCount: Integer;
    FBlockColumnCount: Integer;
    FIsInternalSource: Boolean;
    FIsValidTarget: Boolean;
    FHandled: Boolean;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property RowObject: TValue read FRowObject write FRowObject;
    property Location: TPoint read FLocation write FLocation;
    property Data: IDataObject read FData write FData;
    property KeyState: Integer read FKeyState write FKeyState;
    property AllowedEffect: TThemedGridDragDropEffects read FAllowedEffect write FAllowedEffect;
    property Effect: TThemedGridDragDropEffects read FEffect write FEffect;
    property BlockRowCount: Integer read FBlockRowCount write FBlockRowCount;
    property BlockColumnCount: Integer read FBlockColumnCount write FBlockColumnCount;
    property IsInternalSource: Boolean read FIsInternalSource write FIsInternalSource;
    property IsValidTarget: Boolean read FIsValidTarget write FIsValidTarget;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDropEventArgs = class sealed(TThemedGridDragEventArgs)
  public

  end;

  TThemedGridDropCompletedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FAppliedCellCount: Integer;
    FSkippedCellCount: Integer;
    FClearedCellCount: Integer;
    FEffect: TThemedGridDragDropEffects;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property AppliedCellCount: Integer read FAppliedCellCount write FAppliedCellCount;
    property SkippedCellCount: Integer read FSkippedCellCount write FSkippedCellCount;
    property ClearedCellCount: Integer read FClearedCellCount write FClearedCellCount;
    property Effect: TThemedGridDragDropEffects read FEffect write FEffect;
  end;

  TThemedGridDragStartEvent = procedure(ASender: TObject; const AArgs: TThemedGridDragStartEventArgs) of object;
  TThemedGridDragEvent = procedure(ASender: TObject; const AArgs: TThemedGridDragEventArgs) of object;
  TThemedGridDropEvent = procedure(ASender: TObject; const AArgs: TThemedGridDropEventArgs) of object;
  TThemedGridDropCompletedEvent = procedure(ASender: TObject; const AArgs: TThemedGridDropCompletedEventArgs) of object;

function ThemedGridEffectsToOle(const AEffects: TThemedGridDragDropEffects): Integer;
function ThemedGridEffectsFromOle(const AEffects: Integer): TThemedGridDragDropEffects;

implementation

function ThemedGridEffectsToOle(const AEffects: TThemedGridDragDropEffects): Integer;
begin
  Result := 0;
  if TThemedGridDragDropEffect.Copy in AEffects then
    Result := Result or DROPEFFECT_COPY;
  if TThemedGridDragDropEffect.Move in AEffects then
    Result := Result or DROPEFFECT_MOVE;
  if TThemedGridDragDropEffect.Link in AEffects then
    Result := Result or DROPEFFECT_LINK;
  if TThemedGridDragDropEffect.Scroll in AEffects then
    Result := Result or Integer(DROPEFFECT_SCROLL);
end;

function ThemedGridEffectsFromOle(const AEffects: Integer): TThemedGridDragDropEffects;
begin
  Result := [];
  if (AEffects and DROPEFFECT_COPY) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Copy);
  if (AEffects and DROPEFFECT_MOVE) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Move);
  if (AEffects and DROPEFFECT_LINK) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Link);
  if (AEffects and Integer(DROPEFFECT_SCROLL)) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Scroll);
end;

end.

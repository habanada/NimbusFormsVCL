unit NimbusForms.Grid.Events.Undo;

interface

uses
  NimbusForms.Grid.Events,
  NimbusForms.Grid.UndoTypes;

type
  TThemedGridUndoEventArgs = class sealed(TThemedGridEventArgs)
  private
    FUnit: TThemedGridUndoUnit;
    FIsRedo: Boolean;
    FAppliedCellCount: Integer;
    FSkippedCellCount: Integer;
  public
    constructor Create(const AUnit: TThemedGridUndoUnit; const AIsRedo: Boolean);
    property UndoUnit: TThemedGridUndoUnit read FUnit;
    property IsRedo: Boolean read FIsRedo;
    property AppliedCellCount: Integer read FAppliedCellCount write FAppliedCellCount;
    property SkippedCellCount: Integer read FSkippedCellCount write FSkippedCellCount;
  end;

  TThemedGridUndoEvent = procedure(ASender: TObject; const AArgs: TThemedGridUndoEventArgs) of object;

implementation

constructor TThemedGridUndoEventArgs.Create(const AUnit: TThemedGridUndoUnit; const AIsRedo: Boolean);
begin
  inherited Create;
  FUnit := AUnit;
  FIsRedo := AIsRedo;
end;

end.

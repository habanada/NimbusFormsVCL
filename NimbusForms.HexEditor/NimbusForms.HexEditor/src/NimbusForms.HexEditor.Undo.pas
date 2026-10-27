unit NimbusForms.HexEditor.Undo;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.DataSource;

type
  TEditKind = (ekOverwrite, ekInsert, ekDelete);

  TEditCommand = class
  private
    FKind: TEditKind;
    FOffset: Int64;
    FOldData: TBytes;
    FNewData: TBytes;
  public
    constructor Create(const AKind: TEditKind; const AOffset: Int64;
      const AOldData, ANewData: TBytes);
    property Kind: TEditKind read FKind;
    property Offset: Int64 read FOffset;
    property OldData: TBytes read FOldData;
    property NewData: TBytes read FNewData;
  end;

  TUndoManager = class
  private
    FUndo: TObjectList<TEditCommand>;
    FRedo: TObjectList<TEditCommand>;
    function GetCanUndo: Boolean;
    function GetCanRedo: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Push(const ACommand: TEditCommand);
    function UndoCommands: TArray<TEditCommand>;
    function PopUndo: TEditCommand;
    function PopRedo: TEditCommand;
    procedure PushRedo(const ACommand: TEditCommand);
    procedure Clear;
    property CanUndo: Boolean read GetCanUndo;
    property CanRedo: Boolean read GetCanRedo;
  end;

implementation

constructor TEditCommand.Create(const AKind: TEditKind; const AOffset: Int64;
  const AOldData, ANewData: TBytes);
begin
  inherited Create;
  FKind := AKind;
  FOffset := AOffset;
  FOldData := Copy(AOldData, 0, Length(AOldData));
  FNewData := Copy(ANewData, 0, Length(ANewData));
end;

constructor TUndoManager.Create;
begin
  inherited Create;
  FUndo := TObjectList<TEditCommand>.Create(True);
  FRedo := TObjectList<TEditCommand>.Create(True);
end;

destructor TUndoManager.Destroy;
begin
  FUndo.Free;
  FRedo.Free;
  inherited Destroy;
end;

function TUndoManager.GetCanUndo: Boolean;
begin
  Result := FUndo.Count > 0;
end;

function TUndoManager.GetCanRedo: Boolean;
begin
  Result := FRedo.Count > 0;
end;

procedure TUndoManager.Push(const ACommand: TEditCommand);
begin
  FUndo.Add(ACommand);
  FRedo.Clear;
end;

function TUndoManager.UndoCommands: TArray<TEditCommand>;
begin
  Result := FUndo.ToArray;
end;

function TUndoManager.PopUndo: TEditCommand;
begin
  if FUndo.Count = 0 then
    Exit(nil);
  Result := FUndo.Extract(FUndo.Last);
end;

function TUndoManager.PopRedo: TEditCommand;
begin
  if FRedo.Count = 0 then
    Exit(nil);
  Result := FRedo.Extract(FRedo.Last);
end;

procedure TUndoManager.PushRedo(const ACommand: TEditCommand);
begin
  FRedo.Add(ACommand);
end;

procedure TUndoManager.Clear;
begin
  FUndo.Clear;
  FRedo.Clear;
end;

end.

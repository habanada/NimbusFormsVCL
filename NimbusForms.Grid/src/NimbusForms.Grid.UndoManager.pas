unit NimbusForms.Grid.UndoManager;

interface

uses
  System.Classes,
  System.Generics.Collections,
  NimbusForms.Grid.UndoTypes;

type
  TThemedGridUndoManager = class
  private
    FUndoUnits: TObjectList<TThemedGridUndoUnit>;
    FRedoUnits: TObjectList<TThemedGridUndoUnit>;
    FOpenUnit: TThemedGridUndoUnit;
    FTransactionDepth: Integer;
    FSuspendCount: Integer;
    FMaxDepth: Integer;
    FOnChanged: TNotifyEvent;
    procedure SetMaxDepth(const AValue: Integer);
    function GetIsSuspended: Boolean;
    function GetIsTransactionOpen: Boolean;
    function GetCanUndo: Boolean;
    function GetCanRedo: Boolean;
    function GetUndoCount: Integer;
    function GetRedoCount: Integer;
    function ResolveName(const AName: string): string;
    procedure PushUndoUnit(const AUnit: TThemedGridUndoUnit; const AClearRedo: Boolean);
    procedure TrimUndoUnits;
    procedure DoChanged;
  public
    constructor Create;
    destructor Destroy; override;
    function PeekUndoName: string;
    function PeekRedoName: string;
    procedure Suspend;
    procedure Resume;
    procedure BeginTransaction(const AName: string);
    procedure EndTransaction;
    procedure CancelTransaction;
    procedure RecordChange(const AChange: TThemedGridUndoCellChange; const AName: string);
    procedure RecordRowMove(const ARowMove: TThemedGridUndoRowMove; const AName: string);
    procedure RecordRowAction(const ARowAction: TThemedGridUndoRowAction; const AName: string);
    function PopUndo: TThemedGridUndoUnit;
    function PopRedo: TThemedGridUndoUnit;
    procedure PushUndo(const AUnit: TThemedGridUndoUnit);
    procedure PushRedo(const AUnit: TThemedGridUndoUnit);
    procedure TruncateUndo(const ACount: Integer);
    procedure Clear;
    procedure NotifyChanged;
    property MaxDepth: Integer read FMaxDepth write SetMaxDepth;
    property IsSuspended: Boolean read GetIsSuspended;
    property IsTransactionOpen: Boolean read GetIsTransactionOpen;
    property CanUndo: Boolean read GetCanUndo;
    property CanRedo: Boolean read GetCanRedo;
    property UndoCount: Integer read GetUndoCount;
    property RedoCount: Integer read GetRedoCount;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

uses
  System.SysUtils,
  NimbusForms.Grid.UndoOptions,
  NimbusForms.Grid.UndoStrings;

constructor TThemedGridUndoManager.Create;
begin
  inherited Create;
  FUndoUnits := TObjectList<TThemedGridUndoUnit>.Create(True);
  FRedoUnits := TObjectList<TThemedGridUndoUnit>.Create(True);
  FMaxDepth := CThemedGridUndoDefaultMaxDepth;
end;

destructor TThemedGridUndoManager.Destroy;
begin
  FOpenUnit.Free;
  FRedoUnits.Free;
  FUndoUnits.Free;
  inherited Destroy;
end;

procedure TThemedGridUndoManager.SetMaxDepth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < CThemedGridUndoMinimumMaxDepth then
    LValue := CThemedGridUndoMinimumMaxDepth;
  if FMaxDepth = LValue then Exit;
  FMaxDepth := LValue;
  TrimUndoUnits;
end;

function TThemedGridUndoManager.GetIsSuspended: Boolean;
begin
  Result := FSuspendCount > 0;
end;

function TThemedGridUndoManager.GetIsTransactionOpen: Boolean;
begin
  Result := FTransactionDepth > 0;
end;

function TThemedGridUndoManager.GetCanUndo: Boolean;
begin
  Result := FUndoUnits.Count > 0;
end;

function TThemedGridUndoManager.GetCanRedo: Boolean;
begin
  Result := FRedoUnits.Count > 0;
end;

function TThemedGridUndoManager.GetUndoCount: Integer;
begin
  Result := FUndoUnits.Count;
end;

function TThemedGridUndoManager.GetRedoCount: Integer;
begin
  Result := FRedoUnits.Count;
end;

function TThemedGridUndoManager.ResolveName(const AName: string): string;
begin
  if AName = '' then
    Result := TThemedGridUndoStrings.UnitNameDefault
  else
    Result := AName;
end;

function TThemedGridUndoManager.PeekUndoName: string;
begin
  if FUndoUnits.Count > 0 then
    Result := FUndoUnits[FUndoUnits.Count - 1].Name
  else
    Result := '';
end;

function TThemedGridUndoManager.PeekRedoName: string;
begin
  if FRedoUnits.Count > 0 then
    Result := FRedoUnits[FRedoUnits.Count - 1].Name
  else
    Result := '';
end;

procedure TThemedGridUndoManager.Suspend;
begin
  Inc(FSuspendCount);
end;

procedure TThemedGridUndoManager.Resume;
begin
  if FSuspendCount > 0 then
    Dec(FSuspendCount);
end;

procedure TThemedGridUndoManager.BeginTransaction(const AName: string);
begin
  Inc(FTransactionDepth);
  if FTransactionDepth > 1 then
    Exit;
  FOpenUnit.Free;
  FOpenUnit := TThemedGridUndoUnit.Create(ResolveName(AName));
end;

procedure TThemedGridUndoManager.EndTransaction;
var
  LUnit: TThemedGridUndoUnit;
begin
  if FTransactionDepth <= 0 then
    Exit;
  Dec(FTransactionDepth);
  if FTransactionDepth > 0 then
    Exit;
  LUnit := FOpenUnit;
  FOpenUnit := nil;
  if LUnit = nil then
    Exit;
  if LUnit.Count = 0 then
  begin
    LUnit.Free;
    Exit;
  end;
  PushUndoUnit(LUnit, True);
end;

procedure TThemedGridUndoManager.CancelTransaction;
begin
  FTransactionDepth := 0;
  FreeAndNil(FOpenUnit);
end;

procedure TThemedGridUndoManager.RecordChange(const AChange: TThemedGridUndoCellChange; const AName: string);
var
  LUnit: TThemedGridUndoUnit;
begin
  if AChange = nil then
    Exit;
  if FSuspendCount > 0 then
  begin
    AChange.Free;
    Exit;
  end;
  if FOpenUnit <> nil then
  begin
    FOpenUnit.Add(AChange);
    Exit;
  end;
  LUnit := TThemedGridUndoUnit.Create(ResolveName(AName));
  LUnit.Add(AChange);
  PushUndoUnit(LUnit, True);
end;

procedure TThemedGridUndoManager.RecordRowMove(const ARowMove: TThemedGridUndoRowMove; const AName: string);
var
  LUnit: TThemedGridUndoUnit;
begin
  if ARowMove = nil then
    Exit;
  if FSuspendCount > 0 then
  begin
    ARowMove.Free;
    Exit;
  end;
  if FOpenUnit <> nil then
  begin
    FOpenUnit.Add(ARowMove);
    Exit;
  end;
  LUnit := TThemedGridUndoUnit.Create(ResolveName(AName));
  LUnit.Add(ARowMove);
  PushUndoUnit(LUnit, True);
end;

procedure TThemedGridUndoManager.RecordRowAction(const ARowAction: TThemedGridUndoRowAction; const AName: string);
var
  LUnit: TThemedGridUndoUnit;
begin
  if ARowAction = nil then
    Exit;
  if FSuspendCount > 0 then
  begin
    ARowAction.Free;
    Exit;
  end;
  if FOpenUnit <> nil then
  begin
    FOpenUnit.Add(ARowAction);
    Exit;
  end;
  LUnit := TThemedGridUndoUnit.Create(ResolveName(AName));
  LUnit.Add(ARowAction);
  PushUndoUnit(LUnit, True);
end;

function TThemedGridUndoManager.PopUndo: TThemedGridUndoUnit;
begin
  if FUndoUnits.Count = 0 then
    Exit(nil);
  Result := FUndoUnits.Extract(FUndoUnits[FUndoUnits.Count - 1]);
end;

function TThemedGridUndoManager.PopRedo: TThemedGridUndoUnit;
begin
  if FRedoUnits.Count = 0 then
    Exit(nil);
  Result := FRedoUnits.Extract(FRedoUnits[FRedoUnits.Count - 1]);
end;

procedure TThemedGridUndoManager.PushRedo(const AUnit: TThemedGridUndoUnit);
begin
  if AUnit = nil then
    Exit;
  FRedoUnits.Add(AUnit);
  DoChanged;
end;

procedure TThemedGridUndoManager.PushUndo(const AUnit: TThemedGridUndoUnit);
begin
  PushUndoUnit(AUnit, False);
end;

procedure TThemedGridUndoManager.TruncateUndo(const ACount: Integer);
var
  LChanged: Boolean;
begin
  LChanged := False;
  while FUndoUnits.Count > ACount do
  begin
    FUndoUnits.Delete(FUndoUnits.Count - 1);
    LChanged := True;
  end;
  if LChanged then
    DoChanged;
end;

procedure TThemedGridUndoManager.Clear;
var
  LHadContent: Boolean;
begin
  LHadContent := (FUndoUnits.Count > 0) or (FRedoUnits.Count > 0) or (FOpenUnit <> nil);
  FUndoUnits.Clear;
  FRedoUnits.Clear;
  FreeAndNil(FOpenUnit);
  FTransactionDepth := 0;
  if LHadContent then
    DoChanged;
end;

procedure TThemedGridUndoManager.NotifyChanged;
begin
  DoChanged;
end;

procedure TThemedGridUndoManager.PushUndoUnit(const AUnit: TThemedGridUndoUnit; const AClearRedo: Boolean);
begin
  if AUnit = nil then
    Exit;
  if AUnit.Count = 0 then
  begin
    AUnit.Free;
    Exit;
  end;
  FUndoUnits.Add(AUnit);
  if AClearRedo then
    FRedoUnits.Clear;
  TrimUndoUnits;
  DoChanged;
end;

procedure TThemedGridUndoManager.TrimUndoUnits;
begin
  while FUndoUnits.Count > FMaxDepth do
    FUndoUnits.Delete(0);
end;

procedure TThemedGridUndoManager.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

end.

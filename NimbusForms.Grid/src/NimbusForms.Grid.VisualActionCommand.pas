unit NimbusForms.Grid.VisualActionCommand;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  NimbusForms.Grid.Events.Visual;

type
  TThemedGridVisualActionHandler = reference to procedure(ASender: TObject;
    const AArgs: TThemedGridVisualActionEventArgs);

  TThemedGridVisualActionCommand = class
  private
    FKey: string;
    FEnabled: Boolean;
    FClickHandlers: TList<TThemedGridVisualActionHandler>;
    FDoubleClickHandlers: TList<TThemedGridVisualActionHandler>;
  public
    constructor Create(const AKey: string);
    destructor Destroy; override;
    procedure AddClick(const AHandler: TThemedGridVisualActionHandler);
    procedure AddDoubleClick(const AHandler: TThemedGridVisualActionHandler);
    procedure RaiseClick(const ASender: TObject; const AArgs: TThemedGridVisualActionEventArgs);
    procedure RaiseDoubleClick(const ASender: TObject; const AArgs: TThemedGridVisualActionEventArgs);
    property Key: string read FKey;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TThemedGridVisualActionCommandCollection = class
  private
    FCommands: TObjectDictionary<string, TThemedGridVisualActionCommand>;
    function GetCount: Integer;
    function GetItem(const AKey: string): TThemedGridVisualActionCommand;
    function ResolveCommand(const AArgs: TThemedGridVisualActionEventArgs): TThemedGridVisualActionCommand;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AKey: string): TThemedGridVisualActionCommand; overload;
    function Add(const AKey: string; const AClick: TThemedGridVisualActionHandler): TThemedGridVisualActionCommand; overload;
    function Add(const AKey: string; const AClick, ADoubleClick: TThemedGridVisualActionHandler): TThemedGridVisualActionCommand; overload;
    function Contains(const AKey: string): Boolean;
    function Remove(const AKey: string): Boolean;
    procedure Clear;
    function ExecuteClick(const ASender: TObject; const AArgs: TThemedGridVisualActionEventArgs): Boolean;
    function ExecuteDoubleClick(const ASender: TObject; const AArgs: TThemedGridVisualActionEventArgs): Boolean;
    property Count: Integer read GetCount;
    property Items[const AKey: string]: TThemedGridVisualActionCommand read GetItem; default;
  end;

implementation

uses
  NimbusForms.Grid.VisualStrings;

constructor TThemedGridVisualActionCommand.Create(const AKey: string);
begin
  inherited Create;
  FKey := AKey;
  FEnabled := True;
  FClickHandlers := TList<TThemedGridVisualActionHandler>.Create;
  FDoubleClickHandlers := TList<TThemedGridVisualActionHandler>.Create;
end;

destructor TThemedGridVisualActionCommand.Destroy;
begin
  FDoubleClickHandlers.Free;
  FClickHandlers.Free;
  inherited Destroy;
end;

procedure TThemedGridVisualActionCommand.AddClick(const AHandler: TThemedGridVisualActionHandler);
begin
  if Assigned(AHandler) then
    FClickHandlers.Add(AHandler);
end;

procedure TThemedGridVisualActionCommand.AddDoubleClick(const AHandler: TThemedGridVisualActionHandler);
begin
  if Assigned(AHandler) then
    FDoubleClickHandlers.Add(AHandler);
end;

procedure TThemedGridVisualActionCommand.RaiseClick(const ASender: TObject;
  const AArgs: TThemedGridVisualActionEventArgs);
var
  LHandlers: TArray<TThemedGridVisualActionHandler>;
  LHandler: TThemedGridVisualActionHandler;
begin
  if not FEnabled then
    Exit;
  LHandlers := FClickHandlers.ToArray;
  for LHandler in LHandlers do
    LHandler(ASender, AArgs);
end;

procedure TThemedGridVisualActionCommand.RaiseDoubleClick(const ASender: TObject;
  const AArgs: TThemedGridVisualActionEventArgs);
var
  LHandlers: TArray<TThemedGridVisualActionHandler>;
  LHandler: TThemedGridVisualActionHandler;
begin
  if not FEnabled then
    Exit;
  LHandlers := FDoubleClickHandlers.ToArray;
  for LHandler in LHandlers do
    LHandler(ASender, AArgs);
end;

constructor TThemedGridVisualActionCommandCollection.Create;
begin
  inherited Create;
  FCommands := TObjectDictionary<string, TThemedGridVisualActionCommand>.Create([doOwnsValues],
    TIStringComparer.Ordinal);
end;

destructor TThemedGridVisualActionCommandCollection.Destroy;
begin
  FCommands.Free;
  inherited Destroy;
end;

function TThemedGridVisualActionCommandCollection.GetCount: Integer;
begin
  Result := FCommands.Count;
end;

function TThemedGridVisualActionCommandCollection.GetItem(const AKey: string): TThemedGridVisualActionCommand;
begin
  if (AKey = '') or not FCommands.TryGetValue(AKey, Result) then
    Result := nil;
end;

function TThemedGridVisualActionCommandCollection.Add(const AKey: string): TThemedGridVisualActionCommand;
begin
  if AKey = '' then
    raise EArgumentException.Create(ThemedGridVisualStrings.ErrActionKeyRequired);
  if not FCommands.TryGetValue(AKey, Result) then
  begin
    Result := TThemedGridVisualActionCommand.Create(AKey);
    FCommands.Add(AKey, Result);
  end;
end;

function TThemedGridVisualActionCommandCollection.Add(const AKey: string;
  const AClick: TThemedGridVisualActionHandler): TThemedGridVisualActionCommand;
begin
  Result := Add(AKey);
  Result.AddClick(AClick);
end;

function TThemedGridVisualActionCommandCollection.Add(const AKey: string; const AClick,
  ADoubleClick: TThemedGridVisualActionHandler): TThemedGridVisualActionCommand;
begin
  Result := Add(AKey);
  Result.AddClick(AClick);
  Result.AddDoubleClick(ADoubleClick);
end;

function TThemedGridVisualActionCommandCollection.Contains(const AKey: string): Boolean;
begin
  Result := (AKey <> '') and FCommands.ContainsKey(AKey);
end;

function TThemedGridVisualActionCommandCollection.Remove(const AKey: string): Boolean;
begin
  Result := (AKey <> '') and FCommands.ContainsKey(AKey);
  if Result then
    FCommands.Remove(AKey);
end;

procedure TThemedGridVisualActionCommandCollection.Clear;
begin
  FCommands.Clear;
end;

function TThemedGridVisualActionCommandCollection.ResolveCommand(
  const AArgs: TThemedGridVisualActionEventArgs): TThemedGridVisualActionCommand;
var
  LKey: string;
begin
  Result := nil;
  if AArgs = nil then
    Exit;
  LKey := AArgs.ActionKey;
  if (LKey = '') or not FCommands.TryGetValue(LKey, Result) then
    Result := nil;
end;

function TThemedGridVisualActionCommandCollection.ExecuteClick(const ASender: TObject;
  const AArgs: TThemedGridVisualActionEventArgs): Boolean;
var
  LCommand: TThemedGridVisualActionCommand;
begin
  LCommand := ResolveCommand(AArgs);
  if (LCommand = nil) or not LCommand.Enabled then
    Exit(False);
  LCommand.RaiseClick(ASender, AArgs);
  Result := (AArgs <> nil) and AArgs.Handled;
end;

function TThemedGridVisualActionCommandCollection.ExecuteDoubleClick(const ASender: TObject;
  const AArgs: TThemedGridVisualActionEventArgs): Boolean;
var
  LCommand: TThemedGridVisualActionCommand;
begin
  LCommand := ResolveCommand(AArgs);
  if (LCommand = nil) or not LCommand.Enabled then
    Exit(False);
  LCommand.RaiseDoubleClick(ASender, AArgs);
  Result := (AArgs <> nil) and AArgs.Handled;
end;

end.

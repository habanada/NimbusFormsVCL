unit NimbusForms.Grid.DetailRelationCollection;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.DetailRelation;

type
  TThemedGridDetailRelationCollection = class
  private
    FItems: TObjectList<TThemedGridDetailRelation>;
    FChangedCallback: TProc;
    function GetItem(const AIndex: Integer): TThemedGridDetailRelation;
    procedure SetItem(const AIndex: Integer; const AValue: TThemedGridDetailRelation);
    function GetCount: Integer;
    procedure DoChanged;
  public
    constructor Create; overload;
    constructor Create(const AChangedCallback: TProc); overload;
    destructor Destroy; override;
    procedure Add(const AItem: TThemedGridDetailRelation); overload;
    function Add(const AName: string): TThemedGridDetailRelation; overload;
    function Add(const AName, ACaption: string): TThemedGridDetailRelation; overload;
    function FindByName(const AName: string): TThemedGridDetailRelation;
    procedure Insert(const AIndex: Integer; const AItem: TThemedGridDetailRelation);
    function Remove(const AItem: TThemedGridDetailRelation): Boolean;
    procedure RemoveAt(const AIndex: Integer);
    procedure Clear;
    function Contains(const AItem: TThemedGridDetailRelation): Boolean;
    function IndexOf(const AItem: TThemedGridDetailRelation): Integer;
    function GetEnumerator: TEnumerator<TThemedGridDetailRelation>;
    property Items[const AIndex: Integer]: TThemedGridDetailRelation read GetItem write SetItem; default;
    property Count: Integer read GetCount;
  end;

implementation

constructor TThemedGridDetailRelationCollection.Create;
begin
  Create(nil);
end;

constructor TThemedGridDetailRelationCollection.Create(const AChangedCallback: TProc);
begin
  inherited Create;
  FItems := TObjectList<TThemedGridDetailRelation>.Create(True);
  FChangedCallback := AChangedCallback;
end;

destructor TThemedGridDetailRelationCollection.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TThemedGridDetailRelationCollection.DoChanged;
begin
  if Assigned(FChangedCallback) then
    FChangedCallback();
end;

function TThemedGridDetailRelationCollection.GetItem(const AIndex: Integer): TThemedGridDetailRelation;
begin
  Result := FItems[AIndex];
end;

procedure TThemedGridDetailRelationCollection.SetItem(const AIndex: Integer;
  const AValue: TThemedGridDetailRelation);
begin
  if FItems[AIndex] = AValue then
    Exit;
  if (AValue <> nil) and (FItems.IndexOf(AValue) >= 0) then
    Exit;
  FItems[AIndex] := AValue;
  DoChanged;
end;

function TThemedGridDetailRelationCollection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TThemedGridDetailRelationCollection.Add(const AItem: TThemedGridDetailRelation);
begin
  Insert(FItems.Count, AItem);
end;

function TThemedGridDetailRelationCollection.Add(const AName: string): TThemedGridDetailRelation;
begin
  Result := Add(AName, AName);
end;

function TThemedGridDetailRelationCollection.Add(const AName, ACaption: string): TThemedGridDetailRelation;
begin
  Result := TThemedGridDetailRelation.Create(AName, ACaption);
  Add(Result);
end;

function TThemedGridDetailRelationCollection.FindByName(const AName: string): TThemedGridDetailRelation;
var
  I: Integer;
begin
  if AName = '' then
    Exit(nil);
  for I := 0 to FItems.Count - 1 do
    if (FItems[I] <> nil) and (FItems[I].Name = AName) then
      Exit(FItems[I]);
  Result := nil;
end;

procedure TThemedGridDetailRelationCollection.Insert(const AIndex: Integer;
  const AItem: TThemedGridDetailRelation);
begin
  if AItem = nil then
    Exit;
  if FItems.IndexOf(AItem) >= 0 then
    Exit;
  FItems.Insert(AIndex, AItem);
  DoChanged;
end;

function TThemedGridDetailRelationCollection.Remove(const AItem: TThemedGridDetailRelation): Boolean;
var
  LIndex: Integer;
begin
  LIndex := FItems.IndexOf(AItem);
  if LIndex < 0 then
    Exit(False);
  RemoveAt(LIndex);
  Result := True;
end;

procedure TThemedGridDetailRelationCollection.RemoveAt(const AIndex: Integer);
begin
  FItems.Delete(AIndex);
  DoChanged;
end;

procedure TThemedGridDetailRelationCollection.Clear;
begin
  FItems.Clear;
  DoChanged;
end;

function TThemedGridDetailRelationCollection.Contains(const AItem: TThemedGridDetailRelation): Boolean;
begin
  Result := FItems.IndexOf(AItem) >= 0;
end;

function TThemedGridDetailRelationCollection.IndexOf(const AItem: TThemedGridDetailRelation): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

function TThemedGridDetailRelationCollection.GetEnumerator: TEnumerator<TThemedGridDetailRelation>;
begin
  Result := FItems.GetEnumerator;
end;

end.

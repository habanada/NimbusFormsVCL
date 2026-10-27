unit NimbusForms.Grid.GroupDescriptorCollection;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.GroupDescriptor;

type
  TThemedGridGroupDescriptorCollection = class
  private
    FItems: TObjectList<TThemedGridGroupDescriptor>;
    FUpdateCount: Integer;
    FChanged: Boolean;
    FOnChanged: TNotifyEvent;
    function GetItem(const AIndex: Integer): TThemedGridGroupDescriptor;
    procedure SetItem(const AIndex: Integer; const AValue: TThemedGridGroupDescriptor);
    function GetCount: Integer;
    procedure Attach(const AItem: TThemedGridGroupDescriptor);
    procedure Detach(const AItem: TThemedGridGroupDescriptor);
    procedure ItemChanged(ASender: TObject);
    procedure RaiseChanged;
    procedure DoChanged;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Add(const AItem: TThemedGridGroupDescriptor); overload;
    function Add(const AColumnName: string): TThemedGridGroupDescriptor; overload;
    procedure Insert(const AIndex: Integer; const AItem: TThemedGridGroupDescriptor);
    function Remove(const AItem: TThemedGridGroupDescriptor): Boolean;
    procedure RemoveAt(const AIndex: Integer);
    procedure Clear;
    function Contains(const AItem: TThemedGridGroupDescriptor): Boolean;
    function IndexOf(const AItem: TThemedGridGroupDescriptor): Integer;
    function GetEnumerator: TEnumerator<TThemedGridGroupDescriptor>;
    property Items[const AIndex: Integer]: TThemedGridGroupDescriptor read GetItem write SetItem; default;
    property Count: Integer read GetCount;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridGroupDescriptorCollection.Create;
begin
  inherited Create;
  FItems := TObjectList<TThemedGridGroupDescriptor>.Create(True);
end;

destructor TThemedGridGroupDescriptorCollection.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Detach(FItems[I]);
  FItems.Free;
  inherited Destroy;
end;

function TThemedGridGroupDescriptorCollection.GetItem(const AIndex: Integer): TThemedGridGroupDescriptor;
begin
  Result := FItems[AIndex];
end;

procedure TThemedGridGroupDescriptorCollection.SetItem(const AIndex: Integer;
  const AValue: TThemedGridGroupDescriptor);
var
  LOld: TThemedGridGroupDescriptor;
begin
  LOld := FItems[AIndex];
  if LOld = AValue then
    Exit;
  if (AValue <> nil) and (FItems.IndexOf(AValue) >= 0) then
    Exit;
  Detach(LOld);
  FItems[AIndex] := AValue;
  Attach(AValue);
  RaiseChanged;
end;

function TThemedGridGroupDescriptorCollection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TThemedGridGroupDescriptorCollection.Attach(const AItem: TThemedGridGroupDescriptor);
begin
  if AItem <> nil then
    AItem.OnChanged := ItemChanged;
end;

procedure TThemedGridGroupDescriptorCollection.Detach(const AItem: TThemedGridGroupDescriptor);
begin
  if AItem <> nil then
    AItem.OnChanged := nil;
end;

procedure TThemedGridGroupDescriptorCollection.ItemChanged(ASender: TObject);
begin
  RaiseChanged;
end;

procedure TThemedGridGroupDescriptorCollection.RaiseChanged;
begin
  if FUpdateCount > 0 then
  begin
    FChanged := True;
    Exit;
  end;
  DoChanged;
end;

procedure TThemedGridGroupDescriptorCollection.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridGroupDescriptorCollection.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TThemedGridGroupDescriptorCollection.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);
  if (FUpdateCount = 0) and FChanged then
  begin
    FChanged := False;
    DoChanged;
  end;
end;

procedure TThemedGridGroupDescriptorCollection.Add(const AItem: TThemedGridGroupDescriptor);
begin
  Insert(FItems.Count, AItem);
end;

function TThemedGridGroupDescriptorCollection.Add(const AColumnName: string): TThemedGridGroupDescriptor;
begin
  Result := TThemedGridGroupDescriptor.Create(AColumnName);
  Add(Result);
end;

procedure TThemedGridGroupDescriptorCollection.Insert(const AIndex: Integer;
  const AItem: TThemedGridGroupDescriptor);
begin
  if AItem = nil then
    Exit;
  if FItems.IndexOf(AItem) >= 0 then
    Exit;
  FItems.Insert(AIndex, AItem);
  Attach(AItem);
  RaiseChanged;
end;

function TThemedGridGroupDescriptorCollection.Remove(const AItem: TThemedGridGroupDescriptor): Boolean;
var
  LIndex: Integer;
begin
  LIndex := FItems.IndexOf(AItem);
  if LIndex < 0 then
    Exit(False);
  RemoveAt(LIndex);
  Result := True;
end;

procedure TThemedGridGroupDescriptorCollection.RemoveAt(const AIndex: Integer);
begin
  Detach(FItems[AIndex]);
  FItems.Delete(AIndex);
  RaiseChanged;
end;

procedure TThemedGridGroupDescriptorCollection.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Detach(FItems[I]);
  FItems.Clear;
  RaiseChanged;
end;

function TThemedGridGroupDescriptorCollection.Contains(const AItem: TThemedGridGroupDescriptor): Boolean;
begin
  Result := FItems.IndexOf(AItem) >= 0;
end;

function TThemedGridGroupDescriptorCollection.IndexOf(const AItem: TThemedGridGroupDescriptor): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

function TThemedGridGroupDescriptorCollection.GetEnumerator: TEnumerator<TThemedGridGroupDescriptor>;
begin
  Result := FItems.GetEnumerator;
end;

end.

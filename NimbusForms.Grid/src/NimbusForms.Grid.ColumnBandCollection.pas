unit NimbusForms.Grid.ColumnBandCollection;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.ColumnBand;

type
  TThemedGridColumnBandCollection = class
  private
    FItems: TObjectList<TThemedGridColumnBand>;
    FOnChanged: TNotifyEvent;
    procedure Attach(const ABand: TThemedGridColumnBand);
    procedure Detach(const ABand: TThemedGridColumnBand);
    procedure BandChanged(ASender: TObject);
    procedure NormalizeDisplayIndexes;
    function CreateDefaultName: string;
    procedure DoChanged;
    function GetItem(const AIndex: Integer): TThemedGridColumnBand;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const ABand: TThemedGridColumnBand): TThemedGridColumnBand; overload;
    function Add(const AName, AText: string): TThemedGridColumnBand; overload;
    procedure RemoveAt(const AIndex: Integer);
    function Remove(const ABand: TThemedGridColumnBand): Boolean;
    procedure Clear;
    function Contains(const AName: string): Boolean;
    function FindByName(const AName: string): TThemedGridColumnBand;
    function GetVisibleBands: TList<TThemedGridColumnBand>;
    property Items[const AIndex: Integer]: TThemedGridColumnBand read GetItem; default;
    property Count: Integer read GetCount;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

uses
  System.Generics.Defaults;

constructor TThemedGridColumnBandCollection.Create;
begin
  inherited Create;
  FItems := TObjectList<TThemedGridColumnBand>.Create(True);
end;

destructor TThemedGridColumnBandCollection.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Detach(FItems[I]);
  FItems.Free;
  inherited Destroy;
end;

function TThemedGridColumnBandCollection.GetItem(const AIndex: Integer): TThemedGridColumnBand;
begin
  Result := FItems[AIndex];
end;

function TThemedGridColumnBandCollection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TThemedGridColumnBandCollection.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridColumnBandCollection.Attach(const ABand: TThemedGridColumnBand);
begin
  if ABand <> nil then
    ABand.OnChanged := BandChanged;
end;

procedure TThemedGridColumnBandCollection.Detach(const ABand: TThemedGridColumnBand);
begin
  if ABand <> nil then
    ABand.OnChanged := nil;
end;

procedure TThemedGridColumnBandCollection.BandChanged(ASender: TObject);
begin
  NormalizeDisplayIndexes;
  DoChanged;
end;

procedure TThemedGridColumnBandCollection.NormalizeDisplayIndexes;
var
  I, LDisplayIndex: Integer;
  LBand: TThemedGridColumnBand;
begin
  LDisplayIndex := 0;
  for I := 0 to FItems.Count - 1 do
  begin
    LBand := FItems[I];
    if not LBand.Visible then
      Continue;
    if LBand.DisplayIndex < 0 then
      LBand.DisplayIndex := LDisplayIndex;
    Inc(LDisplayIndex);
  end;
end;

function TThemedGridColumnBandCollection.CreateDefaultName: string;
var
  LIndex: Integer;
  LName: string;
begin
  LIndex := FItems.Count + 1;
  LName := 'Band' + IntToStr(LIndex);
  while Contains(LName) do
  begin
    Inc(LIndex);
    LName := 'Band' + IntToStr(LIndex);
  end;
  Result := LName;
end;

function TThemedGridColumnBandCollection.Add(const ABand: TThemedGridColumnBand): TThemedGridColumnBand;
begin
  if ABand = nil then
    raise EArgumentNilException.Create('band');
  if ABand.Name = '' then
    ABand.Name := CreateDefaultName;
  FItems.Add(ABand);
  Attach(ABand);
  NormalizeDisplayIndexes;
  DoChanged;
  Result := ABand;
end;

function TThemedGridColumnBandCollection.Add(const AName, AText: string): TThemedGridColumnBand;
var
  LBand: TThemedGridColumnBand;
begin
  LBand := TThemedGridColumnBand.Create;
  LBand.Name := AName;
  LBand.Text := AText;
  Result := Add(LBand);
end;

procedure TThemedGridColumnBandCollection.RemoveAt(const AIndex: Integer);
begin
  Detach(FItems[AIndex]);
  FItems.Delete(AIndex);
  NormalizeDisplayIndexes;
  DoChanged;
end;

function TThemedGridColumnBandCollection.Remove(const ABand: TThemedGridColumnBand): Boolean;
var
  LIndex: Integer;
begin
  LIndex := FItems.IndexOf(ABand);
  if LIndex < 0 then
    Exit(False);
  RemoveAt(LIndex);
  Result := True;
end;

procedure TThemedGridColumnBandCollection.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Detach(FItems[I]);
  FItems.Clear;
  DoChanged;
end;

function TThemedGridColumnBandCollection.Contains(const AName: string): Boolean;
begin
  Result := FindByName(AName) <> nil;
end;

function TThemedGridColumnBandCollection.FindByName(const AName: string): TThemedGridColumnBand;
var
  I: Integer;
begin
  if AName = '' then
    Exit(nil);
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].Name, AName) then
      Exit(FItems[I]);
  Result := nil;
end;

function TThemedGridColumnBandCollection.GetVisibleBands: TList<TThemedGridColumnBand>;
var
  I: Integer;
begin
  Result := TList<TThemedGridColumnBand>.Create;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Visible then
      Result.Add(FItems[I]);
  Result.Sort(TComparer<TThemedGridColumnBand>.Construct(
    function(const L, R: TThemedGridColumnBand): Integer
    begin
      Result := L.DisplayIndex - R.DisplayIndex;
      if Result = 0 then
        Result := CompareText(L.Name, R.Name);
    end));
end;

end.

unit NimbusForms.Grid.StringSet;

interface

uses
  System.Generics.Collections;

type
  TThemedGridStringSet = class
  private
    FItems: TDictionary<string, Boolean>;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AValue: string): Boolean;
    function Remove(const AValue: string): Boolean;
    function Contains(const AValue: string): Boolean;
    procedure Clear;
    function ToArray: TArray<string>;
    property Count: Integer read GetCount;
  end;

implementation

constructor TThemedGridStringSet.Create;
begin
  inherited Create;
  FItems := TDictionary<string, Boolean>.Create;
end;

destructor TThemedGridStringSet.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TThemedGridStringSet.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TThemedGridStringSet.Add(const AValue: string): Boolean;
begin
  Result := not FItems.ContainsKey(AValue);
  if Result then
    FItems.Add(AValue, True);
end;

function TThemedGridStringSet.Remove(const AValue: string): Boolean;
begin
  Result := FItems.ContainsKey(AValue);
  if Result then
    FItems.Remove(AValue);
end;

function TThemedGridStringSet.Contains(const AValue: string): Boolean;
begin
  Result := FItems.ContainsKey(AValue);
end;

procedure TThemedGridStringSet.Clear;
begin
  FItems.Clear;
end;

function TThemedGridStringSet.ToArray: TArray<string>;
begin
  Result := FItems.Keys.ToArray;
end;

end.

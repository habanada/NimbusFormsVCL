unit NimbusForms.HexEditor.Bookmarks;

interface

uses
  System.Generics.Collections,
  NimbusForms.Theming.Types;

type
  THexBookmark = class
  private
    FOffset: Int64;
    FName: string;
    FColor: TThemeColor;
    FHasColor: Boolean;
  public
    property Offset: Int64 read FOffset write FOffset;
    property Name: string read FName write FName;
    property Color: TThemeColor read FColor write FColor;
    property HasColor: Boolean read FHasColor write FHasColor;
  end;

  THexBookmarkManager = class
  private
    FItems: TObjectDictionary<Int64, THexBookmark>;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const ABookmark: THexBookmark);
    function Remove(const AOffset: Int64): Boolean;
    function Move(const AOffset, ANewOffset: Int64): Boolean;
    function Contains(const AOffset: Int64): Boolean;
    function TryGet(const AOffset: Int64; out ABookmark: THexBookmark): Boolean;
    procedure Clear;
    function Values: TArray<THexBookmark>;
    property Count: Integer read GetCount;
  end;

implementation

constructor THexBookmarkManager.Create;
begin
  inherited Create;
  FItems := TObjectDictionary<Int64, THexBookmark>.Create([doOwnsValues]);
end;

destructor THexBookmarkManager.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function THexBookmarkManager.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure THexBookmarkManager.Add(const ABookmark: THexBookmark);
begin
  if ABookmark = nil then
    Exit;
  FItems.AddOrSetValue(ABookmark.Offset, ABookmark);
end;

function THexBookmarkManager.Remove(const AOffset: Int64): Boolean;
begin
  Result := FItems.ContainsKey(AOffset);
  if Result then
    FItems.Remove(AOffset);
end;

function THexBookmarkManager.Move(const AOffset, ANewOffset: Int64): Boolean;
var
  LBookmark: THexBookmark;
begin
  Result := (ANewOffset >= 0) and FItems.TryGetValue(AOffset, LBookmark);
  if not Result or (AOffset = ANewOffset) then Exit;
  if FItems.ContainsKey(ANewOffset) then Exit(False);
  FItems.Add(ANewOffset, LBookmark);
  FItems.ExtractPair(AOffset);
  LBookmark.Offset := ANewOffset;
end;

function THexBookmarkManager.Contains(const AOffset: Int64): Boolean;
begin
  Result := FItems.ContainsKey(AOffset);
end;

function THexBookmarkManager.TryGet(const AOffset: Int64;
  out ABookmark: THexBookmark): Boolean;
begin
  Result := FItems.TryGetValue(AOffset, ABookmark);
end;

procedure THexBookmarkManager.Clear;
begin
  FItems.Clear;
end;

function THexBookmarkManager.Values: TArray<THexBookmark>;
begin
  Result := FItems.Values.ToArray;
end;

end.

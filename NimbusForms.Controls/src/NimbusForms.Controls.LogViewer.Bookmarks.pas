unit NimbusForms.Controls.LogViewer.Bookmarks;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections;

type
  TNimbusLogBookmark = class(TPersistent)
  private
    FSourceIndex: Int64;
    FLineID: UInt64;
    FLabelText: string;
    FNote: string;
  published
    property SourceIndex: Int64 read FSourceIndex write FSourceIndex;
    property LineID: UInt64 read FLineID write FLineID;
    property LabelText: string read FLabelText write FLabelText;
    property Note: string read FNote write FNote;
  end;

  TNimbusLogBookmarks = class
  private
    FItems: TObjectList<TNimbusLogBookmark>;
    FOnChange: TNotifyEvent;
    function GetCount: Integer;
    function GetItem(const AIndex: Integer): TNimbusLogBookmark;
    procedure Changed;
  public
    constructor Create(const AOnChange: TNotifyEvent = nil);
    destructor Destroy; override;
    function Add(const ASourceIndex: Int64; const ALineID: UInt64; const ALabelText: string = ''; const ANote: string = ''): TNimbusLogBookmark;
    function FindBySourceIndex(const ASourceIndex: Int64): TNimbusLogBookmark;
    function FindByLineID(const ALineID: UInt64): TNimbusLogBookmark;
    function RemoveBySourceIndex(const ASourceIndex: Int64): Boolean;
    function RemoveByLineID(const ALineID: UInt64): Boolean;
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: TNimbusLogBookmark read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TNimbusLogBookmarks.Create(const AOnChange: TNotifyEvent);
begin
  inherited Create;
  FItems := TObjectList<TNimbusLogBookmark>.Create(True);
  FOnChange := AOnChange;
end;

destructor TNimbusLogBookmarks.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TNimbusLogBookmarks.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TNimbusLogBookmarks.GetItem(const AIndex: Integer): TNimbusLogBookmark;
begin
  Result := FItems[AIndex];
end;

procedure TNimbusLogBookmarks.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNimbusLogBookmarks.FindBySourceIndex(const ASourceIndex: Int64): TNimbusLogBookmark;
var Item: TNimbusLogBookmark;
begin
  Result := nil;
  for Item in FItems do
    if Item.SourceIndex = ASourceIndex then Exit(Item);
end;

function TNimbusLogBookmarks.FindByLineID(const ALineID: UInt64): TNimbusLogBookmark;
var Item: TNimbusLogBookmark;
begin
  Result := nil;
  if ALineID = 0 then Exit;
  for Item in FItems do
    if Item.LineID = ALineID then Exit(Item);
end;

function TNimbusLogBookmarks.Add(const ASourceIndex: Int64; const ALineID: UInt64;
  const ALabelText, ANote: string): TNimbusLogBookmark;
begin
  Result := FindBySourceIndex(ASourceIndex);
  if Result = nil then
  begin
    Result := TNimbusLogBookmark.Create;
    Result.SourceIndex := ASourceIndex;
    FItems.Add(Result);
  end;
  Result.LineID := ALineID;
  Result.LabelText := ALabelText;
  Result.Note := ANote;
  Changed;
end;

function TNimbusLogBookmarks.RemoveBySourceIndex(const ASourceIndex: Int64): Boolean;
var Item: TNimbusLogBookmark;
begin
  Item := FindBySourceIndex(ASourceIndex);
  Result := Item <> nil;
  if Result then
  begin
    FItems.Remove(Item);
    Changed;
  end;
end;

function TNimbusLogBookmarks.RemoveByLineID(const ALineID: UInt64): Boolean;
var Item: TNimbusLogBookmark;
begin
  Item := FindByLineID(ALineID);
  Result := Item <> nil;
  if Result then
  begin
    FItems.Remove(Item);
    Changed;
  end;
end;

procedure TNimbusLogBookmarks.Clear;
begin
  if FItems.Count = 0 then Exit;
  FItems.Clear;
  Changed;
end;

end.

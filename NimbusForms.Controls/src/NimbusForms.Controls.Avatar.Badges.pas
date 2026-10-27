{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Avatar.Badges;

interface

uses System.Classes, System.UITypes, Vcl.Graphics, NimbusForms.Rendering.Avatar;

type
  TThemedAvatarBadge = class(TCollectionItem)
  private
    FInfo: TThemedAvatarBadgeInfo;
    function GetKey: string;
    function GetText: string;
    function GetHint: string;
    function GetKind: TThemedAvatarBadgeKind;
    function GetTone: TThemedAvatarBadgeTone;
    function GetAnchor: TThemedAvatarBadgeAnchor;
    function GetCount: Integer;
    function GetLimit: Integer;
    function GetSize: Integer;
    function GetOffsetX: Integer;
    function GetOffsetY: Integer;
    function GetColor: TColor;
    function GetTextColor: TColor;
    function GetVisible: Boolean;
    function GetEnabled: Boolean;
    function GetHideWhenZero: Boolean;
    function GetTag: Integer;
    procedure SetKey(const Value: string);
    procedure SetText(const Value: string);
    procedure SetHint(const Value: string);
    procedure SetKind(Value: TThemedAvatarBadgeKind);
    procedure SetTone(Value: TThemedAvatarBadgeTone);
    procedure SetAnchor(Value: TThemedAvatarBadgeAnchor);
    procedure SetCount(Value: Integer);
    procedure SetLimit(Value: Integer);
    procedure SetSize(Value: Integer);
    procedure SetOffsetX(Value: Integer);
    procedure SetOffsetY(Value: Integer);
    procedure SetColor(Value: TColor);
    procedure SetTextColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHideWhenZero(Value: Boolean);
    procedure SetTag(Value: Integer);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function RenderInfo: TThemedAvatarBadgeInfo;
    procedure Increment(Delta: Integer = 1);
  published
    property Key: string read GetKey write SetKey;
    property Text: string read GetText write SetText;
    property Hint: string read GetHint write SetHint;
    property Kind: TThemedAvatarBadgeKind read GetKind write SetKind default tabkDot;
    property Tone: TThemedAvatarBadgeTone read GetTone write SetTone default tabtAccent;
    property Anchor: TThemedAvatarBadgeAnchor read GetAnchor write SetAnchor default tabaTopRight;
    property Count: Integer read GetCount write SetCount default 0;
    property Limit: Integer read GetLimit write SetLimit default 99;
    property HideWhenZero: Boolean read GetHideWhenZero write SetHideWhenZero default True;
    property Visible: Boolean read GetVisible write SetVisible default True;
    property Enabled: Boolean read GetEnabled write SetEnabled default True;
    property Color: TColor read GetColor write SetColor default clNone;
    property TextColor: TColor read GetTextColor write SetTextColor default clNone;
    property Size: Integer read GetSize write SetSize default 0;
    property OffsetX: Integer read GetOffsetX write SetOffsetX default 0;
    property OffsetY: Integer read GetOffsetY write SetOffsetY default 0;
    property Tag: Integer read GetTag write SetTag default 0;
  end;

  TThemedAvatarBadges = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TThemedAvatarBadge;
    procedure SetItem(Index: Integer; const Value: TThemedAvatarBadge);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedAvatarBadge;
    function AddNamed(const Key: string): TThemedAvatarBadge;
    function Find(const Key: string): TThemedAvatarBadge;
    function Ensure(const Key: string): TThemedAvatarBadge;
    property Items[Index: Integer]: TThemedAvatarBadge read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses System.SysUtils, System.Math;

resourcestring
  SDuplicateKey = 'An avatar badge with key "%s" already exists.';
  SEmptyKey = 'An avatar badge key cannot be empty.';
  SReservedKey = 'The avatar badge key "%s" is reserved for a built-in badge.';

procedure ValidateAvatarBadgeKey(const Key: string; AllowEmpty: Boolean);
var S: string;
begin
  S := Trim(Key);
  if (S = '') and not AllowEmpty then raise EArgumentException.Create(SEmptyKey);
  if SameText(S, 'status') or SameText(S, 'counter') or SameText(S, 'star') then
    raise EArgumentException.CreateFmt(SReservedKey, [S]);
end;

constructor TThemedAvatarBadge.Create(Collection: TCollection);
begin
  FInfo.Visible := True; FInfo.Enabled := True; FInfo.HideWhenZero := True; FInfo.Limit := 99;
  FInfo.Color := clNone; FInfo.TextColor := clNone; FInfo.Anchor := tabaTopRight; FInfo.Part := tapBadge;
  inherited Create(Collection);
end;

function TThemedAvatarBadge.GetDisplayName: string;
begin if FInfo.Key <> '' then Result := FInfo.Key else Result := inherited GetDisplayName; end;

function TThemedAvatarBadge.RenderInfo: TThemedAvatarBadgeInfo;
begin Result := FInfo; Result.ID := ID; end;

function TThemedAvatarBadge.GetKey: string;
begin Result := FInfo.Key; end;
function TThemedAvatarBadge.GetText: string;
begin Result := FInfo.Text; end;
function TThemedAvatarBadge.GetHint: string;
begin Result := FInfo.Hint; end;
function TThemedAvatarBadge.GetKind: TThemedAvatarBadgeKind;
begin Result := FInfo.Kind; end;
function TThemedAvatarBadge.GetTone: TThemedAvatarBadgeTone;
begin Result := FInfo.Tone; end;
function TThemedAvatarBadge.GetAnchor: TThemedAvatarBadgeAnchor;
begin Result := FInfo.Anchor; end;
function TThemedAvatarBadge.GetCount: Integer;
begin Result := FInfo.Count; end;
function TThemedAvatarBadge.GetLimit: Integer;
begin Result := FInfo.Limit; end;
function TThemedAvatarBadge.GetSize: Integer;
begin Result := FInfo.Size; end;
function TThemedAvatarBadge.GetOffsetX: Integer;
begin Result := FInfo.OffsetX; end;
function TThemedAvatarBadge.GetOffsetY: Integer;
begin Result := FInfo.OffsetY; end;
function TThemedAvatarBadge.GetColor: TColor;
begin Result := FInfo.Color; end;
function TThemedAvatarBadge.GetTextColor: TColor;
begin Result := FInfo.TextColor; end;
function TThemedAvatarBadge.GetVisible: Boolean;
begin Result := FInfo.Visible; end;
function TThemedAvatarBadge.GetEnabled: Boolean;
begin Result := FInfo.Enabled; end;
function TThemedAvatarBadge.GetHideWhenZero: Boolean;
begin Result := FInfo.HideWhenZero; end;
function TThemedAvatarBadge.GetTag: Integer;
begin Result := FInfo.Tag; end;

procedure TThemedAvatarBadge.Assign(Source: TPersistent);
var Info: TThemedAvatarBadgeInfo;
begin
  if not (Source is TThemedAvatarBadge) then begin inherited; Exit; end;
  Info := TThemedAvatarBadge(Source).FInfo;
  if Collection <> nil then Collection.BeginUpdate;
  try SetKey(Info.Key); FInfo := Info; Changed(False);
  finally if Collection <> nil then Collection.EndUpdate; end;
end;

procedure TThemedAvatarBadge.SetKey(const Value: string);
var Candidate: TThemedAvatarBadge; S: string;
begin
  S := Trim(Value); if S = FInfo.Key then Exit;
  ValidateAvatarBadgeKey(S, True);
  if (S <> '') and (Collection is TThemedAvatarBadges) then
  begin
    Candidate := TThemedAvatarBadges(Collection).Find(S);
    if (Candidate <> nil) and (Candidate <> Self) then raise EArgumentException.CreateFmt(SDuplicateKey, [S]);
  end;
  FInfo.Key := S; Changed(False);
end;
procedure TThemedAvatarBadge.SetText(const Value: string);
begin if FInfo.Text = Value then Exit; FInfo.Text := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetHint(const Value: string);
begin if FInfo.Hint = Value then Exit; FInfo.Hint := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetKind(Value: TThemedAvatarBadgeKind);
begin if FInfo.Kind = Value then Exit; FInfo.Kind := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetTone(Value: TThemedAvatarBadgeTone);
begin if FInfo.Tone = Value then Exit; FInfo.Tone := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetAnchor(Value: TThemedAvatarBadgeAnchor);
begin if FInfo.Anchor = Value then Exit; FInfo.Anchor := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetCount(Value: Integer);
begin Value := Max(0, Value); if FInfo.Count = Value then Exit; FInfo.Count := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetLimit(Value: Integer);
begin Value := Max(1, Value); if FInfo.Limit = Value then Exit; FInfo.Limit := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetSize(Value: Integer);
begin Value := EnsureRange(Value, 0, 256); if FInfo.Size = Value then Exit; FInfo.Size := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetOffsetX(Value: Integer);
begin Value := EnsureRange(Value, -256, 256); if FInfo.OffsetX = Value then Exit; FInfo.OffsetX := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetOffsetY(Value: Integer);
begin Value := EnsureRange(Value, -256, 256); if FInfo.OffsetY = Value then Exit; FInfo.OffsetY := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetColor(Value: TColor);
begin if FInfo.Color = Value then Exit; FInfo.Color := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetTextColor(Value: TColor);
begin if FInfo.TextColor = Value then Exit; FInfo.TextColor := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetVisible(Value: Boolean);
begin if FInfo.Visible = Value then Exit; FInfo.Visible := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetEnabled(Value: Boolean);
begin if FInfo.Enabled = Value then Exit; FInfo.Enabled := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetHideWhenZero(Value: Boolean);
begin if FInfo.HideWhenZero = Value then Exit; FInfo.HideWhenZero := Value; Changed(False); end;
procedure TThemedAvatarBadge.SetTag(Value: Integer);
begin if FInfo.Tag = Value then Exit; FInfo.Tag := Value; Changed(False); end;
procedure TThemedAvatarBadge.Increment(Delta: Integer);
begin SetCount(Integer(EnsureRange(Int64(FInfo.Count) + Delta, Int64(0), Int64(MaxInt)))); end;

constructor TThemedAvatarBadges.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TThemedAvatarBadge); end;
function TThemedAvatarBadges.GetItem(Index: Integer): TThemedAvatarBadge;
begin Result := TThemedAvatarBadge(inherited Items[Index]); end;
procedure TThemedAvatarBadges.SetItem(Index: Integer; const Value: TThemedAvatarBadge);
begin Items[Index].Assign(Value); end;
function TThemedAvatarBadges.Add: TThemedAvatarBadge;
begin Result := TThemedAvatarBadge(inherited Add); end;
function TThemedAvatarBadges.Find(const Key: string): TThemedAvatarBadge;
var I: Integer;
begin
  if Trim(Key) = '' then Exit(nil);
  for I := 0 to Count - 1 do if SameText(Items[I].Key, Trim(Key)) then Exit(Items[I]);
  Result := nil;
end;
function TThemedAvatarBadges.AddNamed(const Key: string): TThemedAvatarBadge;
begin
  ValidateAvatarBadgeKey(Key, False);
  if Find(Key) <> nil then raise EArgumentException.CreateFmt(SDuplicateKey, [Trim(Key)]);
  BeginUpdate;
  try Result := Add; Result.Key := Key;
  finally EndUpdate; end;
end;
function TThemedAvatarBadges.Ensure(const Key: string): TThemedAvatarBadge;
begin
  ValidateAvatarBadgeKey(Key, False);
  Result := Find(Key); if Result = nil then Result := AddNamed(Key);
end;
procedure TThemedAvatarBadges.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self); end;

end.

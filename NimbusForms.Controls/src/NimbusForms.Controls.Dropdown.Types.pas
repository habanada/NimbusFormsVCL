{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Dropdown.Types;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Variants,
  Vcl.Graphics;

type
  TThemedDropdownStyleMode = (tdsNormal, tdsIdeCompact);
  TThemedDropdownValidationState = (tdvNormal, tdvError, tdvWarning, tdvSuccess);
  TThemedDropdownClearButtonMode = (tdcNever, tdcWhenSelected, tdcAlways);

  TThemedDropdownItem = class(TCollectionItem)
  private
    FText: string;
    FValue: Variant;
    FImage: Vcl.Graphics.TBitmap;
    FTag: NativeInt;
    FDataItem: TObject;
    FEnabled: Boolean;
    FChecked: Boolean;
    FIsSeparator: Boolean;
    FGroupText: string;
    procedure SetText(const AValue: string);
    procedure SetValue(const AValue: Variant);
    procedure SetImage(const AValue: Vcl.Graphics.TBitmap);
    procedure ImageChanged(Sender: TObject);
    procedure SetTag(const AValue: NativeInt);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetChecked(const AValue: Boolean);
    procedure SetIsSeparator(const AValue: Boolean);
    procedure SetGroupText(const AValue: string);
    function GetIsGroupHeader: Boolean;
    function GetSelectable: Boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property DataItem: TObject read FDataItem write FDataItem;
    property Value: Variant read FValue write SetValue;
    property IsGroupHeader: Boolean read GetIsGroupHeader;
    property Selectable: Boolean read GetSelectable;
  published
    property Text: string read FText write SetText;
    property Image: Vcl.Graphics.TBitmap read FImage write SetImage;
    property Tag: NativeInt read FTag write SetTag default 0;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Checked: Boolean read FChecked write SetChecked default False;
    property IsSeparator: Boolean read FIsSeparator write SetIsSeparator default False;
    property GroupText: string read FGroupText write SetGroupText;
  end;

  TThemedDropdownItemsChangedEvent = procedure(Sender: TObject; Item: TThemedDropdownItem) of object;

  TThemedDropdownItems = class(TOwnedCollection)
  private
    FOnChange: TThemedDropdownItemsChangedEvent;
    function GetItem(Index: Integer): TThemedDropdownItem;
    procedure SetItem(Index: Integer; const AValue: TThemedDropdownItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedDropdownItem;
    function AddItem(const AText: string): TThemedDropdownItem;
    function AddSeparator: TThemedDropdownItem;
    function AddGroup(const AGroupText: string): TThemedDropdownItem;
    property Items[Index: Integer]: TThemedDropdownItem read GetItem write SetItem; default;
    property OnChange: TThemedDropdownItemsChangedEvent read FOnChange write FOnChange;
  end;

  TThemedDropdownItemEvent = procedure(Sender: TObject; Item: TThemedDropdownItem) of object;

implementation

constructor TThemedDropdownItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
  FValue := Unassigned;
  FImage := Vcl.Graphics.TBitmap.Create;
  FImage.OnChange := ImageChanged;
end;

destructor TThemedDropdownItem.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

procedure TThemedDropdownItem.Assign(Source: TPersistent);
var
  LSource: TThemedDropdownItem;
begin
  if Source is TThemedDropdownItem then
  begin
    LSource := TThemedDropdownItem(Source);
    FText := LSource.FText;
    FValue := LSource.FValue;
    FImage.Assign(LSource.FImage);
    FTag := LSource.FTag;
    FDataItem := LSource.FDataItem;
    FEnabled := LSource.FEnabled;
    FChecked := LSource.FChecked;
    FIsSeparator := LSource.FIsSeparator;
    FGroupText := LSource.FGroupText;
    Changed(False);
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TThemedDropdownItem.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue;
  Changed(False);
end;

procedure TThemedDropdownItem.SetValue(const AValue: Variant);
begin
  if VarSameValue(FValue, AValue) then Exit;
  FValue := AValue;
  Changed(False);
end;

procedure TThemedDropdownItem.SetImage(const AValue: Vcl.Graphics.TBitmap);
begin
  if AValue = nil then
    FImage.SetSize(0, 0)
  else
    FImage.Assign(AValue);
end;

procedure TThemedDropdownItem.ImageChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TThemedDropdownItem.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit;
  FTag := AValue;
  Changed(False);
end;

procedure TThemedDropdownItem.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  Changed(False);
end;

procedure TThemedDropdownItem.SetChecked(const AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  Changed(False);
end;

procedure TThemedDropdownItem.SetIsSeparator(const AValue: Boolean);
begin
  if FIsSeparator = AValue then Exit;
  FIsSeparator := AValue;
  if FIsSeparator then FGroupText := '';
  Changed(False);
end;

procedure TThemedDropdownItem.SetGroupText(const AValue: string);
begin
  if FGroupText = AValue then Exit;
  FGroupText := AValue;
  if FGroupText <> '' then FIsSeparator := False;
  Changed(False);
end;

function TThemedDropdownItem.GetIsGroupHeader: Boolean;
begin
  Result := FGroupText <> '';
end;

function TThemedDropdownItem.GetSelectable: Boolean;
begin
  Result := not FIsSeparator and not GetIsGroupHeader and FEnabled;
end;

constructor TThemedDropdownItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TThemedDropdownItem);
end;

function TThemedDropdownItems.Add: TThemedDropdownItem;
begin
  Result := TThemedDropdownItem(inherited Add);
end;

function TThemedDropdownItems.AddItem(const AText: string): TThemedDropdownItem;
begin
  Result := Add;
  Result.Text := AText;
end;

function TThemedDropdownItems.AddSeparator: TThemedDropdownItem;
begin
  Result := Add;
  Result.IsSeparator := True;
end;

function TThemedDropdownItems.AddGroup(const AGroupText: string): TThemedDropdownItem;
begin
  Result := Add;
  Result.GroupText := AGroupText;
end;

function TThemedDropdownItems.GetItem(Index: Integer): TThemedDropdownItem;
begin
  Result := TThemedDropdownItem(inherited GetItem(Index));
end;

procedure TThemedDropdownItems.SetItem(Index: Integer; const AValue: TThemedDropdownItem);
begin
  inherited SetItem(Index, AValue);
end;

procedure TThemedDropdownItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self, TThemedDropdownItem(Item));
end;

end.

unit NimbusForms.Grid.DetailItemCollection;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.DetailItem;

type
  TThemedGridDetailItemCollection = class(TList<TThemedGridDetailItem>)
  private
    FBorrowed: TList<TThemedGridDetailItem>;
    class function CreateItem(const AKey, AText: string; const AValue: TValue; const AWidth: Integer;
      const ARenderKind: TThemedGridCellRenderKind): TThemedGridDetailItem; static;
  public
    constructor Create;
    destructor Destroy; override;
    function AddText(const AKey, AText: string; const AWidth: Integer): TThemedGridDetailItem;
    function AddValue(const AKey, AText: string; const AValue: TValue; const AWidth: Integer): TThemedGridDetailItem;
    function AddCheckBox(const AKey: string; const AValue: Boolean; const AWidth: Integer): TThemedGridDetailItem;
    function AddToggle(const AKey: string; const AValue: Boolean; const AWidth: Integer): TThemedGridDetailItem;
    function AddProgress(const AKey: string; const AValue: Extended; const AWidth: Integer): TThemedGridDetailItem;
    function AddBadge(const AKey, AText: string; const AWidth: Integer): TThemedGridDetailItem;
    function AddRating(const AKey: string; const AValue: Extended; const AWidth: Integer): TThemedGridDetailItem;
    function AddButton(const AKey, AText: string; const AWidth: Integer): TThemedGridDetailItem; overload;
    function AddButton(const AKey, AText: string; const AWidth: Integer;
      const AAction: TThemedGridDetailItemAction): TThemedGridDetailItem; overload;
    function AddBorrowed(const AItem: TThemedGridDetailItem): Integer;
    procedure FreeAndClear;
  end;

implementation

uses
  NimbusForms.Grid.DetailStrings;

constructor TThemedGridDetailItemCollection.Create;
begin
  inherited Create;
  FBorrowed := TList<TThemedGridDetailItem>.Create;
end;

destructor TThemedGridDetailItemCollection.Destroy;
begin
  FreeAndClear;
  FBorrowed.Free;
  inherited Destroy;
end;

class function TThemedGridDetailItemCollection.CreateItem(const AKey, AText: string; const AValue: TValue;
  const AWidth: Integer; const ARenderKind: TThemedGridCellRenderKind): TThemedGridDetailItem;
begin
  Result := TThemedGridDetailItem.Create;
  Result.Key := AKey;
  Result.Text := AText;
  Result.Value := AValue;
  Result.Width := AWidth;
  Result.RenderKind := ARenderKind;
end;

function TThemedGridDetailItemCollection.AddText(const AKey, AText: string;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, AText, TValue.From<string>(AText), AWidth, TThemedGridCellRenderKind.Text);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleLeft;
  Result.ToggleOnClick := False;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddValue(const AKey, AText: string; const AValue: TValue;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, AText, AValue, AWidth, TThemedGridCellRenderKind.Text);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleLeft;
  Result.ToggleOnClick := False;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddCheckBox(const AKey: string; const AValue: Boolean;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, '', TValue.From<Boolean>(AValue), AWidth, TThemedGridCellRenderKind.CheckBox);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result.ToggleOnClick := True;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddToggle(const AKey: string; const AValue: Boolean;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, '', TValue.From<Boolean>(AValue), AWidth, TThemedGridCellRenderKind.Toggle);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result.ToggleOnClick := True;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddProgress(const AKey: string; const AValue: Extended;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, FormatFloat(ThemedGridDetailStrings.ProgressFormat, AValue * 100),
    TValue.From<Extended>(AValue), AWidth, TThemedGridCellRenderKind.ProgressBar);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result.ToggleOnClick := False;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddBadge(const AKey, AText: string;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, AText, TValue.From<string>(AText), AWidth, TThemedGridCellRenderKind.Badge);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result.ToggleOnClick := False;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddRating(const AKey: string; const AValue: Extended;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, FormatFloat(ThemedGridDetailStrings.RatingFormat, AValue),
    TValue.From<Extended>(AValue), AWidth, TThemedGridCellRenderKind.Rating);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result.ToggleOnClick := False;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddButton(const AKey, AText: string;
  const AWidth: Integer): TThemedGridDetailItem;
begin
  Result := CreateItem(AKey, AText, TValue.From<string>(AText), AWidth, TThemedGridCellRenderKind.Button);
  Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result.ToggleOnClick := False;
  Result.AutoHandleAction := True;
  Add(Result);
end;

function TThemedGridDetailItemCollection.AddButton(const AKey, AText: string; const AWidth: Integer;
  const AAction: TThemedGridDetailItemAction): TThemedGridDetailItem;
begin
  Result := AddButton(AKey, AText, AWidth);
  Result.Action := AAction;
end;

function TThemedGridDetailItemCollection.AddBorrowed(const AItem: TThemedGridDetailItem): Integer;
begin
  Result := Add(AItem);
  FBorrowed.Add(AItem);
end;

procedure TThemedGridDetailItemCollection.FreeAndClear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if FBorrowed.IndexOf(Items[I]) < 0 then
      Items[I].Free;
  FBorrowed.Clear;
  Clear;
end;

end.

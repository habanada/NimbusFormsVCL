unit NimbusForms.Grid.DetailGridColumn;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types;

type
  TThemedGridDetailGridColumn = class
  private
    FName: string;
    FHeaderText: string;
    FDataPropertyName: string;
    FFormatString: string;
    FWidth: Integer;
    FMinimumWidth: Integer;
    FVisible: Boolean;
    FReadOnly: Boolean;
    FAutoWidth: Boolean;
    FTextAlignment: TThemedGridContentAlignment;
    FRenderKind: TThemedGridCellRenderKind;
    FTag: TValue;
    FBounds: TRect;
    procedure SetWidth(const AValue: Integer);
    procedure SetMinimumWidth(const AValue: Integer);
  public
    constructor Create; overload;
    constructor Create(const AName, AHeaderText, ADataPropertyName: string); overload;
    property Name: string read FName write FName;
    property HeaderText: string read FHeaderText write FHeaderText;
    property DataPropertyName: string read FDataPropertyName write FDataPropertyName;
    property FormatString: string read FFormatString write FFormatString;
    property Width: Integer read FWidth write SetWidth;
    property MinimumWidth: Integer read FMinimumWidth write SetMinimumWidth;
    property Visible: Boolean read FVisible write FVisible;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth;
    property TextAlignment: TThemedGridContentAlignment read FTextAlignment write FTextAlignment;
    property RenderKind: TThemedGridCellRenderKind read FRenderKind write FRenderKind;
    property Tag: TValue read FTag write FTag;
    property Bounds: TRect read FBounds write FBounds;
  end;

  TThemedGridDetailGridColumnCollection = class(TObjectList<TThemedGridDetailGridColumn>)
  public
    constructor Create;
    function Add(const AName, AHeaderText, ADataPropertyName: string): TThemedGridDetailGridColumn; reintroduce; overload;
    function Add(const AName, AHeaderText, ADataPropertyName: string;
      const AWidth: Integer): TThemedGridDetailGridColumn; reintroduce; overload;
    function Add(const AName, AHeaderText, ADataPropertyName: string; const AWidth: Integer;
      const ARenderKind: TThemedGridCellRenderKind): TThemedGridDetailGridColumn; reintroduce; overload;
    function FindByName(const AName: string): TThemedGridDetailGridColumn;
    function FindByDataPropertyName(const ADataPropertyName: string): TThemedGridDetailGridColumn;
  end;

const
  CThemedGridDetailGridColumnMinimumWidth = 16;
  CThemedGridDetailGridColumnMaximumWidth = 4000;
  CThemedGridDetailGridColumnDefaultWidth = 120;
  CThemedGridDetailGridColumnDefaultMinimumWidth = 32;

implementation

constructor TThemedGridDetailGridColumn.Create;
begin
  Create('', '', '');
end;

constructor TThemedGridDetailGridColumn.Create(const AName, AHeaderText, ADataPropertyName: string);
begin
  inherited Create;
  FName := AName;
  FHeaderText := AHeaderText;
  FDataPropertyName := ADataPropertyName;
  FFormatString := '';
  FWidth := CThemedGridDetailGridColumnDefaultWidth;
  FMinimumWidth := CThemedGridDetailGridColumnDefaultMinimumWidth;
  FVisible := True;
  FReadOnly := True;
  FAutoWidth := False;
  FTextAlignment := TThemedGridContentAlignment.MiddleLeft;
  FRenderKind := TThemedGridCellRenderKind.Auto;
  FBounds := TRect.Empty;
end;

procedure TThemedGridDetailGridColumn.SetWidth(const AValue: Integer);
begin
  if AValue < CThemedGridDetailGridColumnMinimumWidth then
    FWidth := CThemedGridDetailGridColumnMinimumWidth
  else if AValue > CThemedGridDetailGridColumnMaximumWidth then
    FWidth := CThemedGridDetailGridColumnMaximumWidth
  else
    FWidth := AValue;
end;

procedure TThemedGridDetailGridColumn.SetMinimumWidth(const AValue: Integer);
begin
  if AValue < CThemedGridDetailGridColumnMinimumWidth then
    FMinimumWidth := CThemedGridDetailGridColumnMinimumWidth
  else if AValue > CThemedGridDetailGridColumnMaximumWidth then
    FMinimumWidth := CThemedGridDetailGridColumnMaximumWidth
  else
    FMinimumWidth := AValue;
end;

constructor TThemedGridDetailGridColumnCollection.Create;
begin
  inherited Create(True);
end;

function TThemedGridDetailGridColumnCollection.Add(const AName, AHeaderText,
  ADataPropertyName: string): TThemedGridDetailGridColumn;
begin
  Result := TThemedGridDetailGridColumn.Create(AName, AHeaderText, ADataPropertyName);
  inherited Add(Result);
end;

function TThemedGridDetailGridColumnCollection.Add(const AName, AHeaderText, ADataPropertyName: string;
  const AWidth: Integer): TThemedGridDetailGridColumn;
begin
  Result := Add(AName, AHeaderText, ADataPropertyName);
  Result.Width := AWidth;
end;

function TThemedGridDetailGridColumnCollection.Add(const AName, AHeaderText, ADataPropertyName: string;
  const AWidth: Integer; const ARenderKind: TThemedGridCellRenderKind): TThemedGridDetailGridColumn;
begin
  Result := Add(AName, AHeaderText, ADataPropertyName, AWidth);
  Result.RenderKind := ARenderKind;
end;

function TThemedGridDetailGridColumnCollection.FindByName(const AName: string): TThemedGridDetailGridColumn;
var
  I: Integer;
begin
  if AName = '' then
    Exit(nil);
  for I := 0 to Count - 1 do
    if (Items[I] <> nil) and (Items[I].Name = AName) then
      Exit(Items[I]);
  Result := nil;
end;

function TThemedGridDetailGridColumnCollection.FindByDataPropertyName(
  const ADataPropertyName: string): TThemedGridDetailGridColumn;
var
  I: Integer;
begin
  if ADataPropertyName = '' then
    Exit(nil);
  for I := 0 to Count - 1 do
    if (Items[I] <> nil) and (Items[I].DataPropertyName = ADataPropertyName) then
      Exit(Items[I]);
  Result := nil;
end;

end.

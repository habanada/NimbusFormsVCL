unit NimbusForms.Grid.ColumnCollection;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column;

type
  TThemedGridColumnCollection = class
  private
    FItems: TObjectList<TThemedGridColumn>;
    FOnChanged: TNotifyEvent;
    procedure Attach(const AColumn: TThemedGridColumn);
    procedure Detach(const AColumn: TThemedGridColumn);
    procedure ColumnChanged(ASender: TObject);
    procedure NormalizeVisibleIndexes;
    function CreateDefaultName: string;
    procedure DoChanged;
    function GetItem(const AIndex: Integer): TThemedGridColumn;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AColumn: TThemedGridColumn): TThemedGridColumn; overload;
    function Add(const AName, AFieldName, AHeaderText: string): TThemedGridColumn; overload;
    function AddText(const AName, AFieldName: string): TThemedGridColumn; overload;
    function AddText(const AName, AFieldName, AHeaderText: string): TThemedGridColumn; overload;
    function AddNumber(const AName, AFieldName, AFormatString: string): TThemedGridColumn;
    function AddDate(const AName, AFieldName, AFormatString: string): TThemedGridColumn;
    function AddCheck(const AName, AFieldName: string): TThemedGridColumn;
    function AddImage(const AName, AFieldName: string): TThemedGridColumn;
    procedure Insert(const AIndex: Integer; const AColumn: TThemedGridColumn);
    procedure RemoveAt(const AIndex: Integer);
    function Remove(const AColumn: TThemedGridColumn): Boolean;
    procedure Clear;
    function Contains(const AName: string): Boolean;
    function IndexOf(const AColumn: TThemedGridColumn): Integer; overload;
    function IndexOf(const AName: string): Integer; overload;
    function FindByName(const AName: string): TThemedGridColumn;
    function GetVisibleColumns: TList<TThemedGridColumn>;
    function GetVisibleWidth: Integer;
    property Items[const AIndex: Integer]: TThemedGridColumn read GetItem; default;
    property Count: Integer read GetCount;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

uses
  System.Generics.Defaults;

constructor TThemedGridColumnCollection.Create;
begin
  inherited Create;
  FItems := TObjectList<TThemedGridColumn>.Create(True);
end;

destructor TThemedGridColumnCollection.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Detach(FItems[I]);
  FItems.Free;
  inherited Destroy;
end;

function TThemedGridColumnCollection.GetItem(const AIndex: Integer): TThemedGridColumn;
begin
  Result := FItems[AIndex];
end;

function TThemedGridColumnCollection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TThemedGridColumnCollection.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridColumnCollection.Attach(const AColumn: TThemedGridColumn);
begin
  if AColumn = nil then
    Exit;
  AColumn.OnChanged := ColumnChanged;
end;

procedure TThemedGridColumnCollection.Detach(const AColumn: TThemedGridColumn);
begin
  if AColumn = nil then
    Exit;
  AColumn.OnChanged := nil;
end;

procedure TThemedGridColumnCollection.ColumnChanged(ASender: TObject);
begin
  NormalizeVisibleIndexes;
  DoChanged;
end;

procedure TThemedGridColumnCollection.NormalizeVisibleIndexes;
var
  I, LVisibleIndex: Integer;
  LColumn: TThemedGridColumn;
begin
  LVisibleIndex := 0;
  for I := 0 to FItems.Count - 1 do
  begin
    LColumn := FItems[I];
    if not LColumn.Visible then
      Continue;
    if LColumn.VisibleIndex < 0 then
      LColumn.VisibleIndex := LVisibleIndex;
    Inc(LVisibleIndex);
  end;
end;

function TThemedGridColumnCollection.CreateDefaultName: string;
var
  LIndex: Integer;
  LName: string;
begin
  LIndex := FItems.Count + 1;
  LName := 'Column' + IntToStr(LIndex);
  while Contains(LName) do
  begin
    Inc(LIndex);
    LName := 'Column' + IntToStr(LIndex);
  end;
  Result := LName;
end;

function TThemedGridColumnCollection.Add(const AColumn: TThemedGridColumn): TThemedGridColumn;
begin
  if AColumn = nil then
    raise EArgumentNilException.Create('column');
  if AColumn.Name = '' then
    AColumn.Name := CreateDefaultName;
  FItems.Add(AColumn);
  Attach(AColumn);
  NormalizeVisibleIndexes;
  DoChanged;
  Result := AColumn;
end;

function TThemedGridColumnCollection.Add(const AName, AFieldName, AHeaderText: string): TThemedGridColumn;
begin
  Result := Add(TThemedGridColumn.Create(AName, AFieldName, AHeaderText));
end;

function TThemedGridColumnCollection.AddText(const AName, AFieldName: string): TThemedGridColumn;
var
  LColumn: TThemedGridColumn;
begin
  LColumn := TThemedGridColumn.Create(AName, AFieldName, AName);
  LColumn.RenderKind := TThemedGridCellRenderKind.Text;
  LColumn.EditorKind := TThemedGridEditorKind.TextBox;
  Result := Add(LColumn);
end;

function TThemedGridColumnCollection.AddText(const AName, AFieldName, AHeaderText: string): TThemedGridColumn;
var
  LColumn: TThemedGridColumn;
begin
  LColumn := TThemedGridColumn.Create(AName, AFieldName, AHeaderText);
  LColumn.RenderKind := TThemedGridCellRenderKind.Text;
  LColumn.EditorKind := TThemedGridEditorKind.TextBox;
  Result := Add(LColumn);
end;

function TThemedGridColumnCollection.AddNumber(const AName, AFieldName, AFormatString: string): TThemedGridColumn;
var
  LColumn: TThemedGridColumn;
begin
  LColumn := TThemedGridColumn.Create(AName, AFieldName, AName);
  LColumn.RenderKind := TThemedGridCellRenderKind.Number;
  LColumn.EditorKind := TThemedGridEditorKind.Numeric;
  LColumn.FormatString := AFormatString;
  LColumn.TextAlignment := TThemedGridContentAlignment.MiddleRight;
  Result := Add(LColumn);
end;

function TThemedGridColumnCollection.AddDate(const AName, AFieldName, AFormatString: string): TThemedGridColumn;
var
  LColumn: TThemedGridColumn;
begin
  LColumn := TThemedGridColumn.Create(AName, AFieldName, AName);
  LColumn.RenderKind := TThemedGridCellRenderKind.Date;
  LColumn.EditorKind := TThemedGridEditorKind.DatePicker;
  LColumn.FormatString := AFormatString;
  Result := Add(LColumn);
end;

function TThemedGridColumnCollection.AddCheck(const AName, AFieldName: string): TThemedGridColumn;
var
  LColumn: TThemedGridColumn;
begin
  LColumn := TThemedGridColumn.Create(AName, AFieldName, AName);
  LColumn.RenderKind := TThemedGridCellRenderKind.CheckBox;
  LColumn.EditorKind := TThemedGridEditorKind.CheckBox;
  LColumn.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result := Add(LColumn);
end;

function TThemedGridColumnCollection.AddImage(const AName, AFieldName: string): TThemedGridColumn;
var
  LColumn: TThemedGridColumn;
begin
  LColumn := TThemedGridColumn.Create(AName, AFieldName, AName);
  LColumn.RenderKind := TThemedGridCellRenderKind.Image;
  LColumn.EditorKind := TThemedGridEditorKind.ImagePicker;
  LColumn.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
  Result := Add(LColumn);
end;

procedure TThemedGridColumnCollection.Insert(const AIndex: Integer; const AColumn: TThemedGridColumn);
begin
  if AColumn = nil then
    raise EArgumentException.Create('value');
  if AColumn.Name = '' then
    AColumn.Name := CreateDefaultName;
  FItems.Insert(AIndex, AColumn);
  Attach(AColumn);
  NormalizeVisibleIndexes;
  DoChanged;
end;

procedure TThemedGridColumnCollection.RemoveAt(const AIndex: Integer);
begin
  Detach(FItems[AIndex]);
  FItems.Delete(AIndex);
  NormalizeVisibleIndexes;
  DoChanged;
end;

function TThemedGridColumnCollection.Remove(const AColumn: TThemedGridColumn): Boolean;
var
  LIndex: Integer;
begin
  LIndex := FItems.IndexOf(AColumn);
  if LIndex < 0 then
    Exit(False);
  RemoveAt(LIndex);
  Result := True;
end;

procedure TThemedGridColumnCollection.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    Detach(FItems[I]);
  FItems.Clear;
  DoChanged;
end;

function TThemedGridColumnCollection.Contains(const AName: string): Boolean;
begin
  Result := FindByName(AName) <> nil;
end;

function TThemedGridColumnCollection.IndexOf(const AColumn: TThemedGridColumn): Integer;
begin
  Result := FItems.IndexOf(AColumn);
end;

function TThemedGridColumnCollection.IndexOf(const AName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].Name, AName) then
      Exit(I);
  Result := -1;
end;

function TThemedGridColumnCollection.FindByName(const AName: string): TThemedGridColumn;
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

function TThemedGridColumnCollection.GetVisibleColumns: TList<TThemedGridColumn>;
var
  I: Integer;
begin
  Result := TList<TThemedGridColumn>.Create;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Visible then
      Result.Add(FItems[I]);
  Result.Sort(TComparer<TThemedGridColumn>.Construct(
    function(const L, R: TThemedGridColumn): Integer
    begin
      Result := L.VisibleIndex - R.VisibleIndex;
      if Result = 0 then
        Result := CompareText(L.Name, R.Name);
    end));
end;

function TThemedGridColumnCollection.GetVisibleWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Visible then
      Inc(Result, FItems[I].Width);
end;

end.

unit NimbusForms.Grid.Column;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.EditorOptions;

type
  TThemedGridValueGetter = reference to function(const ARow: TValue): TValue;
  TThemedGridValueSetter = reference to procedure(const ARow, AValue: TValue);

  TThemedGridColumn = class
  private
    FName: string;
    FFieldName: string;
    FHeaderText: string;
    FBandName: string;
    FTag: TValue;
    FWidth: Integer;
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FAutoSize: Boolean;
    FAutoSizeMode: TThemedGridAutoSizeMode;
    FVisible: Boolean;
    FVisibleIndex: Integer;
    FReadOnly: Boolean;
    FValueType: PTypeInfo;
    FFormatString: string;
    FFormatSettings: TFormatSettings;
    FHasFormatProvider: Boolean;
    FFilter: TObject;
    FIsFiltered: Boolean;
    FNullText: string;
    FNullDisplayMode: TThemedGridNullDisplayMode;
    FTextAlignment: TThemedGridContentAlignment;
    FRenderKind: TThemedGridCellRenderKind;
    FEditorKind: TThemedGridEditorKind;
    FEditorOptions: TThemedGridEditorOptions;
    FFixedStyle: TThemedGridColumnFixedStyle;
    FFillWeight: Integer;
    FSortDirection: TThemedGridSortDirection;
    FAllowFilter: Boolean;
    FFilterMode: TThemedGridFilterMode;
    FSummaryType: TThemedGridSummaryType;
    FSummaryFormatString: string;
    FSummaryText: string;
    FSummaryPrefix: string;
    FSummarySuffix: string;
    FValueGetter: TThemedGridValueGetter;
    FValueSetter: TThemedGridValueSetter;
    FRenderer: IInterface;
    FEditor: IInterface;
    FOnChanged: TNotifyEvent;
    procedure SetName(const AValue: string);
    procedure SetFieldName(const AValue: string);
    procedure SetHeaderText(const AValue: string);
    procedure SetBandName(const AValue: string);
    procedure SetWidth(const AValue: Integer);
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    procedure SetAutoSizeMode(const AValue: TThemedGridAutoSizeMode);
    procedure SetVisible(const AValue: Boolean);
    procedure SetVisibleIndex(const AValue: Integer);
    procedure SetNullDisplayMode(const AValue: TThemedGridNullDisplayMode);
    procedure SetTextAlignment(const AValue: TThemedGridContentAlignment);
    procedure SetRenderKind(const AValue: TThemedGridCellRenderKind);
    procedure SetEditorKind(const AValue: TThemedGridEditorKind);
    procedure SetFixedStyle(const AValue: TThemedGridColumnFixedStyle);
    procedure SetFillWeight(const AValue: Integer);
    procedure SetSortDirection(const AValue: TThemedGridSortDirection);
    procedure SetAllowFilter(const AValue: Boolean);
    procedure SetFilterMode(const AValue: TThemedGridFilterMode);
    procedure SetSummaryType(const AValue: TThemedGridSummaryType);
    procedure SetSummaryFormatString(const AValue: string);
    procedure SetSummaryText(const AValue: string);
    procedure SetSummaryPrefix(const AValue: string);
    procedure SetSummarySuffix(const AValue: string);
    procedure SetFormatSettings(const AValue: TFormatSettings);
    function GetEditorOptions: TThemedGridEditorOptions;
    procedure DoChanged;
  public
    constructor Create; overload;
    constructor Create(const AName, AFieldName, AHeaderText: string); overload;
    destructor Destroy; override;
    function GetBestHeaderText: string;
    function ToString: string; override;
    property Name: string read FName write SetName;
    property FieldName: string read FFieldName write SetFieldName;
    property HeaderText: string read FHeaderText write SetHeaderText;
    property BandName: string read FBandName write SetBandName;
    property Tag: TValue read FTag write FTag;
    property Width: Integer read FWidth write SetWidth;
    property MinWidth: Integer read FMinWidth write SetMinWidth;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth;
    property AutoSize: Boolean read FAutoSize write FAutoSize;
    property AutoSizeMode: TThemedGridAutoSizeMode read FAutoSizeMode write SetAutoSizeMode;
    property Visible: Boolean read FVisible write SetVisible;
    property VisibleIndex: Integer read FVisibleIndex write SetVisibleIndex;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property ValueType: PTypeInfo read FValueType write FValueType;
    property FormatString: string read FFormatString write FFormatString;
    property FormatProvider: TFormatSettings read FFormatSettings write SetFormatSettings;
    property HasFormatProvider: Boolean read FHasFormatProvider;
    property NullText: string read FNullText write FNullText;
    property NullDisplayMode: TThemedGridNullDisplayMode read FNullDisplayMode write SetNullDisplayMode;
    property TextAlignment: TThemedGridContentAlignment read FTextAlignment write SetTextAlignment;
    property RenderKind: TThemedGridCellRenderKind read FRenderKind write SetRenderKind;
    property EditorKind: TThemedGridEditorKind read FEditorKind write SetEditorKind;
    property EditorOptions: TThemedGridEditorOptions read GetEditorOptions;
    property FixedStyle: TThemedGridColumnFixedStyle read FFixedStyle write SetFixedStyle;
    property FillWeight: Integer read FFillWeight write SetFillWeight;
    property SortDirection: TThemedGridSortDirection read FSortDirection write SetSortDirection;
    property AllowFilter: Boolean read FAllowFilter write SetAllowFilter;
    property FilterMode: TThemedGridFilterMode read FFilterMode write SetFilterMode;
    property Filter: TObject read FFilter write FFilter;
    property IsFiltered: Boolean read FIsFiltered write FIsFiltered;
    property SummaryType: TThemedGridSummaryType read FSummaryType write SetSummaryType;
    property SummaryFormatString: string read FSummaryFormatString write SetSummaryFormatString;
    property SummaryText: string read FSummaryText write SetSummaryText;
    property SummaryPrefix: string read FSummaryPrefix write SetSummaryPrefix;
    property SummarySuffix: string read FSummarySuffix write SetSummarySuffix;
    property ValueGetter: TThemedGridValueGetter read FValueGetter write FValueGetter;
    property ValueSetter: TThemedGridValueSetter read FValueSetter write FValueSetter;
    property Renderer: IInterface read FRenderer write FRenderer;
    property Editor: IInterface read FEditor write FEditor;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridColumn.Create;
begin
  inherited Create;
  FWidth := 120;
  FMinWidth := 24;
  FMaxWidth := 1000;
  FVisible := True;
  FVisibleIndex := -1;
  FTextAlignment := TThemedGridContentAlignment.MiddleLeft;
  FAutoSizeMode := TThemedGridAutoSizeMode.None;
  FRenderKind := TThemedGridCellRenderKind.Auto;
  FEditorKind := TThemedGridEditorKind.TextBox;
  FNullDisplayMode := TThemedGridNullDisplayMode.Empty;
  FFixedStyle := TThemedGridColumnFixedStyle.None;
  FSortDirection := TThemedGridSortDirection.None;
  FAllowFilter := True;
  FFilterMode := TThemedGridFilterMode.Auto;
  FSummaryType := TThemedGridSummaryType.None;
  FFillWeight := 100;
end;

constructor TThemedGridColumn.Create(const AName, AFieldName, AHeaderText: string);
begin
  Create;
  FName := AName;
  FFieldName := AFieldName;
  FHeaderText := AHeaderText;
end;

destructor TThemedGridColumn.Destroy;
begin
  FEditorOptions.Free;
  inherited Destroy;
end;

procedure TThemedGridColumn.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridColumn.SetName(const AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetFieldName(const AValue: string);
begin
  if FFieldName = AValue then
    Exit;
  FFieldName := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetHeaderText(const AValue: string);
begin
  if FHeaderText = AValue then
    Exit;
  FHeaderText := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetBandName(const AValue: string);
begin
  if FBandName = AValue then
    Exit;
  FBandName := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < FMinWidth then
    LValue := FMinWidth;
  if LValue > FMaxWidth then
    LValue := FMaxWidth;
  if FWidth = LValue then
    Exit;
  FWidth := LValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetMinWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 8 then
    LValue := 8;
  if FMinWidth = LValue then
    Exit;
  FMinWidth := LValue;
  if FWidth < FMinWidth then
    FWidth := FMinWidth;
  if FMaxWidth < FMinWidth then
    FMaxWidth := FMinWidth;
  DoChanged;
end;

procedure TThemedGridColumn.SetMaxWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < FMinWidth then
    LValue := FMinWidth;
  if FMaxWidth = LValue then
    Exit;
  FMaxWidth := LValue;
  if FWidth > FMaxWidth then
    FWidth := FMaxWidth;
  DoChanged;
end;

procedure TThemedGridColumn.SetAutoSizeMode(const AValue: TThemedGridAutoSizeMode);
begin
  if FAutoSizeMode = AValue then
    Exit;
  FAutoSizeMode := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetVisibleIndex(const AValue: Integer);
begin
  if FVisibleIndex = AValue then
    Exit;
  FVisibleIndex := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetNullDisplayMode(const AValue: TThemedGridNullDisplayMode);
begin
  if FNullDisplayMode = AValue then
    Exit;
  FNullDisplayMode := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetTextAlignment(const AValue: TThemedGridContentAlignment);
begin
  if FTextAlignment = AValue then
    Exit;
  FTextAlignment := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetRenderKind(const AValue: TThemedGridCellRenderKind);
begin
  if FRenderKind = AValue then
    Exit;
  FRenderKind := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetEditorKind(const AValue: TThemedGridEditorKind);
begin
  if FEditorKind = AValue then
    Exit;
  FEditorKind := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetFixedStyle(const AValue: TThemedGridColumnFixedStyle);
begin
  if FFixedStyle = AValue then
    Exit;
  FFixedStyle := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetFillWeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then
    LValue := 1;
  if FFillWeight = LValue then
    Exit;
  FFillWeight := LValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetSortDirection(const AValue: TThemedGridSortDirection);
begin
  if FSortDirection = AValue then
    Exit;
  FSortDirection := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetAllowFilter(const AValue: Boolean);
begin
  if FAllowFilter = AValue then
    Exit;
  FAllowFilter := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetFilterMode(const AValue: TThemedGridFilterMode);
begin
  if FFilterMode = AValue then
    Exit;
  FFilterMode := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetSummaryType(const AValue: TThemedGridSummaryType);
begin
  if FSummaryType = AValue then
    Exit;
  FSummaryType := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetSummaryFormatString(const AValue: string);
begin
  if FSummaryFormatString = AValue then
    Exit;
  FSummaryFormatString := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetSummaryText(const AValue: string);
begin
  if FSummaryText = AValue then
    Exit;
  FSummaryText := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetSummaryPrefix(const AValue: string);
begin
  if FSummaryPrefix = AValue then
    Exit;
  FSummaryPrefix := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetSummarySuffix(const AValue: string);
begin
  if FSummarySuffix = AValue then
    Exit;
  FSummarySuffix := AValue;
  DoChanged;
end;

procedure TThemedGridColumn.SetFormatSettings(const AValue: TFormatSettings);
begin
  FFormatSettings := AValue;
  FHasFormatProvider := True;
end;

function TThemedGridColumn.GetEditorOptions: TThemedGridEditorOptions;
begin
  if FEditorOptions = nil then
    FEditorOptions := TThemedGridEditorOptions.Create;
  Result := FEditorOptions;
end;

function TThemedGridColumn.GetBestHeaderText: string;
begin
  if FHeaderText <> '' then
    Exit(FHeaderText);
  if FName <> '' then
    Exit(FName);
  Result := FFieldName;
end;

function TThemedGridColumn.ToString: string;
begin
  Result := GetBestHeaderText;
end;

end.

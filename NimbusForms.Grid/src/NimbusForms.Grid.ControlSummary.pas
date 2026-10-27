unit NimbusForms.Grid.ControlSummary;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.Generics.Collections,   System.TypInfo,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.ControlCells;

type
  TThemedGridControlSummary = class(TThemedGridControlCells)
  private
    FSummaryCache: TDictionary<string, string>;
    FSummaryCacheVersion: Integer;
    FSummaryCacheRowCount: Integer;
    FSummaryHoverColumnIndex: Integer;
    FSummaryPressedColumnIndex: Integer;
    FOnCustomSummaryCalculate: TThemedGridSummaryCustomEvent;
    FOnSummaryCellClick: TThemedGridSummaryCellEvent;
    FOnSummaryCellDoubleClick: TThemedGridSummaryCellEvent;
    procedure EnsureSummaryCache;
    function CalculateSummaryText(const AColumn: TThemedGridColumn): string;
    function CalculateCustomSummaryText(const AColumn: TThemedGridColumn): string;
    function CalculateNumericSummary(const AColumn: TThemedGridColumn; const ASummaryType: TThemedGridSummaryType): Extended;
    function FormatSummaryValue(const AColumn: TThemedGridColumn; const AValue: TValue): string;
    function ApplySummaryPrefixSuffix(const AColumn: TThemedGridColumn; const AText: string): string;
  protected
    procedure DoCustomSummaryCalculate(const AArgs: TThemedGridSummaryCustomEventArgs); virtual;
    procedure DoSummaryCellClick(const AArgs: TThemedGridSummaryCellEventArgs); virtual;
    procedure DoSummaryCellDoubleClick(const AArgs: TThemedGridSummaryCellEventArgs); virtual;
    procedure InvalidateSummaryCache;
    function GetSummaryText(const AColumn: TThemedGridColumn): string;
    function GetSummaryFooterCellBounds(const AColumnIndex: Integer): TRect;
    function GetSummaryFooterColumnIndex(const ALocation: TPoint): Integer;
    function GetFixedLeftSummaryFooterViewportBounds: TRect;
    function GetFixedRightSummaryFooterViewportBounds: TRect;
    function GetScrollableSummaryFooterViewportBounds: TRect;
    function CreateSummaryCellEventArgs(const AColumnIndex: Integer): TThemedGridSummaryCellEventArgs;
    property SummaryHoverColumnIndex: Integer read FSummaryHoverColumnIndex write FSummaryHoverColumnIndex;
    property SummaryPressedColumnIndex: Integer read FSummaryPressedColumnIndex write FSummaryPressedColumnIndex;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearSummaryCache;
    property OnCustomSummaryCalculate: TThemedGridSummaryCustomEvent
      read FOnCustomSummaryCalculate write FOnCustomSummaryCalculate;
    property OnSummaryCellClick: TThemedGridSummaryCellEvent read FOnSummaryCellClick write FOnSummaryCellClick;
    property OnSummaryCellDoubleClick: TThemedGridSummaryCellEvent
      read FOnSummaryCellDoubleClick write FOnSummaryCellDoubleClick;
  end;

implementation

uses
  System.Math,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter;

constructor TThemedGridControlSummary.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSummaryCache := TDictionary<string, string>.Create;
  FSummaryCacheVersion := -1;
  FSummaryCacheRowCount := -1;
  FSummaryHoverColumnIndex := -1;
  FSummaryPressedColumnIndex := -1;
end;

destructor TThemedGridControlSummary.Destroy;
begin
  FSummaryCache.Free;
  inherited Destroy;
end;

procedure TThemedGridControlSummary.DoCustomSummaryCalculate(const AArgs: TThemedGridSummaryCustomEventArgs);
begin
  if Assigned(FOnCustomSummaryCalculate) then
    FOnCustomSummaryCalculate(Self, AArgs);
end;

procedure TThemedGridControlSummary.DoSummaryCellClick(const AArgs: TThemedGridSummaryCellEventArgs);
begin
  if Assigned(FOnSummaryCellClick) then
    FOnSummaryCellClick(Self, AArgs);
end;

procedure TThemedGridControlSummary.DoSummaryCellDoubleClick(const AArgs: TThemedGridSummaryCellEventArgs);
begin
  if Assigned(FOnSummaryCellDoubleClick) then
    FOnSummaryCellDoubleClick(Self, AArgs);
end;

procedure TThemedGridControlSummary.InvalidateSummaryCache;
begin
  FSummaryCache.Clear;
  FSummaryCacheVersion := -1;
  FSummaryCacheRowCount := -1;
end;

procedure TThemedGridControlSummary.ClearSummaryCache;
begin
  InvalidateSummaryCache;
  Invalidate;
end;

function TThemedGridControlSummary.GetSummaryText(const AColumn: TThemedGridColumn): string;
begin
  if AColumn = nil then
    Exit('');
  if AColumn.SummaryType = TThemedGridSummaryType.None then
    Exit('');
  EnsureSummaryCache;
  if not FSummaryCache.TryGetValue(AColumn.Name, Result) then
    Result := '';
end;

procedure TThemedGridControlSummary.EnsureSummaryCache;
var
  LVersion, LRowCount, I: Integer;
  LColumns: TList<TThemedGridColumn>;
  LColumn: TThemedGridColumn;
begin
  if DataController <> nil then
  begin
    LVersion := DataController.Version;
    LRowCount := DataController.RowCount;
  end
  else
  begin
    LVersion := -1;
    LRowCount := 0;
  end;
  if (FSummaryCacheVersion = LVersion) and (FSummaryCacheRowCount = LRowCount) then
    Exit;
  FSummaryCache.Clear;
  FSummaryCacheVersion := LVersion;
  FSummaryCacheRowCount := LRowCount;
  if DataController = nil then
    Exit;
  LColumns := GetVisibleColumns;
  for I := 0 to LColumns.Count - 1 do
  begin
    LColumn := LColumns[I];
    if LColumn.SummaryType = TThemedGridSummaryType.None then
      Continue;
    FSummaryCache.AddOrSetValue(LColumn.Name, CalculateSummaryText(LColumn));
  end;
end;

function TThemedGridControlSummary.CalculateSummaryText(const AColumn: TThemedGridColumn): string;
var
  LRowCount: Integer;
  LValue: TValue;
  LArgs: TThemedGridSummaryCustomEventArgs;
begin
  if AColumn = nil then
    Exit('');
  if AColumn.SummaryText <> '' then
    Exit(AColumn.SummaryText);
  if DataController <> nil then
    LRowCount := DataController.RowCount
  else
    LRowCount := 0;
  LValue := TValue.Empty;
  case AColumn.SummaryType of
    TThemedGridSummaryType.Count:
      LValue := TValue.From<Integer>(LRowCount);
    TThemedGridSummaryType.Sum:
      LValue := TValue.From<Extended>(CalculateNumericSummary(AColumn, TThemedGridSummaryType.Sum));
    TThemedGridSummaryType.Min:
      LValue := TValue.From<Extended>(CalculateNumericSummary(AColumn, TThemedGridSummaryType.Min));
    TThemedGridSummaryType.Max:
      LValue := TValue.From<Extended>(CalculateNumericSummary(AColumn, TThemedGridSummaryType.Max));
    TThemedGridSummaryType.Average:
      LValue := TValue.From<Extended>(CalculateNumericSummary(AColumn, TThemedGridSummaryType.Average));
    TThemedGridSummaryType.Custom:
      Exit(CalculateCustomSummaryText(AColumn));
  end;
  LArgs := TThemedGridSummaryCustomEventArgs.Create;
  try
    LArgs.Column := AColumn;
    LArgs.SummaryType := AColumn.SummaryType;
    LArgs.Value := LValue;
    LArgs.DisplayText := FormatSummaryValue(AColumn, LValue);
    DoCustomSummaryCalculate(LArgs);
    Result := LArgs.DisplayText;
  finally
    LArgs.Free;
  end;
end;

function TThemedGridControlSummary.CalculateCustomSummaryText(const AColumn: TThemedGridColumn): string;
var
  LArgs: TThemedGridSummaryCustomEventArgs;
begin
  LArgs := TThemedGridSummaryCustomEventArgs.Create;
  try
    LArgs.Column := AColumn;
    LArgs.SummaryType := TThemedGridSummaryType.Custom;
    LArgs.Value := TValue.Empty;
    LArgs.DisplayText := '';
    DoCustomSummaryCalculate(LArgs);
    if LArgs.Handled then
      Result := LArgs.DisplayText
    else
      Result := '';
  finally
    LArgs.Free;
  end;
end;

function TThemedGridControlSummary.CalculateNumericSummary(const AColumn: TThemedGridColumn;
  const ASummaryType: TThemedGridSummaryType): Extended;
var
  LSum, LNumber: Extended;
  LCount, LRowCount, LRowIndex, LDataSourceIndex: Integer;
  LHasValue: Boolean;
  LValue: TValue;
begin
  Result := 0;
  LSum := 0;
  LCount := 0;
  LHasValue := False;
  if DataController = nil then
    Exit;
  LRowCount := DataController.RowCount;
  for LRowIndex := 0 to LRowCount - 1 do
  begin
    LDataSourceIndex := DataController.GetDataSourceIndex(LRowIndex);
    if LDataSourceIndex < 0 then
      Continue;
    LValue := DataController.GetValue(LDataSourceIndex, AColumn);
    if TThemedGridValueConverter.IsNull(LValue) then
      Continue;
    if not TThemedGridValueConverter.TryToNumber(LValue, LNumber) then
      Continue;
    if not LHasValue then
    begin
      Result := LNumber;
      LHasValue := True;
    end;
    if (ASummaryType = TThemedGridSummaryType.Min) and (LNumber < Result) then
      Result := LNumber;
    if (ASummaryType = TThemedGridSummaryType.Max) and (LNumber > Result) then
      Result := LNumber;
    LSum := LSum + LNumber;
    Inc(LCount);
  end;
  if not LHasValue then
    Exit(0);
  if ASummaryType = TThemedGridSummaryType.Sum then
    Exit(LSum);
  if ASummaryType = TThemedGridSummaryType.Average then
  begin
    if LCount > 0 then
      Exit(LSum / LCount);
    Exit(0);
  end;
end;

function TThemedGridControlSummary.FormatSummaryValue(const AColumn: TThemedGridColumn;
  const AValue: TValue): string;
var
  LFormat: string;
  LHandled: Boolean;
  LSettings: TFormatSettings;
begin
  LFormat := AColumn.SummaryFormatString;
  if LFormat = '' then
    LFormat := AColumn.FormatString;
  if LFormat <> '' then
  begin
    if AColumn.HasFormatProvider then
      LSettings := AColumn.FormatProvider
    else
      LSettings := FormatSettings;
    Result := TThemedGridValueFormatter.FormatByString(AValue, LFormat, LSettings, LHandled);
    if LHandled then
      Exit(ApplySummaryPrefixSuffix(AColumn, Result));
  end;
  Result := ApplySummaryPrefixSuffix(AColumn, TThemedGridValueConverter.ToText(AValue));
end;

function TThemedGridControlSummary.ApplySummaryPrefixSuffix(const AColumn: TThemedGridColumn;
  const AText: string): string;
begin
  Result := AText;
  if AColumn = nil then
    Exit;
  if AColumn.SummaryPrefix <> '' then
    Result := AColumn.SummaryPrefix + Result;
  if AColumn.SummarySuffix <> '' then
    Result := Result + AColumn.SummarySuffix;
end;

function TThemedGridControlSummary.GetFixedLeftSummaryFooterViewportBounds: TRect;
var
  LWidth: Integer;
begin
  LWidth := Min(GetFixedLeftWidth, SummaryFooterBounds.Right - SummaryFooterBounds.Left);
  if LWidth <= 0 then
    Exit(Rect(0, 0, 0, 0));
  Result := Rect(SummaryFooterBounds.Left, SummaryFooterBounds.Top, SummaryFooterBounds.Left + LWidth,
    SummaryFooterBounds.Bottom);
end;

function TThemedGridControlSummary.GetFixedRightSummaryFooterViewportBounds: TRect;
var
  LWidth: Integer;
begin
  LWidth := Min(GetFixedRightWidth, SummaryFooterBounds.Right - SummaryFooterBounds.Left);
  if LWidth <= 0 then
    Exit(Rect(0, 0, 0, 0));
  Result := Rect(SummaryFooterBounds.Right - LWidth, SummaryFooterBounds.Top, SummaryFooterBounds.Right,
    SummaryFooterBounds.Bottom);
end;

function TThemedGridControlSummary.GetScrollableSummaryFooterViewportBounds: TRect;
var
  LLeftWidth, LRemaining, LRightWidth, LLeft, LRight: Integer;
begin
  LLeftWidth := Min(GetFixedLeftWidth, SummaryFooterBounds.Right - SummaryFooterBounds.Left);
  LRemaining := Max(0, SummaryFooterBounds.Right - SummaryFooterBounds.Left - LLeftWidth);
  LRightWidth := Min(GetFixedRightWidth, LRemaining);
  LLeft := SummaryFooterBounds.Left + LLeftWidth;
  LRight := SummaryFooterBounds.Right - LRightWidth;
  if LRight < LLeft then
    LRight := LLeft;
  Result := Rect(LLeft, SummaryFooterBounds.Top, LRight, SummaryFooterBounds.Bottom);
end;

function TThemedGridControlSummary.GetSummaryFooterCellBounds(const AColumnIndex: Integer): TRect;
var
  LColumn: TThemedGridColumn;
  LX: Integer;
begin
  if (SummaryFooterBounds.Right <= SummaryFooterBounds.Left) or
     (SummaryFooterBounds.Bottom <= SummaryFooterBounds.Top) then
    Exit(Rect(0, 0, 0, 0));
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit(Rect(0, 0, 0, 0));
  if LColumn.FixedStyle = TThemedGridColumnFixedStyle.Left then
    LX := DataBounds.Left + GetFixedColumnLeft(AColumnIndex)
  else if LColumn.FixedStyle = TThemedGridColumnFixedStyle.Right then
    LX := DataBounds.Right - GetFixedRightWidth + GetFixedRightColumnLeft(AColumnIndex)
  else
    LX := GetScrollableViewportBounds.Left + GetScrollableColumnLeft(AColumnIndex) - HorizontalOffset;
  Result := Rect(LX, SummaryFooterBounds.Top, LX + LColumn.Width, SummaryFooterBounds.Bottom);
end;

function TThemedGridControlSummary.GetSummaryFooterColumnIndex(const ALocation: TPoint): Integer;
var
  I: Integer;
  LBounds: TRect;
begin
  for I := 0 to GetVisibleColumns.Count - 1 do
  begin
    LBounds := GetSummaryFooterCellBounds(I);
    if PtInRect(LBounds, ALocation) then
      Exit(I);
  end;
  Result := -1;
end;

function TThemedGridControlSummary.CreateSummaryCellEventArgs(const AColumnIndex: Integer): TThemedGridSummaryCellEventArgs;
begin
  Result := TThemedGridSummaryCellEventArgs.Create;
  Result.ColumnIndex := AColumnIndex;
  Result.Column := GetColumn(AColumnIndex);
  Result.Bounds := GetSummaryFooterCellBounds(AColumnIndex);
  Result.Text := GetSummaryText(Result.Column);
end;

end.

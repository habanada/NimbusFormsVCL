unit NimbusForms.Grid.DistinctValueList;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Math,
  System.Rtti,
  System.TypInfo,
  System.StrUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  System.UITypes,
  Vcl.StdCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.DistinctValue;

type
  TThemedGridDistinctValueList = class(TCustomControl)
  private
    FValues: TObjectList<TThemedGridDistinctValue>;
    FVisibleIndexes: TList<Integer>;
    FCheckedKeys: THashSet<string>;
    FScrollBar: TScrollBar;
    FFilterText: string;
    FRowHeight: Integer;
    FHoverIndex: Integer;
    FBackColor: TColor;
    FForeColor: TColor;
    FBorderColor: TColor;
    FHoverColor: TColor;
    FCheckColor: TColor;
    FOnSelectionChanged: TNotifyEvent;
    function GetTotalCount: Integer;
    function GetCheckedCount: Integer;
    function GetListBounds: TRect;
    function GetVisibleIndexAt(const ALocation: TPoint): Integer;
    function GetFirstIndex: Integer;
    function GetVisibleRowCount: Integer;
    function BuildItemText(const AItem: TThemedGridDistinctValue): string;
    procedure ApplyTextFilter;
    procedure UpdateScrollBar;
    procedure UpdateMetrics;
    function ScaleValue(const AValue: Integer): Integer;
    procedure ScrollBarChange(ASender: TObject);
    procedure DoSelectionChanged;
    procedure DrawCheckBox(const ARowBounds: TRect; const AChecked: Boolean);
    class function CreateValueKey(const AValue: TValue): string; static;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure MouseMove(AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure SetValues(const AValues: TObjectList<TThemedGridDistinctValue>);
    procedure SetCheckedValues(const AValues: TList<TValue>);
    procedure SetFilterText(const AText: string);
    procedure SetAllVisibleChecked(const AValue: Boolean);
    function GetCheckedValues: TList<TValue>;
    property TotalCount: Integer read GetTotalCount;
    property CheckedCount: Integer read GetCheckedCount;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
  end;

implementation

uses
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.FilterStrings;

constructor TThemedGridDistinctValueList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValues := TObjectList<TThemedGridDistinctValue>.Create(True);
  FVisibleIndexes := TList<Integer>.Create;
  FCheckedKeys := THashSet<string>.Create(TIStringComparer.Ordinal);
  FHoverIndex := -1;
  FBackColor := clWindow;
  FForeColor := clWindowText;
  FBorderColor := clBtnShadow;
  FHoverColor := clBtnFace;
  FCheckColor := clHighlight;
  DoubleBuffered := True;
  TabStop := True;
  ControlStyle := ControlStyle + [csOpaque];

  FScrollBar := TScrollBar.Create(Self);
  FScrollBar.Parent := Self;
  FScrollBar.Kind := sbVertical;
  FScrollBar.Align := alRight;
  FScrollBar.TabStop := False;
  FScrollBar.Visible := False;
  FScrollBar.OnChange := ScrollBarChange;
  UpdateMetrics;
end;

destructor TThemedGridDistinctValueList.Destroy;
begin
  FCheckedKeys.Free;
  FVisibleIndexes.Free;
  FValues.Free;
  inherited Destroy;
end;

class function TThemedGridDistinctValueList.CreateValueKey(const AValue: TValue): string;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit('<null>');
  Result := string(AValue.TypeInfo.Name) + '|' + TThemedGridValueConverter.ToTextInvariant(AValue);
end;

function TThemedGridDistinctValueList.GetTotalCount: Integer;
begin
  Result := FVisibleIndexes.Count;
end;

function TThemedGridDistinctValueList.GetCheckedCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FVisibleIndexes.Count - 1 do
    if FCheckedKeys.Contains(CreateValueKey(FValues[FVisibleIndexes[I]].Value)) then
      Inc(Result);
end;

function TThemedGridDistinctValueList.ScaleValue(const AValue: Integer): Integer;
begin
  if HandleAllocated then
    Result := MulDiv(AValue, CurrentPPI, 96)
  else
    Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
end;

procedure TThemedGridDistinctValueList.UpdateMetrics;
begin
  FRowHeight := Max(1, ScaleValue(24));
end;

procedure TThemedGridDistinctValueList.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  FBackColor := ThemeColorToColor(APalette.ControlBackColor);
  FForeColor := ThemeColorToColor(APalette.ControlForeColor);
  FBorderColor := ThemeColorToColor(APalette.ControlBorderColor);
  FHoverColor := ThemeColorToColor(APalette.HoverBackColor);
  FCheckColor := ThemeColorToColor(APalette.SelectedBackColor);
  Color := FBackColor;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.SetValues(const AValues: TObjectList<TThemedGridDistinctValue>);
var
  I: Integer;
begin
  FValues.Clear;
  FVisibleIndexes.Clear;
  FCheckedKeys.Clear;
  if AValues <> nil then
    for I := 0 to AValues.Count - 1 do
      if AValues[I] <> nil then
      begin
        FValues.Add(AValues[I].Clone);
        FCheckedKeys.Add(CreateValueKey(AValues[I].Value));
      end;
  ApplyTextFilter;
  UpdateScrollBar;
  DoSelectionChanged;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.SetCheckedValues(const AValues: TList<TValue>);
var
  I: Integer;
begin
  FCheckedKeys.Clear;
  if AValues <> nil then
    for I := 0 to AValues.Count - 1 do
      FCheckedKeys.Add(CreateValueKey(AValues[I]));
  DoSelectionChanged;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.SetFilterText(const AText: string);
begin
  FFilterText := AText;
  ApplyTextFilter;
  UpdateScrollBar;
  DoSelectionChanged;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.SetAllVisibleChecked(const AValue: Boolean);
var
  I: Integer;
  LKey: string;
begin
  for I := 0 to FVisibleIndexes.Count - 1 do
  begin
    LKey := CreateValueKey(FValues[FVisibleIndexes[I]].Value);
    if AValue then
      FCheckedKeys.Add(LKey)
    else
      FCheckedKeys.Remove(LKey);
  end;
  DoSelectionChanged;
  Invalidate;
end;

function TThemedGridDistinctValueList.GetCheckedValues: TList<TValue>;
var
  I: Integer;
begin
  Result := TList<TValue>.Create;
  for I := 0 to FValues.Count - 1 do
    if FCheckedKeys.Contains(CreateValueKey(FValues[I].Value)) then
      Result.Add(FValues[I].Value);
end;

procedure TThemedGridDistinctValueList.ApplyTextFilter;
var
  I: Integer;
begin
  FVisibleIndexes.Clear;
  for I := 0 to FValues.Count - 1 do
    if (FFilterText = '') or ContainsText(FValues[I].DisplayText, FFilterText) then
      FVisibleIndexes.Add(I);
  FHoverIndex := -1;
end;

function TThemedGridDistinctValueList.GetListBounds: TRect;
begin
  Result := Rect(0, 0, ClientWidth, ClientHeight);
  if FScrollBar.Visible then
    Dec(Result.Right, FScrollBar.Width);
end;

function TThemedGridDistinctValueList.GetVisibleRowCount: Integer;
begin
  Result := Max(1, ClientHeight div FRowHeight);
end;

function TThemedGridDistinctValueList.GetFirstIndex: Integer;
begin
  if FScrollBar.Visible then
    Result := FScrollBar.Position
  else
    Result := 0;
end;

procedure TThemedGridDistinctValueList.UpdateScrollBar;
var
  LRows, LMaxFirst: Integer;
begin
  if FScrollBar = nil then
    Exit;
  LRows := GetVisibleRowCount;
  LMaxFirst := Max(0, FVisibleIndexes.Count - LRows);
  if LMaxFirst > 0 then
  begin
    FScrollBar.SetParams(Min(FScrollBar.Position, LMaxFirst), 0, FVisibleIndexes.Count - 1);
    FScrollBar.PageSize := LRows;
    FScrollBar.LargeChange := LRows;
    FScrollBar.SmallChange := 1;
    FScrollBar.Visible := True;
  end
  else
  begin
    FScrollBar.Position := 0;
    FScrollBar.Visible := False;
  end;
end;

function TThemedGridDistinctValueList.GetVisibleIndexAt(const ALocation: TPoint): Integer;
var
  LBounds: TRect;
begin
  LBounds := GetListBounds;
  if not LBounds.Contains(ALocation) then
    Exit(-1);
  Result := GetFirstIndex + (ALocation.Y - LBounds.Top) div FRowHeight;
end;

function TThemedGridDistinctValueList.BuildItemText(const AItem: TThemedGridDistinctValue): string;
begin
  if AItem = nil then
    Exit('');
  Result := AItem.DisplayText + ' (' + IntToStr(AItem.Count) + ')';
end;

procedure TThemedGridDistinctValueList.DrawCheckBox(const ARowBounds: TRect; const AChecked: Boolean);
var
  LSize, LLeft, LTop: Integer;
  LBox: TRect;
  LPoints: array[0..2] of TPoint;
begin
  LSize := ScaleValue(14);
  LLeft := ARowBounds.Left + ScaleValue(7);
  LTop := ARowBounds.Top + (ARowBounds.Height - LSize) div 2;
  LBox := Rect(LLeft, LTop, LLeft + LSize, LTop + LSize);
  if AChecked then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FCheckColor;
    Canvas.FillRect(LBox);
  end;
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.Rectangle(LBox);
  if not AChecked then
    Exit;
  LPoints[0] := Point(LBox.Left + ScaleValue(3), LBox.Top + ScaleValue(7));
  LPoints[1] := Point(LBox.Left + ScaleValue(6), LBox.Bottom - ScaleValue(4));
  LPoints[2] := Point(LBox.Right - ScaleValue(3), LBox.Top + ScaleValue(4));
  Canvas.Pen.Color := FForeColor;
  Canvas.Pen.Width := Max(1, ScaleValue(2));
  Canvas.Polyline(LPoints);
end;

procedure TThemedGridDistinctValueList.Paint;
var
  LListBounds, LRowBounds, LTextBounds: TRect;
  LFirst, LRows, LRow, LVisibleIndex: Integer;
  LItem: TThemedGridDistinctValue;
  LText: string;
begin
  Canvas.Font := Font;
  Canvas.Font.Color := FForeColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FBackColor;
  Canvas.FillRect(ClientRect);
  LListBounds := GetListBounds;
  if FVisibleIndexes.Count = 0 then
  begin
    Canvas.Brush.Style := bsClear;
    LText := ThemedGridFilterStrings.NoValues;
    DrawText(Canvas.Handle, PChar(LText), Length(LText), LListBounds,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
  end
  else
  begin
    LFirst := GetFirstIndex;
    LRows := Max(1, LListBounds.Height div FRowHeight + 1);
    for LRow := 0 to LRows - 1 do
    begin
      LVisibleIndex := LFirst + LRow;
      if (LVisibleIndex < 0) or (LVisibleIndex >= FVisibleIndexes.Count) then
        Break;
      LItem := FValues[FVisibleIndexes[LVisibleIndex]];
      LRowBounds := Rect(LListBounds.Left, LListBounds.Top + LRow * FRowHeight, LListBounds.Right,
        LListBounds.Top + (LRow + 1) * FRowHeight);
      if LVisibleIndex = FHoverIndex then
      begin
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := FHoverColor;
        Canvas.FillRect(LRowBounds);
      end;
      DrawCheckBox(LRowBounds, FCheckedKeys.Contains(CreateValueKey(LItem.Value)));
      LTextBounds := Rect(LRowBounds.Left + ScaleValue(28), LRowBounds.Top,
        LRowBounds.Right - ScaleValue(4), LRowBounds.Bottom);
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := FForeColor;
      LText := BuildItemText(LItem);
      DrawText(Canvas.Handle, PChar(LText), Length(LText), LTextBounds,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX);
    end;
  end;
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);
end;

procedure TThemedGridDistinctValueList.Resize;
begin
  inherited Resize;
  UpdateScrollBar;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.CreateWnd;
begin
  inherited CreateWnd;
  UpdateMetrics;
  UpdateScrollBar;
end;

procedure TThemedGridDistinctValueList.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  UpdateMetrics;
  UpdateScrollBar;
end;

procedure TThemedGridDistinctValueList.MouseMove(AShift: TShiftState; AX, AY: Integer);
var
  LIndex: Integer;
begin
  inherited MouseMove(AShift, AX, AY);
  LIndex := GetVisibleIndexAt(Point(AX, AY));
  if LIndex = FHoverIndex then
    Exit;
  FHoverIndex := LIndex;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if FHoverIndex = -1 then
    Exit;
  FHoverIndex := -1;
  Invalidate;
end;

procedure TThemedGridDistinctValueList.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
var
  LIndex: Integer;
  LKey: string;
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if CanFocus then
    SetFocus;
  if AButton <> mbLeft then
    Exit;
  LIndex := GetVisibleIndexAt(Point(AX, AY));
  if (LIndex < 0) or (LIndex >= FVisibleIndexes.Count) then
    Exit;
  LKey := CreateValueKey(FValues[FVisibleIndexes[LIndex]].Value);
  if FCheckedKeys.Contains(LKey) then
    FCheckedKeys.Remove(LKey)
  else
    FCheckedKeys.Add(LKey);
  DoSelectionChanged;
  Invalidate;
end;

function TThemedGridDistinctValueList.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer;
  AMousePos: TPoint): Boolean;
var
  LValue, LMaxFirst: Integer;
begin
  Result := True;
  if not FScrollBar.Visible then
    Exit;
  LMaxFirst := Max(0, FVisibleIndexes.Count - GetVisibleRowCount);
  if AWheelDelta > 0 then
    LValue := FScrollBar.Position - 3
  else
    LValue := FScrollBar.Position + 3;
  FScrollBar.Position := Max(0, Min(LValue, LMaxFirst));
  Invalidate;
end;

procedure TThemedGridDistinctValueList.ScrollBarChange(ASender: TObject);
begin
  Invalidate;
end;

procedure TThemedGridDistinctValueList.DoSelectionChanged;
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self);
end;

end.

unit NimbusForms.Grid.ControlKeys;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Math,
  Vcl.Controls,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.ControlMouse;

type
  TThemedGridControlKeys = class(TThemedGridControlMouse)
  private
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
    function TryHandleDetailKey(const AKey: Word): Boolean;
  protected
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
    function HandleNavigationKey(const AKey: Word): Boolean;
    function TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean; virtual;
    function ToggleCurrentCellBooleanValue: Boolean; virtual;
    function TryStepCurrentCellValue(const ADirection: Integer): Boolean; virtual;
    function CanBeginEditCurrentCell: Boolean; virtual;
  end;

implementation

procedure TThemedGridControlKeys.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  inherited;
  AMessage.Result := AMessage.Result or DLGC_WANTARROWS;
end;

function TThemedGridControlKeys.TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean;
begin
  Result := False;
end;

function TThemedGridControlKeys.ToggleCurrentCellBooleanValue: Boolean;
begin
  Result := False;
end;

function TThemedGridControlKeys.TryStepCurrentCellValue(const ADirection: Integer): Boolean;
begin
  Result := False;
end;

function TThemedGridControlKeys.CanBeginEditCurrentCell: Boolean;
begin
  Result := False;
end;

function TThemedGridControlKeys.TryHandleDetailKey(const AKey: Word): Boolean;
begin
  if (DetailOptions = nil) or not DetailOptions.Enabled then
    Exit(False);
  if not DetailOptions.HasExpandTrigger(TThemedGridDetailExpandTrigger.Keyboard) then
    Exit(False);
  if (CurrentRowIndex < 0) or not CanExpandDetailRow(CurrentRowIndex) then
    Exit(False);
  case AKey of
    VK_ADD: Result := ExpandDetailRow(CurrentRowIndex);
    VK_SUBTRACT: Result := CollapseDetailRow(CurrentRowIndex);
    VK_MULTIPLY: Result := ToggleDetailRow(CurrentRowIndex);
  else
    Result := False;
  end;
end;

function TThemedGridControlKeys.HandleNavigationKey(const AKey: Word): Boolean;
var
  LRow, LColumn, LDirection, LColumnCount: Integer;
  LShift: Boolean;
  LAnchor: TThemedGridCurrentCell;
begin
  LColumnCount := GetVisibleColumns.Count;
  if (RowCount <= 0) or (LColumnCount <= 0) then
    Exit(False);

  LRow := CurrentRowIndex;
  LColumn := CurrentColumnIndex;

  if LRow < 0 then
    LRow := NormalizeCellRowIndex(0, 1)
  else if not IsDataViewRow(LRow) then
    LRow := NormalizeCellRowIndex(LRow, 1);

  if LRow < 0 then
    Exit(False);

  if LColumn < 0 then
    LColumn := 0;

  LShift := GetKeyState(VK_SHIFT) < 0;
  LAnchor := SelectionModel.AnchorCell;
  if not LAnchor.IsValid then
    LAnchor := TThemedGridCurrentCell.Create(LRow, LColumn);

  case AKey of
    VK_UP:
      begin
        Dec(LRow);
        LDirection := -1;
      end;
    VK_DOWN:
      begin
        Inc(LRow);
        LDirection := 1;
      end;
    VK_LEFT:
      begin
        Dec(LColumn);
        LDirection := 0;
      end;
    VK_RIGHT:
      begin
        Inc(LColumn);
        LDirection := 0;
      end;
    VK_PRIOR:
      begin
        Dec(LRow, Max(1, GetVerticalScrollLargeChange - 1));
        LDirection := -1;
      end;
    VK_NEXT:
      begin
        Inc(LRow, Max(1, GetVerticalScrollLargeChange - 1));
        LDirection := 1;
      end;
    VK_HOME:
      begin
        LColumn := 0;
        LDirection := 0;
      end;
    VK_END:
      begin
        LColumn := LColumnCount - 1;
        LDirection := 0;
      end;
  else
    Exit(False);
  end;

  if LRow < 0 then
    LRow := 0;
  if LRow >= RowCount then
    LRow := RowCount - 1;

  if not IsDataViewRow(LRow) then
  begin
    if LDirection = 0 then
      LDirection := 1;
    LRow := NormalizeCellRowIndex(LRow, LDirection);
  end;

  if LRow < 0 then
    Exit(False);

  if LColumn < 0 then
    LColumn := 0;
  if LColumn >= LColumnCount then
    LColumn := LColumnCount - 1;

  if LShift and SelectionOptions.AllowRangeSelection then
  begin
    CurrentRowIndex := LRow;
    CurrentColumnIndex := LColumn;
    SelectionModel.SelectRange(LAnchor.RowIndex, LAnchor.ColumnIndex, LRow, LColumn);
    EnsureVisible(LRow, LColumn);
    Invalidate;
    Exit(True);
  end;

  SetCurrentCell(LRow, LColumn);
  Result := True;
end;

procedure TThemedGridControlKeys.KeyDown(var AKey: Word; AShift: TShiftState);
var
  LEditing, LPlain: Boolean;
begin
  if TryHandleExtendedKey(AKey, AShift) then
  begin
    AKey := 0;
    Exit;
  end;

  LEditing := IsEditing;
  LPlain := AShift = [];

  if not LEditing and LPlain and TryHandleDetailKey(AKey) then
  begin
    AKey := 0;
    Exit;
  end;

  if not LEditing and (AShift = [ssCtrl]) and ((AKey = VK_LEFT) or (AKey = VK_RIGHT)) then
  begin
    if AKey = VK_RIGHT then
    begin
      if TryStepCurrentCellValue(1) then
      begin
        AKey := 0;
        Exit;
      end;
    end
    else if TryStepCurrentCellValue(-1) then
    begin
      AKey := 0;
      Exit;
    end;
  end;

  if (AKey = VK_F2) and EditOptions.EditOnF2 then
  begin
    if not ToggleCurrentCellBooleanValue then
      BeginEditCurrentCell;
    AKey := 0;
    Exit;
  end;

  if not LEditing and (AKey = VK_RETURN) and LPlain and EditOptions.EditOnEnter and
    CanBeginEditCurrentCell then
  begin
    BeginEditCurrentCell;
    AKey := 0;
    Exit;
  end;

  if HandleNavigationKey(AKey) then
  begin
    AKey := 0;
    Exit;
  end;

  inherited KeyDown(AKey, AShift);
end;

end.

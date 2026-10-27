{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.GridEditors;

interface

uses
  System.Classes, System.Types, System.Rtti, System.Generics.Collections, Vcl.Controls,
  NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas, NimbusForms.Controls.GridTypes,
  NimbusForms.Grid.Column, NimbusForms.Grid.Cell, NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext, NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.EditorIntf, NimbusForms.Grid.EditorBase;

type
  TNimbusGridControlEditor = class(TThemedGridEditorBase, IThemedGridCellRenderer,
    IThemedGridInteractiveCellEditor, IThemedGridEditorPopupState)
  private
    FKind: TNimbusGridControlKind;
    FContext: TThemedGridCellEditContext;
    FLoading: Boolean;
    FGetter: TNimbusGridValueGetter;
    FSetter: TNimbusGridValueSetter;
    FOnConfigure: TNimbusGridConfigureEvent;
    FOnDraw: TNimbusGridDrawEvent;
    FPopupGetter: TNimbusGridPopupGetter;
    FPopupCloser: TNimbusGridPopupCloser;
    FHostKeyDown: TKeyEvent;
    FHostExit: TNotifyEvent;
    FUserKeyDown: TKeyEvent;
    FUserExit: TNotifyEvent;
    FHooksInstalled: Boolean;
    FEventControl: TWinControl;
    FValues: TList<TValue>;
    FRenderObject: TNimbusRenderCanvas;
    FRenderCanvas: INimbusRenderCanvas;
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControlExit(Sender: TObject);
    procedure InstallHooks;
    procedure RemoveHooks;
    procedure ClosePopup;
    procedure LoadChoices(const AColumn: TThemedGridColumn);
    procedure AddChoice(const AText: string; const AValue: TValue);
    function GetIsPopupOpen: Boolean;
  protected
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create(const AControl: TWinControl; const AGetter: TNimbusGridValueGetter = nil;
      const ASetter: TNimbusGridValueSetter = nil);
    destructor Destroy; override;
    class function Bind(const AColumn: TThemedGridColumn; const AKind: TNimbusGridControlKind): TNimbusGridControlEditor; static;
    procedure BindColumn(const AColumn: TThemedGridColumn);
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell;
      const ALocation: TPoint): TThemedGridHitInfo;
    function HitTest(const ABounds: TRect; const ALocation: TPoint): Boolean;
    procedure Activate(const ALocation: TPoint);
    procedure RequestCommit;
    procedure RequestCancel;
    property Control: TWinControl read GetControl;
    property Context: TThemedGridCellEditContext read FContext;
    property Loading: Boolean read FLoading;
    property OnConfigure: TNimbusGridConfigureEvent read FOnConfigure write FOnConfigure;
    property OnDraw: TNimbusGridDrawEvent read FOnDraw write FOnDraw;
    property PopupGetter: TNimbusGridPopupGetter read FPopupGetter write FPopupGetter;
    property PopupCloser: TNimbusGridPopupCloser read FPopupCloser write FPopupCloser;
    property EventControl: TWinControl read FEventControl;
    procedure SetEventControl(const AControl: TWinControl);
  end;

implementation

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.TypInfo, System.Math, Vcl.Graphics, Vcl.StdCtrls,
  NimbusForms.Theming.Types, NimbusForms.Rendering.Types, NimbusForms.Controls.Types,
  NimbusForms.Controls.CheckBox, NimbusForms.Controls.ToggleBox, NimbusForms.Controls.Rating,
  NimbusForms.Controls.ComboBox, NimbusForms.Controls.DatePicker, NimbusForms.Controls.Avatar,
  NimbusForms.Controls.Button, NimbusForms.Rendering.GridCells, NimbusForms.Rendering.ToggleBox,
  NimbusForms.Grid.Types, NimbusForms.Grid.CellRendererParts,
  NimbusForms.Grid.ValueConverter, NimbusForms.Grid.ValueAccessor, NimbusForms.Grid.EditorSupport;

type
  TGridControlAccess = class(TWinControl)
  public
    property AutoSize;
    property OnKeyDown;
    property OnExit;
  end;

constructor TNimbusGridControlEditor.Create(const AControl: TWinControl;
  const AGetter: TNimbusGridValueGetter; const ASetter: TNimbusGridValueSetter);
begin
  inherited Create;
  if AControl = nil then raise EArgumentNilException.Create('AControl');
  if (AControl.Owner <> nil) or (AControl.Parent <> nil) then
    raise EArgumentException.Create('The editor control must have no owner or parent');
  InitControl(AControl);
  FEventControl := AControl;
  AControl.Visible := False;
  FGetter := AGetter;
  FSetter := ASetter;
  FValues := TList<TValue>.Create;
  FRenderObject := TNimbusRenderCanvas.Create;
  FRenderCanvas := FRenderObject;
  if AControl is TThemedCheckBox then FKind := ngckCheckBox
  else if AControl is TThemedToggleBox then FKind := ngckToggle
  else if AControl is TThemedRatingControl then FKind := ngckRating
  else if AControl is TThemedComboBox then FKind := ngckComboBox
  else if AControl is TThemedDatePicker then FKind := ngckDateTime
  else if AControl is TThemedAvatar then FKind := ngckAvatar
  else if AControl is TThemedButton then FKind := ngckButton
  else if not Assigned(FGetter) or not Assigned(FSetter) then
    raise EArgumentException.Create('Custom controls require value getter and setter callbacks');
end;

destructor TNimbusGridControlEditor.Destroy;
begin
  RemoveHooks;
  ClosePopup;
  FContext := nil;
  FRenderCanvas := nil;
  FValues.Free;
  inherited Destroy;
end;

class function TNimbusGridControlEditor.Bind(const AColumn: TThemedGridColumn;
  const AKind: TNimbusGridControlKind): TNimbusGridControlEditor;
var
  LControl: TWinControl;
  LEditor: IThemedGridCellEditor;
begin
  if AColumn = nil then raise EArgumentNilException.Create('AColumn');
  case AKind of
    ngckCheckBox:
      begin
        LControl := TThemedCheckBox.Create(nil);
        TThemedCheckBox(LControl).Caption := '';
        TGridControlAccess(LControl).AutoSize := False;
      end;
    ngckToggle:
      begin
        LControl := TThemedToggleBox.Create(nil);
        TThemedToggleBox(LControl).Caption := '';
        TThemedToggleBox(LControl).ShowBorder := False;
        TThemedToggleBox(LControl).SwitchAlignment := tsaCenter;
        TThemedToggleBox(LControl).LabelPosition := tlpHidden;
      end;
    ngckRating:
      begin
        LControl := TThemedRatingControl.Create(nil);
        TThemedRatingControl(LControl).AutoSize := False;
        TThemedRatingControl(LControl).ItemSize := 22;
        if AColumn.EditorOptions.HasMaximum then
          TThemedRatingControl(LControl).Maximum := EnsureRange(Round(AColumn.EditorOptions.Maximum), 1, 20);
      end;
    ngckComboBox:
      begin
        LControl := TThemedComboBox.Create(nil);
        TThemedComboBox(LControl).Style := csDropDownList;
      end;
    ngckDateTime: LControl := TThemedDatePicker.Create(nil);
    ngckAvatar: LControl := TThemedAvatar.Create(nil);
    ngckButton:
      begin
        LControl := TThemedButton.Create(nil);
        TThemedButton(LControl).ButtonStyle := tbstOutline;
        TThemedButton(LControl).Caption := 'Open';
      end;
  else
    raise EArgumentException.Create('Use Create with a control and callbacks for custom editors');
  end;
  Result := TNimbusGridControlEditor.Create(LControl);
  LEditor := Result;
  Result.BindColumn(AColumn);
end;

procedure TNimbusGridControlEditor.BindColumn(const AColumn: TThemedGridColumn);
var
  LEditor: IThemedGridCellEditor;
  LRenderer: IThemedGridCellRenderer;
begin
  if AColumn = nil then raise EArgumentNilException.Create('AColumn');
  LEditor := Self;
  LRenderer := Self;
  AColumn.Editor := LEditor;
  AColumn.Renderer := LRenderer;
  AColumn.EditorKind := TThemedGridEditorKind.Custom;
  AColumn.RenderKind := TThemedGridCellRenderKind.Custom;
end;

procedure TNimbusGridControlEditor.ApplyTheme(const APalette: TThemePalette);
var
  LAware: IThemeAware;
begin
  if Supports(Control, IThemeAware, LAware) then LAware.ApplyTheme(APalette)
  else inherited ApplyTheme(APalette);
end;

procedure TNimbusGridControlEditor.AddChoice(const AText: string; const AValue: TValue);
begin
  TThemedComboBox(Control).Items.Add(AText);
  FValues.Add(AValue);
end;

procedure TNimbusGridControlEditor.LoadChoices(const AColumn: TThemedGridColumn);
var
  LSource, LEnumerator: TObject;
  LRtti: TRttiContext;
  LType: TRttiType;
  LGetEnumerator, LMoveNext: TRttiMethod;
  LCurrent: TRttiProperty;
  LItem, LDisplay, LValue: TValue;
  LData: PTypeData;
  I: Integer;
begin
  LSource := AColumn.EditorOptions.DataSource;
  if (LSource = nil) and ((ValueType = nil) or (ValueType.Kind <> tkEnumeration)) then Exit;
  TThemedComboBox(Control).Items.BeginUpdate;
  try
    TThemedComboBox(Control).Items.Clear;
    FValues.Clear;
    if LSource is TStrings then
      for I := 0 to TStrings(LSource).Count - 1 do
        AddChoice(TStrings(LSource)[I], TValue.From<string>(TStrings(LSource)[I]))
    else if LSource <> nil then
    begin
      LRtti := TRttiContext.Create;
      try
        LType := LRtti.GetType(LSource.ClassType);
        LGetEnumerator := LType.GetMethod('GetEnumerator');
        if LGetEnumerator = nil then raise EArgumentException.Create('The choice source must be enumerable');
        LValue := LGetEnumerator.Invoke(LSource, []);
        LEnumerator := LValue.AsObject;
        if LEnumerator = nil then Exit;
        try
          LType := LRtti.GetType(LEnumerator.ClassType);
          LMoveNext := LType.GetMethod('MoveNext');
          LCurrent := LType.GetProperty('Current');
          if (LMoveNext = nil) or (LCurrent = nil) then
            raise EArgumentException.Create('The choice enumerator requires MoveNext and Current');
          while LMoveNext.Invoke(LEnumerator, []).AsBoolean do
          begin
            LItem := LCurrent.GetValue(LEnumerator);
            LDisplay := LItem;
            LValue := LItem;
            if AColumn.EditorOptions.DisplayMember <> '' then
              LDisplay := TThemedGridValueAccessorCache.GetAccessor(LItem, AColumn.EditorOptions.DisplayMember).GetValue(LItem);
            if AColumn.EditorOptions.ValueMember <> '' then
              LValue := TThemedGridValueAccessorCache.GetAccessor(LItem, AColumn.EditorOptions.ValueMember).GetValue(LItem);
            AddChoice(TThemedGridValueConverter.ToText(LDisplay), LValue);
          end;
        finally
          LEnumerator.Free;
        end;
      finally
        LRtti.Free;
      end;
    end
    else
    begin
      LData := GetTypeData(ValueType);
      for I := LData.MinValue to LData.MaxValue do
        AddChoice(GetEnumName(ValueType, I), TValue.FromOrdinal(ValueType, I));
    end;
  finally
    TThemedComboBox(Control).Items.EndUpdate;
  end;
end;

procedure TNimbusGridControlEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
begin
  RemoveHooks;
  FContext := AContext;
  FLoading := True;
  try
    if FKind = ngckComboBox then LoadChoices(AContext.Column);
    if FKind = ngckDateTime then
    begin
      TThemedDatePicker(Control).ShowTime := AContext.Column.EditorOptions.ShowTime;
      if AContext.Column.EditorOptions.HasMinDate then
        TThemedDatePicker(Control).MinDate := AContext.Column.EditorOptions.MinDate;
      if AContext.Column.EditorOptions.HasMaxDate then
        TThemedDatePicker(Control).MaxDate := AContext.Column.EditorOptions.MaxDate;
      TThemedDatePicker(Control).CustomFormat := AContext.Column.FormatString;
    end;
    if Assigned(FOnConfigure) then FOnConfigure(Self, Control, AContext);
    SetValue(AContext.Value);
  finally
    FLoading := False;
    InstallHooks;
  end;
  FocusEditor;
end;

function TNimbusGridControlEditor.GetValue: TValue;
var
  I: Integer;
begin
  if Assigned(FGetter) then Exit(FGetter(Control));
  case FKind of
    ngckCheckBox: Result := TValue.From<Boolean>(TThemedCheckBox(Control).Checked);
    ngckToggle: Result := TValue.From<Boolean>(TThemedToggleBox(Control).Checked);
    ngckRating: Result := TThemedGridEditorSupport.ConvertNumber(TThemedRatingControl(Control).RatingValue, ValueType);
    ngckComboBox:
      begin
        I := TThemedComboBox(Control).ItemIndex;
        if (I >= 0) and (I < FValues.Count) then Result := FValues[I]
        else if (I < 0) and (TThemedComboBox(Control).Style = csDropDownList) then Result := OriginalValue
        else Result := TValue.From<string>(TThemedComboBox(Control).Text);
      end;
    ngckDateTime: Result := TValue.From<TDateTime>(TThemedDatePicker(Control).Value);
  else
    Result := OriginalValue;
  end;
end;

procedure TNimbusGridControlEditor.SetValue(const AValue: TValue);
var
  LValue: TValue;
  LNumber: Extended;
  LDate: TDateTime;
  I, LIndex: Integer;
  LWasLoading: Boolean;
begin
  LWasLoading := FLoading;
  FLoading := True;
  try
    if Assigned(FSetter) then
    begin
      FSetter(Control, AValue);
      Exit;
    end;
    case FKind of
      ngckCheckBox, ngckToggle:
        begin
          LValue := TThemedGridValueConverter.Convert(AValue, TypeInfo(Boolean));
          if FKind = ngckCheckBox then TThemedCheckBox(Control).Checked := LValue.AsBoolean
          else TThemedToggleBox(Control).Checked := LValue.AsBoolean;
        end;
      ngckRating:
        begin
          if not TThemedGridValueConverter.TryToNumber(AValue, LNumber) then LNumber := 0;
          TThemedRatingControl(Control).RatingValue := LNumber;
        end;
      ngckComboBox:
        begin
          LIndex := -1;
          for I := 0 to FValues.Count - 1 do
            if TThemedGridEditorSupport.ValuesEqual(FValues[I], AValue) then
            begin
              LIndex := I;
              Break;
            end;
          if FValues.Count = 0 then LIndex := TThemedComboBox(Control).Items.IndexOf(AValue.ToString);
          TThemedComboBox(Control).ItemIndex := LIndex;
          if TThemedComboBox(Control).Style <> csDropDownList then TThemedComboBox(Control).Text := AValue.ToString;
        end;
      ngckDateTime:
        if TThemedGridValueConverter.TryGetDate(AValue, LDate) then TThemedDatePicker(Control).Value := LDate;
      ngckAvatar: TThemedAvatar(Control).Text := AValue.ToString;
    end;
  finally
    FLoading := LWasLoading;
  end;
end;

procedure TNimbusGridControlEditor.InstallHooks;
begin
  if FHooksInstalled then Exit;
  FUserKeyDown := TGridControlAccess(FEventControl).OnKeyDown;
  FUserExit := TGridControlAccess(FEventControl).OnExit;
  TGridControlAccess(FEventControl).OnKeyDown := KeyDown;
  TGridControlAccess(FEventControl).OnExit := ControlExit;
  FHooksInstalled := True;
end;

procedure TNimbusGridControlEditor.RemoveHooks;
begin
  if not FHooksInstalled then Exit;
  FHooksInstalled := False;
  TGridControlAccess(FEventControl).OnKeyDown := FUserKeyDown;
  TGridControlAccess(FEventControl).OnExit := FUserExit;
end;

procedure TNimbusGridControlEditor.SetEventControl(const AControl: TWinControl);
var
  LComponent: TComponent;
  LBelongsToEditor: Boolean;
begin
  if AControl = nil then
    raise EArgumentException.Create('The event control must belong to the editor');
  LBelongsToEditor := (AControl = Control) or Control.ContainsControl(AControl);
  LComponent := AControl.Owner;
  while not LBelongsToEditor and (LComponent <> nil) do
  begin
    LBelongsToEditor := LComponent = Control;
    LComponent := LComponent.Owner;
  end;
  if not LBelongsToEditor then
    raise EArgumentException.Create('The event control must belong to the editor');
  RemoveHooks;
  FEventControl := AControl;
  if FContext <> nil then InstallHooks;
end;

procedure TNimbusGridControlEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  RemoveHooks;
  FHostKeyDown := AKeyDown;
  FHostExit := AExit;
  if not Assigned(AKeyDown) and not Assigned(AExit) then
  begin
    FContext := nil;
    ClosePopup;
  end;
end;

procedure TNimbusGridControlEditor.KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LKey: Word;
begin
  LKey := Key;
  if Assigned(FUserKeyDown) then FUserKeyDown(Sender, Key, Shift);
  if (FEventControl <> Control) and (Key = 0) and (LKey in [VK_RETURN, VK_ESCAPE]) then Key := LKey;
  if not GetIsPopupOpen and Assigned(FHostKeyDown) then FHostKeyDown(Sender, Key, Shift);
end;

procedure TNimbusGridControlEditor.ControlExit(Sender: TObject);
begin
  if Assigned(FUserExit) then FUserExit(Sender);
  if Assigned(FHostExit) then FHostExit(Sender);
end;

function TNimbusGridControlEditor.GetIsPopupOpen: Boolean;
begin
  if Assigned(FPopupGetter) then Exit(FPopupGetter(Control));
  case FKind of
    ngckComboBox: Result := Control.HandleAllocated and TThemedComboBox(Control).DroppedDown;
    ngckDateTime: Result := TThemedDatePicker(Control).DroppedDown;
  else
    Result := False;
  end;
end;

procedure TNimbusGridControlEditor.ClosePopup;
begin
  if Control = nil then Exit;
  if Assigned(FPopupCloser) then
  begin
    FPopupCloser(Control);
    Exit;
  end;
  case FKind of
    ngckComboBox:
      if Control.HandleAllocated then TThemedComboBox(Control).DroppedDown := False;
    ngckDateTime: TThemedDatePicker(Control).CloseDropDown;
  end;
end;

function TNimbusGridControlEditor.HitTest(const ABounds: TRect; const ALocation: TPoint): Boolean;
begin
  Result := PtInRect(ABounds, ALocation);
end;

procedure TNimbusGridControlEditor.Activate(const ALocation: TPoint);
var
  LPoint: TPoint;
  LPosition: LPARAM;
begin
  if (FContext = nil) or FContext.Cell.IsReadOnly then Exit;
  LPoint := Control.ScreenToClient(FContext.Grid.ClientToScreen(ALocation));
  case FKind of
    ngckComboBox: TThemedComboBox(Control).DroppedDown := True;
    ngckDateTime: TThemedDatePicker(Control).ShowDropDown;
  else
    begin
      Control.Update;
      LPosition := LPARAM(LongWord(Word(LPoint.X)) or (LongWord(Word(LPoint.Y)) shl 16));
      Control.Perform(WM_LBUTTONDOWN, MK_LBUTTON, LPosition);
      if (FContext <> nil) and (Control.Parent <> nil) then
        Control.Perform(WM_LBUTTONUP, 0, LPosition);
      if FKind in [ngckCheckBox, ngckToggle, ngckRating] then RequestCommit;
    end;
  end;
end;

procedure TNimbusGridControlEditor.RequestCommit;
var
  LKey: Word;
begin
  if FLoading or (FContext = nil) or not Assigned(FHostKeyDown) then Exit;
  LKey := VK_RETURN;
  FHostKeyDown(Control, LKey, []);
end;

procedure TNimbusGridControlEditor.RequestCancel;
var
  LKey: Word;
begin
  if FLoading or (FContext = nil) or not Assigned(FHostKeyDown) then Exit;
  LKey := VK_ESCAPE;
  FHostKeyDown(Control, LKey, []);
end;

procedure TNimbusGridControlEditor.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
begin
  TNimbusGridCellRenderer.Draw(FRenderObject, FRenderCanvas, Control, FKind, FOnDraw, AContext, ACell);
end;

function TNimbusGridControlEditor.Measure(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TSize;
begin
  Result := TSize.Create(Control.Width, Control.Height);
end;

function TNimbusGridControlEditor.HitTestContent(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := nil;
  if not HitTest(ACell.Bounds, ALocation) then Exit;
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
  Result.HitArea := TThemedGridHitArea.Editor;
end;

end.

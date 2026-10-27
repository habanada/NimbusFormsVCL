{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Dropdown;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.SysUtils,
  System.UITypes,
  System.Variants,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.AppEvnts,
  Data.DB,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.Dropdown.Types,
  NimbusForms.Controls.DropdownPopup,
  NimbusForms.Rendering.Dropdown;

type
  TThemedDropdownItemArray = TArray<TThemedDropdownItem>;
  TThemedDropdownValueArray = TArray<Variant>;
  TThemedDropdownObjectArray = TArray<TObject>;

  TCustomThemedDropdown = class(TCustomNimbusControl)
  private
    FEditor: TEdit;
    FItems: TThemedDropdownItems;
    FManualItems: TThemedDropdownItems;
    FDataLink: TDataLink;
    FDisplayMember: string;
    FValueMember: string;
    FImageMember: string;
    FDataRebuilding: Boolean;
    FVisibleItems: TList<TThemedDropdownItem>;
    FApplicationEvents: TApplicationEvents;
    FPopup: TThemedDropdownPopupForm;
    FStyleMode: TThemedDropdownStyleMode;
    FValidationState: TThemedDropdownValidationState;
    FClearButtonMode: TThemedDropdownClearButtonMode;
    FShowFocusGlow: Boolean;
    FReadOnlyDimmed: Boolean;
    FCustomBorderColor: System.UITypes.TColor;
    FCustomFocusBorderColor: System.UITypes.TColor;
    FCustomBackColor: System.UITypes.TColor;
    FCustomForeColor: System.UITypes.TColor;
    FCustomCueColor: System.UITypes.TColor;
    FHovered: Boolean;
    FFocused: Boolean;
    FClearHovered: Boolean;
    FClearPressed: Boolean;
    FDroppedDown: Boolean;
    FBorderThickness: Integer;
    FLogicalBorderThickness: Integer;
    FLogicalClearButtonWidth: Integer;
    FClearButtonWidth: Integer;
    FSelectedIndex: Integer;
    FMultiSelect: Boolean;
    FEmptyText: string;
    FGroupPrefixText: string;
    FAutoCompleteEnabled: Boolean;
    FAutoCompleteMinimumCharacters: Integer;
    FFilterText: string;
    FSuppressEditTextChanged: Boolean;
    FUserIsEditing: Boolean;
    FCommittedTextBeforeEdit: string;
    FOnSelectedIndexChanged: TNotifyEvent;
    FOnSelectedItemChanged: TNotifyEvent;
    FOnCheckedItemsChanged: TNotifyEvent;
    function GetText: string;
    function GetDataSource: TDataSource;
    procedure SetDataSource(const AValue: TDataSource);
    procedure SetItems(const AValue: TThemedDropdownItems);
    procedure SetDisplayMember(const AValue: string);
    procedure SetValueMember(const AValue: string);
    procedure SetImageMember(const AValue: string);
    procedure RebuildItemsFromDataSource(const APreserveSelection: Boolean);
    procedure RestoreManualItems;
    procedure DataSourceChanged;
    procedure SetText(const AValue: string);
    procedure SetStyleMode(const AValue: TThemedDropdownStyleMode);
    procedure SetValidationState(const AValue: TThemedDropdownValidationState);
    procedure SetClearButtonMode(const AValue: TThemedDropdownClearButtonMode);
    procedure SetShowFocusGlow(const AValue: Boolean);
    procedure SetReadOnlyDimmed(const AValue: Boolean);
    procedure SetCustomBorderColor(const AValue: System.UITypes.TColor);
    procedure SetCustomFocusBorderColor(const AValue: System.UITypes.TColor);
    procedure SetCustomBackColor(const AValue: System.UITypes.TColor);
    procedure SetCustomForeColor(const AValue: System.UITypes.TColor);
    procedure SetCustomCueColor(const AValue: System.UITypes.TColor);
    procedure SetMultiSelect(const AValue: Boolean);
    procedure SetEmptyText(const AValue: string);
    procedure SetGroupPrefixText(const AValue: string);
    procedure SetAutoCompleteEnabled(const AValue: Boolean);
    procedure SetAutoCompleteMinimumCharacters(const AValue: Integer);
    procedure SetSelectedIndex(const AValue: Integer);
    function GetSelectedItem: TThemedDropdownItem;
    procedure SetSelectedItem(const AValue: TThemedDropdownItem);
    function GetSelectedValue: Variant;
    procedure SetSelectedValue(const AValue: Variant);
    function GetSelectedDataItem: TObject;
    procedure SetSelectedDataItem(const AValue: TObject);
    function GetCheckedItems: TThemedDropdownItemArray;
    function GetCheckedValues: TThemedDropdownValueArray;
    function GetCheckedDataItems: TThemedDropdownObjectArray;
    function CanShowClearButton: Boolean;
    function GetClearButtonRect: TRect;
    function GetArrowButtonWidth: Integer;
    function GetArrowButtonRect: TRect;
    function GetTextRect: TRect;
    function BuildRenderContext: TThemedDropdownRenderContext;
    procedure UpdateMetrics;
    procedure UpdateEditorLayout;
    procedure UpdateEditorTheme;
    procedure UpdateEditorMode;
    procedure UpdateVisibleItems;
    procedure RefreshPopupItems(const AKeepVisible: Boolean);
    procedure SyncPopupSelection;
    procedure SyncTextFromSelection;
    procedure SetEditorText(const AValue: string);
    procedure BeginEditing(const APreserveCurrentText: Boolean);
    procedure CommitCurrentSelection;
    procedure CancelCurrentEdit;
    procedure SelectAllEditorText;
    procedure FocusInternal;
    procedure ClearDropdownSelection;
    procedure MoveSelection(const ADelta: Integer);
    procedure ToggleSelectedItemChecked;
    function FindFirstSelectableIndex: Integer;
    function CoerceSelectableIndex(const AValue: Integer): Integer;
    function FindIndexByValue(const AValue: Variant): Integer;
    function FindIndexByDataItem(const AValue: TObject): Integer;
    function IsFilterMatch(const AItem: TThemedDropdownItem; const AFilter: string): Boolean;
    procedure HandleAutoCompleteTextChanged;
    procedure EnsurePopup;
    function GetPopupBounds: TRect;
    procedure RefreshPopupBounds;
    function PointInControlScreen(const APoint: TPoint): Boolean;
    function PointInPopupScreen(const APoint: TPoint): Boolean;
    procedure ProcessNavigationKey(var Key: Word; Shift: TShiftState);
    procedure ItemsChanged(Sender: TObject; Item: TThemedDropdownItem);
    procedure EditorChange(Sender: TObject);
    procedure EditorEnter(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditorMouseEnter(Sender: TObject);
    procedure EditorMouseLeave(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PopupItemSelected(Sender: TObject; Item: TThemedDropdownItem);
    procedure PopupCheckedItemsChanged(Sender: TObject);
    procedure PopupListSelectedIndexChanged(Sender: TObject);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ApplicationDeactivate(Sender: TObject);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoSelectedIndexChanged; virtual;
    procedure DoSelectedItemChanged; virtual;
    procedure DoCheckedItemsChanged; virtual;
    property StyleMode: TThemedDropdownStyleMode read FStyleMode write SetStyleMode default tdsNormal;
    property ValidationState: TThemedDropdownValidationState read FValidationState write SetValidationState default tdvNormal;
    property ClearButtonMode: TThemedDropdownClearButtonMode read FClearButtonMode write SetClearButtonMode default tdcNever;
    property ShowFocusGlow: Boolean read FShowFocusGlow write SetShowFocusGlow default True;
    property ReadOnlyDimmed: Boolean read FReadOnlyDimmed write SetReadOnlyDimmed default True;
    property DropdownBorderColor: System.UITypes.TColor read FCustomBorderColor write SetCustomBorderColor default clNone;
    property DropdownFocusBorderColor: System.UITypes.TColor read FCustomFocusBorderColor write SetCustomFocusBorderColor default clNone;
    property DropdownBackColor: System.UITypes.TColor read FCustomBackColor write SetCustomBackColor default clNone;
    property DropdownForeColor: System.UITypes.TColor read FCustomForeColor write SetCustomForeColor default clNone;
    property CueColor: System.UITypes.TColor read FCustomCueColor write SetCustomCueColor default clNone;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default False;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property GroupPrefixText: string read FGroupPrefixText write SetGroupPrefixText;
    property AutoCompleteEnabled: Boolean read FAutoCompleteEnabled write SetAutoCompleteEnabled default False;
    property AutoCompleteMinimumCharacters: Integer read FAutoCompleteMinimumCharacters write SetAutoCompleteMinimumCharacters default 0;
    property Items: TThemedDropdownItems read FItems write SetItems;
    property Text: string read GetText write SetText;
    property OnSelectedIndexChanged: TNotifyEvent read FOnSelectedIndexChanged write FOnSelectedIndexChanged;
    property OnSelectedItemChanged: TNotifyEvent read FOnSelectedItemChanged write FOnSelectedItemChanged;
    property OnCheckedItemsChanged: TNotifyEvent read FOnCheckedItemsChanged write FOnCheckedItemsChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure MouseWheelHandler(var Message: TMessage); override;
    function AddItem(const AText: string): TThemedDropdownItem; overload;
    function AddItem(const AText: string; const AValue: Variant): TThemedDropdownItem; overload;
    function AddItem(const AText: string; const AValue: Variant; const AImage: Vcl.Graphics.TBitmap; const ATag: NativeInt = 0): TThemedDropdownItem; overload;
    function AddSeparator: TThemedDropdownItem;
    function AddGroup(const AGroupText: string): TThemedDropdownItem;
    procedure ClearItems;
    procedure RefreshDataSourceItems;
    procedure SetItemChecked(const AIndex: Integer; const AChecked: Boolean);
    procedure SetCheckedDataItems(const ADataItems: array of TObject);
    procedure ClearCheckedItems;
    procedure ApplyFilter(const AFilterText: string);
    procedure ClearFilter;
    procedure ShowDropdown;
    procedure CloseDropdown;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property SelectedItem: TThemedDropdownItem read GetSelectedItem write SetSelectedItem;
    property SelectedValue: Variant read GetSelectedValue write SetSelectedValue;
    property SelectedDataItem: TObject read GetSelectedDataItem write SetSelectedDataItem;
    property CheckedItems: TThemedDropdownItemArray read GetCheckedItems;
    property CheckedValues: TThemedDropdownValueArray read GetCheckedValues;
    property CheckedDataItems: TThemedDropdownObjectArray read GetCheckedDataItems;
    property FilterText: string read FFilterText;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DisplayMember: string read FDisplayMember write SetDisplayMember;
    property ValueMember: string read FValueMember write SetValueMember;
    property ImageMember: string read FImageMember write SetImageMember;
    property DroppedDown: Boolean read FDroppedDown;
    property Editor: TEdit read FEditor;
  end;

  TThemedDropdown = class(TCustomThemedDropdown)
  published
    property Action;
    property Align;
    property Anchors;
    property AutoCompleteEnabled;
    property AutoCompleteMinimumCharacters;
    property BiDiMode;
    property ClearButtonMode;
    property Constraints;
    property DataSource;
    property DisplayMember;
    property CueColor;
    property DropdownBackColor;
    property DropdownBorderColor;
    property DropdownFocusBorderColor;
    property DropdownForeColor;
    property EmptyText;
    property ImageMember;
    property Enabled;
    property Font;
    property GroupPrefixText;
    property Items;
    property MultiSelect;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnlyDimmed;
    property ShowFocusGlow;
    property ShowHint;
    property StyleMode;
    property TabOrder;
    property TabStop default True;
    property Text;
    property ValidationState;
    property ValueMember;
    property Visible;
    property OnCheckedItemsChanged;
    property OnClick;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnSelectedIndexChanged;
    property OnSelectedItemChanged;
  end;

implementation

uses
  System.Math,
  System.StrUtils,
  Vcl.Forms,
  Vcl.Imaging.pngimage,
  NimbusForms.Controls.Strings,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

type
  TControlAccess = class(TControl);

  TThemedDropdownDataLink = class(TDataLink)
  private
    FOwner: TCustomThemedDropdown;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
  public
    constructor Create(AOwner: TCustomThemedDropdown);
  end;

constructor TThemedDropdownDataLink.Create(AOwner: TCustomThemedDropdown);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TThemedDropdownDataLink.ActiveChanged;
begin
  inherited;
  if FOwner <> nil then FOwner.DataSourceChanged;
end;

procedure TThemedDropdownDataLink.DataSetChanged;
begin
  inherited;
  if FOwner <> nil then FOwner.DataSourceChanged;
end;

constructor TCustomThemedDropdown.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 180;
  Height := 28;
  TabStop := True;
  FItems := TThemedDropdownItems.Create(Self);
  FItems.OnChange := ItemsChanged;
  FManualItems := TThemedDropdownItems.Create(Self);
  FDataLink := TThemedDropdownDataLink.Create(Self);
  FVisibleItems := TList<TThemedDropdownItem>.Create;
  FApplicationEvents := TApplicationEvents.Create(Self);
  FApplicationEvents.OnMessage := ApplicationMessage;
  FApplicationEvents.OnDeactivate := ApplicationDeactivate;
  FStyleMode := tdsNormal;
  FValidationState := tdvNormal;
  FClearButtonMode := tdcNever;
  FShowFocusGlow := True;
  FReadOnlyDimmed := True;
  FCustomBorderColor := clNone;
  FCustomFocusBorderColor := clNone;
  FCustomBackColor := clNone;
  FCustomForeColor := clNone;
  FCustomCueColor := clNone;
  FLogicalBorderThickness := 1;
  FBorderThickness := 1;
  FLogicalClearButtonWidth := 22;
  FClearButtonWidth := 22;
  FSelectedIndex := -1;
  FGroupPrefixText := SDropdownGroupPrefix;
  FEditor := TEdit.Create(Self);
  FEditor.BorderStyle := Vcl.Forms.bsNone;
  FEditor.ParentFont := False;
  FEditor.Font.Assign(Font);
  FEditor.ParentColor := False;
  FEditor.ReadOnly := True;
  FEditor.TabStop := False;
  FEditor.AutoSize := False;
  FEditor.OnChange := EditorChange;
  FEditor.OnEnter := EditorEnter;
  FEditor.OnExit := EditorExit;
  FEditor.OnMouseDown := EditorMouseDown;
  FEditor.OnMouseEnter := EditorMouseEnter;
  FEditor.OnMouseLeave := EditorMouseLeave;
  FEditor.OnKeyDown := EditorKeyDown;
  UpdateMetrics;
  UpdateVisibleItems;
  SyncTextFromSelection;
end;

destructor TCustomThemedDropdown.Destroy;
begin
  if FPopup <> nil then
  begin
    FPopup.ClosePopup;
    FPopup.Free;
  end;
  FDataLink.Free;
  FManualItems.Free;
  FVisibleItems.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TCustomThemedDropdown.SetParent(AParent: TWinControl);
begin
  if (AParent = nil) and (FEditor <> nil) and (FEditor.Parent = Self) then FEditor.Parent := nil;
  inherited SetParent(AParent);
  if (AParent <> nil) and (FEditor <> nil) and (FEditor.Parent <> Self) then
  begin
    FEditor.Parent := Self;
    UpdateEditorTheme;
    UpdateEditorLayout;
  end;
end;

procedure TCustomThemedDropdown.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = DataSource) then
  begin
    FDataLink.DataSource := nil;
    RestoreManualItems;
  end;
end;

procedure TCustomThemedDropdown.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  UpdateEditorTheme;
  if FPopup <> nil then FPopup.ApplyTheme(Palette);
end;

function TCustomThemedDropdown.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TCustomThemedDropdown.SetItems(const AValue: TThemedDropdownItems);
begin
  if AValue = nil then Exit;
  if DataSource <> nil then FManualItems.Assign(AValue) else FItems.Assign(AValue);
end;

procedure TCustomThemedDropdown.SetDataSource(const AValue: TDataSource);
var
  LOld: TDataSource;
begin
  LOld := FDataLink.DataSource;
  if LOld = AValue then Exit;
  if (LOld = nil) and (AValue <> nil) then FManualItems.Assign(FItems);
  if LOld <> nil then LOld.RemoveFreeNotification(Self);
  FDataLink.DataSource := AValue;
  if AValue <> nil then AValue.FreeNotification(Self);
  if AValue = nil then RestoreManualItems else RebuildItemsFromDataSource(True);
end;

procedure TCustomThemedDropdown.SetDisplayMember(const AValue: string);
begin
  if FDisplayMember = AValue then Exit;
  FDisplayMember := AValue;
  if DataSource <> nil then RebuildItemsFromDataSource(True);
end;

procedure TCustomThemedDropdown.SetValueMember(const AValue: string);
begin
  if FValueMember = AValue then Exit;
  FValueMember := AValue;
  if DataSource <> nil then RebuildItemsFromDataSource(True);
end;

procedure TCustomThemedDropdown.SetImageMember(const AValue: string);
begin
  if FImageMember = AValue then Exit;
  FImageMember := AValue;
  if DataSource <> nil then RebuildItemsFromDataSource(True);
end;

procedure TCustomThemedDropdown.RestoreManualItems;
begin
  FDataRebuilding := True;
  try
    FItems.Assign(FManualItems);
  finally
    FDataRebuilding := False;
  end;
  FSelectedIndex := CoerceSelectableIndex(FSelectedIndex);
  if FSelectedIndex < 0 then FSelectedIndex := FindFirstSelectableIndex;
  UpdateVisibleItems;
  SyncTextFromSelection;
  if FDroppedDown then RefreshPopupItems(True);
end;

procedure TCustomThemedDropdown.RebuildItemsFromDataSource(const APreserveSelection: Boolean);
var
  LDataSet: TDataSet;
  LBookmark: TBookmark;
  LSelectedValue: Variant;
  LDisplayField, LValueField, LImageField: TField;
  LItem: TThemedDropdownItem;
  LStream: TMemoryStream;
  LPicture: TPicture;
begin
  if DataSource = nil then Exit;
  LDataSet := DataSource.DataSet;
  if (LDataSet = nil) or not LDataSet.Active then
  begin
    FDataRebuilding := True;
    try
      FItems.Clear;
    finally
      FDataRebuilding := False;
    end;
    FSelectedIndex := -1;
    UpdateVisibleItems;
    SyncTextFromSelection;
    Exit;
  end;
  if APreserveSelection then LSelectedValue := GetSelectedValue else LSelectedValue := Unassigned;
  LDisplayField := nil;
  LValueField := nil;
  LImageField := nil;
  if FDisplayMember <> '' then LDisplayField := LDataSet.FindField(FDisplayMember);
  if FValueMember <> '' then LValueField := LDataSet.FindField(FValueMember);
  if FImageMember <> '' then LImageField := LDataSet.FindField(FImageMember);
  if (LDisplayField = nil) and (LDataSet.FieldCount > 0) then LDisplayField := LDataSet.Fields[0];
  if LValueField = nil then LValueField := LDisplayField;
  LBookmark := LDataSet.Bookmark;
  LDataSet.DisableControls;
  FDataRebuilding := True;
  try
    FItems.Clear;
    LDataSet.First;
    while not LDataSet.Eof do
    begin
      LItem := FItems.Add;
      if LDisplayField <> nil then LItem.Text := LDisplayField.AsString;
      if LValueField <> nil then LItem.Value := LValueField.Value;
      if (LImageField <> nil) and not LImageField.IsNull and (LImageField is TBlobField) then
      begin
        LStream := TMemoryStream.Create;
        LPicture := TPicture.Create;
        try
          TBlobField(LImageField).SaveToStream(LStream);
          LStream.Position := 0;
          if LStream.Size > 0 then
          begin
            LPicture.LoadFromStream(LStream);
            if (LPicture.Graphic <> nil) and not LPicture.Graphic.Empty then LItem.Image.Assign(LPicture.Graphic);
          end;
        finally
          LPicture.Free;
          LStream.Free;
        end;
      end;
      LDataSet.Next;
    end;
    if LDataSet.BookmarkValid(LBookmark) then LDataSet.Bookmark := LBookmark;
  finally
    FDataRebuilding := False;
    LDataSet.EnableControls;
  end;
  if APreserveSelection and not VarIsEmpty(LSelectedValue) then FSelectedIndex := FindIndexByValue(LSelectedValue)
  else FSelectedIndex := FindFirstSelectableIndex;
  if FSelectedIndex < 0 then FSelectedIndex := FindFirstSelectableIndex;
  UpdateVisibleItems;
  SyncTextFromSelection;
  if FDroppedDown then RefreshPopupItems(True);
  Invalidate;
end;

procedure TCustomThemedDropdown.DataSourceChanged;
begin
  if not (csDestroying in ComponentState) and (DataSource <> nil) then RebuildItemsFromDataSource(True);
end;

function TCustomThemedDropdown.GetText: string;
begin
  Result := FEditor.Text;
end;

procedure TCustomThemedDropdown.SetText(const AValue: string);
begin
  SetEditorText(AValue);
  if FAutoCompleteEnabled then FFilterText := FEditor.Text;
end;

procedure TCustomThemedDropdown.SetStyleMode(const AValue: TThemedDropdownStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  if FStyleMode = tdsIdeCompact then
  begin
    if Height = NimbusScaleValue(28, CurrentPPI) then Height := NimbusScaleValue(24, CurrentPPI);
  end
  else if Height = NimbusScaleValue(24, CurrentPPI) then
    Height := NimbusScaleValue(28, CurrentPPI);
  UpdateMetrics;
  UpdateEditorLayout;
  if FPopup <> nil then FPopup.ListControl.StyleMode := FStyleMode;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetValidationState(const AValue: TThemedDropdownValidationState);
begin
  if FValidationState = AValue then Exit;
  FValidationState := AValue;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetClearButtonMode(const AValue: TThemedDropdownClearButtonMode);
begin
  if FClearButtonMode = AValue then Exit;
  FClearButtonMode := AValue;
  UpdateEditorLayout;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetShowFocusGlow(const AValue: Boolean);
begin
  if FShowFocusGlow = AValue then Exit;
  FShowFocusGlow := AValue;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetReadOnlyDimmed(const AValue: Boolean);
begin
  if FReadOnlyDimmed = AValue then Exit;
  FReadOnlyDimmed := AValue;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetCustomBorderColor(const AValue: System.UITypes.TColor);
begin
  if FCustomBorderColor = AValue then Exit;
  FCustomBorderColor := AValue;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetCustomFocusBorderColor(const AValue: System.UITypes.TColor);
begin
  if FCustomFocusBorderColor = AValue then Exit;
  FCustomFocusBorderColor := AValue;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetCustomBackColor(const AValue: System.UITypes.TColor);
begin
  if FCustomBackColor = AValue then Exit;
  FCustomBackColor := AValue;
  UpdateEditorTheme;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetCustomForeColor(const AValue: System.UITypes.TColor);
begin
  if FCustomForeColor = AValue then Exit;
  FCustomForeColor := AValue;
  UpdateEditorTheme;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetCustomCueColor(const AValue: System.UITypes.TColor);
begin
  if FCustomCueColor = AValue then Exit;
  FCustomCueColor := AValue;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetMultiSelect(const AValue: Boolean);
var
  I: Integer;
  LFirst: Integer;
begin
  if FMultiSelect = AValue then Exit;
  FMultiSelect := AValue;
  if not FMultiSelect then
  begin
    LFirst := -1;
    FItems.BeginUpdate;
    try
      for I := 0 to FItems.Count - 1 do
        if FItems[I].Selectable and FItems[I].Checked then
        begin
          if LFirst < 0 then LFirst := I else FItems[I].Checked := False;
        end;
    finally
      FItems.EndUpdate;
    end;
    if LFirst >= 0 then FSelectedIndex := LFirst;
  end;
  if FPopup <> nil then FPopup.ListControl.ShowCheckboxes := FMultiSelect;
  SyncTextFromSelection;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then Exit;
  FEmptyText := AValue;
  SyncTextFromSelection;
end;

procedure TCustomThemedDropdown.SetGroupPrefixText(const AValue: string);
begin
  if FGroupPrefixText = AValue then Exit;
  FGroupPrefixText := AValue;
  SyncTextFromSelection;
end;

procedure TCustomThemedDropdown.SetAutoCompleteEnabled(const AValue: Boolean);
begin
  if FAutoCompleteEnabled = AValue then Exit;
  FAutoCompleteEnabled := AValue;
  FFilterText := '';
  FUserIsEditing := False;
  FCommittedTextBeforeEdit := '';
  UpdateEditorMode;
  UpdateVisibleItems;
  SyncTextFromSelection;
  if FDroppedDown then RefreshPopupItems(True);
end;

procedure TCustomThemedDropdown.SetAutoCompleteMinimumCharacters(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FAutoCompleteMinimumCharacters = LValue then Exit;
  FAutoCompleteMinimumCharacters := LValue;
  if FAutoCompleteEnabled then
  begin
    UpdateVisibleItems;
    if FDroppedDown then RefreshPopupItems(True);
  end;
end;

procedure TCustomThemedDropdown.SetSelectedIndex(const AValue: Integer);
var
  I, LValue: Integer;
begin
  LValue := CoerceSelectableIndex(AValue);
  if FSelectedIndex = LValue then Exit;
  FSelectedIndex := LValue;
  if not FMultiSelect then
  begin
    FItems.BeginUpdate;
    try
      for I := 0 to FItems.Count - 1 do
        if FItems[I].Selectable then FItems[I].Checked := I = FSelectedIndex;
    finally
      FItems.EndUpdate;
    end;
  end;
  if not FUserIsEditing then SyncTextFromSelection;
  DoSelectedIndexChanged;
  DoSelectedItemChanged;
  if FDroppedDown then SyncPopupSelection;
  Invalidate;
end;

function TCustomThemedDropdown.GetSelectedItem: TThemedDropdownItem;
begin
  if (FSelectedIndex >= 0) and (FSelectedIndex < FItems.Count) then Result := FItems[FSelectedIndex] else Result := nil;
end;

procedure TCustomThemedDropdown.SetSelectedItem(const AValue: TThemedDropdownItem);
begin
  if AValue = nil then SelectedIndex := -1 else if AValue.Collection = FItems then SelectedIndex := AValue.Index;
end;

function TCustomThemedDropdown.GetSelectedValue: Variant;
var
  LItem: TThemedDropdownItem;
begin
  LItem := SelectedItem;
  if LItem <> nil then Result := LItem.Value else Result := Unassigned;
end;

procedure TCustomThemedDropdown.SetSelectedValue(const AValue: Variant);
begin
  SelectedIndex := FindIndexByValue(AValue);
end;

function TCustomThemedDropdown.GetSelectedDataItem: TObject;
var
  LItem: TThemedDropdownItem;
begin
  LItem := SelectedItem;
  if LItem <> nil then Result := LItem.DataItem else Result := nil;
end;

procedure TCustomThemedDropdown.SetSelectedDataItem(const AValue: TObject);
begin
  if AValue = nil then SelectedIndex := -1 else SelectedIndex := FindIndexByDataItem(AValue);
end;

function TCustomThemedDropdown.GetCheckedItems: TThemedDropdownItemArray;
var
  I, LCount: Integer;
begin
  SetLength(Result, 0);
  LCount := 0;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Selectable and FItems[I].Checked then
    begin
      SetLength(Result, LCount + 1);
      Result[LCount] := FItems[I];
      Inc(LCount);
    end;
end;

function TCustomThemedDropdown.GetCheckedValues: TThemedDropdownValueArray;
var
  I, LCount: Integer;
begin
  SetLength(Result, 0);
  LCount := 0;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Selectable and FItems[I].Checked then
    begin
      SetLength(Result, LCount + 1);
      Result[LCount] := FItems[I].Value;
      Inc(LCount);
    end;
end;

function TCustomThemedDropdown.GetCheckedDataItems: TThemedDropdownObjectArray;
var
  I, LCount: Integer;
begin
  SetLength(Result, 0);
  LCount := 0;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Selectable and FItems[I].Checked then
    begin
      SetLength(Result, LCount + 1);
      Result[LCount] := FItems[I].DataItem;
      Inc(LCount);
    end;
end;

function TCustomThemedDropdown.CanShowClearButton: Boolean;
begin
  if not Enabled or (FClearButtonMode = tdcNever) then Exit(False);
  if FClearButtonMode = tdcAlways then Exit(True);
  if FMultiSelect then Exit(Length(GetCheckedItems) > 0);
  Result := FSelectedIndex >= 0;
end;

function TCustomThemedDropdown.GetArrowButtonWidth: Integer;
begin
  if FStyleMode = tdsIdeCompact then Result := NimbusScaleValue(22, CurrentPPI) else Result := NimbusScaleValue(24, CurrentPPI);
end;

function TCustomThemedDropdown.GetArrowButtonRect: TRect;
var
  LWidth: Integer;
begin
  LWidth := GetArrowButtonWidth;
  Result := Rect(Width - LWidth, 0, Width, Height);
end;

function TCustomThemedDropdown.GetClearButtonRect: TRect;
var
  LArrowWidth: Integer;
begin
  LArrowWidth := GetArrowButtonWidth;
  Result := Rect(Width - LArrowWidth - FClearButtonWidth, 0, Width - LArrowWidth, Height);
end;

function TCustomThemedDropdown.GetTextRect: TRect;
var
  LLeft, LRight, LImageSpace: Integer;
  LItem: TThemedDropdownItem;
begin
  if FStyleMode = tdsIdeCompact then
  begin
    LLeft := NimbusScaleValue(6, CurrentPPI);
    LRight := NimbusScaleValue(24, CurrentPPI);
  end
  else
  begin
    LLeft := NimbusScaleValue(8, CurrentPPI);
    LRight := NimbusScaleValue(28, CurrentPPI);
  end;
  LItem := SelectedItem;
  if not FMultiSelect and not FAutoCompleteEnabled and (LItem <> nil) and not LItem.Image.Empty then
  begin
    LImageSpace := NimbusScaleValue(24, CurrentPPI);
    Inc(LLeft, LImageSpace);
  end;
  if CanShowClearButton then Inc(LRight, FClearButtonWidth);
  Result := Rect(FBorderThickness + LLeft, FBorderThickness, Width - FBorderThickness - LRight, Height - FBorderThickness);
end;

function TCustomThemedDropdown.BuildRenderContext: TThemedDropdownRenderContext;
begin
  Result.Bounds := ClientRect;
  Result.Palette := Palette;
  Result.StyleMode := FStyleMode;
  Result.ValidationState := FValidationState;
  Result.Enabled := Enabled;
  Result.Focused := FFocused;
  Result.Hovered := FHovered;
  Result.Pressed := FClearPressed;
  Result.DroppedDown := FDroppedDown;
  Result.ShowFocusGlow := FShowFocusGlow;
  Result.BackColor := Color;
  Result.ForeColor := Font.Color;
  Result.CustomBorderColor := FCustomBorderColor;
  Result.CustomFocusBorderColor := FCustomFocusBorderColor;
  Result.CustomBackColor := FCustomBackColor;
  Result.CustomForeColor := FCustomForeColor;
  Result.CustomCueColor := FCustomCueColor;
  Result.BorderThickness := FBorderThickness;
  Result.PPI := CurrentPPI;
end;

procedure TCustomThemedDropdown.UpdateMetrics;
begin
  FBorderThickness := Max(1, NimbusScaleValue(FLogicalBorderThickness, CurrentPPI));
  FClearButtonWidth := Max(18, NimbusScaleValue(FLogicalClearButtonWidth, CurrentPPI));
end;

procedure TCustomThemedDropdown.UpdateEditorLayout;
var
  LRect: TRect;
  LTop, LHeight: Integer;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) then Exit;
  LRect := GetTextRect;
  LHeight := NimbusScaleValue(18, CurrentPPI);
  if LHeight > LRect.Height then LHeight := LRect.Height;
  LTop := LRect.Top + (LRect.Height - LHeight) div 2;
  FEditor.SetBounds(LRect.Left, LTop, Max(1, LRect.Width), Max(1, LHeight));
end;

procedure TCustomThemedDropdown.UpdateEditorTheme;
var
  LBack, LFore: TThemeColor;
begin
  if FEditor = nil then Exit;
  if not Enabled then
  begin
    LBack := NimbusDisabledBackColor(Palette);
    LFore := NimbusDisabledForeColor(Palette);
  end
  else
  begin
    if FCustomBackColor <> clNone then LBack := ColorToThemeColor(FCustomBackColor) else LBack := NimbusInputBackColor(Palette);
    if FCustomForeColor <> clNone then LFore := ColorToThemeColor(FCustomForeColor) else LFore := NimbusInputForeColor(Palette);
  end;
  FEditor.ParentColor := False;
  FEditor.Color := ThemeColorToColor(LBack);
  FEditor.ParentFont := False;
  FEditor.Font.Assign(Font);
  FEditor.Font.Color := ThemeColorToColor(LFore);
end;

procedure TCustomThemedDropdown.UpdateEditorMode;
begin
  FEditor.ReadOnly := not FAutoCompleteEnabled;
  FEditor.TabStop := FAutoCompleteEnabled;
end;

procedure TCustomThemedDropdown.UpdateVisibleItems;
var
  I: Integer;
  LFilter: string;
  LItem, LPendingGroup, LPendingSeparator: TThemedDropdownItem;
  LHasSelectable: Boolean;
begin
  FVisibleItems.Clear;
  if not FAutoCompleteEnabled or (Length(FFilterText) < FAutoCompleteMinimumCharacters) then
  begin
    for I := 0 to FItems.Count - 1 do FVisibleItems.Add(FItems[I]);
    Exit;
  end;
  LFilter := Trim(FFilterText);
  if LFilter = '' then
  begin
    for I := 0 to FItems.Count - 1 do FVisibleItems.Add(FItems[I]);
    Exit;
  end;
  LPendingGroup := nil;
  LPendingSeparator := nil;
  LHasSelectable := False;
  for I := 0 to FItems.Count - 1 do
  begin
    LItem := FItems[I];
    if LItem.IsSeparator then
    begin
      LPendingSeparator := LItem;
      LPendingGroup := nil;
      Continue;
    end;
    if LItem.IsGroupHeader then
    begin
      LPendingGroup := LItem;
      Continue;
    end;
    if not LItem.Selectable or not IsFilterMatch(LItem, LFilter) then Continue;
    if (LPendingSeparator <> nil) and LHasSelectable then
      if (FVisibleItems.Count = 0) or not FVisibleItems[FVisibleItems.Count - 1].IsSeparator then FVisibleItems.Add(LPendingSeparator);
    if LPendingGroup <> nil then
      if (FVisibleItems.Count = 0) or (FVisibleItems[FVisibleItems.Count - 1] <> LPendingGroup) then FVisibleItems.Add(LPendingGroup);
    FVisibleItems.Add(LItem);
    LHasSelectable := True;
    LPendingSeparator := nil;
  end;
  while (FVisibleItems.Count > 0) and FVisibleItems[FVisibleItems.Count - 1].IsSeparator do FVisibleItems.Delete(FVisibleItems.Count - 1);
end;

procedure TCustomThemedDropdown.RefreshPopupItems(const AKeepVisible: Boolean);
begin
  if FPopup = nil then Exit;
  FPopup.ListControl.SetItems(FVisibleItems);
  FPopup.ListControl.ShowCheckboxes := FMultiSelect;
  FPopup.ListControl.StyleMode := FStyleMode;
  FPopup.SyncSize(Width);
  SyncPopupSelection;
  if not AKeepVisible and (FVisibleItems.Count = 0) then CloseDropdown;
end;

procedure TCustomThemedDropdown.SyncPopupSelection;
var
  LVisibleIndex, I: Integer;
  LSelected: TThemedDropdownItem;
begin
  if FPopup = nil then Exit;
  LVisibleIndex := -1;
  if not FUserIsEditing then
  begin
    LSelected := SelectedItem;
    if LSelected <> nil then LVisibleIndex := FPopup.ListControl.GetIndexOfItem(LSelected);
  end;
  if LVisibleIndex < 0 then
    for I := 0 to FVisibleItems.Count - 1 do
      if FVisibleItems[I].Selectable then
      begin
        LVisibleIndex := I;
        Break;
      end;
  FPopup.ListControl.SelectedIndex := LVisibleIndex;
end;

procedure TCustomThemedDropdown.SyncTextFromSelection;
var
  LChecked: TThemedDropdownItemArray;
  LItem: TThemedDropdownItem;
begin
  if FAutoCompleteEnabled and FUserIsEditing then
  begin
    SetEditorText(FFilterText);
    UpdateEditorLayout;
    Invalidate;
    Exit;
  end;
  if FMultiSelect then
  begin
    LChecked := GetCheckedItems;
    if Length(LChecked) = 0 then SetEditorText(FEmptyText)
    else if Length(LChecked) = 1 then SetEditorText(LChecked[0].Text)
    else SetEditorText(IntToStr(Length(LChecked)) + SDropdownSelectedSuffix);
  end
  else
  begin
    LItem := SelectedItem;
    if LItem = nil then SetEditorText(FEmptyText)
    else if LItem.IsGroupHeader then SetEditorText(FGroupPrefixText + LItem.GroupText)
    else SetEditorText(LItem.Text);
  end;
  UpdateEditorLayout;
  Invalidate;
end;

procedure TCustomThemedDropdown.SetEditorText(const AValue: string);
begin
  FSuppressEditTextChanged := True;
  try
    FEditor.Text := AValue;
  finally
    FSuppressEditTextChanged := False;
  end;
end;

procedure TCustomThemedDropdown.BeginEditing(const APreserveCurrentText: Boolean);
begin
  if not FAutoCompleteEnabled then Exit;
  if not FUserIsEditing then FCommittedTextBeforeEdit := FEditor.Text;
  FUserIsEditing := True;
  if APreserveCurrentText then
  begin
    FFilterText := FEditor.Text;
    if FFilterText = FEmptyText then
    begin
      FFilterText := '';
      SetEditorText('');
    end;
  end
  else
  begin
    FFilterText := '';
    SetEditorText('');
  end;
end;

procedure TCustomThemedDropdown.CommitCurrentSelection;
begin
  FFilterText := '';
  FUserIsEditing := False;
  UpdateVisibleItems;
  SyncTextFromSelection;
  CloseDropdown;
  SelectAllEditorText;
end;

procedure TCustomThemedDropdown.CancelCurrentEdit;
begin
  FUserIsEditing := False;
  FFilterText := '';
  SetEditorText(FCommittedTextBeforeEdit);
  if (SelectedItem <> nil) or (FEmptyText <> '') then SyncTextFromSelection;
  UpdateVisibleItems;
  CloseDropdown;
  SelectAllEditorText;
end;

procedure TCustomThemedDropdown.SelectAllEditorText;
begin
  if not FAutoCompleteEnabled or (FEditor.Parent <> Self) then Exit;
  FEditor.SelectAll;
end;

procedure TCustomThemedDropdown.FocusInternal;
begin
  if FAutoCompleteEnabled and FEditor.CanFocus then FEditor.SetFocus
  else if CanFocus then SetFocus;
  FFocused := True;
  Invalidate;
end;

procedure TCustomThemedDropdown.ClearDropdownSelection;
begin
  if FMultiSelect then ClearCheckedItems else SelectedIndex := -1;
  FFilterText := '';
  FUserIsEditing := False;
  SyncTextFromSelection;
  UpdateEditorLayout;
  Invalidate;
end;

procedure TCustomThemedDropdown.MoveSelection(const ADelta: Integer);
var
  I, LIndex, LStart, LStep: Integer;
begin
  if FItems.Count = 0 then Exit;
  if ADelta >= 0 then LStep := 1 else LStep := -1;
  LStart := FSelectedIndex;
  if LStart < 0 then
  begin
    if LStep > 0 then LStart := -1 else LStart := FItems.Count;
  end;
  LIndex := LStart;
  for I := 0 to FItems.Count - 1 do
  begin
    Inc(LIndex, LStep);
    if LIndex < 0 then LIndex := FItems.Count - 1 else if LIndex >= FItems.Count then LIndex := 0;
    if FItems[LIndex].Selectable then
    begin
      SelectedIndex := LIndex;
      Exit;
    end;
  end;
end;

procedure TCustomThemedDropdown.ToggleSelectedItemChecked;
var
  LItem: TThemedDropdownItem;
begin
  LItem := SelectedItem;
  if (LItem = nil) or not LItem.Selectable then Exit;
  LItem.Checked := not LItem.Checked;
  SyncTextFromSelection;
  DoCheckedItemsChanged;
  RefreshPopupItems(False);
  Invalidate;
end;

function TCustomThemedDropdown.FindFirstSelectableIndex: Integer;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do if FItems[I].Selectable then Exit(I);
  Result := -1;
end;

function TCustomThemedDropdown.CoerceSelectableIndex(const AValue: Integer): Integer;
var
  I, LValue: Integer;
begin
  if FItems.Count = 0 then Exit(-1);
  LValue := AValue;
  if LValue < -1 then LValue := -1;
  if LValue >= FItems.Count then LValue := FItems.Count - 1;
  if LValue = -1 then Exit(-1);
  if FItems[LValue].Selectable then Exit(LValue);
  for I := LValue + 1 to FItems.Count - 1 do if FItems[I].Selectable then Exit(I);
  for I := LValue - 1 downto 0 do if FItems[I].Selectable then Exit(I);
  Result := -1;
end;

function TCustomThemedDropdown.FindIndexByValue(const AValue: Variant): Integer;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Selectable and VarSameValue(FItems[I].Value, AValue) then Exit(I);
  Result := -1;
end;

function TCustomThemedDropdown.FindIndexByDataItem(const AValue: TObject): Integer;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Selectable and (FItems[I].DataItem = AValue) then Exit(I);
  Result := -1;
end;

function TCustomThemedDropdown.IsFilterMatch(const AItem: TThemedDropdownItem; const AFilter: string): Boolean;
var
  LValueText: string;
begin
  if AItem = nil then Exit(False);
  if AFilter = '' then Exit(True);
  if ContainsText(AItem.Text, AFilter) then Exit(True);
  if not VarIsEmpty(AItem.Value) and not VarIsNull(AItem.Value) then
  begin
    LValueText := VarToStr(AItem.Value);
    if ContainsText(LValueText, AFilter) then Exit(True);
  end;
  Result := False;
end;

procedure TCustomThemedDropdown.HandleAutoCompleteTextChanged;
begin
  UpdateVisibleItems;
  if Length(FFilterText) < FAutoCompleteMinimumCharacters then
  begin
    CloseDropdown;
    Exit;
  end;
  if FVisibleItems.Count = 0 then
  begin
    CloseDropdown;
    Exit;
  end;
  if not FDroppedDown then ShowDropdown else RefreshPopupItems(True);
end;

procedure TCustomThemedDropdown.EnsurePopup;
begin
  if FPopup <> nil then Exit;
  FPopup := TThemedDropdownPopupForm.Create(Self);
  TControlAccess(FPopup.ListControl).Font.Assign(Font);
  FPopup.ListControl.StyleMode := FStyleMode;
  FPopup.ListControl.ShowCheckboxes := FMultiSelect;
  FPopup.ListControl.OnSelectedIndexChanged := PopupListSelectedIndexChanged;
  FPopup.OnItemSelected := PopupItemSelected;
  FPopup.OnCheckedItemsChanged := PopupCheckedItemsChanged;
  FPopup.ApplyTheme(Palette);
  FPopup.SyncSize(Width);
end;

function TCustomThemedDropdown.GetPopupBounds: TRect;
var
  LPoint: TPoint;
  LWork: TRect;
  LHeight: Integer;
begin
  EnsurePopup;
  FPopup.SyncSize(Width);
  LHeight := FPopup.Height;
  LPoint := ClientToScreen(Point(0, Height));
  LWork := Screen.WorkAreaRect;
  if LPoint.Y + LHeight > LWork.Bottom then
    LPoint := ClientToScreen(Point(0, 0 - LHeight));
  Result := Rect(LPoint.X, LPoint.Y, LPoint.X + Width, LPoint.Y + LHeight);
end;

procedure TCustomThemedDropdown.RefreshPopupBounds;
var
  LBounds: TRect;
begin
  if (FPopup = nil) or not FDroppedDown then Exit;
  LBounds := GetPopupBounds;
  FPopup.ShowPopup(Self, LBounds);
end;

function TCustomThemedDropdown.PointInControlScreen(const APoint: TPoint): Boolean;
var
  LTopLeft, LBottomRight: TPoint;
  LRect: TRect;
begin
  LTopLeft := ClientToScreen(Point(0, 0));
  LBottomRight := ClientToScreen(Point(Width, Height));
  LRect := Rect(LTopLeft.X, LTopLeft.Y, LBottomRight.X, LBottomRight.Y);
  Result := PtInRect(LRect, APoint);
end;

function TCustomThemedDropdown.PointInPopupScreen(const APoint: TPoint): Boolean;
var
  LRect: TRect;
begin
  Result := False;
  if (FPopup = nil) or not FPopup.PopupVisible or not FPopup.HandleAllocated then Exit;
  if GetWindowRect(FPopup.Handle, LRect) then Result := PtInRect(LRect, APoint);
end;

procedure TCustomThemedDropdown.ProcessNavigationKey(var Key: Word; Shift: TShiftState);
begin
  if not Enabled then Exit;
  if ((ssAlt in Shift) and (Key = VK_DOWN)) or (Key = VK_F4) then
  begin
    if FDroppedDown then CloseDropdown else ShowDropdown;
    Key := 0;
    Exit;
  end;
  if FAutoCompleteEnabled then
  begin
    case Key of
      VK_DOWN:
        begin
          if not FDroppedDown then ShowDropdown;
          if FPopup <> nil then FPopup.ListControl.MoveSelection(1);
          Key := 0;
        end;
      VK_UP:
        begin
          if not FDroppedDown then ShowDropdown;
          if FPopup <> nil then FPopup.ListControl.MoveSelection(-1);
          Key := 0;
        end;
      VK_RETURN, VK_TAB:
        if FDroppedDown and (FPopup <> nil) then
        begin
          FPopup.ListControl.InvokeSelectedItem;
          Key := 0;
        end;
      VK_ESCAPE:
        begin
          CancelCurrentEdit;
          Key := 0;
        end;
    end;
    Exit;
  end;
  case Key of
    VK_DOWN:
      begin
        if FDroppedDown and (FPopup <> nil) then FPopup.ListControl.MoveSelection(1) else MoveSelection(1);
        Key := 0;
      end;
    VK_UP:
      begin
        if FDroppedDown and (FPopup <> nil) then FPopup.ListControl.MoveSelection(-1) else MoveSelection(-1);
        Key := 0;
      end;
    VK_SPACE:
      if FMultiSelect then
      begin
        if FDroppedDown and (FPopup <> nil) then FPopup.ListControl.ToggleSelectedCheckState else ToggleSelectedItemChecked;
        Key := 0;
      end;
    VK_RETURN:
      if FDroppedDown and (FPopup <> nil) then
      begin
        FPopup.ListControl.InvokeSelectedItem;
        Key := 0;
      end;
    VK_ESCAPE:
      if FDroppedDown then
      begin
        CloseDropdown;
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedDropdown.ItemsChanged(Sender: TObject; Item: TThemedDropdownItem);
begin
  if FDataRebuilding then Exit;
  FSelectedIndex := CoerceSelectableIndex(FSelectedIndex);
  UpdateVisibleItems;
  if not FUserIsEditing then SyncTextFromSelection;
  if FDroppedDown then RefreshPopupItems(True);
  Invalidate;
end;

procedure TCustomThemedDropdown.EditorChange(Sender: TObject);
begin
  if FSuppressEditTextChanged or not FAutoCompleteEnabled then Exit;
  FFilterText := FEditor.Text;
  FUserIsEditing := True;
  HandleAutoCompleteTextChanged;
end;

procedure TCustomThemedDropdown.EditorEnter(Sender: TObject);
begin
  FFocused := True;
  if FAutoCompleteEnabled and (FEditor.Text = FEmptyText) then SetEditorText('');
  Invalidate;
end;

procedure TCustomThemedDropdown.EditorExit(Sender: TObject);
begin
  FFocused := Focused;
  if FAutoCompleteEnabled and not FDroppedDown then
  begin
    FFilterText := '';
    FUserIsEditing := False;
    SyncTextFromSelection;
  end;
  Invalidate;
end;

procedure TCustomThemedDropdown.EditorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled or (Button <> mbLeft) then Exit;
  if FAutoCompleteEnabled then
  begin
    if not FUserIsEditing then BeginEditing(True);
    if not FDroppedDown then ShowDropdown;
  end
  else
  begin
    FocusInternal;
    if FDroppedDown then CloseDropdown else ShowDropdown;
  end;
end;

procedure TCustomThemedDropdown.EditorMouseEnter(Sender: TObject);
begin
  FHovered := True;
  Invalidate;
end;

procedure TCustomThemedDropdown.EditorMouseLeave(Sender: TObject);
begin
  if not PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos)) then
  begin
    FHovered := False;
    FClearHovered := False;
    Invalidate;
  end;
end;

procedure TCustomThemedDropdown.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  ProcessNavigationKey(Key, Shift);
end;

procedure TCustomThemedDropdown.PopupItemSelected(Sender: TObject; Item: TThemedDropdownItem);
begin
  if Item = nil then Exit;
  if FMultiSelect then
  begin
    Item.Checked := not Item.Checked;
    DoCheckedItemsChanged;
    RefreshPopupItems(True);
    Exit;
  end;
  SelectedIndex := Item.Index;
  CommitCurrentSelection;
  Click;
end;

procedure TCustomThemedDropdown.PopupCheckedItemsChanged(Sender: TObject);
begin
  if not FMultiSelect then Exit;
  SyncTextFromSelection;
  DoCheckedItemsChanged;
  Invalidate;
  FDroppedDown := True;
end;

procedure TCustomThemedDropdown.PopupListSelectedIndexChanged(Sender: TObject);
begin
end;

procedure TCustomThemedDropdown.ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
var
  LPoint: TPoint;
begin
  if not FDroppedDown then Exit;
  case Msg.message of
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN:
      begin
        GetCursorPos(LPoint);
        if not PointInControlScreen(LPoint) and not PointInPopupScreen(LPoint) then CloseDropdown;
      end;
    WM_MOVE, WM_SIZE:
      if (Parent <> nil) and Parent.HandleAllocated and (Msg.hwnd = Parent.Handle) then CloseDropdown;
  end;
end;

procedure TCustomThemedDropdown.ApplicationDeactivate(Sender: TObject);
begin
  if FDroppedDown then CloseDropdown;
end;

procedure TCustomThemedDropdown.Paint;
var
  LContext: TThemedDropdownRenderContext;
  LItem: TThemedDropdownItem;
  LTextRect: TRect;
begin
  LContext := BuildRenderContext;
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedDropdownRenderer.RenderControl(RenderCanvas, LContext, GetArrowButtonRect, GetClearButtonRect, CanShowClearButton, FClearHovered, FClearPressed);
    LItem := SelectedItem;
    if not FMultiSelect and not FAutoCompleteEnabled and (LItem <> nil) and not LItem.Image.Empty then
    begin
      LTextRect := GetTextRect;
      LTextRect.Left := FBorderThickness + IfThen(FStyleMode = tdsIdeCompact, NimbusScaleValue(6, CurrentPPI), NimbusScaleValue(8, CurrentPPI));
      TThemedDropdownRenderer.RenderSelectedImage(RenderCanvas, LContext, LItem.Image, LTextRect);
    end;
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedDropdown.Resize;
begin
  inherited Resize;
  UpdateMetrics;
  UpdateEditorLayout;
  if FDroppedDown then RefreshPopupBounds;
end;

procedure TCustomThemedDropdown.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LHover: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LHover := CanShowClearButton and PtInRect(GetClearButtonRect, Point(X, Y));
  if FClearHovered = LHover then Exit;
  FClearHovered := LHover;
  if LHover then Cursor := crHandPoint else Cursor := crDefault;
  Invalidate;
end;

procedure TCustomThemedDropdown.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanShowClearButton and PtInRect(GetClearButtonRect, Point(X, Y)) then
  begin
    FClearPressed := True;
    MouseCapture := True;
    Invalidate;
    Exit;
  end;
  FocusInternal;
  if FAutoCompleteEnabled then
  begin
    if PtInRect(GetArrowButtonRect, Point(X, Y)) then
    begin
      if FDroppedDown then CloseDropdown
      else
      begin
        FUserIsEditing := False;
        FFilterText := '';
        UpdateVisibleItems;
        ShowDropdown;
      end;
    end;
    Exit;
  end;
  if FDroppedDown then CloseDropdown else ShowDropdown;
end;

procedure TCustomThemedDropdown.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LExecute: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  if FClearPressed then
  begin
    LExecute := CanShowClearButton and PtInRect(GetClearButtonRect, Point(X, Y));
    FClearPressed := False;
    MouseCapture := False;
    if LExecute then
    begin
      ClearDropdownSelection;
      Click;
    end;
    Invalidate;
  end;
end;

procedure TCustomThemedDropdown.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  ProcessNavigationKey(Key, Shift);
end;

procedure TCustomThemedDropdown.MouseWheelHandler(var Message: TMessage);
var
  LDelta: SmallInt;
begin
  inherited MouseWheelHandler(Message);
  if not Enabled or (FItems.Count = 0) then Exit;
  LDelta := SmallInt(HiWord(Message.WParam));
  if FAutoCompleteEnabled then
  begin
    if not FDroppedDown then ShowDropdown;
    if FPopup <> nil then
    begin
      if LDelta < 0 then FPopup.ListControl.MoveSelection(1) else if LDelta > 0 then FPopup.ListControl.MoveSelection(-1);
    end;
  end
  else if FDroppedDown and (FPopup <> nil) then
  begin
    if LDelta < 0 then FPopup.ListControl.MoveSelection(1) else if LDelta > 0 then FPopup.ListControl.MoveSelection(-1);
  end
  else
  begin
    if LDelta < 0 then MoveSelection(1) else if LDelta > 0 then MoveSelection(-1);
  end;
end;

procedure TCustomThemedDropdown.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FHovered := True;
  Invalidate;
end;

procedure TCustomThemedDropdown.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if not PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos)) then
  begin
    FHovered := False;
    FClearHovered := False;
    Invalidate;
  end;
end;

procedure TCustomThemedDropdown.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then CloseDropdown;
  FEditor.Enabled := Enabled;
  UpdateEditorTheme;
  Invalidate;
end;

procedure TCustomThemedDropdown.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateEditorTheme;
  UpdateEditorLayout;
  if FPopup <> nil then TControlAccess(FPopup.ListControl).Font.Assign(Font);
end;

procedure TCustomThemedDropdown.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  FEditor.BiDiMode := BiDiMode;
  Invalidate;
end;

procedure TCustomThemedDropdown.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if MouseCapture then Exit;
  if FClearPressed then
  begin
    FClearPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedDropdown.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCustomThemedDropdown.DoSelectedIndexChanged;
begin
  if Assigned(FOnSelectedIndexChanged) then FOnSelectedIndexChanged(Self);
end;

procedure TCustomThemedDropdown.DoSelectedItemChanged;
begin
  if Assigned(FOnSelectedItemChanged) then FOnSelectedItemChanged(Self);
end;

procedure TCustomThemedDropdown.DoCheckedItemsChanged;
begin
  if Assigned(FOnCheckedItemsChanged) then FOnCheckedItemsChanged(Self);
end;

function TCustomThemedDropdown.AddItem(const AText: string): TThemedDropdownItem;
begin
  if DataSource <> nil then Result := FManualItems.AddItem(AText) else Result := FItems.AddItem(AText);
end;

function TCustomThemedDropdown.AddItem(const AText: string; const AValue: Variant): TThemedDropdownItem;
begin
  Result := AddItem(AText);
  Result.Value := AValue;
end;

function TCustomThemedDropdown.AddItem(const AText: string; const AValue: Variant; const AImage: Vcl.Graphics.TBitmap; const ATag: NativeInt): TThemedDropdownItem;
begin
  Result := AddItem(AText);
  Result.Value := AValue;
  if AImage <> nil then Result.Image := AImage;
  Result.Tag := ATag;
end;

function TCustomThemedDropdown.AddSeparator: TThemedDropdownItem;
begin
  if DataSource <> nil then Result := FManualItems.AddSeparator else Result := FItems.AddSeparator;
end;

function TCustomThemedDropdown.AddGroup(const AGroupText: string): TThemedDropdownItem;
begin
  if DataSource <> nil then Result := FManualItems.AddGroup(AGroupText) else Result := FItems.AddGroup(AGroupText);
end;

procedure TCustomThemedDropdown.ClearItems;
begin
  FManualItems.Clear;
  if DataSource <> nil then Exit;
  FItems.Clear;
  FSelectedIndex := -1;
  UpdateVisibleItems;
  SyncTextFromSelection;
end;

procedure TCustomThemedDropdown.RefreshDataSourceItems;
begin
  if DataSource <> nil then RebuildItemsFromDataSource(True);
end;

procedure TCustomThemedDropdown.SetItemChecked(const AIndex: Integer; const AChecked: Boolean);
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) or not FItems[AIndex].Selectable then Exit;
  if FItems[AIndex].Checked = AChecked then Exit;
  FItems[AIndex].Checked := AChecked;
  if not FMultiSelect and AChecked then SelectedIndex := AIndex else SyncTextFromSelection;
  DoCheckedItemsChanged;
  if FDroppedDown then RefreshPopupItems(True);
end;

procedure TCustomThemedDropdown.SetCheckedDataItems(const ADataItems: array of TObject);
var
  I, J: Integer;
  LChecked, LChanged: Boolean;
begin
  if not FMultiSelect then Exit;
  LChanged := False;
  FItems.BeginUpdate;
  try
    for I := 0 to FItems.Count - 1 do
      if FItems[I].Selectable then
      begin
        LChecked := False;
        if FItems[I].DataItem <> nil then
          for J := 0 to High(ADataItems) do
            if ADataItems[J] = FItems[I].DataItem then
            begin
              LChecked := True;
              Break;
            end;
        if FItems[I].Checked <> LChecked then
        begin
          FItems[I].Checked := LChecked;
          LChanged := True;
        end;
      end;
  finally
    FItems.EndUpdate;
  end;
  if not LChanged then Exit;
  FSelectedIndex := FindFirstSelectableIndex;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Selectable and FItems[I].Checked then
    begin
      FSelectedIndex := I;
      Break;
    end;
  SyncTextFromSelection;
  DoCheckedItemsChanged;
  if FDroppedDown then RefreshPopupItems(True);
  Invalidate;
end;

procedure TCustomThemedDropdown.ClearCheckedItems;
var
  I: Integer;
  LChanged: Boolean;
begin
  LChanged := False;
  FItems.BeginUpdate;
  try
    for I := 0 to FItems.Count - 1 do
      if FItems[I].Selectable and FItems[I].Checked then
      begin
        FItems[I].Checked := False;
        LChanged := True;
      end;
  finally
    FItems.EndUpdate;
  end;
  if not FMultiSelect then FSelectedIndex := -1;
  if LChanged then
  begin
    SyncTextFromSelection;
    DoCheckedItemsChanged;
    if FDroppedDown then RefreshPopupItems(True);
  end;
end;

procedure TCustomThemedDropdown.ApplyFilter(const AFilterText: string);
begin
  if not FAutoCompleteEnabled then Exit;
  BeginEditing(False);
  FFilterText := AFilterText;
  SetEditorText(FFilterText);
  HandleAutoCompleteTextChanged;
end;

procedure TCustomThemedDropdown.ClearFilter;
begin
  FFilterText := '';
  FUserIsEditing := False;
  UpdateVisibleItems;
  if FDroppedDown then RefreshPopupItems(False);
  SyncTextFromSelection;
end;

procedure TCustomThemedDropdown.ShowDropdown;
var
  LBounds: TRect;
begin
  UpdateVisibleItems;
  if FVisibleItems.Count = 0 then
  begin
    CloseDropdown;
    Exit;
  end;
  EnsurePopup;
  RefreshPopupItems(True);
  LBounds := GetPopupBounds;
  FPopup.ShowPopup(Self, LBounds);
  FDroppedDown := True;
  Invalidate;
end;

procedure TCustomThemedDropdown.CloseDropdown;
begin
  if FPopup <> nil then FPopup.ClosePopup;
  FDroppedDown := False;
  Invalidate;
end;

end.

unit NimbusForms.Grid.EditorBase;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.Rtti,
  System.TypInfo,
  Vcl.Controls,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.EditorIntf;

type
  TThemedGridEditorBase = class(TInterfacedObject, IThemedGridCellEditor)
  private
    FControl: TWinControl;
    FOriginalValue: TValue;
    FValueType: PTypeInfo;
    FAllowNull: Boolean;
  protected
    procedure InitControl(const AControl: TWinControl);
    function GetControl: TWinControl;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    procedure BeginEdit(const AContext: TThemedGridCellEditContext);
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); virtual; abstract;
    function GetValue: TValue; virtual; abstract;
    procedure SetValue(const AValue: TValue); virtual; abstract;
    function CommitEdit: Boolean; virtual;
    procedure CancelEdit; virtual;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); virtual; abstract;
    procedure FocusEditor;
    property OriginalValue: TValue read FOriginalValue;
    property ValueType: PTypeInfo read FValueType;
    property AllowNull: Boolean read FAllowNull;
  public
    destructor Destroy; override;
  end;

implementation

uses
  NimbusForms.Grid.EditorSupport;

destructor TThemedGridEditorBase.Destroy;
begin
  FControl.Free;
  inherited Destroy;
end;

procedure TThemedGridEditorBase.InitControl(const AControl: TWinControl);
begin
  FControl := AControl;
end;

function TThemedGridEditorBase.GetControl: TWinControl;
begin
  Result := FControl;
end;

procedure TThemedGridEditorBase.ApplyTheme(const APalette: TThemePalette);
begin
  TThemedGridEditorSupport.ApplyInputColors(FControl, APalette);
end;

procedure TThemedGridEditorBase.BeginEdit(const AContext: TThemedGridCellEditContext);
begin
  if AContext <> nil then
  begin
    FOriginalValue := AContext.Value;
    FValueType := AContext.ValueType;
  end
  else
  begin
    FOriginalValue := TValue.Empty;
    FValueType := nil;
  end;
  FAllowNull := TThemedGridEditorSupport.AllowNull(FValueType, FOriginalValue);
  DoBeginEdit(AContext);
end;

function TThemedGridEditorBase.CommitEdit: Boolean;
begin
  Result := True;
end;

procedure TThemedGridEditorBase.CancelEdit;
begin
  SetValue(FOriginalValue);
end;

procedure TThemedGridEditorBase.FocusEditor;
begin
  if (FControl <> nil) and FControl.CanFocus then
    FControl.SetFocus;
end;

end.

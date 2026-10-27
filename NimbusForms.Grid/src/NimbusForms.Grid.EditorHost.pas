unit NimbusForms.Grid.EditorHost;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Types,
  System.Classes,
  System.Rtti,
  Vcl.Controls,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.EditorIntf;

type
  TThemedGridEditorHost = class
  private
    FOwner: TWinControl;
    FEditor: IThemedGridCellEditor;
    FContext: TThemedGridCellEditContext;
    FOnEditorKeyDown: TKeyEvent;
    FOnEditLostFocus: TNotifyEvent;
    procedure ControlKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
    procedure ControlExit(ASender: TObject);
    procedure EndControlOnly;
    function GetIsEditing: Boolean;
    function GetControl: TWinControl;
    function GetIsPopupOpen: Boolean;
  public
    constructor Create(const AOwner: TWinControl);
    destructor Destroy; override;
    procedure BeginEdit(const AEditor: IThemedGridCellEditor; const AContext: TThemedGridCellEditContext;
      const APalette: TThemePalette);
    function GetValue: TValue;
    function CommitEdit: Boolean;
    procedure CancelEdit;
    procedure Close;
    function TakeContext: TThemedGridCellEditContext;
    procedure UpdateBounds(const ABounds: TRect);
    function ControlHasFocus: Boolean;
    property IsEditing: Boolean read GetIsEditing;
    property Context: TThemedGridCellEditContext read FContext;
    property Control: TWinControl read GetControl;
    property Editor: IThemedGridCellEditor read FEditor;
    property IsPopupOpen: Boolean read GetIsPopupOpen;
    property OnEditorKeyDown: TKeyEvent read FOnEditorKeyDown write FOnEditorKeyDown;
    property OnEditLostFocus: TNotifyEvent read FOnEditLostFocus write FOnEditLostFocus;
  end;

implementation

uses
  System.SysUtils;

type
  TControlFontCracker = class(TControl)
  public
    property Font;
  end;

constructor TThemedGridEditorHost.Create(const AOwner: TWinControl);
begin
  inherited Create;
  if AOwner = nil then
    raise EArgumentNilException.Create('AOwner');
  FOwner := AOwner;
end;

destructor TThemedGridEditorHost.Destroy;
begin
  EndControlOnly;
  inherited Destroy;
end;

function TThemedGridEditorHost.GetIsEditing: Boolean;
begin
  Result := FEditor <> nil;
end;

function TThemedGridEditorHost.GetControl: TWinControl;
begin
  if FEditor <> nil then
    Result := FEditor.Control
  else
    Result := nil;
end;

function TThemedGridEditorHost.GetIsPopupOpen: Boolean;
var
  LState: IThemedGridEditorPopupState;
begin
  Result := False;
  if (FEditor <> nil) and Supports(FEditor, IThemedGridEditorPopupState, LState) then
    Result := LState.IsPopupOpen;
end;

procedure TThemedGridEditorHost.BeginEdit(const AEditor: IThemedGridCellEditor;
  const AContext: TThemedGridCellEditContext; const APalette: TThemePalette);
var
  LControl: TWinControl;
begin
  EndControlOnly;
  if (AEditor = nil) or (AContext = nil) or (AEditor.Control = nil) then
  begin
    AContext.Free;
    Exit;
  end;
  FEditor := AEditor;
  FContext := AContext;
  LControl := AEditor.Control;
  LControl.Visible := False;
  LControl.Parent := FOwner;
  LControl.Align := alNone;
  TControlFontCracker(LControl).Font.Assign(TControlFontCracker(FOwner).Font);
  AEditor.ApplyTheme(APalette);
  LControl.BoundsRect := AContext.Bounds;
  AEditor.AttachHooks(ControlKeyDown, ControlExit);
  LControl.Visible := True;
  LControl.BringToFront;
  AEditor.BeginEdit(AContext);
end;

function TThemedGridEditorHost.GetValue: TValue;
begin
  if FEditor <> nil then
    Result := FEditor.GetValue
  else
    Result := TValue.Empty;
end;

function TThemedGridEditorHost.CommitEdit: Boolean;
begin
  Result := (FEditor = nil) or FEditor.CommitEdit;
end;

procedure TThemedGridEditorHost.CancelEdit;
begin
  if FEditor <> nil then
    FEditor.CancelEdit;
  EndControlOnly;
end;

procedure TThemedGridEditorHost.Close;
begin
  EndControlOnly;
end;

function TThemedGridEditorHost.TakeContext: TThemedGridCellEditContext;
begin
  Result := FContext;
  FContext := nil;
  EndControlOnly;
end;

procedure TThemedGridEditorHost.UpdateBounds(const ABounds: TRect);
begin
  if (FEditor <> nil) and (FEditor.Control <> nil) then
    FEditor.Control.BoundsRect := ABounds;
end;

function TThemedGridEditorHost.ControlHasFocus: Boolean;
var
  LControl: TWinControl;
  LFocus: HWND;
begin
  Result := False;
  LControl := Control;
  if (LControl = nil) or not LControl.HandleAllocated then
    Exit;
  LFocus := GetFocus;
  Result := (LFocus <> 0) and ((LFocus = LControl.Handle) or IsChild(LControl.Handle, LFocus));
end;

procedure TThemedGridEditorHost.EndControlOnly;
var
  LEditor: IThemedGridCellEditor;
  LControl: TWinControl;
begin
  LEditor := FEditor;
  FEditor := nil;
  if LEditor <> nil then
  begin
    LEditor.AttachHooks(nil, nil);
    LControl := LEditor.Control;
    if LControl <> nil then
    begin
      LControl.Visible := False;
      LControl.Parent := nil;
    end;
  end;
  FContext.Free;
  FContext := nil;
end;

procedure TThemedGridEditorHost.ControlKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
begin
  if Assigned(FOnEditorKeyDown) then
    FOnEditorKeyDown(ASender, AKey, AShift);
end;

procedure TThemedGridEditorHost.ControlExit(ASender: TObject);
begin
  if Assigned(FOnEditLostFocus) then
    FOnEditLostFocus(Self);
end;

end.

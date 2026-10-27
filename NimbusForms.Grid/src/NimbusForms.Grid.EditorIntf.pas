unit NimbusForms.Grid.EditorIntf;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  Vcl.Controls,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell;

type
  TThemedGridCellEditContext = class
  private
    FGrid: TWinControl;
    FCell: TThemedGridCell;
    FColumn: TThemedGridColumn;
    FRowObject: TValue;
    FValue: TValue;
    FValueType: PTypeInfo;
    FBounds: TRect;
  public
    destructor Destroy; override;
    property Grid: TWinControl read FGrid write FGrid;
    property Cell: TThemedGridCell read FCell write FCell;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property RowObject: TValue read FRowObject write FRowObject;
    property Value: TValue read FValue write FValue;
    property ValueType: PTypeInfo read FValueType write FValueType;
    property Bounds: TRect read FBounds write FBounds;
  end;

  IThemedGridCellEditor = interface
    ['{C2E997FD-88EA-4BB5-A2C2-7A9BDFA14EA4}']
    function GetControl: TWinControl;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure BeginEdit(const AContext: TThemedGridCellEditContext);
    function GetValue: TValue;
    procedure SetValue(const AValue: TValue);
    function CommitEdit: Boolean;
    procedure CancelEdit;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
    property Control: TWinControl read GetControl;
  end;

  IThemedGridInteractiveCellEditor = interface
    ['{E04CC7A8-2B12-46A9-B456-B2A68A4DF431}']
    function HitTest(const ABounds: TRect; const ALocation: TPoint): Boolean;
    procedure Activate(const ALocation: TPoint);
  end;

  IThemedGridEditorPopupState = interface
    ['{2E87E9C0-6A67-47D7-A983-0BA75318AD69}']
    function GetIsPopupOpen: Boolean;
    property IsPopupOpen: Boolean read GetIsPopupOpen;
  end;

implementation

destructor TThemedGridCellEditContext.Destroy;
begin
  FCell.Free;
  inherited Destroy;
end;

end.

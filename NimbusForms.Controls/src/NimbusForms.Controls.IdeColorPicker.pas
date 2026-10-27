{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.IdeColorPicker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.UITypes,
  System.SysUtils, System.Generics.Collections, Vcl.Controls, Vcl.Graphics,
  Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, NimbusForms.Controls.Base, NimbusForms.Rendering.IdeColorPicker,
  NimbusForms.Menus.PopupMenu, NimbusForms.Controls.Dropdown,
  NimbusForms.Controls.Dropdown.Types, NimbusForms.ColorPalettes.Catalog;

type
  TIdeColorPaletteMode = (icpmAll, icpmBasic, icpmSystem, icpmWeb, icpmCustom, icpmGradient, icpmLibrary);
  TIdeColorTab = (ictBasic, ictSystem, ictWeb, ictCustom, ictGradient, ictLibrary);
  TIdeColorCopyFormat = (iccfHex, iccfHexWithAlpha, iccfRgb, iccfRgba, iccfCSharpColor, iccfHtml);
  TIdeColorCommitMode = (iccmImmediate, iccmOkCancel);
  TIdeColorSizeMode = (icsmCompact, icsmNormal);
  TIdeColorChangedEvent = procedure(Sender: TObject; AOldColor, ANewColor: TColor) of object;
  TIdeColorSelectedEvent = procedure(Sender: TObject; AColor: TColor; const ASource: string) of object;
  TIdeCustomColorEvent = procedure(Sender: TObject; AColor: TColor; AIndex: Integer) of object;
  TIdeArgbSelectedEvent = procedure(Sender: TObject; AARGB: Cardinal; const ASource: string) of object;

  TCustomThemedIdeColorPicker = class(TCustomNimbusControl)
  private
    FSelectedColor: TColor;
    FOriginalColor: TColor;
    FGradientColor: TColor;
    FGradientHue: Single;
    FGradientSaturation: Single;
    FGradientBrightness: Single;
    FScrollRow: Integer;
    FKeyboardIndex: Integer;
    FHexEditing: Boolean;
    FHexInput: string;
    FHexEdit: TEdit;
    FHexSyncing: Boolean;
    FNumericEditIndex: Integer;
    FNumericInput: string;
    FCustomMenu: TThemedPopupMenu;
    FPaletteLibrary: TNimbusColorPaletteLibrary;
    FOwnPaletteLibrary: TNimbusColorPaletteLibrary;
    FCategoryDropdown: TThemedDropdown;
    FPaletteDropdown: TThemedDropdown;
    FCategoryIndex: Integer;
    FPaletteIndex: Integer;
    FPaletteFileName: string;
    FUpdatingLibrary: Boolean;
    FOnLibraryPaletteChanged: TNotifyEvent;
    FContextColorIndex: Integer;
    FSelectedAlpha: Byte;
    FOriginalAlpha: Byte;
    FSizeMode: TIdeColorSizeMode;
    FPaletteMode: TIdeColorPaletteMode;
    FSelectedTab: TIdeColorTab;
    FCommitMode: TIdeColorCommitMode;
    FCopyFormat: TIdeColorCopyFormat;
    FShowAlpha: Boolean;
    FShowCopyButton: Boolean;
    FShowBasicColors: Boolean;
    FShowSystemColors: Boolean;
    FShowWebColors: Boolean;
    FShowCustomColors: Boolean;
    FShowCustomToolbar: Boolean;
    FAutoAddSelectedColorToCustom: Boolean;
    FSelectedCustomColorIndex: Integer;
    FPaletteVisibleRows: Integer;
    FBarHitPadding: Integer;
    FCustomColors: TList<TColor>;
    FCustomAlphas: TList<Byte>;
    FHover: TPoint;
    FPressedButton: Integer;
    FDragTarget: Integer;
    FOnSelectedColorChanged: TIdeColorChangedEvent;
    FOnColorSelected: TIdeColorSelectedEvent;
    FOnARGBColorSelected: TIdeArgbSelectedEvent;
    FOnCustomColorAdded: TIdeCustomColorEvent;
    FOnCustomColorRemoved: TIdeCustomColorEvent;
    FOnCustomColorsCleared: TNotifyEvent;
    FOnOkClicked: TNotifyEvent;
    FOnCancelClicked: TNotifyEvent;
    FOnDone: TNotifyEvent;
    FCopyCaption: string;
    FCustomAddCaption: string;
    FCustomRemoveCaption: string;
    FCustomClearCaption: string;
    FOkCaption: string;
    FCancelCaption: string;
    FPending: Boolean;
    FLastActionCancel: Boolean;
    function Density(ANormal, ACompact: Integer): Integer;
    procedure LoadDefaultPaletteLibrary;
    procedure SetPaletteFileName(const AValue: string);
    procedure SetPaletteLibrary(AValue: TNimbusColorPaletteLibrary);
    procedure FillPaletteCategories;
    procedure FillPaletteNames;
    procedure CategoryChanged(Sender: TObject);
    procedure PaletteDropdownChanged(Sender: TObject);
    procedure PositionLibraryDropdowns;
    procedure UpdateLibraryVisibility;
    function CurrentLibraryPalette: TNimbusColorPalette;
    procedure LibraryChanged(Sender: TObject);
    function GetSelectedCategoryId: string;
    function GetSelectedPaletteId: string;
    procedure SetSelectedCategoryId(const AValue: string);
    procedure SetSelectedPaletteId(const AValue: string);
    procedure SetSizeMode(AValue: TIdeColorSizeMode);
    function ActiveTab: TIdeColorTab;
    function TabRect(AIndex: Integer): TRect;
    function TabVisible(ATab: TIdeColorTab): Boolean;
    function PaletteCellCount: Integer;
    function PaletteCell(AIndex: Integer): TColor;
    function CellRect(AIndex: Integer): TRect;
    function GradientRect: TRect;
    function HueRect: TRect;
    function BrightnessRect: TRect;
    function AlphaRect: TRect;
    function HexRect: TRect;
    procedure PositionHexEdit;
    procedure SyncHexEdit;
    procedure HexEditExit(Sender: TObject);
    procedure HexEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetHexColor: string;
    procedure SetHexColor(const AValue: string);
    function TryParseHexColor(const AValue: string; out AARGB: Cardinal): Boolean;
    procedure SyncHSV;
    procedure ApplyNumericInput;
    procedure CustomMenuAdd(Sender: TObject);
    procedure CustomMenuRemove(Sender: TObject);
    procedure CustomMenuClear(Sender: TObject);
    function SliderRect(AIndex: Integer): TRect;
    function ToolRect(AIndex: Integer): TRect;
    function ButtonAt(const P: TPoint): Integer;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    function ActionRect(AIndex: Integer): TRect;
    function SliderValue(AIndex: Integer): Integer;
    procedure SetSliderValue(AIndex, AValue: Integer);
    procedure SetSelectedColor(AValue: TColor);
    procedure SetSelectedAlpha(AValue: Byte);
    procedure SetPaletteMode(AValue: TIdeColorPaletteMode);
    procedure SetSelectedTab(AValue: TIdeColorTab);
    procedure SetShowAlpha(AValue: Boolean);
    procedure SetShowCopyButton(AValue: Boolean);
    procedure SetShowBasicColors(AValue: Boolean);
    procedure SetShowSystemColors(AValue: Boolean);
    procedure SetShowWebColors(AValue: Boolean);
    procedure SetShowCustomColors(AValue: Boolean);
    procedure SetShowCustomToolbar(AValue: Boolean);
    procedure SetCommitMode(AValue: TIdeColorCommitMode);
    procedure SetPaletteVisibleRows(AValue: Integer);
    function HitBar(const ARect: TRect; const APoint: TPoint): Boolean;
    procedure SetCustomColorsString(const AValue: string);
    function GetCustomColorsString: string;
    function GetCustomColor(AIndex: Integer): TColor;
    function GetCustomColorCount: Integer;
    function GetARGB: Cardinal;
    procedure SetARGB(AValue: Cardinal);
    procedure ChooseColor(AColor: TColor; const ASource: string);
    procedure Commit;
    procedure Cancel;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginSelection;
    procedure AddCustomColor(AColor: TColor);
    procedure AddCustomARGB(AARGB: Cardinal);
    procedure AddSelectedColorToCustomPalette;
    function RemoveCustomColor(AColor: TColor): Boolean;
    function RemoveCustomColorAt(AIndex: Integer): Boolean;
    procedure ClearCustomColors;
    procedure LoadCustomColorsFromString(const AValue: string);
    function SaveCustomColorsToString: string;
    function ColorText: string;
    procedure CopySelectedColorToClipboard;
    property CustomColorCount: Integer read GetCustomColorCount;
    property ARGB: Cardinal read GetARGB write SetARGB;
    property HexColor: string read GetHexColor write SetHexColor;
    property CustomColors[AIndex: Integer]: TColor read GetCustomColor;
    property SelectedCategoryId: string read GetSelectedCategoryId write SetSelectedCategoryId;
    property SelectedPaletteId: string read GetSelectedPaletteId write SetSelectedPaletteId;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabStop;
    property Font;
    property ParentFont;
    property Action;
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor default clWhite;
    property SelectedAlpha: Byte read FSelectedAlpha write SetSelectedAlpha default 255;
    property SizeMode: TIdeColorSizeMode read FSizeMode write SetSizeMode default icsmCompact;
    property PaletteMode: TIdeColorPaletteMode read FPaletteMode write SetPaletteMode default icpmAll;
    property PaletteLibrary: TNimbusColorPaletteLibrary read FPaletteLibrary write SetPaletteLibrary;
    property PaletteFileName: string read FPaletteFileName write SetPaletteFileName;
    property OnLibraryPaletteChanged: TNotifyEvent read FOnLibraryPaletteChanged write FOnLibraryPaletteChanged;
    property SelectedTab: TIdeColorTab read FSelectedTab write SetSelectedTab default ictBasic;
    property CommitMode: TIdeColorCommitMode read FCommitMode write SetCommitMode default iccmImmediate;
    property CopyFormat: TIdeColorCopyFormat read FCopyFormat write FCopyFormat default iccfHex;
    property ShowAlpha: Boolean read FShowAlpha write SetShowAlpha default True;
    property ShowCopyButton: Boolean read FShowCopyButton write SetShowCopyButton default True;
    property ShowBasicColors: Boolean read FShowBasicColors write SetShowBasicColors default True;
    property ShowSystemColors: Boolean read FShowSystemColors write SetShowSystemColors default True;
    property ShowWebColors: Boolean read FShowWebColors write SetShowWebColors default True;
    property ShowCustomColors: Boolean read FShowCustomColors write SetShowCustomColors default True;
    property ShowCustomToolbar: Boolean read FShowCustomToolbar write SetShowCustomToolbar default True;
    property AutoAddSelectedColorToCustom: Boolean read FAutoAddSelectedColorToCustom write FAutoAddSelectedColorToCustom default False;
    property SelectedCustomColorIndex: Integer read FSelectedCustomColorIndex write FSelectedCustomColorIndex default -1;
    property PaletteVisibleRows: Integer read FPaletteVisibleRows write SetPaletteVisibleRows default 5;
    property BarHitPadding: Integer read FBarHitPadding write FBarHitPadding default 5;
    property CustomColorsString: string read GetCustomColorsString write SetCustomColorsString;
    property CopyCaption: string read FCopyCaption write FCopyCaption;
    property CustomAddCaption: string read FCustomAddCaption write FCustomAddCaption;
    property CustomRemoveCaption: string read FCustomRemoveCaption write FCustomRemoveCaption;
    property CustomClearCaption: string read FCustomClearCaption write FCustomClearCaption;
    property OkCaption: string read FOkCaption write FOkCaption;
    property CancelCaption: string read FCancelCaption write FCancelCaption;
    property OnSelectedColorChanged: TIdeColorChangedEvent read FOnSelectedColorChanged write FOnSelectedColorChanged;
    property OnColorSelected: TIdeColorSelectedEvent read FOnColorSelected write FOnColorSelected;
    property OnARGBColorSelected: TIdeArgbSelectedEvent read FOnARGBColorSelected write FOnARGBColorSelected;
    property OnCustomColorAdded: TIdeCustomColorEvent read FOnCustomColorAdded write FOnCustomColorAdded;
    property OnCustomColorRemoved: TIdeCustomColorEvent read FOnCustomColorRemoved write FOnCustomColorRemoved;
    property OnCustomColorsCleared: TNotifyEvent read FOnCustomColorsCleared write FOnCustomColorsCleared;
    property OnOkClicked: TNotifyEvent read FOnOkClicked write FOnOkClicked;
    property OnCancelClicked: TNotifyEvent read FOnCancelClicked write FOnCancelClicked;
    property OnClick;
    property OnEnter;
    property OnExit;
  end;

  TThemedIdeColorPicker = class(TCustomThemedIdeColorPicker)
  end;

  TThemedIdeColorPickerButton = class(TCustomNimbusControl)
  private
    FPicker: TThemedIdeColorPicker;
    FPopup: TForm;
    FSelectedColor: TColor;
    FButtonText: string;
    FMouseHover: Boolean;
    FMousePressed: Boolean;
    FDropDownSize: TSize;
    FSizeMode: TIdeColorSizeMode;
    FPaletteMode: TIdeColorPaletteMode;
    FPaletteFileName: string;
    FCommitMode: TIdeColorCommitMode;
    FShowAlpha: Boolean;
    FCopyFormat: TIdeColorCopyFormat;
    FCloseOnCustomColorSelected: Boolean;
    FCloseOnPaletteColorSelected: Boolean;
    FCloseOnGradientColorSelected: Boolean;
    FCloseOnEditorColorSelected: Boolean;
    FCloseOnOk: Boolean;
    FCloseOnCancel: Boolean;
    FDropDownOriginalColor: TColor;
    FOnColorAccepted: TNotifyEvent;
    FOnColorCancelled: TNotifyEvent;
    FOnSelectedColorChanged: TIdeColorChangedEvent;
    FOnColorSelected: TIdeColorSelectedEvent;
    procedure PopupColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
    procedure PopupColorSelected(Sender: TObject; AColor: TColor; const ASource: string);
    procedure PopupDone(Sender: TObject);
    procedure PopupDeactivate(Sender: TObject);
    procedure SetSelectedColor(AValue: TColor);
    procedure SetButtonText(const AValue: string);
    procedure SetDropDownSize(const AValue: TSize);
    procedure SetSizeMode(AValue: TIdeColorSizeMode);
    function GetDropDownWidth: Integer;
    function GetDropDownHeight: Integer;
    procedure SetDropDownWidth(AValue: Integer);
    procedure SetDropDownHeight(AValue: Integer);
    procedure SetPaletteMode(AValue: TIdeColorPaletteMode);
    procedure SetPaletteFileName(const AValue: string);
    procedure SetCommitMode(AValue: TIdeColorCommitMode);
    function GetDroppedDown: Boolean;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenDropDown;
    procedure CloseDropDown;
    property Picker: TThemedIdeColorPicker read FPicker;
    property DroppedDown: Boolean read GetDroppedDown;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property Font;
    property ParentFont;
    property TabStop;
    property Action;
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor default clWhite;
    property ButtonText: string read FButtonText write SetButtonText;
    property SizeMode: TIdeColorSizeMode read FSizeMode write SetSizeMode default icsmCompact;
    property DropDownWidth: Integer read GetDropDownWidth write SetDropDownWidth default 300;
    property DropDownHeight: Integer read GetDropDownHeight write SetDropDownHeight default 326;
    property PaletteMode: TIdeColorPaletteMode read FPaletteMode write SetPaletteMode default icpmAll;
    property PaletteFileName: string read FPaletteFileName write SetPaletteFileName;
    property CommitMode: TIdeColorCommitMode read FCommitMode write SetCommitMode default iccmImmediate;
    property ShowAlpha: Boolean read FShowAlpha write FShowAlpha default True;
    property CopyFormat: TIdeColorCopyFormat read FCopyFormat write FCopyFormat default iccfHex;
    property CloseOnCustomColorSelected: Boolean read FCloseOnCustomColorSelected write FCloseOnCustomColorSelected default False;
    property CloseOnPaletteColorSelected: Boolean read FCloseOnPaletteColorSelected write FCloseOnPaletteColorSelected default False;
    property CloseOnGradientColorSelected: Boolean read FCloseOnGradientColorSelected write FCloseOnGradientColorSelected default True;
    property CloseOnEditorColorSelected: Boolean read FCloseOnEditorColorSelected write FCloseOnEditorColorSelected default True;
    property CloseOnOk: Boolean read FCloseOnOk write FCloseOnOk default True;
    property CloseOnCancel: Boolean read FCloseOnCancel write FCloseOnCancel default True;
    property OnSelectedColorChanged: TIdeColorChangedEvent read FOnSelectedColorChanged write FOnSelectedColorChanged;
    property OnColorSelected: TIdeColorSelectedEvent read FOnColorSelected write FOnColorSelected;
    property OnColorAccepted: TNotifyEvent read FOnColorAccepted write FOnColorAccepted;
    property OnColorCancelled: TNotifyEvent read FOnColorCancelled write FOnColorCancelled;
    property OnClick;
  end;

implementation

uses
  System.Math, System.StrUtils, Vcl.Clipbrd, NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas, NimbusForms.Theming.Types, NimbusForms.Theming.Palette;

function IdeColorSize(AX, AY: Integer): TSize;
begin
  Result.cx := AX;
  Result.cy := AY;
end;

const
  BasicColors: array[0..41] of TColor = (
    clBlack, $696969, clGray, $A9A9A9, clSilver, $D3D3D3, clWhite,
    clMaroon, clRed, $4500FF, $00A5FF, $00D7FF, clYellow, $E0FFFF,
    $006400, clGreen, $578B2E, $71B33C, $32CD32, clLime, $98FB98,
    $8B8B00, $808000, $A09E5F, $FFBF00, $FF901E, $E1691E, clBlue,
    clNavy, $82004B, clPurple, $DB7093, clFuchsia, $9314FF, $CBC0FF,
    $2A2AA5, $2D69A0, $1E69D2, $3F85CD, $8CB4D2, $87B8DE, $DCF5F5);
  WebColors: array[0..147] of TColor = (
    $FFF8F0, $D7EBFA, $FFFF00, $D4FF7F, $FFFFF0, $DCF5F5, $C4E4FF, $000000,
    $CDEBFF, $FF0000, $E22B8A, $2A2AA5, $87B8DE, $A09E5F, $00FF7F, $1E69D2,
    $507FFF, $ED9564, $DCF8FF, $3C14DC, $FFFF00, $8B0000, $8B8B00, $0B86B8,
    $A9A9A9, $006400, $A9A9A9, $6BB7BD, $8B008B, $2F6B55, $008CFF, $CC3299,
    $00008B, $7A96E9, $8FBC8F, $8B3D48, $4F4F2F, $4F4F2F, $D1CE00, $D30094,
    $9314FF, $FFBF00, $696969, $696969, $FF901E, $2222B2, $F0FAFF, $228B22,
    $FF00FF, $DCDCDC, $FFF8F8, $00D7FF, $20A5DA, $808080, $008000, $2FFFAD,
    $808080, $F0FFF0, $B469FF, $5C5CCD, $82004B, $F0FFFF, $8CE6F0, $FAE6E6,
    $F5F0FF, $00FC7C, $CDFAFF, $E6D8AD, $8080F0, $FFFFE0, $D2FAFA, $D3D3D3,
    $90EE90, $D3D3D3, $C1B6FF, $7AA0FF, $AAB220, $FACE87, $998877, $998877,
    $DEC4B0, $E0FFFF, $00FF00, $32CD32, $E6F0FA, $FF00FF, $000080, $AACD66,
    $CD0000, $D355BA, $DB7093, $71B33C, $EE687B, $9AFA00, $CCD148, $8515C7,
    $701919, $FAFFF5, $E1E4FF, $B5E4FF, $ADDEFF, $800000, $E6F5FD, $008080,
    $238E6B, $00A5FF, $0045FF, $D670DA, $AAE8EE, $98FB98, $EEEEAF, $9370DB,
    $D5EFFF, $B9DAFF, $3F85CD, $CBC0FF, $DDA0DD, $E6E0B0, $800080, $993366,
    $0000FF, $8F8FBC, $E16941, $13458B, $7280FA, $60A4F4, $578B2E, $EEF5FF,
    $2D52A0, $C0C0C0, $EBCE87, $CD5A6A, $908070, $908070, $FAFAFF, $7FFF00,
    $B48246, $8CB4D2, $808000, $D8BFD8, $4763FF, $D0E040, $EE82EE, $B3DEF5,
    $FFFFFF, $F5F5F5, $00FFFF, $32CD9A);

constructor TCustomThemedIdeColorPicker.Create(AOwner: TComponent);
var Item: TMenuItem;
begin
  inherited Create(AOwner);
  FSizeMode := icsmCompact;
  Width := 300;
  Height := 326;
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FSelectedColor := clWhite;
  FOriginalColor := clWhite;
  FSelectedAlpha := 255;
  FOriginalAlpha := 255;
  FGradientColor := clRed;
  FGradientHue := 0;
  FGradientSaturation := 0;
  FGradientBrightness := 1;
  FHexInput := '#FFFFFF';
  FCategoryIndex := 0;
  FPaletteIndex := 0;
  FOwnPaletteLibrary := TNimbusColorPaletteLibrary.Create(Self);
  FPaletteLibrary := FOwnPaletteLibrary;
  FCategoryDropdown := TThemedDropdown.Create(Self);
  FCategoryDropdown.StyleMode := tdsIdeCompact;
  FCategoryDropdown.AutoCompleteEnabled := False;
  FCategoryDropdown.TabStop := True;
  FCategoryDropdown.OnSelectedIndexChanged := CategoryChanged;
  FPaletteDropdown := TThemedDropdown.Create(Self);
  FPaletteDropdown.StyleMode := tdsIdeCompact;
  FPaletteDropdown.AutoCompleteEnabled := False;
  FPaletteDropdown.TabStop := True;
  FPaletteDropdown.OnSelectedIndexChanged := PaletteDropdownChanged;
  LoadDefaultPaletteLibrary;
  FillPaletteCategories;
  FHexEdit := TEdit.Create(Self);
  FHexEdit.TabStop := True;
  FHexEdit.BorderStyle := bsNone;
  FHexEdit.Color := clBlack;
  FHexEdit.Font.Name := 'Segoe UI';
  FHexEdit.Font.Size := 9;
  FHexEdit.Font.Color := clWhite;
  FHexEdit.OnExit := HexEditExit;
  FHexEdit.OnKeyDown := HexEditKeyDown;
  FNumericEditIndex := -1;
  FContextColorIndex := -1;
  FCustomMenu := TThemedPopupMenu.Create(Self);
  Item := TMenuItem.Create(FCustomMenu);
  Item.Caption := 'Add current color';
  Item.OnClick := CustomMenuAdd;
  FCustomMenu.Items.Add(Item);
  Item := TMenuItem.Create(FCustomMenu);
  Item.Caption := 'Remove color';
  Item.OnClick := CustomMenuRemove;
  FCustomMenu.Items.Add(Item);
  Item := TMenuItem.Create(FCustomMenu);
  Item.Caption := '-';
  FCustomMenu.Items.Add(Item);
  Item := TMenuItem.Create(FCustomMenu);
  Item.Caption := 'Clear custom colors';
  Item.OnClick := CustomMenuClear;
  FCustomMenu.Items.Add(Item);
  FPaletteVisibleRows := 5;
  FKeyboardIndex := -1;
  FBarHitPadding := 4;
  FSelectedCustomColorIndex := -1;
  FShowAlpha := True;
  FShowCopyButton := True;
  FShowBasicColors := True;
  FShowSystemColors := True;
  FShowWebColors := True;
  FShowCustomColors := True;
  FShowCustomToolbar := True;
  FHover := Point(-1,-1);
  FPressedButton := -1;
  FDragTarget := -1;
  FCopyCaption := 'Copy';
  FCustomAddCaption := 'Add';
  FCustomRemoveCaption := 'Remove';
  FCustomClearCaption := 'Clear';
  FOkCaption := 'OK';
  FCancelCaption := 'Cancel';
  FCustomColors := TList<TColor>.Create;
  FCustomAlphas := TList<Byte>.Create;
end;

destructor TCustomThemedIdeColorPicker.Destroy;
begin
  if (FPaletteLibrary <> nil) and (FPaletteLibrary <> FOwnPaletteLibrary) then
    FPaletteLibrary.RemoveFreeNotification(Self);
  FCategoryDropdown.Free;
  FPaletteDropdown.Free;
  FOwnPaletteLibrary.Free;
  FCustomMenu.Free;
  FreeAndNil(FHexEdit);
  FCustomAlphas.Free;
  FCustomColors.Free;
  inherited Destroy;
end;

procedure TCustomThemedIdeColorPicker.LoadDefaultPaletteLibrary;
var
  Dir, Candidate: string;
  I: Integer;
begin
  if FOwnPaletteLibrary = nil then Exit;
  Dir := ExtractFilePath(ParamStr(0));
  for I := 0 to 7 do
  begin
    Candidate := IncludeTrailingPathDelimiter(Dir) +
      'NimbusForms.Controls\Palettes\NimbusForms.ColorPalettes.json';
    if FileExists(Candidate) then
    begin
      FOwnPaletteLibrary.LoadFromFile(Candidate);
      Exit;
    end;
    Candidate := IncludeTrailingPathDelimiter(Dir) + 'NimbusForms.ColorPalettes.json';
    if FileExists(Candidate) then
    begin
      FOwnPaletteLibrary.LoadFromFile(Candidate);
      Exit;
    end;
    if ExtractFileDir(ExcludeTrailingPathDelimiter(Dir)) = ExcludeTrailingPathDelimiter(Dir) then Break;
    Dir := ExtractFileDir(ExcludeTrailingPathDelimiter(Dir));
  end;
end;

procedure TCustomThemedIdeColorPicker.SetPaletteFileName(const AValue: string);
begin
  if FPaletteFileName = AValue then Exit;
  if (AValue <> '') and FileExists(AValue) then
  begin
    FOwnPaletteLibrary.LoadFromFile(AValue);
    if FPaletteLibrary = FOwnPaletteLibrary then FillPaletteCategories;
  end;
  FPaletteFileName := AValue;
end;

procedure TCustomThemedIdeColorPicker.SetPaletteLibrary(AValue: TNimbusColorPaletteLibrary);
begin
  if AValue = nil then AValue := FOwnPaletteLibrary;
  if FPaletteLibrary = AValue then Exit;
  if (FPaletteLibrary <> nil) and (FPaletteLibrary <> FOwnPaletteLibrary) then
    FPaletteLibrary.RemoveFreeNotification(Self);
  FPaletteLibrary := AValue;
  if FPaletteLibrary <> FOwnPaletteLibrary then FPaletteLibrary.FreeNotification(Self);
  FillPaletteCategories;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPaletteLibrary) then
  begin
    if AComponent = FOwnPaletteLibrary then FOwnPaletteLibrary := nil;
    FPaletteLibrary := FOwnPaletteLibrary;
    if not (csDestroying in ComponentState) then FillPaletteCategories;
  end;
end;

procedure TCustomThemedIdeColorPicker.LibraryChanged(Sender: TObject);
begin
  FillPaletteCategories;
end;

procedure TCustomThemedIdeColorPicker.FillPaletteCategories;
var I: Integer;
begin
  if (FCategoryDropdown = nil) or (FPaletteLibrary = nil) then Exit;
  FUpdatingLibrary := True;
  try
    FCategoryDropdown.ClearItems;
    for I := 0 to FPaletteLibrary.CategoryCount - 1 do
      FCategoryDropdown.AddItem(FPaletteLibrary.CategoryAt(I).Name);
    if FPaletteLibrary.CategoryCount > 0 then
    begin
      if FCategoryIndex >= FPaletteLibrary.CategoryCount then FCategoryIndex := 0;
      FCategoryDropdown.SelectedIndex := FCategoryIndex;
    end;
  finally
    FUpdatingLibrary := False;
  end;
  FillPaletteNames;
end;

procedure TCustomThemedIdeColorPicker.FillPaletteNames;
var I: Integer; Category: TNimbusColorPaletteCategory;
begin
  if (FPaletteDropdown = nil) or (FPaletteLibrary = nil) then Exit;
  FUpdatingLibrary := True;
  try
    FPaletteDropdown.ClearItems;
    if (FCategoryIndex >= 0) and (FCategoryIndex < FPaletteLibrary.CategoryCount) then
    begin
      Category := FPaletteLibrary.CategoryAt(FCategoryIndex);
      for I := 0 to Category.PaletteCount - 1 do
        FPaletteDropdown.AddItem(Category.PaletteAt(I).Name);
      if Category.PaletteCount > 0 then
      begin
        if FPaletteIndex >= Category.PaletteCount then FPaletteIndex := 0;
        FPaletteDropdown.SelectedIndex := FPaletteIndex;
      end;
    end;
  finally
    FUpdatingLibrary := False;
  end;
  FScrollRow := 0;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.CategoryChanged(Sender: TObject);
begin
  if FUpdatingLibrary then Exit;
  FCategoryIndex := FCategoryDropdown.SelectedIndex;
  FPaletteIndex := 0;
  FillPaletteNames;
end;

procedure TCustomThemedIdeColorPicker.PaletteDropdownChanged(Sender: TObject);
begin
  if FUpdatingLibrary then Exit;
  FPaletteIndex := FPaletteDropdown.SelectedIndex;
  FScrollRow := 0;
  Invalidate;
  if Assigned(FOnLibraryPaletteChanged) then FOnLibraryPaletteChanged(Self);
end;

procedure TCustomThemedIdeColorPicker.PositionLibraryDropdowns;
var Margin, Gap, TopPos, W: Integer;
begin
  if (FCategoryDropdown = nil) or (FPaletteDropdown = nil) then Exit;
  Margin := ScaleValue(10);
  Gap := ScaleValue(5);
  W := Max(ScaleValue(60), (ClientWidth - 2 * Margin - Gap) div 2);
  TopPos := ScaleValue(23);
  FCategoryDropdown.SetBounds(Margin, TopPos, W, ScaleValue(25));
  FPaletteDropdown.SetBounds(Margin + W + Gap, TopPos, W, ScaleValue(25));
end;

procedure TCustomThemedIdeColorPicker.UpdateLibraryVisibility;
var V: Boolean;
begin
  if (FCategoryDropdown = nil) or (FPaletteDropdown = nil) then Exit;
  V := FPaletteMode = icpmLibrary;
  FCategoryDropdown.Visible := V;
  FPaletteDropdown.Visible := V;
end;

function TCustomThemedIdeColorPicker.CurrentLibraryPalette: TNimbusColorPalette;
var Category: TNimbusColorPaletteCategory;
begin
  Result := nil;
  if (FPaletteLibrary = nil) or
     (FCategoryIndex < 0) or (FCategoryIndex >= FPaletteLibrary.CategoryCount) then Exit;
  Category := FPaletteLibrary.CategoryAt(FCategoryIndex);
  if (FPaletteIndex >= 0) and (FPaletteIndex < Category.PaletteCount) then
    Result := Category.PaletteAt(FPaletteIndex);
end;

function TCustomThemedIdeColorPicker.GetSelectedCategoryId: string;
begin
  Result := '';
  if (FPaletteLibrary <> nil) and (FCategoryIndex >= 0) and
     (FCategoryIndex < FPaletteLibrary.CategoryCount) then
    Result := FPaletteLibrary.CategoryAt(FCategoryIndex).Id;
end;

function TCustomThemedIdeColorPicker.GetSelectedPaletteId: string;
var Pal: TNimbusColorPalette;
begin
  Result := '';
  Pal := CurrentLibraryPalette;
  if Pal <> nil then Result := Pal.Id;
end;

procedure TCustomThemedIdeColorPicker.SetSelectedCategoryId(const AValue: string);
var I: Integer;
begin
  if FPaletteLibrary = nil then Exit;
  I := FPaletteLibrary.FindCategory(AValue);
  if (I < 0) or (I = FCategoryIndex) then Exit;
  FCategoryIndex := I;
  FPaletteIndex := 0;
  FillPaletteCategories;
  if Assigned(FOnLibraryPaletteChanged) then FOnLibraryPaletteChanged(Self);
end;

procedure TCustomThemedIdeColorPicker.SetSelectedPaletteId(const AValue: string);
var I: Integer;
begin
  if FPaletteLibrary = nil then Exit;
  I := FPaletteLibrary.FindPalette(FCategoryIndex, AValue);
  if (I < 0) or (I = FPaletteIndex) then Exit;
  FPaletteIndex := I;
  FUpdatingLibrary := True;
  try
    FPaletteDropdown.SelectedIndex := I;
  finally
    FUpdatingLibrary := False;
  end;
  Invalidate;
  if Assigned(FOnLibraryPaletteChanged) then FOnLibraryPaletteChanged(Self);
end;

function TCustomThemedIdeColorPicker.Density(ANormal, ACompact: Integer): Integer;
begin
  if FSizeMode = icsmCompact then Result := ACompact else Result := ANormal;
end;

procedure TCustomThemedIdeColorPicker.SetSizeMode(AValue: TIdeColorSizeMode);
begin
  if FSizeMode = AValue then Exit;
  FSizeMode := AValue;
  if AValue = icsmCompact then
  begin
    SetBounds(Left,Top,300,326);
    FPaletteVisibleRows := 5;
  end
  else
  begin
    SetBounds(Left,Top,420,420);
    FPaletteVisibleRows := 6;
  end;
  FScrollRow := 0;
  PositionHexEdit;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCustomThemedIdeColorPicker.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent = nil) or (csDestroying in ComponentState) then Exit;
  if FCategoryDropdown <> nil then
  begin
    if FCategoryDropdown.Parent <> Self then FCategoryDropdown.Parent := Self;
    if (FPaletteDropdown <> nil) and (FPaletteDropdown.Parent <> Self) then
      FPaletteDropdown.Parent := Self;
    UpdateLibraryVisibility;
    PositionLibraryDropdowns;
  end;
  if FHexEdit <> nil then
  begin
    if FHexEdit.Parent <> Self then FHexEdit.Parent := Self;
    PositionHexEdit;
    SyncHexEdit;
  end;
end;

procedure TCustomThemedIdeColorPicker.Resize;
begin
  inherited Resize;
  PositionHexEdit;
  PositionLibraryDropdowns;
  Invalidate;
end;

function TCustomThemedIdeColorPicker.ActiveTab: TIdeColorTab;
begin
  Result := FSelectedTab;
  if (FPaletteMode=icpmAll) and not TabVisible(Result) then
  begin
    Result := ictGradient;
    if FShowBasicColors then Result := ictBasic
    else if FShowSystemColors then Result := ictSystem
    else if FShowWebColors then Result := ictWeb
    else if FShowCustomColors then Result := ictCustom;
  end;
  case FPaletteMode of
    icpmBasic: Result := ictBasic;
    icpmSystem: Result := ictSystem;
    icpmWeb: Result := ictWeb;
    icpmCustom: Result := ictCustom;
    icpmGradient: Result := ictGradient;
    icpmLibrary: Result := ictLibrary;
  end;
end;

function TCustomThemedIdeColorPicker.TabVisible(ATab: TIdeColorTab): Boolean;
begin
  case ATab of
    ictBasic: Result := FShowBasicColors;
    ictSystem: Result := FShowSystemColors;
    ictWeb: Result := FShowWebColors;
    ictCustom: Result := FShowCustomColors;
  else Result := True;
  end;
end;

function TCustomThemedIdeColorPicker.TabRect(AIndex: Integer): TRect;
var I, X, Count, W: Integer; T: TIdeColorTab;
begin
  Result := Rect(0,0,0,0);
  if (AIndex<0) or (AIndex>4) or (FPaletteMode<>icpmAll) then Exit;
  Count := 0;
  for I := 0 to 4 do
    if TabVisible(TIdeColorTab(I)) then Inc(Count);
  if Count=0 then Exit;
  W := Max(1,(ClientWidth-ScaleValue(Density(20,16))) div Count);
  X := ScaleValue(Density(10,8));
  for I := 0 to 4 do
  begin
    T := TIdeColorTab(I);
    if not TabVisible(T) then Continue;
    if I=AIndex then
    begin
      Result := Rect(X,ScaleValue(Density(8,6)),X+W-ScaleValue(2),ScaleValue(Density(34,29)));
      Exit;
    end;
    Inc(X,W);
  end;
end;

function TCustomThemedIdeColorPicker.PaletteCellCount: Integer;
begin
  case ActiveTab of
    ictBasic: Result := Length(BasicColors);
    ictSystem: Result := 24;
    ictWeb: Result := Length(WebColors);
    ictCustom: Result := FCustomColors.Count;
    ictLibrary:
      if CurrentLibraryPalette <> nil then
        Result := CurrentLibraryPalette.ColorCount
      else
        Result := 0;
  else Result := 0;
  end;
end;

function TCustomThemedIdeColorPicker.PaletteCell(AIndex: Integer): TColor;
const SystemColors: array[0..23] of Integer = (
  COLOR_WINDOW,COLOR_WINDOWTEXT,COLOR_BTNFACE,COLOR_BTNTEXT,COLOR_HIGHLIGHT,
  COLOR_HIGHLIGHTTEXT,COLOR_GRAYTEXT,COLOR_INFOBK,COLOR_INFOTEXT,COLOR_MENU,
  COLOR_MENUTEXT,COLOR_ACTIVECAPTION,COLOR_INACTIVECAPTION,COLOR_APPWORKSPACE,
  COLOR_3DSHADOW,COLOR_3DHILIGHT,COLOR_3DDKSHADOW,COLOR_3DLIGHT,COLOR_SCROLLBAR,
  COLOR_DESKTOP,COLOR_HOTLIGHT,COLOR_MENUHILIGHT,COLOR_MENUBAR,COLOR_WINDOWFRAME);
begin
  Result := clWhite;
  if (AIndex < 0) or (AIndex >= PaletteCellCount) then Exit;
  case ActiveTab of
    ictBasic: Result := BasicColors[AIndex];
    ictSystem: Result := GetSysColor(SystemColors[AIndex]);
    ictWeb: Result := WebColors[AIndex];
    ictCustom: Result := FCustomColors[AIndex];
    ictLibrary: Result := CurrentLibraryPalette.ColorAt(AIndex);
  end;
end;

function TCustomThemedIdeColorPicker.CellRect(AIndex: Integer): TRect;
var W, X, Y, Cols, CellW: Integer;
begin
  W := Max(1,ClientWidth-ScaleValue(Density(24,20)));
  Cols := 8;
  CellW := W div Cols;
  X := ScaleValue(Density(12,10))+(AIndex mod Cols)*CellW;
  Y := ScaleValue(Density(46,42))+((AIndex div Cols)-FScrollRow)*ScaleValue(Density(27,21));
  if ActiveTab = ictLibrary then Inc(Y, ScaleValue(50));
  Result := Rect(X,Y,X+CellW-ScaleValue(2),Y+ScaleValue(Density(25,18)));
end;

function TCustomThemedIdeColorPicker.GradientRect: TRect;
begin
  Result := Rect(ScaleValue(12),ScaleValue(Density(48,43) - IfThen(FPaletteMode <> icpmAll, 24, 0)),
    ClientWidth-ScaleValue(12),ScaleValue(Density(144,119) - IfThen(FPaletteMode <> icpmAll, 24, 0)));
end;

function TCustomThemedIdeColorPicker.HueRect: TRect;
begin
  Result := Rect(ScaleValue(54),ScaleValue(Density(153,125) - IfThen(FPaletteMode <> icpmAll, 24, 0)),
    ClientWidth-ScaleValue(12),ScaleValue(Density(164,134) - IfThen(FPaletteMode <> icpmAll, 24, 0)));
end;

function TCustomThemedIdeColorPicker.BrightnessRect: TRect;
begin
  Result := Rect(ScaleValue(54),ScaleValue(Density(174,142) - IfThen(FPaletteMode <> icpmAll, 24, 0)),
    ClientWidth-ScaleValue(12),ScaleValue(Density(185,151) - IfThen(FPaletteMode <> icpmAll, 24, 0)));
end;

function TCustomThemedIdeColorPicker.AlphaRect: TRect;
begin
  Result := Rect(ScaleValue(54),ScaleValue(Density(195,159) - IfThen(FPaletteMode <> icpmAll, 24, 0)),
    ClientWidth-ScaleValue(12),ScaleValue(Density(206,168) - IfThen(FPaletteMode <> icpmAll, 24, 0)));
end;

function TCustomThemedIdeColorPicker.HexRect: TRect;
begin
  Result := Rect(ScaleValue(Density(77,70)),ClientHeight-ScaleValue(Density(178,142)),
    ClientWidth-ScaleValue(12),ClientHeight-ScaleValue(Density(152,120)));
  if FShowCopyButton then
    Dec(Result.Right,ScaleValue(Density(75,57)));
end;

procedure TCustomThemedIdeColorPicker.PositionHexEdit;
var R: TRect;
begin
  if (FHexEdit = nil) or (FHexEdit.Parent = nil) then Exit;
  R := HexRect;
  FHexEdit.SetBounds(R.Left+ScaleValue(6),R.Top+Max(1,(R.Height-FHexEdit.Height) div 2),
    Max(8,R.Width-ScaleValue(12)),FHexEdit.Height);
end;

procedure TCustomThemedIdeColorPicker.SyncHexEdit;
begin
  if (FHexEdit = nil) or FHexEdit.Focused or FHexSyncing then Exit;
  FHexSyncing := True;
  try
    FHexEdit.Text := GetHexColor;
    FHexEdit.Modified := False;
  finally
    FHexSyncing := False;
  end;
end;

procedure TCustomThemedIdeColorPicker.HexEditExit(Sender: TObject);
begin
  if FHexEdit = nil then Exit;
  if FHexEdit.Modified then SetHexColor(FHexEdit.Text);
  FHexEdit.Modified := False;
  SyncHexEdit;
end;

procedure TCustomThemedIdeColorPicker.HexEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    SetHexColor(FHexEdit.Text);
    FHexEdit.Modified := False;
    Key := 0;
    if CanFocus then SetFocus;
    SyncHexEdit;
  end
  else if Key = VK_ESCAPE then
  begin
    FHexEdit.Modified := False;
    FHexEdit.Text := GetHexColor;
    FHexEdit.Modified := False;
    Key := 0;
    if CanFocus then SetFocus;
  end;
end;

function TCustomThemedIdeColorPicker.SliderRect(AIndex: Integer): TRect;
begin
  Result := Rect(ScaleValue(12),ClientHeight-ScaleValue(Density(134,108))+ScaleValue(AIndex*Density(23,20)),
    ClientWidth-ScaleValue(12),ClientHeight-ScaleValue(Density(112,90))+ScaleValue(AIndex*Density(23,20)));
end;

function TCustomThemedIdeColorPicker.ToolRect(AIndex: Integer): TRect;
var W, R: Integer;
begin
  if AIndex = 3 then
  begin
    W := ScaleValue(Density(68,51));
    R := ClientWidth-ScaleValue(12);
    Result := Rect(R-W,ClientHeight-ScaleValue(Density(178,142)),
      R,ClientHeight-ScaleValue(Density(152,120)));
    Exit;
  end;
  W := Max(40,(ClientWidth-ScaleValue(36)) div 4);
  Result := Rect(ScaleValue(12)+AIndex*(W+ScaleValue(4)), ClientHeight-ScaleValue(Density(208,167)),
    ScaleValue(12)+AIndex*(W+ScaleValue(4))+W,ClientHeight-ScaleValue(Density(185,146)));
end;

function TCustomThemedIdeColorPicker.ActionRect(AIndex: Integer): TRect;
begin
  Result := Rect(ClientWidth-ScaleValue(Density(168,126))+AIndex*ScaleValue(Density(78,60)),ClientHeight-ScaleValue(Density(29,26)),
    ClientWidth-ScaleValue(Density(92,66))+AIndex*ScaleValue(Density(78,60)),ClientHeight-ScaleValue(5));
end;

procedure TCustomThemedIdeColorPicker.ApplyNumericInput;
var V, I: Integer;
begin
  I := FNumericEditIndex;
  FNumericEditIndex := -1;
  if (I >= 0) and (I <= 3) and TryStrToInt(Trim(FNumericInput), V) then
    SetSliderValue(I, EnsureRange(V, 0, 255));
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.CustomMenuAdd(Sender: TObject);
begin
  AddSelectedColorToCustomPalette;
end;

procedure TCustomThemedIdeColorPicker.CustomMenuRemove(Sender: TObject);
begin
  RemoveCustomColorAt(FContextColorIndex);
end;

procedure TCustomThemedIdeColorPicker.CustomMenuClear(Sender: TObject);
begin
  ClearCustomColors;
end;

function TCustomThemedIdeColorPicker.SliderValue(AIndex: Integer): Integer;
var C: COLORREF;
begin
  C := ColorToRGB(FSelectedColor);
  case AIndex of
    0: Result := GetRValue(C);
    1: Result := GetGValue(C);
    2: Result := GetBValue(C);
  else Result := FSelectedAlpha;
  end;
end;

procedure TCustomThemedIdeColorPicker.SetSliderValue(AIndex, AValue: Integer);
var R,G,B: Byte;
begin
  R := SliderValue(0); G := SliderValue(1); B := SliderValue(2);
  if AIndex=3 then begin SetSelectedAlpha(EnsureRange(AValue,0,255)); Exit; end;
  case AIndex of
    0: R := EnsureRange(AValue,0,255);
    1: G := EnsureRange(AValue,0,255);
    2: B := EnsureRange(AValue,0,255);
  end;
  ChooseColor(RGB(R,G,B),'Editor');
end;

procedure TCustomThemedIdeColorPicker.SyncHSV;
var C: COLORREF; R,G,B,Hi,Lo,D: Single;
begin
  C := ColorToRGB(FSelectedColor);
  R := GetRValue(C)/255;
  G := GetGValue(C)/255;
  B := GetBValue(C)/255;
  Hi := Max(R,Max(G,B));
  Lo := Min(R,Min(G,B));
  D := Hi-Lo;
  FGradientBrightness := Hi;
  if Hi < 0.00001 then FGradientSaturation := 0
  else FGradientSaturation := D/Hi;
  if D < 0.00001 then Exit;
  if Hi=R then FGradientHue := (G-B)/D
  else if Hi=G then FGradientHue := 2+(B-R)/D
  else FGradientHue := 4+(R-G)/D;
  FGradientHue := FGradientHue*60;
  if FGradientHue<0 then FGradientHue := FGradientHue+360;
end;


procedure TCustomThemedIdeColorPicker.SetSelectedColor(AValue: TColor);
var Old: TColor;
begin
  AValue := ColorToRGB(AValue);
  if FSelectedColor = AValue then Exit;
  Old := FSelectedColor;
  FSelectedColor := AValue;
  SyncHSV;
  SyncHexEdit;
  Invalidate;
  if Assigned(FOnSelectedColorChanged) then FOnSelectedColorChanged(Self,Old,AValue);
end;

procedure TCustomThemedIdeColorPicker.SetSelectedAlpha(AValue: Byte);
begin
  if FSelectedAlpha=AValue then Exit;
  FSelectedAlpha := AValue;
  SyncHexEdit;
  Invalidate;
  if Assigned(FOnARGBColorSelected) then FOnARGBColorSelected(Self,ARGB,'Alpha');
end;

function TCustomThemedIdeColorPicker.GetARGB: Cardinal;
begin
  Result := (Cardinal(FSelectedAlpha) shl 24) or
    (Cardinal(GetRValue(ColorToRGB(FSelectedColor))) shl 16) or
    (Cardinal(GetGValue(ColorToRGB(FSelectedColor))) shl 8) or
    Cardinal(GetBValue(ColorToRGB(FSelectedColor)));
end;

procedure TCustomThemedIdeColorPicker.SetARGB(AValue: Cardinal);
begin
  SelectedAlpha := Byte(AValue shr 24);
  SelectedColor := RGB(Byte(AValue shr 16),Byte(AValue shr 8),Byte(AValue));
end;

procedure TCustomThemedIdeColorPicker.SetPaletteMode(AValue: TIdeColorPaletteMode);
begin
  if FPaletteMode = AValue then Exit;
  FPaletteMode := AValue;
  FScrollRow := 0;
  if (AValue = icpmLibrary) and (FSizeMode = icsmCompact) and (Height < ScaleValue(380)) then
    Height := ScaleValue(380);
  UpdateLibraryVisibility;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowAlpha(AValue: Boolean);
begin
  if FShowAlpha=AValue then Exit;
  FShowAlpha:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowCopyButton(AValue: Boolean);
begin
  if FShowCopyButton=AValue then Exit;
  FShowCopyButton:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowBasicColors(AValue: Boolean);
begin
  if FShowBasicColors=AValue then Exit;
  FShowBasicColors:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowSystemColors(AValue: Boolean);
begin
  if FShowSystemColors=AValue then Exit;
  FShowSystemColors:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowWebColors(AValue: Boolean);
begin
  if FShowWebColors=AValue then Exit;
  FShowWebColors:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowCustomColors(AValue: Boolean);
begin
  if FShowCustomColors=AValue then Exit;
  FShowCustomColors:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetShowCustomToolbar(AValue: Boolean);
begin
  if FShowCustomToolbar=AValue then Exit;
  FShowCustomToolbar:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetCommitMode(AValue: TIdeColorCommitMode);
begin
  if FCommitMode=AValue then Exit;
  FCommitMode:=AValue;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.SetPaletteVisibleRows(AValue: Integer);
begin
  AValue:=EnsureRange(AValue,1,12);
  if FPaletteVisibleRows=AValue then Exit;
  FPaletteVisibleRows:=AValue;
  FScrollRow:=0;
  Invalidate;
end;

function TCustomThemedIdeColorPicker.HitBar(const ARect: TRect; const APoint: TPoint): Boolean;
var R: TRect;
begin
  R:=ARect;
  InflateRect(R,0,ScaleValue(FBarHitPadding));
  Result:=PtInRect(R,APoint);
end;

procedure TCustomThemedIdeColorPicker.SetSelectedTab(AValue: TIdeColorTab);
begin
  if FSelectedTab = AValue then Exit;
  FSelectedTab := AValue;
  FScrollRow := 0;
  FKeyboardIndex := -1;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.ChooseColor(AColor: TColor; const ASource: string);
begin
  SetSelectedColor(AColor);
  if Assigned(FOnColorSelected) then FOnColorSelected(Self,FSelectedColor,ASource);
  if Assigned(FOnARGBColorSelected) then FOnARGBColorSelected(Self,ARGB,ASource);
  if FAutoAddSelectedColorToCustom then AddSelectedColorToCustomPalette;
  if FCommitMode = iccmImmediate then FOriginalColor := FSelectedColor;
end;

procedure TCustomThemedIdeColorPicker.BeginSelection;
begin
  FOriginalColor := FSelectedColor;
  FOriginalAlpha := FSelectedAlpha;
  FPending := True;
end;

procedure TCustomThemedIdeColorPicker.Commit;
begin
  FLastActionCancel := False;
  FOriginalColor := FSelectedColor;
  FOriginalAlpha := FSelectedAlpha;
  FPending := False;
  if Assigned(FOnOkClicked) then FOnOkClicked(Self);
  if Assigned(FOnDone) then FOnDone(Self);
end;

procedure TCustomThemedIdeColorPicker.Cancel;
begin
  FLastActionCancel := True;
  if FPending and (FCommitMode = iccmOkCancel) then
  begin
    SetSelectedColor(FOriginalColor);
    SetSelectedAlpha(FOriginalAlpha);
  end;
  FPending := False;
  if Assigned(FOnCancelClicked) then FOnCancelClicked(Self);
  if Assigned(FOnDone) then FOnDone(Self);
end;

function TCustomThemedIdeColorPicker.ButtonAt(const P: TPoint): Integer;
var I: Integer;
begin
  Result := -1;
  if FShowCustomToolbar and (ActiveTab = ictCustom) then
    for I := 0 to 2 do
      if PtInRect(ToolRect(I), P) then Exit(I);
  if FShowCopyButton and PtInRect(ToolRect(3), P) then Exit(3);
  if FCommitMode = iccmOkCancel then
    for I := 0 to 1 do
      if PtInRect(ActionRect(I), P) then Exit(4 + I);
end;

procedure TCustomThemedIdeColorPicker.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHover := Point(-1, -1);
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  FDragTarget := -1;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Hit: Integer;
begin
  Hit := FPressedButton;
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  FPressedButton := -1;
  if FDragTarget >= 0 then FDragTarget := -1;
  if MouseCapture then MouseCapture := False;
  Invalidate;
  if (Hit < 0) or (Hit <> ButtonAt(Point(X, Y))) then Exit;
  case Hit of
    0: AddSelectedColorToCustomPalette;
    1: RemoveCustomColorAt(FSelectedCustomColorIndex);
    2: ClearCustomColors;
    3: CopySelectedColorToClipboard;
    4: Cancel;
    5: Commit;
  end;
end;

procedure TCustomThemedIdeColorPicker.Paint;
var C: INimbusRenderCanvas; I: Integer; T: TIdeColorTab; A: TRect;
  Labels: array[0..4] of string;
  B: TThemeColor;
begin
  C := RenderCanvas;
  if C=nil then Exit;
  Labels[0] := 'Basic'; Labels[1] := 'System'; Labels[2] := 'Web';
  Labels[3] := 'Custom'; Labels[4] := 'Gradient';
  C.BeginRender(Canvas);
  try
    TIdeColorPickerRenderer.Surface(C,ClientRect,Palette);
    if FPaletteMode=icpmAll then
      for I := 0 to 4 do
      begin
        T := TIdeColorTab(I);
        if TabVisible(T) then
          TIdeColorPickerRenderer.Tab(C,TabRect(I),Palette,Font,Labels[I],T=ActiveTab,
            PtInRect(TabRect(I),FHover));
      end;
    if ActiveTab=ictLibrary then
      C.DrawText('Palette Library',Font,NimbusControlForeColor(Palette),
        Rect(ScaleValue(10),ScaleValue(4),ClientWidth-ScaleValue(10),ScaleValue(20)),
        [ntfVCenter,ntfSingleLine]);
    if ActiveTab=ictGradient then
      TIdeColorPickerRenderer.Gradient(C,GradientRect,HueRect,BrightnessRect,AlphaRect,
        Palette,Font,FGradientHue,FGradientSaturation,FGradientBrightness,
        FSelectedColor,FSelectedAlpha,FShowAlpha,ScaleValue(5))
    else
      for I := 0 to PaletteCellCount-1 do
      begin
        A := CellRect(I);
        if (A.Top>=ScaleValue(Density(46,42))) and (A.Bottom<=ClientHeight-ScaleValue(Density(207,168)))
          and ((I div 8)-FScrollRow<FPaletteVisibleRows) then
          TIdeColorPickerRenderer.Cell(C,A,Palette,PaletteCell(I),
            PaletteCell(I)=FSelectedColor,PtInRect(A,FHover) or (I=FKeyboardIndex));
      end;
    A := Rect(ScaleValue(12),ClientHeight-ScaleValue(Density(179,143)),
      ScaleValue(Density(68,62)),ClientHeight-ScaleValue(Density(153,121)));
    C.FillRectangle(NimbusInputBackColor(Palette),A);
    if FSelectedAlpha<255 then
    begin
      C.FillRoundedRectangle(ColorToThemeColor(clSilver),A,4);
      C.FillRoundedRectangle(NimbusBlendColor(ColorToThemeColor(clSilver),
        ColorToThemeColor(FSelectedColor),FSelectedAlpha),A,4);
    end
    else C.FillRoundedRectangle(ColorToThemeColor(FSelectedColor),A,4);
    C.DrawRoundedRectangle(NimbusControlBorderColor(Palette),A,4);
    B := NimbusControlForeColor(Palette);
    C.FillRoundedRectangle(NimbusInputBackColor(Palette),HexRect,3);
    C.DrawRoundedRectangle(NimbusControlBorderColor(Palette),HexRect,3);
    if FShowCustomToolbar and (ActiveTab=ictCustom) then
    begin
      TIdeColorPickerRenderer.Button(C,ToolRect(0),Palette,Font,FCustomAddCaption,PtInRect(ToolRect(0),FHover), FPressedButton = 0);
      TIdeColorPickerRenderer.Button(C,ToolRect(1),Palette,Font,FCustomRemoveCaption,PtInRect(ToolRect(1),FHover), FPressedButton = 1);
      TIdeColorPickerRenderer.Button(C,ToolRect(2),Palette,Font,FCustomClearCaption,PtInRect(ToolRect(2),FHover), FPressedButton = 2);
    end;
    if FShowCopyButton then
      TIdeColorPickerRenderer.Button(C,ToolRect(3),Palette,Font,FCopyCaption,PtInRect(ToolRect(3),FHover), FPressedButton = 3);
    for I := 0 to IfThen(FShowAlpha,3,2) do
    begin
      TIdeColorPickerRenderer.Slider(C,SliderRect(I),Palette,Font,Copy('RGBA',I+1,1),
        SliderValue(I),FSelectedColor);
      if I = FNumericEditIndex then
      begin
        A := SliderRect(I);
        A.Left := A.Right-ScaleValue(35);
        C.FillRoundedRectangle(NimbusInputBackColor(Palette),A,2);
        C.DrawRoundedRectangle(NimbusAccentColor(Palette),A,2);
        C.DrawText(FNumericInput+'_',Font,NimbusControlForeColor(Palette),A,
          [ntfCenter,ntfVCenter,ntfSingleLine]);
      end;
    end;
    if FCommitMode=iccmOkCancel then
    begin
      TIdeColorPickerRenderer.Button(C,ActionRect(0),Palette,Font,FCancelCaption,PtInRect(ActionRect(0),FHover), FPressedButton = 4);
      TIdeColorPickerRenderer.Button(C,ActionRect(1),Palette,Font,FOkCaption,PtInRect(ActionRect(1),FHover), FPressedButton = 5);
    end;
  finally
    C.EndRender;
  end;
end;

procedure TCustomThemedIdeColorPicker.MouseMove(Shift: TShiftState; X,Y: Integer);
var
  A: TRect;
  I: Integer;
  Old: TPoint;
begin
  inherited MouseMove(Shift,X,Y);
  if (FHover.X = X) and (FHover.Y = Y) then Exit;
  Old := FHover;
  FHover := Point(X,Y);
  if FPressedButton >= 0 then
  begin
    Invalidate;
    Exit;
  end;
  if FDragTarget >= 0 then
  begin
    if not (ssLeft in Shift) then
    begin
      FDragTarget := -1;
      if MouseCapture then MouseCapture := False;
      Invalidate;
      Exit;
    end;
    case FDragTarget of
      0:
        begin
          A := GradientRect;
          FGradientSaturation := EnsureRange((X-A.Left)/Max(1,A.Width),0,1);
          FGradientBrightness := EnsureRange(1-(Y-A.Top)/Max(1,A.Height),0,1);
          ChooseColor(IdeHSVColor(FGradientHue,FGradientSaturation,FGradientBrightness),'Gradient');
        end;
      1:
        begin
          A := HueRect;
          FGradientHue := EnsureRange((X-A.Left)*360/Max(1,A.Width),0,359.999);
          ChooseColor(IdeHSVColor(FGradientHue,FGradientSaturation,FGradientBrightness),'Hue');
        end;
      2:
        begin
          A := BrightnessRect;
          FGradientBrightness := EnsureRange((X-A.Left)/Max(1,A.Width),0,1);
          ChooseColor(IdeHSVColor(FGradientHue,FGradientSaturation,FGradientBrightness),'Brightness');
        end;
      3:
        begin
          A := AlphaRect;
          SetSelectedAlpha(EnsureRange(MulDiv(X-A.Left,255,Max(1,A.Width)),0,255));
        end;
      4..7:
        begin
          I := FDragTarget-4;
          A := SliderRect(I);
          SetSliderValue(I,MulDiv(EnsureRange(X-A.Left-ScaleValue(46),0,
            Max(1,A.Width-ScaleValue(79))),255,Max(1,A.Width-ScaleValue(79))));
        end;
    end;
    Invalidate;
    Exit;
  end;
  if ActiveTab=ictGradient then
  begin
    if ButtonAt(Old)=ButtonAt(FHover) then Exit;
    Invalidate;
    Exit;
  end;
  for I := 0 to PaletteCellCount-1 do
    if PtInRect(CellRect(I),Old) and PtInRect(CellRect(I),FHover) then Exit;
  for I := 0 to 4 do
    if PtInRect(TabRect(I),Old) and PtInRect(TabRect(I),FHover) then Exit;
  for I := 0 to 3 do
    if PtInRect(ToolRect(I),Old) and PtInRect(ToolRect(I),FHover) then Exit;
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var I,V: Integer; P: TPoint; A: TRect;
begin
  inherited MouseDown(Button,Shift,X,Y);
  FPressedButton := -1;
  P := Point(X,Y);
  if (Button=mbRight) and (ActiveTab=ictCustom) then
  begin
    FContextColorIndex := -1;
    for I := 0 to PaletteCellCount-1 do
      if PtInRect(CellRect(I),P) then
      begin
        FContextColorIndex := I;
        Break;
      end;
    FCustomMenu.Items[0].Caption := FCustomAddCaption;
    FCustomMenu.Items[1].Caption := FCustomRemoveCaption;
    FCustomMenu.Items[3].Caption := FCustomClearCaption;
    FCustomMenu.Items[1].Enabled := FContextColorIndex >= 0;
    FCustomMenu.Items[3].Enabled := CustomColorCount > 0;
    P := ClientToScreen(P);
    FCustomMenu.Popup(P.X,P.Y);
    Exit;
  end;
  if Button<>mbLeft then Exit;
  FDragTarget := -1;
  I := ButtonAt(P);
  if I >= 0 then
  begin
    FPressedButton := I;
    MouseCapture := True;
    Invalidate;
    Exit;
  end;
  if FNumericEditIndex>=0 then ApplyNumericInput;
  for I := 0 to IfThen(FShowAlpha,3,2) do
  begin
    A := SliderRect(I);
    if PtInRect(Rect(A.Right-ScaleValue(35),A.Top,A.Right,A.Bottom),P) then
    begin
      FNumericEditIndex := I;
      FNumericInput := IntToStr(SliderValue(I));
      if CanFocus then SetFocus;
      Invalidate;
      Exit;
    end;
  end;
  if CanFocus then SetFocus;
  P := Point(X,Y);
  if FPaletteMode=icpmAll then
    for I := 0 to 4 do
      if PtInRect(TabRect(I),P) then
      begin
        SelectedTab := TIdeColorTab(I);
        Exit;
      end;
  if ActiveTab=ictGradient then
  begin
    A := GradientRect;
    if PtInRect(A,P) then
    begin
      FDragTarget := 0;
      MouseCapture := True;
      FGradientSaturation := EnsureRange((X-A.Left)/Max(1,A.Width),0,1);
      FGradientBrightness := EnsureRange(1-(Y-A.Top)/Max(1,A.Height),0,1);
      ChooseColor(IdeHSVColor(FGradientHue,FGradientSaturation,FGradientBrightness),'Gradient');
      Exit;
    end;
    A := HueRect;
    if HitBar(A,P) then
    begin
      FDragTarget := 1;
      MouseCapture := True;
      FGradientHue := EnsureRange((X-A.Left)*360/Max(1,A.Width),0,359.999);
      ChooseColor(IdeHSVColor(FGradientHue,FGradientSaturation,FGradientBrightness),'Hue');
      Exit;
    end;
    A := BrightnessRect;
    if HitBar(A,P) then
    begin
      FDragTarget := 2;
      MouseCapture := True;
      FGradientBrightness := EnsureRange((X-A.Left)/Max(1,A.Width),0,1);
      ChooseColor(IdeHSVColor(FGradientHue,FGradientSaturation,FGradientBrightness),'Brightness');
      Exit;
    end;
    A := AlphaRect;
    if FShowAlpha and HitBar(A,P) then
    begin
      FDragTarget := 3;
      MouseCapture := True;
      SetSelectedAlpha(EnsureRange(MulDiv(X-A.Left,255,Max(1,A.Width)),0,255));
      Exit;
    end;
  end
  else
    for I := 0 to PaletteCellCount-1 do
    begin
      A := CellRect(I);
      if (A.Top>=ScaleValue(Density(46,42))) and (A.Bottom<=ClientHeight-ScaleValue(Density(207,168)))
        and PtInRect(A,P) then
      begin
        FKeyboardIndex := I;
        if ActiveTab=ictCustom then
        begin
          FSelectedCustomColorIndex := I;
          SetSelectedAlpha(FCustomAlphas[I]);
        end;
        ChooseColor(PaletteCell(I),'Palette');
        Exit;
      end;
    end;
  for I := 0 to IfThen(FShowAlpha,3,2) do
  begin
    A := SliderRect(I);
    if PtInRect(A,P) then
    begin
      FDragTarget := I+4;
      MouseCapture := True;
      SetSliderValue(I,MulDiv(EnsureRange(X-A.Left-ScaleValue(46),0,
        Max(1,A.Width-ScaleValue(79))),255,Max(1,A.Width-ScaleValue(79))));
      Exit;
    end;
  end;
  if PtInRect(HexRect,P) then
  begin
    if FHexEdit <> nil then
    begin
      FHexEdit.SetFocus;
      FHexEdit.SelectAll;
    end;
    Exit;
  end;

  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.KeyDown(var Key: Word; Shift: TShiftState);
var NextIndex,MaxRow: Integer;
begin
  inherited KeyDown(Key,Shift);
  if FNumericEditIndex >= 0 then
  begin
    if Key = VK_ESCAPE then
    begin
      FNumericEditIndex := -1;
      Key := 0;
      Invalidate;
      Exit;
    end;
    if Key = VK_RETURN then
    begin
      ApplyNumericInput;
      Key := 0;
      Exit;
    end;
  end;
  if Key=VK_ESCAPE then begin Cancel; Key:=0; Exit; end;
  if Key=VK_RETURN then
  begin
    if (ActiveTab<>ictGradient) and (FKeyboardIndex>=0) and
      (FKeyboardIndex<PaletteCellCount) then
      ChooseColor(PaletteCell(FKeyboardIndex),'Keyboard')
    else Commit;
    Key:=0;
    Exit;
  end;
  if (ssCtrl in Shift) and (Key=Ord('C')) then
  begin
    CopySelectedColorToClipboard;
    Key:=0;
    Exit;
  end;
  if (ssCtrl in Shift) and ((Key=VK_LEFT) or (Key=VK_RIGHT)) then
  begin
    NextIndex := Ord(ActiveTab)+IfThen(Key=VK_RIGHT,1,-1);
    while (NextIndex>=0) and (NextIndex<=4) do
      if TabVisible(TIdeColorTab(NextIndex)) then Break
      else Inc(NextIndex,IfThen(Key=VK_RIGHT,1,-1));
    if (NextIndex>=0) and (NextIndex<=4) then SelectedTab := TIdeColorTab(NextIndex);
    Key:=0;
    Exit;
  end;
  if (ActiveTab<>ictGradient) and
     ((Key=VK_LEFT) or (Key=VK_RIGHT) or (Key=VK_UP) or (Key=VK_DOWN)) then
  begin
    if FKeyboardIndex<0 then FKeyboardIndex:=0;
    if Key=VK_LEFT then Dec(FKeyboardIndex)
    else if Key=VK_RIGHT then Inc(FKeyboardIndex)
    else if Key=VK_UP then Dec(FKeyboardIndex,8)
    else Inc(FKeyboardIndex,8);
    FKeyboardIndex := EnsureRange(FKeyboardIndex,0,Max(0,PaletteCellCount-1));
    MaxRow := Max(0,(PaletteCellCount+7) div 8-FPaletteVisibleRows);
    if (FKeyboardIndex div 8)<FScrollRow then FScrollRow:=FKeyboardIndex div 8
    else if (FKeyboardIndex div 8)>=FScrollRow+FPaletteVisibleRows then
      FScrollRow := Min(MaxRow,FKeyboardIndex div 8-FPaletteVisibleRows+1);
    Key:=0;
    Invalidate;
  end;
end;

procedure TCustomThemedIdeColorPicker.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if FNumericEditIndex >= 0 then
  begin
    if Key = #8 then
    begin
      if FNumericInput<>'' then Delete(FNumericInput,Length(FNumericInput),1);
    end
    else if CharInSet(Key,['0'..'9']) and (Length(FNumericInput)<3) then
      FNumericInput := FNumericInput+Key;
    Key := #0;
    Invalidate;
    Exit;
  end;

end;

procedure TCustomThemedIdeColorPicker.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCustomThemedIdeColorPicker.WMMouseWheel(var Message: TWMMouseWheel);
var MaxRow: Integer;
begin
  if ActiveTab<>ictGradient then
  begin
    MaxRow := Max(0,(PaletteCellCount+7) div 8-FPaletteVisibleRows);
    if Message.WheelDelta<0 then FScrollRow:=Min(MaxRow,FScrollRow+1)
    else FScrollRow:=Max(0,FScrollRow-1);
    Invalidate;
    Message.Result:=1;
  end
  else inherited;
end;

procedure TCustomThemedIdeColorPicker.AddCustomARGB(AARGB: Cardinal);
var C: TColor; A: Byte; I: Integer;
begin
  C := RGB(Byte(AARGB shr 16),Byte(AARGB shr 8),Byte(AARGB));
  A := Byte(AARGB shr 24);
  for I := 0 to FCustomColors.Count-1 do
    if (FCustomColors[I]=C) and (FCustomAlphas[I]=A) then Exit;
  FSelectedCustomColorIndex := FCustomColors.Add(C);
  FCustomAlphas.Add(A);
  if Assigned(FOnCustomColorAdded) then
    FOnCustomColorAdded(Self,C,FSelectedCustomColorIndex);
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.AddCustomColor(AColor: TColor);
var C: COLORREF;
begin
  C := ColorToRGB(AColor);
  AddCustomARGB($FF000000 or (Cardinal(GetRValue(C)) shl 16) or
    (Cardinal(GetGValue(C)) shl 8) or Cardinal(GetBValue(C)));
end;

procedure TCustomThemedIdeColorPicker.AddSelectedColorToCustomPalette;
begin
  AddCustomARGB(ARGB);
end;

function TCustomThemedIdeColorPicker.RemoveCustomColor(AColor: TColor): Boolean;
begin Result := RemoveCustomColorAt(FCustomColors.IndexOf(ColorToRGB(AColor))); end;

function TCustomThemedIdeColorPicker.RemoveCustomColorAt(AIndex: Integer): Boolean;
var C: TColor;
begin
  Result := (AIndex>=0) and (AIndex<FCustomColors.Count);
  if not Result then Exit;
  C := FCustomColors[AIndex];
  FCustomColors.Delete(AIndex);
  FCustomAlphas.Delete(AIndex);
  FSelectedCustomColorIndex := -1;
  if Assigned(FOnCustomColorRemoved) then FOnCustomColorRemoved(Self,C,AIndex);
  Invalidate;
end;

procedure TCustomThemedIdeColorPicker.ClearCustomColors;
begin
  if FCustomColors.Count=0 then Exit;
  FCustomColors.Clear;
  FCustomAlphas.Clear;
  FSelectedCustomColorIndex := -1;
  if Assigned(FOnCustomColorsCleared) then FOnCustomColorsCleared(Self);
  Invalidate;
end;

function TCustomThemedIdeColorPicker.GetCustomColorCount: Integer;
begin Result := FCustomColors.Count; end;

function TCustomThemedIdeColorPicker.GetCustomColor(AIndex: Integer): TColor;
begin Result := FCustomColors[AIndex]; end;

function TCustomThemedIdeColorPicker.GetCustomColorsString: string;
begin Result := SaveCustomColorsToString; end;

procedure TCustomThemedIdeColorPicker.SetCustomColorsString(const AValue: string);
begin LoadCustomColorsFromString(AValue); end;

procedure TCustomThemedIdeColorPicker.LoadCustomColorsFromString(const AValue: string);
var Parts: TStringList; I: Integer; ARGBValue: Cardinal;
begin
  Parts := TStringList.Create;
  try
    Parts.StrictDelimiter := True;
    Parts.Delimiter := ';';
    Parts.DelimitedText := AValue;
    ClearCustomColors;
    for I := 0 to Parts.Count-1 do
      if TryParseHexColor(Parts[I],ARGBValue) then AddCustomARGB(ARGBValue);
  finally
    Parts.Free;
  end;
end;

function TCustomThemedIdeColorPicker.SaveCustomColorsToString: string;
var I: Integer; C: COLORREF;
begin
  Result := '';
  for I := 0 to FCustomColors.Count-1 do
  begin
    if Result<>'' then Result := Result+';';
    C := ColorToRGB(FCustomColors[I]);
    Result := Result+Format('#%.2x%.2x%.2x%.2x',
      [FCustomAlphas[I],GetRValue(C),GetGValue(C),GetBValue(C)]);
  end;
end;

function TCustomThemedIdeColorPicker.GetHexColor: string;
var C: COLORREF;
begin
  C := ColorToRGB(FSelectedColor);
  if FShowAlpha then
    Result := Format('#%.2x%.2x%.2x%.2x',
      [FSelectedAlpha,GetRValue(C),GetGValue(C),GetBValue(C)])
  else
    Result := Format('#%.2x%.2x%.2x',[GetRValue(C),GetGValue(C),GetBValue(C)]);
end;

function TCustomThemedIdeColorPicker.TryParseHexColor(const AValue: string; out AARGB: Cardinal): Boolean;
var S: string; I: Integer; V: Cardinal;
begin
  S := Trim(AValue);
  if (Length(S)>0) and (S[1]='#') then Delete(S,1,1)
  else if SameText(Copy(S,1,2),'0x') then Delete(S,1,2);
  if Length(S)=3 then
    S := S[1]+S[1]+S[2]+S[2]+S[3]+S[3];
  Result := (Length(S)=6) or (Length(S)=8);
  if not Result then Exit;
  for I := 1 to Length(S) do
    if not CharInSet(S[I],['0'..'9','a'..'f','A'..'F']) then Exit(False);
  Result := TryStrToUInt('$'+S,V);
  if Result then
  begin
    if Length(S)=6 then AARGB := $FF000000 or V
    else AARGB := V;
  end;
end;

procedure TCustomThemedIdeColorPicker.SetHexColor(const AValue: string);
var C: Cardinal;
begin
  if TryParseHexColor(AValue,C) then
  begin
    SetARGB(C);
    if Assigned(FOnColorSelected) then FOnColorSelected(Self,FSelectedColor,'Hex');
    if Assigned(FOnARGBColorSelected) then FOnARGBColorSelected(Self,ARGB,'Hex');
  end;
  SyncHexEdit;
  Invalidate;
end;

function TCustomThemedIdeColorPicker.ColorText: string;
var R,G,B: Byte; C: COLORREF;
begin
  C := ColorToRGB(FSelectedColor);
  R := GetRValue(C); G := GetGValue(C); B := GetBValue(C);
  case FCopyFormat of
    iccfHex: Result := Format('#%.2x%.2x%.2x',[R,G,B]);
    iccfHexWithAlpha: Result := Format('#%.2x%.2x%.2x%.2x',[FSelectedAlpha,R,G,B]);
    iccfRgb: Result := Format('rgb(%d, %d, %d)',[R,G,B]);
    iccfRgba: Result := Format('rgba(%d, %d, %d, %d)',[R,G,B,FSelectedAlpha]);
    iccfCSharpColor: Result := Format('Color.FromArgb(%d, %d, %d, %d)',[FSelectedAlpha,R,G,B]);
  else Result := Format('%.2x%.2x%.2x',[R,G,B]);
  end;
end;

procedure TCustomThemedIdeColorPicker.CopySelectedColorToClipboard;
begin Clipboard.AsText := ColorText; end;

constructor TThemedIdeColorPickerButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 110; Height := 26;
  TabStop := True;
  FSelectedColor := clWhite;
  FButtonText := 'Color';
  FMouseHover := False;
  FMousePressed := False;
  FSizeMode := icsmCompact;
  FDropDownSize := IdeColorSize(300,326);
  FShowAlpha := True;
  FCloseOnGradientColorSelected := True;
  FCloseOnEditorColorSelected := True;
  FCloseOnOk := True;
  FCloseOnCancel := True;
  FPopup := TForm.CreateNew(Self);
  FPopup.BorderStyle := bsNone;
  FPopup.Position := poDesigned;
  FPopup.Visible := False;
  FPopup.FormStyle := fsNormal;
  FPopup.OnDeactivate := PopupDeactivate;
  FPopup.Color := clBtnFace;
  FPicker := TThemedIdeColorPicker.Create(FPopup);
  FPicker.Parent := FPopup;
  FPicker.Align := alClient;
  FPicker.OnSelectedColorChanged := PopupColorChanged;
  FPicker.OnColorSelected := PopupColorSelected;
  FPicker.FOnDone := PopupDone;
end;

destructor TThemedIdeColorPickerButton.Destroy;
begin
  if FPopup<>nil then
  begin
    FPopup.OnDeactivate := nil;
    if FPicker<>nil then
    begin
      FPicker.OnSelectedColorChanged := nil;
      FPicker.OnColorSelected := nil;
      FPicker.FOnDone := nil;
    end;
    FPopup.Hide;
    FPopup.Free;
    FPopup := nil;
    FPicker := nil;
  end;
  inherited Destroy;
end;

procedure TThemedIdeColorPickerButton.SetSelectedColor(AValue: TColor);
var Old: TColor;
begin
  AValue := ColorToRGB(AValue);
  if FSelectedColor=AValue then Exit;
  Old := FSelectedColor;
  FSelectedColor := AValue;
  if FPicker<>nil then FPicker.SelectedColor := AValue;
  Invalidate;
  if Assigned(FOnSelectedColorChanged) then FOnSelectedColorChanged(Self,Old,AValue);
end;

procedure TThemedIdeColorPickerButton.SetButtonText(const AValue: string);
begin if FButtonText<>AValue then begin FButtonText:=AValue; Invalidate; end; end;

function TThemedIdeColorPickerButton.GetDroppedDown: Boolean;
begin Result := (FPopup <> nil) and FPopup.Visible; end;

function TThemedIdeColorPickerButton.GetDropDownWidth: Integer;
begin Result := FDropDownSize.cx; end;

function TThemedIdeColorPickerButton.GetDropDownHeight: Integer;
begin Result := FDropDownSize.cy; end;

procedure TThemedIdeColorPickerButton.SetDropDownWidth(AValue: Integer);
begin SetDropDownSize(IdeColorSize(AValue,FDropDownSize.cy)); end;

procedure TThemedIdeColorPickerButton.SetDropDownHeight(AValue: Integer);
begin SetDropDownSize(IdeColorSize(FDropDownSize.cx,AValue)); end;

procedure TThemedIdeColorPickerButton.SetSizeMode(AValue: TIdeColorSizeMode);
begin
  if FSizeMode = AValue then Exit;
  FSizeMode := AValue;
  if FPicker <> nil then FPicker.SizeMode := AValue;
  if AValue = icsmCompact then FDropDownSize := IdeColorSize(300,326)
  else FDropDownSize := IdeColorSize(420,420);
  Height := ScaleValue(IfThen(AValue = icsmCompact,26,30));
  Invalidate;
end;

procedure TThemedIdeColorPickerButton.SetDropDownSize(const AValue: TSize);
begin
  FDropDownSize := IdeColorSize(Max(260,AValue.cx),Max(260,AValue.cy));
end;

procedure TThemedIdeColorPickerButton.SetPaletteMode(AValue: TIdeColorPaletteMode);
begin FPaletteMode:=AValue; if FPicker<>nil then FPicker.PaletteMode:=AValue; end;

procedure TThemedIdeColorPickerButton.SetPaletteFileName(const AValue: string);
begin
  FPaletteFileName := AValue;
  if FPicker <> nil then FPicker.PaletteFileName := AValue;
end;

procedure TThemedIdeColorPickerButton.SetCommitMode(AValue: TIdeColorCommitMode);
begin FCommitMode:=AValue; if FPicker<>nil then FPicker.CommitMode:=AValue; end;

procedure TThemedIdeColorPickerButton.PopupColorChanged(Sender: TObject; AOldColor,ANewColor: TColor);
begin SetSelectedColor(ANewColor); end;

procedure TThemedIdeColorPickerButton.PopupColorSelected(Sender: TObject; AColor: TColor; const ASource: string);
var CloseNow: Boolean;
begin
  if Assigned(FOnColorSelected) then FOnColorSelected(Self,AColor,ASource);
  if FCommitMode<>iccmImmediate then Exit;
  CloseNow := False;
  if SameText(ASource,'Palette') or SameText(ASource,'Keyboard') then
  begin
    if FPicker.ActiveTab=ictCustom then CloseNow:=FCloseOnCustomColorSelected
    else CloseNow:=FCloseOnPaletteColorSelected;
  end
  else if SameText(ASource,'Gradient') or SameText(ASource,'Hue') or
    SameText(ASource,'Brightness') then CloseNow:=FCloseOnGradientColorSelected
  else if SameText(ASource,'Editor') then
    CloseNow := FCloseOnEditorColorSelected and (FPicker.FDragTarget < 0)
  else if SameText(ASource,'Hex') then
    CloseNow := FCloseOnEditorColorSelected;
  if CloseNow then CloseDropDown;
end;

procedure TThemedIdeColorPickerButton.PopupDeactivate(Sender: TObject);
var
  LMouse: TPoint;
begin
  if FPicker <> nil then
  begin
    if FPicker.FDragTarget >= 0 then Exit;
    if FPicker.FPaletteMode = icpmLibrary then
    begin
      if (FPicker.FCategoryDropdown <> nil) and
         FPicker.FCategoryDropdown.DroppedDown then Exit;
      if (FPicker.FPaletteDropdown <> nil) and
         FPicker.FPaletteDropdown.DroppedDown then Exit;
      LMouse := Mouse.CursorPos;
      if (FPicker.FCategoryDropdown <> nil) and
         FPicker.FCategoryDropdown.Visible and
         PtInRect(FPicker.FCategoryDropdown.ClientRect,
           FPicker.FCategoryDropdown.ScreenToClient(LMouse)) then Exit;
      if (FPicker.FPaletteDropdown <> nil) and
         FPicker.FPaletteDropdown.Visible and
         PtInRect(FPicker.FPaletteDropdown.ClientRect,
           FPicker.FPaletteDropdown.ScreenToClient(LMouse)) then Exit;
    end;
  end;
  CloseDropDown;
end;

procedure TThemedIdeColorPickerButton.PopupDone(Sender: TObject);
var
  LCancelled: Boolean;
begin
  LCancelled := FPicker.FLastActionCancel;
  if LCancelled then SetSelectedColor(FDropDownOriginalColor)
  else SetSelectedColor(FPicker.SelectedColor);
  if (LCancelled and FCloseOnCancel) or (not LCancelled and FCloseOnOk) then CloseDropDown;
  if LCancelled then
  begin
    if Assigned(FOnColorCancelled) then FOnColorCancelled(Self);
  end
  else if Assigned(FOnColorAccepted) then FOnColorAccepted(Self);
end;

procedure TThemedIdeColorPickerButton.OpenDropDown;
var P: TPoint; R: TRect;
begin
  if (FPopup=nil) or FPopup.Visible then Exit;
  FDropDownOriginalColor := FSelectedColor;
  FPicker.SizeMode := FSizeMode;
  FPicker.SelectedColor := FSelectedColor;
  FPicker.PaletteMode := FPaletteMode;
  FPicker.CommitMode := FCommitMode;
  FPicker.ShowAlpha := FShowAlpha;
  FPicker.CopyFormat := FCopyFormat;
  if FPaletteFileName <> '' then FPicker.PaletteFileName := FPaletteFileName;
  FPicker.BeginSelection;
  if FPaletteMode = icpmLibrary then
    FPopup.SetBounds(0,0,FDropDownSize.cx,Max(FDropDownSize.cy,ScaleValue(380)))
  else
    FPopup.SetBounds(0,0,FDropDownSize.cx,FDropDownSize.cy);
  P := ClientToScreen(Point(0,Height));
  R := Screen.MonitorFromPoint(P).WorkareaRect;
  if P.X+FPopup.Width > R.Right then P.X := R.Right-FPopup.Width;
  if P.Y+FPopup.Height > R.Bottom then P.Y := ClientToScreen(Point(0,0)).Y-FPopup.Height;
  P.X := Max(R.Left,P.X); P.Y := Max(R.Top,P.Y);
  FPopup.Left := P.X; FPopup.Top := P.Y;
  FPopup.Show;
  FPicker.SetFocus;
end;

procedure TThemedIdeColorPickerButton.CloseDropDown;
begin
  if (FPopup=nil) or not FPopup.Visible then Exit;
  if (FPicker <> nil) and FPicker.FPending and (FCommitMode = iccmOkCancel) then FPicker.Cancel;
  if not FPopup.Visible then Exit;
  FPopup.OnDeactivate := nil;
  try
    FPopup.Hide;
  finally
    FPopup.OnDeactivate := PopupDeactivate;
  end;
end;

procedure TThemedIdeColorPickerButton.Paint;
var C: INimbusRenderCanvas; R: TRect;
begin
  C := RenderCanvas;
  if C=nil then Exit;
  C.BeginRender(Canvas);
  try
    TIdeColorPickerRenderer.Surface(C,ClientRect,Palette);
    if FMouseHover or FMousePressed or FPopup.Visible then
    begin
      if FMousePressed then
        C.FillRoundedRectangle(NimbusBlendColor(NimbusInputBackColor(Palette),NimbusAccentColor(Palette),25),ClientRect,4)
      else
        C.FillRoundedRectangle(NimbusHoverBackColor(Palette),ClientRect,4);
      C.DrawRoundedRectangle(NimbusControlBorderColor(Palette),ClientRect,4);
    end;
    R := Rect(ScaleValue(7),ScaleValue(5),ScaleValue(27),Height-ScaleValue(5));
    C.FillRoundedRectangle(ColorToThemeColor(FSelectedColor),R,3);
    C.DrawRoundedRectangle(NimbusControlBorderColor(Palette),R,3);
    C.DrawText(FButtonText,Font,NimbusControlForeColor(Palette),Rect(R.Right+ScaleValue(8),0,Width-ScaleValue(20),Height),
      [ntfVCenter,ntfSingleLine,ntfEndEllipsis,ntfNoPrefix]);
    C.DrawLine(NimbusControlForeColor(Palette),Width-ScaleValue(15),Height div 2-2,Width-ScaleValue(11),Height div 2+2);
    C.DrawLine(NimbusControlForeColor(Palette),Width-ScaleValue(11),Height div 2+2,Width-ScaleValue(7),Height div 2-2);
  finally C.EndRender; end;
end;

procedure TThemedIdeColorPickerButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
  inherited MouseDown(Button,Shift,X,Y);
  if (Button = mbLeft) and Enabled then
  begin
    FMousePressed := True;
    MouseCapture := True;
    Invalidate;
  end;
end;

procedure TThemedIdeColorPickerButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var Hovered: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  Hovered := PtInRect(ClientRect, Point(X, Y));
  if FMouseHover <> Hovered then
  begin
    FMouseHover := Hovered;
    Invalidate;
  end;
  if FMousePressed then Invalidate;
end;

procedure TThemedIdeColorPickerButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Activate: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button <> mbLeft) or not FMousePressed then Exit;
  Activate := Enabled and PtInRect(ClientRect, Point(X, Y));
  FMousePressed := False;
  MouseCapture := False;
  Invalidate;
  if Activate then
    if FPopup.Visible then CloseDropDown else OpenDropDown;
end;

procedure TThemedIdeColorPickerButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FMouseHover := False;
  Invalidate;
end;

procedure TThemedIdeColorPickerButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key,Shift);
  if (Key=VK_SPACE) or (Key=VK_RETURN) then begin OpenDropDown; Key:=0; end
  else if Key=VK_ESCAPE then begin CloseDropDown; Key:=0; end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.TextBox;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.TextBox;

type
  TNimbusTextBoxEditor = class(TMemo)
  public
    property PasswordChar;
  end;

  TThemedTextBoxTextChangedEvent = procedure(Sender: TObject; const AOldText, ANewText: string) of object;
  TThemedTextBoxValidationStateChangedEvent = procedure(Sender: TObject; const AOldState, ANewState: TThemedTextBoxValidationState) of object;

  TCustomThemedTextBox = class(TCustomNimbusControl)
  private
    FEditor: TNimbusTextBoxEditor;
    FInnerPadding: TPadding;
    FCompactNormalHeight: Integer;
    FCompactAppliedHeight: Integer;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
    FMeasureCanvas: INimbusRenderCanvas;
    FHovered: Boolean;
    FFocused: Boolean;
    FClearHovered: Boolean;
    FClearPressed: Boolean;
    FPasswordHovered: Boolean;
    FPasswordPressed: Boolean;
    FPasswordVisible: Boolean;
    FOldText: string;
    FBorderThickness: Integer;
    FPlaceholderText: string;
    FPrefixText: string;
    FSuffixText: string;
    FShowClearButton: Boolean;
    FShowPasswordRevealButton: Boolean;
    FAutoSelectAllOnFocus: Boolean;
    FUseRoundedCorners: Boolean;
    FShowValidationIcon: Boolean;
    FCornerRadius: Integer;
    FLogicalButtonWidth: Integer;
    FLogicalIconSize: Integer;
    FLogicalPrefixSuffixGap: Integer;
    FValidationState: TThemedTextBoxValidationState;
    FValidationMessage: string;
    FInputMode: TThemedTextBoxInputMode;
    FRegexPattern: string;
    FMultiline: Boolean;
    FUseSystemPasswordChar: Boolean;
    FAcceptsReturn: Boolean;
    FAcceptsTab: Boolean;
    FScrollBars: System.UITypes.TScrollStyle;
    FEditorRect: TRect;
    FPrefixRect: TRect;
    FSuffixRect: TRect;
    FClearRect: TRect;
    FPasswordRect: TRect;
    FValidationRect: TRect;
    FOnChange: TNotifyEvent;
    FOnClearClicked: TNotifyEvent;
    FOnPasswordRevealClicked: TNotifyEvent;
    FOnEnterPressed: TNotifyEvent;
    FOnEscapePressed: TNotifyEvent;
    FOnTextChangedEx: TThemedTextBoxTextChangedEvent;
    FOnValidationStateChanged: TThemedTextBoxValidationStateChangedEvent;
    function GetText: string;
    procedure SetText(const AValue: string);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const AValue: Boolean);
    function GetUseSystemPasswordChar: Boolean;
    function GetTextAlign: TAlignment;
    procedure SetTextAlign(const AValue: TAlignment);
    function GetCharCase: TEditCharCase;
    procedure SetCharCase(const AValue: TEditCharCase);
    function GetMaxLength: Integer;
    procedure SetMaxLength(const AValue: Integer);
    function GetSelectionStart: Integer;
    procedure SetSelectionStart(const AValue: Integer);
    function GetSelectionLength: Integer;
    procedure SetSelectionLength(const AValue: Integer);
    function GetSelectedText: string;
    procedure SetSelectedText(const AValue: string);
    procedure SetInnerPadding(const AValue: TPadding);
    procedure InnerPaddingChanged(Sender: TObject);
    procedure SetBorderThickness(const AValue: Integer);
    procedure SetPlaceholderText(const AValue: string);
    procedure SetPrefixText(const AValue: string);
    procedure SetSuffixText(const AValue: string);
    procedure SetShowClearButton(const AValue: Boolean);
    procedure SetShowPasswordRevealButton(const AValue: Boolean);
    procedure SetAutoSelectAllOnFocus(const AValue: Boolean);
    procedure SetUseRoundedCorners(const AValue: Boolean);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetShowValidationIcon(const AValue: Boolean);
    procedure SetValidationState(const AValue: TThemedTextBoxValidationState);
    procedure SetValidationMessage(const AValue: string);
    procedure SetInputMode(const AValue: TThemedTextBoxInputMode);
    procedure SetRegexPattern(const AValue: string);
    procedure SetMultiline(const AValue: Boolean);
    procedure SetUseSystemPasswordChar(const AValue: Boolean);
    procedure SetAcceptsReturn(const AValue: Boolean);
    procedure SetAcceptsTab(const AValue: Boolean);
    procedure SetScrollBars(const AValue: System.UITypes.TScrollStyle);
    function MeasureTextWidth(const AText: string): Integer;
    procedure CalculateLayout(out AEditorRect, APrefixRect, ASuffixRect, AClearRect, APasswordRect, AValidationRect: TRect);
    procedure UpdateEditorBounds;
    procedure UpdateEditorTheme;
    procedure UpdatePasswordChar;
    function ClearButtonVisible: Boolean;
    function PasswordButtonVisible: Boolean;
    function ValidationIconVisible: Boolean;
    function BuildRenderContext: TThemedTextBoxRenderContext;
    procedure EditorChange(Sender: TObject);
    procedure EditorEnter(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorMouseEnter(Sender: TObject);
    procedure EditorMouseLeave(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
  protected
    procedure StyleModeChanged; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoEnter; override;
    procedure DoChange; virtual;
    procedure DoClearClicked; virtual;
    procedure DoPasswordRevealClicked; virtual;
    procedure DoEnterPressed; virtual;
    procedure DoEscapePressed; virtual;
    procedure DoTextChangedEx(const AOldText, ANewText: string); virtual;
    procedure DoValidationStateChanged(const AOldState, ANewState: TThemedTextBoxValidationState); virtual;
    property InnerPadding: TPadding read FInnerPadding write SetInnerPadding;
    property BorderThickness: Integer read FBorderThickness write SetBorderThickness default 1;
    property PlaceholderText: string read FPlaceholderText write SetPlaceholderText;
    property PrefixText: string read FPrefixText write SetPrefixText;
    property SuffixText: string read FSuffixText write SetSuffixText;
    property ShowClearButton: Boolean read FShowClearButton write SetShowClearButton default False;
    property ShowPasswordRevealButton: Boolean read FShowPasswordRevealButton write SetShowPasswordRevealButton default False;
    property AutoSelectAllOnFocus: Boolean read FAutoSelectAllOnFocus write SetAutoSelectAllOnFocus default False;
    property UseRoundedCorners: Boolean read FUseRoundedCorners write SetUseRoundedCorners default False;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 4;
    property ShowValidationIcon: Boolean read FShowValidationIcon write SetShowValidationIcon default True;
    property ValidationState: TThemedTextBoxValidationState read FValidationState write SetValidationState default tvsNormal;
    property ValidationMessage: string read FValidationMessage write SetValidationMessage;
    property InputMode: TThemedTextBoxInputMode read FInputMode write SetInputMode default timText;
    property RegexPattern: string read FRegexPattern write SetRegexPattern;
    property Multiline: Boolean read FMultiline write SetMultiline default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property UseSystemPasswordChar: Boolean read GetUseSystemPasswordChar write SetUseSystemPasswordChar default False;
    property TextAlign: TAlignment read GetTextAlign write SetTextAlign default taLeftJustify;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 32767;
    property AcceptsReturn: Boolean read FAcceptsReturn write SetAcceptsReturn default False;
    property AcceptsTab: Boolean read FAcceptsTab write SetAcceptsTab default False;
    property ScrollBars: System.UITypes.TScrollStyle read FScrollBars write SetScrollBars default System.UITypes.TScrollStyle.ssNone;
    property Text: string read GetText write SetText;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClearClicked: TNotifyEvent read FOnClearClicked write FOnClearClicked;
    property OnPasswordRevealClicked: TNotifyEvent read FOnPasswordRevealClicked write FOnPasswordRevealClicked;
    property OnEnterPressed: TNotifyEvent read FOnEnterPressed write FOnEnterPressed;
    property OnEscapePressed: TNotifyEvent read FOnEscapePressed write FOnEscapePressed;
    property OnTextChangedEx: TThemedTextBoxTextChangedEvent read FOnTextChangedEx write FOnTextChangedEx;
    property OnValidationStateChanged: TThemedTextBoxValidationStateChangedEvent read FOnValidationStateChanged write FOnValidationStateChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    function ValidateText: Boolean;
    procedure ClearText;
    procedure SelectAll;
    procedure Select(const AStart, ALength: Integer);
    procedure DeselectAll;
    property Editor: TNimbusTextBoxEditor read FEditor;
    property SelectionStart: Integer read GetSelectionStart write SetSelectionStart;
    property SelectionLength: Integer read GetSelectionLength write SetSelectionLength;
    property SelectedText: string read GetSelectedText write SetSelectedText;
  end;

  TThemedTextBox = class(TCustomThemedTextBox)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property AcceptsReturn;
    property AcceptsTab;
    property AutoSelectAllOnFocus;
    property BiDiMode;
    property BorderThickness;
    property CharCase;
    property Constraints;
    property CornerRadius;
    property Enabled;
    property Font;
    property InnerPadding;
    property InputMode;
    property MaxLength;
    property Multiline;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PlaceholderText;
    property PopupMenu;
    property PrefixText;
    property ReadOnly;
    property RegexPattern;
    property ScrollBars;
    property ShowClearButton;
    property ShowHint;
    property ShowPasswordRevealButton;
    property ShowValidationIcon;
    property SuffixText;
    property TabOrder;
    property TabStop default True;
    property Text;
    property TextAlign;
    property UseRoundedCorners;
    property UseSystemPasswordChar;
    property ValidationMessage;
    property ValidationState;
    property Visible;
    property OnChange;
    property OnClearClicked;
    property OnContextPopup;
    property OnEnter;
    property OnEnterPressed;
    property OnEscapePressed;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnPasswordRevealClicked;
    property OnTextChangedEx;
    property OnValidationStateChanged;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  System.Math,
  System.RegularExpressions,
  Vcl.Forms,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

constructor TCustomThemedTextBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 160;
  Height := 28;
  TabStop := True;
  FBorderThickness := 1;
  FCornerRadius := 4;
  FLogicalButtonWidth := 28;
  FLogicalIconSize := 16;
  FLogicalPrefixSuffixGap := 6;
  FShowValidationIcon := True;
  FValidationState := tvsNormal;
  FInputMode := timText;
  FScrollBars := System.UITypes.TScrollStyle.ssNone;
  FInnerPadding := TPadding.Create(Self);
  FInnerPadding.SetBounds(6, 5, 6, 5);
  FInnerPadding.OnChange := InnerPaddingChanged;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.SetSize(1, 1);
  FMeasureCanvas := TNimbusRenderCanvas.Create;
  FEditor := TNimbusTextBoxEditor.Create(Self);
  FEditor.BorderStyle := Vcl.Forms.bsNone;
  FEditor.ParentFont := False;
  FEditor.Font.Assign(Font);
  FEditor.ParentColor := False;
  FEditor.TabStop := False;
  FEditor.WordWrap := False;
  FEditor.WantReturns := False;
  FEditor.WantTabs := False;
  FEditor.ScrollBars := System.UITypes.TScrollStyle.ssNone;
  FEditor.ReadOnly := False;
  FEditor.CharCase := ecNormal;
  FEditor.Alignment := taLeftJustify;
  FEditor.MaxLength := 32767;
  FEditor.StyleElements := [];
  FEditor.OnChange := EditorChange;
  FEditor.OnEnter := EditorEnter;
  FEditor.OnExit := EditorExit;
  FEditor.OnMouseEnter := EditorMouseEnter;
  FEditor.OnMouseLeave := EditorMouseLeave;
  FEditor.OnKeyDown := EditorKeyDown;
  FEditor.OnKeyPress := EditorKeyPress;
end;

destructor TCustomThemedTextBox.Destroy;
begin
  FMeasureCanvas := nil;
  FMeasureBitmap.Free;
  FInnerPadding.Free;
  inherited Destroy;
end;

procedure TCustomThemedTextBox.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  UpdateEditorTheme;
end;

procedure TCustomThemedTextBox.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if Align = alNone then
  begin
    if StyleMode = stCompact then
    begin
      if (not FMultiline) and (Height > 0) then
      begin
        FCompactNormalHeight := Height;
        FCompactAppliedHeight := Max(ScaleValue(20), (Height * 23 + 28 div 2) div 28);
        Height := FCompactAppliedHeight;
      end;
    end
    else if FCompactNormalHeight > 0 then
    begin
      if Height = FCompactAppliedHeight then Height := FCompactNormalHeight;
      FCompactNormalHeight := 0;
      FCompactAppliedHeight := 0;
    end;
  end;
  UpdateEditorBounds;
end;

procedure TCustomThemedTextBox.SetParent(AParent: TWinControl);
begin
  if (AParent = nil) and (FEditor <> nil) and (FEditor.Parent = Self) then FEditor.Parent := nil;
  inherited SetParent(AParent);
  if (AParent <> nil) and (FEditor <> nil) and (FEditor.Parent <> Self) then
  begin
    FEditor.Parent := Self;
    UpdateEditorBounds;
    UpdateEditorTheme;
    UpdatePasswordChar;
  end;
end;

function TCustomThemedTextBox.GetText: string;
begin
  Result := FEditor.Text;
end;

procedure TCustomThemedTextBox.SetText(const AValue: string);
begin
  if FEditor.Text = AValue then
    Exit;
  FEditor.Text := AValue;
end;

function TCustomThemedTextBox.GetReadOnly: Boolean;
begin
  Result := FEditor.ReadOnly;
end;

procedure TCustomThemedTextBox.SetReadOnly(const AValue: Boolean);
begin
  if FEditor.ReadOnly = AValue then
    Exit;
  FEditor.ReadOnly := AValue;
  UpdateEditorTheme;
  UpdateEditorBounds;
  Invalidate;
end;

function TCustomThemedTextBox.GetUseSystemPasswordChar: Boolean;
begin
  Result := FUseSystemPasswordChar and not FPasswordVisible;
end;

function TCustomThemedTextBox.GetTextAlign: TAlignment;
begin
  Result := FEditor.Alignment;
end;

procedure TCustomThemedTextBox.SetTextAlign(const AValue: TAlignment);
begin
  if FEditor.Alignment = AValue then
    Exit;
  FEditor.Alignment := AValue;
end;

function TCustomThemedTextBox.GetCharCase: TEditCharCase;
begin
  Result := FEditor.CharCase;
end;

procedure TCustomThemedTextBox.SetCharCase(const AValue: TEditCharCase);
begin
  if FEditor.CharCase = AValue then
    Exit;
  FEditor.CharCase := AValue;
end;

function TCustomThemedTextBox.GetMaxLength: Integer;
begin
  Result := FEditor.MaxLength;
end;

procedure TCustomThemedTextBox.SetMaxLength(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FEditor.MaxLength = LValue then
    Exit;
  FEditor.MaxLength := LValue;
end;

function TCustomThemedTextBox.GetSelectionStart: Integer;
begin
  Result := FEditor.SelStart;
end;

procedure TCustomThemedTextBox.SetSelectionStart(const AValue: Integer);
begin
  FEditor.SelStart := AValue;
end;

function TCustomThemedTextBox.GetSelectionLength: Integer;
begin
  Result := FEditor.SelLength;
end;

procedure TCustomThemedTextBox.SetSelectionLength(const AValue: Integer);
begin
  FEditor.SelLength := AValue;
end;

function TCustomThemedTextBox.GetSelectedText: string;
begin
  Result := FEditor.SelText;
end;

procedure TCustomThemedTextBox.SetSelectedText(const AValue: string);
begin
  FEditor.SelText := AValue;
end;

procedure TCustomThemedTextBox.SetInnerPadding(const AValue: TPadding);
begin
  if AValue <> nil then FInnerPadding.Assign(AValue);
end;

procedure TCustomThemedTextBox.InnerPaddingChanged(Sender: TObject);
begin
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetBorderThickness(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if FBorderThickness = LValue then
    Exit;
  FBorderThickness := LValue;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetPlaceholderText(const AValue: string);
begin
  if FPlaceholderText = AValue then
    Exit;
  FPlaceholderText := AValue;
  FEditor.TextHint := AValue;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetPrefixText(const AValue: string);
begin
  if FPrefixText = AValue then
    Exit;
  FPrefixText := AValue;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetSuffixText(const AValue: string);
begin
  if FSuffixText = AValue then
    Exit;
  FSuffixText := AValue;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetShowClearButton(const AValue: Boolean);
begin
  if FShowClearButton = AValue then
    Exit;
  FShowClearButton := AValue;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetShowPasswordRevealButton(const AValue: Boolean);
begin
  if FShowPasswordRevealButton = AValue then
    Exit;
  FShowPasswordRevealButton := AValue;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetAutoSelectAllOnFocus(const AValue: Boolean);
begin
  FAutoSelectAllOnFocus := AValue;
end;

procedure TCustomThemedTextBox.SetUseRoundedCorners(const AValue: Boolean);
begin
  if FUseRoundedCorners = AValue then
    Exit;
  FUseRoundedCorners := AValue;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FCornerRadius = LValue then
    Exit;
  FCornerRadius := LValue;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetShowValidationIcon(const AValue: Boolean);
begin
  if FShowValidationIcon = AValue then
    Exit;
  FShowValidationIcon := AValue;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetValidationState(const AValue: TThemedTextBoxValidationState);
var
  LOld: TThemedTextBoxValidationState;
begin
  if FValidationState = AValue then
    Exit;
  LOld := FValidationState;
  FValidationState := AValue;
  UpdateEditorBounds;
  Invalidate;
  DoValidationStateChanged(LOld, FValidationState);
end;

procedure TCustomThemedTextBox.SetValidationMessage(const AValue: string);
begin
  if FValidationMessage = AValue then
    Exit;
  FValidationMessage := AValue;
end;

procedure TCustomThemedTextBox.SetInputMode(const AValue: TThemedTextBoxInputMode);
begin
  if FInputMode = AValue then
    Exit;
  FInputMode := AValue;
end;

procedure TCustomThemedTextBox.SetRegexPattern(const AValue: string);
begin
  if FRegexPattern = AValue then
    Exit;
  FRegexPattern := AValue;
end;

procedure TCustomThemedTextBox.SetMultiline(const AValue: Boolean);
begin
  if FMultiline = AValue then
    Exit;
  FMultiline := AValue;
  FEditor.WordWrap := AValue;
  FEditor.WantReturns := AValue and FAcceptsReturn;
  if AValue then FEditor.ScrollBars := FScrollBars else FEditor.ScrollBars := System.UITypes.TScrollStyle.ssNone;
  UpdatePasswordChar;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetUseSystemPasswordChar(const AValue: Boolean);
begin
  if FUseSystemPasswordChar = AValue then
    Exit;
  FUseSystemPasswordChar := AValue;
  FPasswordVisible := False;
  UpdatePasswordChar;
  Invalidate;
end;

procedure TCustomThemedTextBox.SetAcceptsReturn(const AValue: Boolean);
begin
  if FAcceptsReturn = AValue then
    Exit;
  FAcceptsReturn := AValue;
  FEditor.WantReturns := FMultiline and AValue;
end;

procedure TCustomThemedTextBox.SetAcceptsTab(const AValue: Boolean);
begin
  if FAcceptsTab = AValue then
    Exit;
  FAcceptsTab := AValue;
  FEditor.WantTabs := AValue;
end;

procedure TCustomThemedTextBox.SetScrollBars(const AValue: System.UITypes.TScrollStyle);
begin
  if FScrollBars = AValue then
    Exit;
  FScrollBars := AValue;
  if FMultiline then FEditor.ScrollBars := AValue else FEditor.ScrollBars := System.UITypes.TScrollStyle.ssNone;
  UpdateEditorBounds;
end;

function TCustomThemedTextBox.MeasureTextWidth(const AText: string): Integer;
var
  LSize: TSize;
begin
  if AText = '' then
    Exit(0);
  FMeasureCanvas.BeginRender(FMeasureBitmap.Canvas);
  try
    LSize := FMeasureCanvas.MeasureText(AText, Font, MaxInt, [ntfSingleLine, ntfNoPrefix]);
  finally
    FMeasureCanvas.EndRender;
  end;
  Result := LSize.cx;
end;

procedure TCustomThemedTextBox.CalculateLayout(out AEditorRect, APrefixRect, ASuffixRect, AClearRect, APasswordRect, AValidationRect: TRect);
var
  LBorder, LLeft, LTop, LRight, LBottom, LWidth, LButtonWidth, LGap, LPrefixWidth, LSuffixWidth: Integer;
begin
  LBorder := ScaleValue(FBorderThickness);
  LLeft := LBorder + ScaleValue(Max(2, FInnerPadding.Left - Ord(StyleMode = stCompact) * 2));
  LTop := LBorder + ScaleValue(Max(1, FInnerPadding.Top - Ord(StyleMode = stCompact) * 2));
  LRight := Width - LBorder - ScaleValue(Max(2, FInnerPadding.Right - Ord(StyleMode = stCompact) * 2));
  LBottom := Height - LBorder - ScaleValue(Max(1, FInnerPadding.Bottom - Ord(StyleMode = stCompact) * 2));
  if LRight < LLeft then LRight := LLeft;
  if LBottom < LTop then LBottom := LTop;
  LGap := ScaleValue(FLogicalPrefixSuffixGap - Ord(StyleMode = stCompact) * 2);
  LButtonWidth := ScaleValue(FLogicalButtonWidth - Ord(StyleMode = stCompact) * 8);
  if LButtonWidth < 1 then LButtonWidth := 1;
  APrefixRect := Rect(0, 0, 0, 0);
  ASuffixRect := Rect(0, 0, 0, 0);
  AClearRect := Rect(0, 0, 0, 0);
  APasswordRect := Rect(0, 0, 0, 0);
  AValidationRect := Rect(0, 0, 0, 0);
  if FPrefixText <> '' then
  begin
    LPrefixWidth := MeasureTextWidth(FPrefixText);
    APrefixRect := Rect(LLeft, 0, LLeft + LPrefixWidth, Height);
    Inc(LLeft, LPrefixWidth + LGap);
  end;
  if ClearButtonVisible then
  begin
    AClearRect := Rect(LRight - LButtonWidth, 0, LRight, Height);
    Dec(LRight, LButtonWidth);
  end;
  if PasswordButtonVisible then
  begin
    APasswordRect := Rect(LRight - LButtonWidth, 0, LRight, Height);
    Dec(LRight, LButtonWidth);
  end;
  if ValidationIconVisible then
  begin
    AValidationRect := Rect(LRight - LButtonWidth, 0, LRight, Height);
    Dec(LRight, LButtonWidth);
  end;
  if FSuffixText <> '' then
  begin
    LSuffixWidth := MeasureTextWidth(FSuffixText);
    ASuffixRect := Rect(LRight - LSuffixWidth, 0, LRight, Height);
    Dec(LRight, LSuffixWidth + LGap);
  end;
  LWidth := LRight - LLeft;
  if LWidth < 1 then LWidth := 1;
  AEditorRect := Rect(LLeft, LTop, LLeft + LWidth, LBottom);
end;

procedure TCustomThemedTextBox.UpdateEditorBounds;
var
  LHeight, LTop: Integer;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) or (Parent = nil) then
    Exit;
  CalculateLayout(FEditorRect, FPrefixRect, FSuffixRect, FClearRect, FPasswordRect, FValidationRect);
  if FMultiline then
    FEditor.SetBounds(FEditorRect.Left, FEditorRect.Top, Max(1, FEditorRect.Width), Max(1, FEditorRect.Height))
  else
  begin
    FMeasureCanvas.BeginRender(FMeasureBitmap.Canvas);
    try
      LHeight := FMeasureCanvas.MeasureText('Ag', Font, MaxInt, [ntfSingleLine, ntfNoPrefix]).cy + ScaleValue(2);
    finally
      FMeasureCanvas.EndRender;
    end;
    if LHeight < 1 then LHeight := 1;
    if LHeight > Height - ScaleValue(FBorderThickness) * 2 then LHeight := Height - ScaleValue(FBorderThickness) * 2;
    if LHeight < 1 then LHeight := 1;
    LTop := (Height - LHeight) div 2;
    FEditor.SetBounds(FEditorRect.Left, LTop, Max(1, FEditorRect.Width), LHeight);
  end;
end;

procedure TCustomThemedTextBox.UpdateEditorTheme;
var
  LBack, LFore: TThemeColor;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) or (Parent = nil) then
    Exit;
  if not Enabled then LBack := NimbusDisabledBackColor(Palette)
  else if FEditor.ReadOnly then LBack := NimbusPanelBackColor(Palette)
  else LBack := NimbusInputBackColor(Palette);
  if Enabled then LFore := NimbusInputForeColor(Palette) else LFore := NimbusDisabledForeColor(Palette);
  FEditor.Color := ThemeColorToColor(LBack);
  FEditor.Font.Color := ThemeColorToColor(LFore);
  FEditor.Enabled := Enabled;
  FEditor.Invalidate;
end;

procedure TCustomThemedTextBox.UpdatePasswordChar;
begin
  if FUseSystemPasswordChar and not FPasswordVisible and not FMultiline then FEditor.PasswordChar := #$25CF else FEditor.PasswordChar := #0;
end;

function TCustomThemedTextBox.ClearButtonVisible: Boolean;
begin
  Result := FShowClearButton and Enabled and not FEditor.ReadOnly and (FEditor.Text <> '');
end;

function TCustomThemedTextBox.PasswordButtonVisible: Boolean;
begin
  Result := FShowPasswordRevealButton and Enabled and not FMultiline;
end;

function TCustomThemedTextBox.ValidationIconVisible: Boolean;
begin
  Result := FShowValidationIcon and (FValidationState <> tvsNormal);
end;

function TCustomThemedTextBox.BuildRenderContext: TThemedTextBoxRenderContext;
begin
  Result.PrefixRect := FPrefixRect;
  Result.SuffixRect := FSuffixRect;
  Result.ClearRect := FClearRect;
  Result.PasswordRect := FPasswordRect;
  Result.ValidationRect := FValidationRect;
  Result.Bounds := ClientRect;
  Result.Font := Font;
  Result.Palette := Palette;
  Result.PrefixText := FPrefixText;
  Result.SuffixText := FSuffixText;
  Result.BorderThickness := ScaleValue(FBorderThickness);
  Result.CornerRadius := ScaleValue(FCornerRadius);
  Result.UseRoundedCorners := FUseRoundedCorners;
  Result.Enabled := Enabled;
  Result.Focused := FFocused;
  Result.Hovered := FHovered;
  Result.ReadOnly := FEditor.ReadOnly;
  Result.ShowClearButton := ClearButtonVisible;
  Result.ShowPasswordButton := PasswordButtonVisible;
  Result.ShowValidationIcon := ValidationIconVisible;
  Result.ClearHovered := FClearHovered;
  Result.ClearPressed := FClearPressed;
  Result.PasswordHovered := FPasswordHovered;
  Result.PasswordPressed := FPasswordPressed;
  Result.PasswordVisible := FPasswordVisible;
  Result.ValidationState := FValidationState;
  Result.RightToLeft := UseRightToLeftReading;
end;

procedure TCustomThemedTextBox.EditorChange(Sender: TObject);
var
  LOld, LNew: string;
begin
  LNew := FEditor.Text;
  LOld := FOldText;
  FOldText := LNew;
  UpdateEditorBounds;
  DoChange;
  DoTextChangedEx(LOld, LNew);
  Invalidate;
end;

procedure TCustomThemedTextBox.EditorEnter(Sender: TObject);
begin
  FFocused := True;
  if FAutoSelectAllOnFocus then FEditor.SelectAll;
  Invalidate;
end;

procedure TCustomThemedTextBox.EditorExit(Sender: TObject);
begin
  FFocused := False;
  Invalidate;
end;

procedure TCustomThemedTextBox.EditorMouseEnter(Sender: TObject);
begin
  FHovered := True;
  Invalidate;
end;

procedure TCustomThemedTextBox.EditorMouseLeave(Sender: TObject);
begin
  if not PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos)) then
  begin
    FHovered := False;
    Invalidate;
  end;
end;

procedure TCustomThemedTextBox.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    DoEnterPressed;
    if not FMultiline or not FAcceptsReturn then Key := 0;
  end
  else if Key = VK_ESCAPE then
    DoEscapePressed;
end;

procedure TCustomThemedTextBox.EditorKeyPress(Sender: TObject; var Key: Char);
var
  LSettings: TFormatSettings;
  LSeparator: Char;
begin
  if Key < #32 then
    Exit;
  case FInputMode of
    timInteger:
      begin
        if not CharInSet(Key, ['0'..'9', '-']) then Key := #0
        else if (Key = '-') and ((FEditor.SelStart <> 0) or (Pos('-', FEditor.Text) > 0)) then Key := #0;
      end;
    timDecimal:
      begin
        LSettings := TFormatSettings.Create;
        LSeparator := LSettings.DecimalSeparator;
        if not CharInSet(Key, ['0'..'9', '-', LSeparator]) then Key := #0
        else if (Key = '-') and ((FEditor.SelStart <> 0) or (Pos('-', FEditor.Text) > 0)) then Key := #0
        else if (Key = LSeparator) and (Pos(string(LSeparator), FEditor.Text) > 0) then Key := #0;
      end;
  end;
end;

procedure TCustomThemedTextBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  UpdateEditorTheme;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then FEditor.Font.Assign(Font);
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then FEditor.BiDiMode := BiDiMode;
  Invalidate;
end;

procedure TCustomThemedTextBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if not PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos)) then
  begin
    FHovered := False;
    FClearHovered := False;
    FPasswordHovered := False;
    if not MouseCapture then
    begin
      FClearPressed := False;
      FPasswordPressed := False;
    end;
    Invalidate;
  end;
end;

procedure TCustomThemedTextBox.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  FClearPressed := False;
  FPasswordPressed := False;
  Invalidate;
end;

procedure TCustomThemedTextBox.Resize;
begin
  inherited Resize;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedTextBox.DoEnter;
begin
  inherited DoEnter;
  if (FEditor.Parent = Self) and FEditor.CanFocus then FEditor.SetFocus;
end;

procedure TCustomThemedTextBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LContext: TThemedTextBoxRenderContext;
  LPoint: TPoint;
  LClear, LPassword: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  FHovered := True;
  LContext := BuildRenderContext;
  LPoint := Point(X, Y);
  LClear := LContext.ShowClearButton and PtInRect(LContext.ClearRect, LPoint);
  LPassword := LContext.ShowPasswordButton and PtInRect(LContext.PasswordRect, LPoint);
  if (FClearHovered <> LClear) or (FPasswordHovered <> LPassword) then
  begin
    FClearHovered := LClear;
    FPasswordHovered := LPassword;
    Invalidate;
  end;
end;

procedure TCustomThemedTextBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LContext: TThemedTextBoxRenderContext;
  LPoint: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then
    Exit;
  LContext := BuildRenderContext;
  LPoint := Point(X, Y);
  if LContext.ShowClearButton and PtInRect(LContext.ClearRect, LPoint) then
  begin
    FClearPressed := True;
    MouseCapture := True;
    Invalidate;
    Exit;
  end;
  if LContext.ShowPasswordButton and PtInRect(LContext.PasswordRect, LPoint) then
  begin
    FPasswordPressed := True;
    MouseCapture := True;
    Invalidate;
    Exit;
  end;
  if (FEditor.Parent = Self) and FEditor.CanFocus then FEditor.SetFocus;
end;

procedure TCustomThemedTextBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LContext: TThemedTextBoxRenderContext;
  LPoint: TPoint;
  LClearClick, LPasswordClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then
    Exit;
  LContext := BuildRenderContext;
  LPoint := Point(X, Y);
  LClearClick := FClearPressed and LContext.ShowClearButton and PtInRect(LContext.ClearRect, LPoint);
  LPasswordClick := FPasswordPressed and LContext.ShowPasswordButton and PtInRect(LContext.PasswordRect, LPoint);
  FClearPressed := False;
  FPasswordPressed := False;
  MouseCapture := False;
  if LClearClick then ClearText;
  if LPasswordClick then
  begin
    FPasswordVisible := not FPasswordVisible;
    UpdatePasswordChar;
    if FEditor.CanFocus then FEditor.SetFocus;
    DoPasswordRevealClicked;
  end;
  Invalidate;
end;

procedure TCustomThemedTextBox.DoChange;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TCustomThemedTextBox.DoClearClicked;
begin
  if Assigned(FOnClearClicked) then FOnClearClicked(Self);
end;

procedure TCustomThemedTextBox.DoPasswordRevealClicked;
begin
  if Assigned(FOnPasswordRevealClicked) then FOnPasswordRevealClicked(Self);
end;

procedure TCustomThemedTextBox.DoEnterPressed;
begin
  if Assigned(FOnEnterPressed) then FOnEnterPressed(Self);
end;

procedure TCustomThemedTextBox.DoEscapePressed;
begin
  if Assigned(FOnEscapePressed) then FOnEscapePressed(Self);
end;

procedure TCustomThemedTextBox.DoTextChangedEx(const AOldText, ANewText: string);
begin
  if Assigned(FOnTextChangedEx) then FOnTextChangedEx(Self, AOldText, ANewText);
end;

procedure TCustomThemedTextBox.DoValidationStateChanged(const AOldState, ANewState: TThemedTextBoxValidationState);
begin
  if Assigned(FOnValidationStateChanged) then FOnValidationStateChanged(Self, AOldState, ANewState);
end;

function TCustomThemedTextBox.ValidateText: Boolean;
var
  LText: string;
begin
  LText := Text;
  if FInputMode = timEmail then
  begin
    Result := (LText = '') or TRegEx.IsMatch(LText, '^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if Result then ValidationState := tvsNormal else ValidationState := tvsError;
    Exit;
  end;
  if FInputMode = timUrl then
  begin
    Result := (LText = '') or TRegEx.IsMatch(LText, '^[A-Za-z][A-Za-z0-9+.-]*://.+$');
    if Result then ValidationState := tvsNormal else ValidationState := tvsError;
    Exit;
  end;
  if FRegexPattern <> '' then
  begin
    Result := TRegEx.IsMatch(LText, FRegexPattern);
    if Result then ValidationState := tvsNormal else ValidationState := tvsError;
    Exit;
  end;
  Result := True;
end;

procedure TCustomThemedTextBox.ClearText;
begin
  if FEditor.Text = '' then
    Exit;
  FEditor.Clear;
  if FEditor.CanFocus then FEditor.SetFocus;
  DoClearClicked;
end;

procedure TCustomThemedTextBox.SelectAll;
begin
  FEditor.SelectAll;
end;

procedure TCustomThemedTextBox.Select(const AStart, ALength: Integer);
begin
  FEditor.SelStart := AStart;
  FEditor.SelLength := ALength;
end;

procedure TCustomThemedTextBox.DeselectAll;
begin
  FEditor.SelLength := 0;
end;

procedure TCustomThemedTextBox.Paint;
var
  LContext: TThemedTextBoxRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := BuildRenderContext;
    TThemedTextBoxRenderer.Render(RenderCanvas, LContext, ScaleValue(FLogicalIconSize - Ord(StyleMode = stCompact) * 2));
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

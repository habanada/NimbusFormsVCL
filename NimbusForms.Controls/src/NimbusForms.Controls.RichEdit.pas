{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.RichEdit;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.HScrollBar,
  NimbusForms.Controls.VScrollBar;

type
  TCustomThemedRichEdit = class(TCustomNimbusControl)
  private
    FEditor: TRichEdit;
    FHorizontalScrollBar: TThemedHScrollBar;
    FVerticalScrollBar: TThemedVScrollBar;
    FUpdatingScrollBars: Boolean;
    FScrollBars: System.UITypes.TScrollStyle;
    FShowBorder: Boolean;
    FBorderThickness: Integer;
    FCornerRadius: Integer;
    FInnerPadding: Integer;
    FFocused: Boolean;
    FHideSelection: Boolean;
    FZoom: Integer;
    FOnChange: TNotifyEvent;
    FOnSelectionChange: TNotifyEvent;
    function GetLines: TStrings;
    procedure SetLines(const AValue: TStrings);
    function GetEditorText: string;
    procedure SetEditorText(const AValue: string);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const AValue: Boolean);
    function GetWordWrap: Boolean;
    procedure SetWordWrap(const AValue: Boolean);
    function GetWantTabs: Boolean;
    procedure SetWantTabs(const AValue: Boolean);
    function GetWantReturns: Boolean;
    procedure SetWantReturns(const AValue: Boolean);
    function GetScrollBars: System.UITypes.TScrollStyle;
    procedure SetScrollBars(const AValue: System.UITypes.TScrollStyle);
    function GetMaxLength: Integer;
    procedure SetMaxLength(const AValue: Integer);
    function GetPlainText: Boolean;
    procedure SetPlainText(const AValue: Boolean);
    function GetHideSelection: Boolean;
    procedure SetHideSelection(const AValue: Boolean);
    function GetZoom: Integer;
    procedure SetZoom(const AValue: Integer);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetBorderThickness(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetInnerPadding(const AValue: Integer);
    procedure EditorChange(Sender: TObject);
    procedure EditorSelectionChange(Sender: TObject);
    procedure EditorEnter(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorClick(Sender: TObject);
    procedure EditorViewportChanged;
    procedure HorizontalScrollBarChanged(Sender: TObject);
    procedure VerticalScrollBarChanged(Sender: TObject);
    procedure UpdateEditorBounds;
    procedure UpdateScrollBars;
    procedure SyncScrollPositions;
    function GetFirstVisibleLine: Integer;
    function GetLineCount: Integer;
    function GetLineHeight: Integer;
    function GetContentWidth: Integer;
    function GetScrollPosition: TPoint;
    procedure SetScrollPosition(const APosition: TPoint);
    procedure ApplyEditorTheme;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    procedure StyleModeChanged; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure DoChange; virtual;
    procedure DoSelectionChange; virtual;
    procedure Paint; override;
    procedure Resize; override;
    property Lines: TStrings read GetLines write SetLines;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default True;
    property WantTabs: Boolean read GetWantTabs write SetWantTabs default False;
    property WantReturns: Boolean read GetWantReturns write SetWantReturns default True;
    property ScrollBars: System.UITypes.TScrollStyle read GetScrollBars write SetScrollBars default System.UITypes.TScrollStyle.ssBoth;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property PlainText: Boolean read GetPlainText write SetPlainText default False;
    property HideSelection: Boolean read GetHideSelection write SetHideSelection default True;
    property Zoom: Integer read GetZoom write SetZoom default 100;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property BorderThickness: Integer read FBorderThickness write SetBorderThickness default 1;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 4;
    property InnerPadding: Integer read FInnerPadding write SetInnerPadding default 6;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure Clear;
    procedure SelectAll;
    property Editor: TRichEdit read FEditor;
    property Text: string read GetEditorText write SetEditorText;
  end;

  TThemedRichEdit = class(TCustomThemedRichEdit)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderThickness;
    property Constraints;
    property CornerRadius;
    property Enabled;
    property Font;
    property HideSelection;
    property InnerPadding;
    property Lines;
    property MaxLength;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PlainText;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowBorder;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property Zoom;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnSelectionChange;
  end;

implementation

uses
  Winapi.RichEdit,
  System.Math,
  Vcl.Forms,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.RichEdit;

type
  TNimbusHostedRichEdit = class(TRichEdit)
  private
    FHost: TCustomThemedRichEdit;
  protected
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor CreateHosted(AOwner: TComponent; AHost: TCustomThemedRichEdit);
  end;

constructor TNimbusHostedRichEdit.CreateHosted(AOwner: TComponent; AHost: TCustomThemedRichEdit);
begin
  inherited Create(AOwner);
  FHost := AHost;
end;

procedure TNimbusHostedRichEdit.CreateWnd;
begin
  inherited CreateWnd;
  if FHost <> nil then FHost.UpdateScrollBars;
end;

procedure TNimbusHostedRichEdit.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if FHost = nil then Exit;
  case Message.Msg of
    WM_SIZE:
      FHost.UpdateScrollBars;
    WM_HSCROLL, WM_VSCROLL, WM_MOUSEWHEEL, WM_MOUSEHWHEEL, WM_KEYDOWN, WM_KEYUP, WM_LBUTTONUP:
      FHost.EditorViewportChanged;
  end;
end;

constructor TCustomThemedRichEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 240;
  Height := 120;
  TabStop := False;
  FShowBorder := True;
  FBorderThickness := 1;
  FCornerRadius := 4;
  FInnerPadding := 6;
  FHideSelection := True;
  FZoom := 100;
  FScrollBars := System.UITypes.TScrollStyle.ssBoth;

  FEditor := TNimbusHostedRichEdit.CreateHosted(Self, Self);
  FEditor.BorderStyle := Vcl.Forms.bsNone;
  FEditor.ParentFont := False;
  FEditor.Font.Assign(Font);
  FEditor.ParentColor := False;
  FEditor.ReadOnly := False;
  FEditor.WordWrap := True;
  FEditor.WantTabs := False;
  FEditor.WantReturns := True;
  FEditor.ScrollBars := System.UITypes.TScrollStyle.ssNone;
  FEditor.MaxLength := 0;
  FEditor.PlainText := False;
  FEditor.StyleElements := [];
  FEditor.OnChange := EditorChange;
  FEditor.OnSelectionChange := EditorSelectionChange;
  FEditor.OnEnter := EditorEnter;
  FEditor.OnExit := EditorExit;
  FEditor.OnClick := EditorClick;

  FHorizontalScrollBar := TThemedHScrollBar.Create(Self);
  FHorizontalScrollBar.TabStop := False;
  FHorizontalScrollBar.Visible := False;
  FHorizontalScrollBar.OnValueChanged := HorizontalScrollBarChanged;

  FVerticalScrollBar := TThemedVScrollBar.Create(Self);
  FVerticalScrollBar.TabStop := False;
  FVerticalScrollBar.Visible := False;
  FVerticalScrollBar.OnValueChanged := VerticalScrollBarChanged;
end;

procedure TCustomThemedRichEdit.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  ApplyEditorTheme;
  if FHorizontalScrollBar <> nil then FHorizontalScrollBar.ApplyTheme(APalette);
  if FVerticalScrollBar <> nil then FVerticalScrollBar.ApplyTheme(APalette);
  UpdateScrollBars;
end;

procedure TCustomThemedRichEdit.SetParent(AParent: TWinControl);
begin
  if AParent = nil then
  begin
    if (FEditor <> nil) and (FEditor.Parent = Self) then FEditor.Parent := nil;
    if (FHorizontalScrollBar <> nil) and (FHorizontalScrollBar.Parent = Self) then FHorizontalScrollBar.Parent := nil;
    if (FVerticalScrollBar <> nil) and (FVerticalScrollBar.Parent = Self) then FVerticalScrollBar.Parent := nil;
  end;
  inherited SetParent(AParent);
  if AParent <> nil then
  begin
    if (FHorizontalScrollBar <> nil) and (FHorizontalScrollBar.Parent <> Self) then FHorizontalScrollBar.Parent := Self;
    if (FVerticalScrollBar <> nil) and (FVerticalScrollBar.Parent <> Self) then FVerticalScrollBar.Parent := Self;
    if (FEditor <> nil) and (FEditor.Parent <> Self) then FEditor.Parent := Self;
    FEditor.HideSelection := FHideSelection;
    FEditor.Zoom := FZoom;
    FHorizontalScrollBar.StyleMode := StyleMode;
    FVerticalScrollBar.StyleMode := StyleMode;
    UpdateScrollBars;
    ApplyEditorTheme;
  end;
end;

procedure TCustomThemedRichEdit.ApplyEditorTheme;
var
  LBack, LFore: TThemeColor;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) or (Parent = nil) then
    Exit;
  if not Enabled then
    LBack := NimbusDisabledBackColor(Palette)
  else if FEditor.ReadOnly then
    LBack := NimbusPanelBackColor(Palette)
  else
    LBack := NimbusInputBackColor(Palette);
  if Enabled then
    LFore := NimbusInputForeColor(Palette)
  else
    LFore := NimbusDisabledForeColor(Palette);
  FEditor.Color := ThemeColorToColor(LBack);
  FEditor.Font.Color := ThemeColorToColor(LFore);
  FEditor.DefAttributes.Color := ThemeColorToColor(LFore);
  FEditor.Enabled := Enabled;
  FEditor.Invalidate;
end;

function TCustomThemedRichEdit.GetLines: TStrings;
begin
  Result := FEditor.Lines;
end;

procedure TCustomThemedRichEdit.SetLines(const AValue: TStrings);
begin
  if AValue <> nil then FEditor.Lines.Assign(AValue) else FEditor.Clear;
  UpdateScrollBars;
end;

function TCustomThemedRichEdit.GetEditorText: string;
begin
  Result := FEditor.Text;
end;

procedure TCustomThemedRichEdit.SetEditorText(const AValue: string);
begin
  if FEditor.Text = AValue then Exit;
  FEditor.Text := AValue;
  UpdateScrollBars;
end;

function TCustomThemedRichEdit.GetReadOnly: Boolean;
begin
  Result := FEditor.ReadOnly;
end;

procedure TCustomThemedRichEdit.SetReadOnly(const AValue: Boolean);
begin
  if FEditor.ReadOnly = AValue then
    Exit;
  FEditor.ReadOnly := AValue;
  ApplyEditorTheme;
  Invalidate;
end;

function TCustomThemedRichEdit.GetWordWrap: Boolean;
begin
  Result := FEditor.WordWrap;
end;

procedure TCustomThemedRichEdit.SetWordWrap(const AValue: Boolean);
begin
  if FEditor.WordWrap = AValue then Exit;
  FEditor.WordWrap := AValue;
  UpdateScrollBars;
end;

function TCustomThemedRichEdit.GetWantTabs: Boolean;
begin
  Result := FEditor.WantTabs;
end;

procedure TCustomThemedRichEdit.SetWantTabs(const AValue: Boolean);
begin
  if FEditor.WantTabs = AValue then
    Exit;
  FEditor.WantTabs := AValue;
end;

function TCustomThemedRichEdit.GetWantReturns: Boolean;
begin
  Result := FEditor.WantReturns;
end;

procedure TCustomThemedRichEdit.SetWantReturns(const AValue: Boolean);
begin
  if FEditor.WantReturns = AValue then
    Exit;
  FEditor.WantReturns := AValue;
end;

function TCustomThemedRichEdit.GetScrollBars: System.UITypes.TScrollStyle;
begin
  Result := FScrollBars;
end;

procedure TCustomThemedRichEdit.SetScrollBars(const AValue: System.UITypes.TScrollStyle);
begin
  if FScrollBars = AValue then Exit;
  FScrollBars := AValue;
  UpdateScrollBars;
end;

function TCustomThemedRichEdit.GetMaxLength: Integer;
begin
  Result := FEditor.MaxLength;
end;

procedure TCustomThemedRichEdit.SetMaxLength(const AValue: Integer);
begin
  if FEditor.MaxLength = AValue then
    Exit;
  FEditor.MaxLength := AValue;
end;

function TCustomThemedRichEdit.GetPlainText: Boolean;
begin
  Result := FEditor.PlainText;
end;

procedure TCustomThemedRichEdit.SetPlainText(const AValue: Boolean);
begin
  if FEditor.PlainText = AValue then
    Exit;
  FEditor.PlainText := AValue;
end;

function TCustomThemedRichEdit.GetHideSelection: Boolean;
begin
  Result := FHideSelection;
end;

procedure TCustomThemedRichEdit.SetHideSelection(const AValue: Boolean);
begin
  if FHideSelection = AValue then
    Exit;
  FHideSelection := AValue;
  if (FEditor.Parent = Self) and (Parent <> nil) then
    FEditor.HideSelection := AValue;
end;

function TCustomThemedRichEdit.GetZoom: Integer;
begin
  Result := FZoom;
end;

procedure TCustomThemedRichEdit.SetZoom(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if LValue > 6399 then LValue := 6399;
  if FZoom = LValue then
    Exit;
  FZoom := LValue;
  if (FEditor.Parent = Self) and (Parent <> nil) then
  begin
    FEditor.Zoom := LValue;
    UpdateScrollBars;
  end;
end;

procedure TCustomThemedRichEdit.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then
    Exit;
  FShowBorder := AValue;
  UpdateScrollBars;
  Invalidate;
end;

procedure TCustomThemedRichEdit.SetBorderThickness(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if FBorderThickness = LValue then
    Exit;
  FBorderThickness := LValue;
  UpdateScrollBars;
  Invalidate;
end;

procedure TCustomThemedRichEdit.SetCornerRadius(const AValue: Integer);
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

procedure TCustomThemedRichEdit.SetInnerPadding(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FInnerPadding = LValue then
    Exit;
  FInnerPadding := LValue;
  UpdateScrollBars;
end;

procedure TCustomThemedRichEdit.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCustomThemedRichEdit.DoSelectionChange;
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
end;

procedure TCustomThemedRichEdit.EditorChange(Sender: TObject);
begin
  UpdateScrollBars;
  DoChange;
end;

procedure TCustomThemedRichEdit.EditorSelectionChange(Sender: TObject);
begin
  UpdateScrollBars;
  DoSelectionChange;
end;

procedure TCustomThemedRichEdit.EditorEnter(Sender: TObject);
begin
  if not FFocused then
  begin
    FFocused := True;
    Invalidate;
  end;
  DoEnter;
end;

procedure TCustomThemedRichEdit.EditorExit(Sender: TObject);
begin
  if FFocused then
  begin
    FFocused := False;
    Invalidate;
  end;
  DoExit;
end;

procedure TCustomThemedRichEdit.EditorClick(Sender: TObject);
begin
  Click;
end;

procedure TCustomThemedRichEdit.EditorViewportChanged;
begin
  if (csDestroying in ComponentState) or FUpdatingScrollBars then Exit;
  SyncScrollPositions;
end;

procedure TCustomThemedRichEdit.HorizontalScrollBarChanged(Sender: TObject);
var
  LPosition: TPoint;
begin
  if FUpdatingScrollBars or (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  LPosition := GetScrollPosition;
  if LPosition.X = FHorizontalScrollBar.Value then Exit;
  LPosition.X := FHorizontalScrollBar.Value;
  FUpdatingScrollBars := True;
  try
    SetScrollPosition(LPosition);
  finally
    FUpdatingScrollBars := False;
  end;
end;

procedure TCustomThemedRichEdit.VerticalScrollBarChanged(Sender: TObject);
var
  LCurrentLine, LDelta: Integer;
begin
  if FUpdatingScrollBars or (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  LCurrentLine := GetFirstVisibleLine;
  LDelta := FVerticalScrollBar.Value - LCurrentLine;
  if LDelta = 0 then Exit;
  FUpdatingScrollBars := True;
  try
    SendMessage(FEditor.Handle, EM_LINESCROLL, 0, LDelta);
  finally
    FUpdatingScrollBars := False;
  end;
  SyncScrollPositions;
end;

procedure TCustomThemedRichEdit.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if FHorizontalScrollBar <> nil then FHorizontalScrollBar.StyleMode := StyleMode;
  if FVerticalScrollBar <> nil then FVerticalScrollBar.StyleMode := StyleMode;
  UpdateScrollBars;
end;

procedure TCustomThemedRichEdit.UpdateEditorBounds;
var
  LBorder, LPadding, LInset, LRight, LBottom, LScrollSize: Integer;
  LHorizontalVisible, LVerticalVisible: Boolean;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) then Exit;
  if FShowBorder then LBorder := ScaleValue(FBorderThickness) else LBorder := 0;
  LPadding := ScaleValue(Max(1, FInnerPadding - Ord(StyleMode = stCompact) * 3));
  LInset := LBorder + LPadding;
  LRight := Max(LInset, Width - LInset);
  LBottom := Max(LInset, Height - LInset);
  if StyleMode = stCompact then LScrollSize := ScaleValue(14) else LScrollSize := ScaleValue(18);
  LHorizontalVisible := (FHorizontalScrollBar <> nil) and FHorizontalScrollBar.Visible;
  LVerticalVisible := (FVerticalScrollBar <> nil) and FVerticalScrollBar.Visible;

  if LVerticalVisible then Dec(LRight, LScrollSize);
  if LHorizontalVisible then Dec(LBottom, LScrollSize);
  if LRight < LInset then LRight := LInset;
  if LBottom < LInset then LBottom := LInset;

  FEditor.SetBounds(LInset, LInset, LRight - LInset, LBottom - LInset);

  if FVerticalScrollBar <> nil then
    FVerticalScrollBar.SetBounds(LRight, LInset, LScrollSize, LBottom - LInset);
  if FHorizontalScrollBar <> nil then
    FHorizontalScrollBar.SetBounds(LInset, LBottom, LRight - LInset, LScrollSize);
end;

function TCustomThemedRichEdit.GetFirstVisibleLine: Integer;
begin
  if (FEditor = nil) or not FEditor.HandleAllocated then Exit(0);
  Result := SendMessage(FEditor.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
  if Result < 0 then Result := 0;
end;

function TCustomThemedRichEdit.GetLineCount: Integer;
begin
  if (FEditor = nil) or not FEditor.HandleAllocated then
  begin
    if FEditor <> nil then Result := Max(1, FEditor.Lines.Count) else Result := 1;
    Exit;
  end;
  Result := SendMessage(FEditor.Handle, EM_GETLINECOUNT, 0, 0);
  if Result < 1 then Result := 1;
end;

function TCustomThemedRichEdit.GetLineHeight: Integer;
var
  LDC: HDC;
  LOldFont: HGDIOBJ;
  LMetric: TTextMetricW;
begin
  Result := Max(1, Abs(FEditor.Font.Height));
  if (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  LDC := GetDC(FEditor.Handle);
  if LDC = 0 then Exit;
  LOldFont := SelectObject(LDC, FEditor.Font.Handle);
  try
    if GetTextMetricsW(LDC, LMetric) then
      Result := Max(1, MulDiv(LMetric.tmHeight, FZoom, 100));
  finally
    if LOldFont <> 0 then SelectObject(LDC, LOldFont);
    ReleaseDC(FEditor.Handle, LDC);
  end;
end;

function TCustomThemedRichEdit.GetContentWidth: Integer;
var
  I, LWidth: Integer;
  LDC: HDC;
  LOldFont: HGDIOBJ;
  LRect: TRect;
  LLine: string;
begin
  Result := 0;
  if (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  LDC := GetDC(FEditor.Handle);
  if LDC = 0 then Exit;
  LOldFont := SelectObject(LDC, FEditor.Font.Handle);
  try
    for I := 0 to FEditor.Lines.Count - 1 do
    begin
      LLine := FEditor.Lines[I];
      if LLine = '' then LLine := ' ';
      LRect := Rect(0, 0, 0, 0);
      DrawTextW(LDC, PWideChar(LLine), Length(LLine), LRect,
        DT_CALCRECT or DT_SINGLELINE or DT_EXPANDTABS or DT_NOPREFIX);
      LWidth := LRect.Right - LRect.Left;
      if LWidth > Result then Result := LWidth;
    end;
  finally
    if LOldFont <> 0 then SelectObject(LDC, LOldFont);
    ReleaseDC(FEditor.Handle, LDC);
  end;
  Result := Max(0, MulDiv(Result, FZoom, 100)) + ScaleValue(8);
end;

function TCustomThemedRichEdit.GetScrollPosition: TPoint;
begin
  Result := Point(0, 0);
  if (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  SendMessage(FEditor.Handle, EM_GETSCROLLPOS, 0, LPARAM(@Result));
end;

procedure TCustomThemedRichEdit.SetScrollPosition(const APosition: TPoint);
var
  LPosition: TPoint;
begin
  if (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  LPosition := APosition;
  SendMessage(FEditor.Handle, EM_SETSCROLLPOS, 0, LPARAM(@LPosition));
end;

procedure TCustomThemedRichEdit.SyncScrollPositions;
var
  LPosition: TPoint;
  LFirstVisibleLine: Integer;
begin
  if FUpdatingScrollBars or (FEditor = nil) or not FEditor.HandleAllocated then Exit;
  LPosition := GetScrollPosition;
  LFirstVisibleLine := GetFirstVisibleLine;
  FUpdatingScrollBars := True;
  try
    if FHorizontalScrollBar.Visible then FHorizontalScrollBar.Value := LPosition.X;
    if FVerticalScrollBar.Visible then FVerticalScrollBar.Value := LFirstVisibleLine;
  finally
    FUpdatingScrollBars := False;
  end;
end;

procedure TCustomThemedRichEdit.UpdateScrollBars;
var
  LContentWidth, LVisibleWidth, LLineHeight, LVisibleLines, LTotalLines: Integer;
  LHorizontalMaximum, LVerticalMaximum, LSmallChange: Integer;
  LPosition: TPoint;
  LHorizontalRequested, LVerticalRequested: Boolean;
begin
  if FUpdatingScrollBars or (FEditor = nil) or (FEditor.Parent <> Self) or not FEditor.HandleAllocated then Exit;
  FUpdatingScrollBars := True;
  try
    if FEditor.ScrollBars <> System.UITypes.TScrollStyle.ssNone then
      FEditor.ScrollBars := System.UITypes.TScrollStyle.ssNone;

    LHorizontalRequested := (FScrollBars in [System.UITypes.TScrollStyle.ssHorizontal, System.UITypes.TScrollStyle.ssBoth]) and not FEditor.WordWrap;
    LVerticalRequested := FScrollBars in [System.UITypes.TScrollStyle.ssVertical, System.UITypes.TScrollStyle.ssBoth];

    FHorizontalScrollBar.Visible := LHorizontalRequested;
    FVerticalScrollBar.Visible := LVerticalRequested;
    UpdateEditorBounds;

    LPosition := GetScrollPosition;
    LSmallChange := Max(1, Max(ScaleValue(8), Abs(FEditor.Font.Height)));

    if FHorizontalScrollBar.Visible then
    begin
      LContentWidth := GetContentWidth;
      LVisibleWidth := Max(1, FEditor.ClientWidth);
      LHorizontalMaximum := Max(LVisibleWidth, LContentWidth);
      FHorizontalScrollBar.Minimum := 0;
      FHorizontalScrollBar.LargeChange := LVisibleWidth;
      FHorizontalScrollBar.Maximum := LHorizontalMaximum;
      FHorizontalScrollBar.SmallChange := LSmallChange;
      FHorizontalScrollBar.Value := Min(Max(0, LPosition.X), FHorizontalScrollBar.EffectiveMaximum);
    end
    else if LPosition.X <> 0 then
    begin
      LPosition.X := 0;
      SetScrollPosition(LPosition);
    end;

    if FVerticalScrollBar.Visible then
    begin
      LLineHeight := GetLineHeight;
      LVisibleLines := Max(1, FEditor.ClientHeight div Max(1, LLineHeight));
      LTotalLines := GetLineCount;
      LVerticalMaximum := Max(LVisibleLines, LTotalLines);
      FVerticalScrollBar.Minimum := 0;
      FVerticalScrollBar.LargeChange := LVisibleLines;
      FVerticalScrollBar.Maximum := LVerticalMaximum;
      FVerticalScrollBar.SmallChange := 1;
      FVerticalScrollBar.Value := Min(GetFirstVisibleLine, FVerticalScrollBar.EffectiveMaximum);
    end;

    FHorizontalScrollBar.Enabled := Enabled;
    FVerticalScrollBar.Enabled := Enabled;
  finally
    FUpdatingScrollBars := False;
  end;
end;

procedure TCustomThemedRichEdit.Resize;
begin
  inherited Resize;
  UpdateScrollBars;
end;

procedure TCustomThemedRichEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  ApplyEditorTheme;
  UpdateScrollBars;
end;

procedure TCustomThemedRichEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then
  begin
    FEditor.Font.Assign(Font);
    ApplyEditorTheme;
    UpdateScrollBars;
  end;
end;

procedure TCustomThemedRichEdit.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedRichEditRenderer.RenderFrame(RenderCanvas, ClientRect, Palette, Enabled,
      FEditor.ReadOnly, FFocused, FShowBorder, ScaleValue(FBorderThickness),
      ScaleValue(FCornerRadius));
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedRichEdit.Clear;
begin
  FEditor.Clear;
  UpdateScrollBars;
end;

procedure TCustomThemedRichEdit.SelectAll;
begin
  FEditor.SelectAll;
end;

end.

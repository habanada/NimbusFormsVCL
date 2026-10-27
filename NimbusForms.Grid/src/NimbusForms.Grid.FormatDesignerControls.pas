unit NimbusForms.Grid.FormatDesignerControls;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.TypInfo,
  System.Math,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Dialogs,
  System.UITypes,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnCollection,
  NimbusForms.Grid.FormatConditionTypes,
  NimbusForms.Grid.FormatConditionModel,
  NimbusForms.Grid.FormatConditionValidation;

type
  TThemedGridDesignerColorEvent = procedure(ASender: TObject; const AColor: TColor) of object;

  TThemedGridDesignerPreset = class
  private
    FName: string;
    FDescription: string;
    FModel: TThemedGridFormatConditionModel;
  public
    constructor Create(const AName, ADescription: string; const AModel: TThemedGridFormatConditionModel);
    destructor Destroy; override;
    property Name: string read FName;
    property Description: string read FDescription;
    property Model: TThemedGridFormatConditionModel read FModel;
  end;

  TThemedGridDesignerButton = class(TCustomControl)
  private
    FHot: Boolean;
    FPressed: Boolean;
    procedure CMMouseEnter(var AMessage: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure PaintContent(const ARect: TRect); virtual;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Caption;
    property Font;
    property OnClick;
  end;

  TThemedGridDesignerColorButton = class(TThemedGridDesignerButton)
  private
    FSelectedColor: TColor;
    FOnColorSelected: TThemedGridDesignerColorEvent;
    procedure SetSelectedColor(const AValue: TColor);
  protected
    procedure PaintContent(const ARect: TRect); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor;
    property OnColorSelected: TThemedGridDesignerColorEvent read FOnColorSelected write FOnColorSelected;
  end;

  TThemedGridDesignerList = class(TCustomControl)
  private
    FPixelsPerInch: Integer;
    FRowHeight: Integer;
    FHoverIndex: Integer;
    FSelectedIndex: Integer;
    FOffset: Integer;
    FSelectable: Boolean;
    FOnSelectedIndexChanged: TNotifyEvent;
    FOnItemActivate: TNotifyEvent;
    procedure SetSelectedIndex(const AValue: Integer);
    procedure SetOffset(const AValue: Integer);
    function MaxOffset: Integer;
    procedure EnsureVisible(const AIndex: Integer);
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    function ItemCount: Integer; virtual; abstract;
    procedure DrawItem(const ARect: TRect; const AIndex: Integer; const ASelected, AHot: Boolean); virtual; abstract;
    procedure DrawEmpty(const ARect: TRect); virtual;
    function ItemAt(const AY: Integer): Integer;
    function S(const AValue: Integer): Integer;
    procedure DrawLabel(const ARect: TRect; const AText: string; const AColor: TColor);
    procedure ItemsChanged;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure DblClick; override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
    property RowHeight: Integer read FRowHeight write FRowHeight;
    property Selectable: Boolean read FSelectable write FSelectable;
  public
    constructor Create(AOwner: TComponent; const APixelsPerInch: Integer); reintroduce;
    procedure SetSelectedIndexSilent(const AValue: Integer);
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property OnSelectedIndexChanged: TNotifyEvent read FOnSelectedIndexChanged write FOnSelectedIndexChanged;
    property OnItemActivate: TNotifyEvent read FOnItemActivate write FOnItemActivate;
  end;

  TThemedGridDesignerRuleList = class(TThemedGridDesignerList)
  private
    FItems: TList<TThemedGridFormatConditionModel>;
    FColumns: TThemedGridColumnCollection;
    function ResolveStyleColor(const AItem: TThemedGridFormatConditionModel): TColor;
    function ResolveDetails(const AItem: TThemedGridFormatConditionModel): string;
    function IsMissingColumn(const AColumnName: string): Boolean;
  protected
    function ItemCount: Integer; override;
    procedure DrawItem(const ARect: TRect; const AIndex: Integer; const ASelected, AHot: Boolean); override;
  public
    constructor Create(AOwner: TComponent; const APixelsPerInch: Integer); reintroduce;
    destructor Destroy; override;
    procedure SetItems(const AItems: TList<TThemedGridFormatConditionModel>;
      const AColumns: TThemedGridColumnCollection);
  end;

  TThemedGridDesignerIssueRow = record
    Title: string;
    Details: string;
    IsError: Boolean;
  end;

  TThemedGridDesignerValidationList = class(TThemedGridDesignerList)
  private
    FItems: TList<TThemedGridDesignerIssueRow>;
  protected
    function ItemCount: Integer; override;
    procedure DrawItem(const ARect: TRect; const AIndex: Integer; const ASelected, AHot: Boolean); override;
    procedure DrawEmpty(const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent; const APixelsPerInch: Integer); reintroduce;
    destructor Destroy; override;
    procedure SetResult(const AResult: TThemedGridFormatConditionValidationResult);
  end;

  TThemedGridDesignerPresetList = class(TThemedGridDesignerList)
  private
    FItems: TList<TThemedGridDesignerPreset>;
    function GetSelectedPreset: TThemedGridDesignerPreset;
    function ResolveMarkerColor(const AItem: TThemedGridDesignerPreset): TColor;
  protected
    function ItemCount: Integer; override;
    procedure DrawItem(const ARect: TRect; const AIndex: Integer; const ASelected, AHot: Boolean); override;
    procedure DrawEmpty(const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent; const APixelsPerInch: Integer); reintroduce;
    destructor Destroy; override;
    procedure SetItems(const AItems: TList<TThemedGridDesignerPreset>);
    property SelectedPreset: TThemedGridDesignerPreset read GetSelectedPreset;
  end;

function DesignerGray(const AValue: Byte): TColor;
function DesignerValueText(const AValue: TValue): string;
function DesignerOperatorName(const AOperator: TThemedGridFormatConditionOperator): string;
function DesignerColumnExists(const AColumns: TThemedGridColumnCollection; const AColumnName: string): Boolean;
function DesignerStyleColor(const AModel: TThemedGridFormatConditionModel; const AFallback: TColor): TColor;

implementation

uses
  Vcl.Forms,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatStyleModel,
  NimbusForms.Grid.FormatDesignerStrings;

type
  TStr = ThemedGridFormatDesignerStrings;

function DesignerGray(const AValue: Byte): TColor;
begin
  Result := TColor(Integer(AValue) or (Integer(AValue) shl 8) or (Integer(AValue) shl 16));
end;

function DesignerValueText(const AValue: TValue): string;
begin
  if AValue.IsEmpty then
    Exit('');
  Result := AValue.ToString;
end;

function DesignerOperatorName(const AOperator: TThemedGridFormatConditionOperator): string;
begin
  Result := GetEnumName(TypeInfo(TThemedGridFormatConditionOperator), Ord(AOperator));
end;

function DesignerColumnExists(const AColumns: TThemedGridColumnCollection; const AColumnName: string): Boolean;
var
  I: Integer;
  LColumn: TThemedGridColumn;
begin
  Result := False;
  if (AColumnName = '') or (AColumns = nil) then
    Exit;
  for I := 0 to AColumns.Count - 1 do
  begin
    LColumn := AColumns[I];
    if LColumn = nil then
      Continue;
    if SameText(LColumn.Name, AColumnName) or SameText(LColumn.FieldName, AColumnName) or
      SameText(LColumn.HeaderText, AColumnName) then
      Exit(True);
  end;
end;

function DesignerStyleColor(const AModel: TThemedGridFormatConditionModel; const AFallback: TColor): TColor;
var
  LStyle: TThemedGridFormatStyle;
begin
  if (AModel = nil) or (AModel.Style = nil) then
    Exit(AFallback);
  LStyle := AModel.Style.ToStyle;
  try
    if LStyle.HasBackColor then
      Result := ThemeColorToColor(LStyle.BackColor)
    else if LStyle.HasForeColor then
      Result := ThemeColorToColor(LStyle.ForeColor)
    else if LStyle.HasBorderColor then
      Result := ThemeColorToColor(LStyle.BorderColor)
    else
      Result := AFallback;
  finally
    LStyle.Free;
  end;
end;

constructor TThemedGridDesignerPreset.Create(const AName, ADescription: string;
  const AModel: TThemedGridFormatConditionModel);
begin
  inherited Create;
  FName := AName;
  FDescription := ADescription;
  FModel := AModel;
end;

destructor TThemedGridDesignerPreset.Destroy;
begin
  FModel.Free;
  inherited Destroy;
end;

constructor TThemedGridDesignerButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  TabStop := True;
  DoubleBuffered := True;
  Width := 86;
  Height := 28;
end;

procedure TThemedGridDesignerButton.CMMouseEnter(var AMessage: TMessage);
begin
  inherited;
  FHot := True;
  Invalidate;
end;

procedure TThemedGridDesignerButton.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  FHot := False;
  FPressed := False;
  Invalidate;
end;

procedure TThemedGridDesignerButton.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TThemedGridDesignerButton.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  AMessage.Result := DLGC_WANTALLKEYS;
end;

procedure TThemedGridDesignerButton.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TThemedGridDesignerButton.Paint;
var
  LBack: TColor;
  LBorder: TColor;
begin
  if FPressed then
    LBack := DesignerGray(75)
  else if FHot then
    LBack := DesignerGray(62)
  else
    LBack := DesignerGray(51);
  if Focused then
    LBorder := DesignerGray(150)
  else
    LBorder := DesignerGray(85);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := LBack;
  Canvas.Pen.Color := LBorder;
  Canvas.Rectangle(ClientRect);
  PaintContent(Rect(1, 1, ClientWidth - 1, ClientHeight - 1));
end;

procedure TThemedGridDesignerButton.PaintContent(const ARect: TRect);
var
  LRect: TRect;
  LText: string;
begin
  LRect := ARect;
  LText := Caption;
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := DesignerGray(230);
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(LRect, LText, [tfCenter, tfVerticalCenter, tfSingleLine, tfEndEllipsis, tfNoPrefix]);
  Canvas.Brush.Style := bsSolid;
end;

procedure TThemedGridDesignerButton.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if (AButton = mbLeft) and CanFocus then
    SetFocus;
  FPressed := AButton = mbLeft;
  Invalidate;
end;

procedure TThemedGridDesignerButton.MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  FPressed := False;
  Invalidate;
  inherited MouseUp(AButton, AShift, AX, AY);
end;

procedure TThemedGridDesignerButton.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  inherited KeyDown(AKey, AShift);
  if (AKey = VK_SPACE) or (AKey = VK_RETURN) then
  begin
    AKey := 0;
    Click;
  end;
end;

constructor TThemedGridDesignerColorButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSelectedColor := clBlack;
  Width := 92;
end;

procedure TThemedGridDesignerColorButton.SetSelectedColor(const AValue: TColor);
begin
  if FSelectedColor = AValue then
    Exit;
  FSelectedColor := AValue;
  Invalidate;
end;

procedure TThemedGridDesignerColorButton.PaintContent(const ARect: TRect);
var
  LSwatch: TRect;
  LText: TRect;
  LCaption: string;
  LSize: Integer;
begin
  LSize := ARect.Height - 10;
  LSwatch := Rect(ARect.Left + 5, ARect.Top + 5, ARect.Left + 5 + LSize, ARect.Top + 5 + LSize);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FSelectedColor;
  Canvas.Pen.Color := DesignerGray(110);
  Canvas.Rectangle(LSwatch);
  LText := Rect(LSwatch.Right + 6, ARect.Top, ARect.Right - 2, ARect.Bottom);
  LCaption := Caption;
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := DesignerGray(230);
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(LText, LCaption, [tfLeft, tfVerticalCenter, tfSingleLine, tfEndEllipsis, tfNoPrefix]);
  Canvas.Brush.Style := bsSolid;
end;

procedure TThemedGridDesignerColorButton.Click;
var
  LDialog: TColorDialog;
begin
  inherited Click;
  LDialog := TColorDialog.Create(nil);
  try
    LDialog.Color := FSelectedColor;
    LDialog.Options := [cdFullOpen];
    if not LDialog.Execute then
      Exit;
    FSelectedColor := LDialog.Color;
    Invalidate;
    if Assigned(FOnColorSelected) then
      FOnColorSelected(Self, FSelectedColor);
  finally
    LDialog.Free;
  end;
end;

constructor TThemedGridDesignerList.Create(AOwner: TComponent; const APixelsPerInch: Integer);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  FPixelsPerInch := APixelsPerInch;
  if FPixelsPerInch <= 0 then
    FPixelsPerInch := Screen.PixelsPerInch;
  FHoverIndex := -1;
  FSelectedIndex := -1;
  FSelectable := True;
  FRowHeight := S(48);
  TabStop := True;
  DoubleBuffered := True;
  Color := DesignerGray(32);
  Font.Name := TStr.FontName;
  Font.Height := -MulDiv(9, FPixelsPerInch, 72);
  Font.Color := DesignerGray(230);
end;

function TThemedGridDesignerList.S(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, FPixelsPerInch, 96);
end;

procedure TThemedGridDesignerList.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  AMessage.Result := DLGC_WANTARROWS;
end;

procedure TThemedGridDesignerList.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TThemedGridDesignerList.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if FHoverIndex <> -1 then
  begin
    FHoverIndex := -1;
    Invalidate;
  end;
end;

function TThemedGridDesignerList.MaxOffset: Integer;
begin
  Result := Max(0, ItemCount * FRowHeight - ClientHeight);
end;

procedure TThemedGridDesignerList.SetOffset(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, MaxOffset);
  if LValue = FOffset then
    Exit;
  FOffset := LValue;
  Invalidate;
end;

procedure TThemedGridDesignerList.EnsureVisible(const AIndex: Integer);
var
  LTop: Integer;
begin
  if AIndex < 0 then
    Exit;
  LTop := AIndex * FRowHeight;
  if LTop < FOffset then
    SetOffset(LTop)
  else if LTop + FRowHeight > FOffset + ClientHeight then
    SetOffset(LTop + FRowHeight - ClientHeight);
end;

function TThemedGridDesignerList.ItemAt(const AY: Integer): Integer;
begin
  if (AY < 0) or (FRowHeight <= 0) then
    Exit(-1);
  Result := (AY + FOffset) div FRowHeight;
  if Result >= ItemCount then
    Result := -1;
end;

procedure TThemedGridDesignerList.DrawEmpty(const ARect: TRect);
begin
end;

procedure TThemedGridDesignerList.DrawLabel(const ARect: TRect; const AText: string; const AColor: TColor);
var
  LRect: TRect;
  LText: string;
begin
  LRect := ARect;
  LText := AText;
  Canvas.Font.Color := AColor;
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(LRect, LText, [tfLeft, tfSingleLine, tfEndEllipsis, tfNoPrefix]);
  Canvas.Brush.Style := bsSolid;
end;

procedure TThemedGridDesignerList.ItemsChanged;
begin
  if FSelectable and (FSelectedIndex >= ItemCount) then
    FSelectedIndex := ItemCount - 1;
  FOffset := EnsureRange(FOffset, 0, MaxOffset);
  FHoverIndex := -1;
  Invalidate;
end;

procedure TThemedGridDesignerList.SetSelectedIndexSilent(const AValue: Integer);
begin
  FSelectedIndex := EnsureRange(AValue, -1, ItemCount - 1);
  EnsureVisible(FSelectedIndex);
  Invalidate;
end;

procedure TThemedGridDesignerList.SetSelectedIndex(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, -1, ItemCount - 1);
  if LValue = FSelectedIndex then
    Exit;
  FSelectedIndex := LValue;
  EnsureVisible(FSelectedIndex);
  Invalidate;
  if Assigned(FOnSelectedIndexChanged) then
    FOnSelectedIndexChanged(Self);
end;

procedure TThemedGridDesignerList.Paint;
var
  I: Integer;
  LRect: TRect;
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);
  Canvas.Font.Assign(Font);
  if ItemCount = 0 then
  begin
    DrawEmpty(ClientRect);
    Exit;
  end;
  for I := FOffset div FRowHeight to ItemCount - 1 do
  begin
    LRect := Rect(0, I * FRowHeight - FOffset, ClientWidth, (I + 1) * FRowHeight - FOffset);
    if LRect.Top >= ClientHeight then
      Break;
    DrawItem(LRect, I, FSelectable and (I = FSelectedIndex), I = FHoverIndex);
  end;
end;

procedure TThemedGridDesignerList.Resize;
begin
  inherited Resize;
  FOffset := EnsureRange(FOffset, 0, MaxOffset);
end;

procedure TThemedGridDesignerList.MouseMove(AShift: TShiftState; AX, AY: Integer);
var
  LIndex: Integer;
begin
  inherited MouseMove(AShift, AX, AY);
  LIndex := ItemAt(AY);
  if LIndex = FHoverIndex then
    Exit;
  FHoverIndex := LIndex;
  Invalidate;
end;

procedure TThemedGridDesignerList.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
var
  LIndex: Integer;
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if CanFocus then
    SetFocus;
  LIndex := ItemAt(AY);
  if FSelectable and (LIndex >= 0) then
    SetSelectedIndex(LIndex);
end;

procedure TThemedGridDesignerList.DblClick;
var
  LPoint: TPoint;
  LIndex: Integer;
begin
  inherited DblClick;
  LPoint := ScreenToClient(Mouse.CursorPos);
  LIndex := ItemAt(LPoint.Y);
  if LIndex < 0 then
    Exit;
  if FSelectable then
    SetSelectedIndex(LIndex);
  if Assigned(FOnItemActivate) then
    FOnItemActivate(Self);
end;

procedure TThemedGridDesignerList.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  inherited KeyDown(AKey, AShift);
  if not FSelectable then
    Exit;
  case AKey of
    VK_UP:
      begin
        SetSelectedIndex(Max(0, FSelectedIndex - 1));
        AKey := 0;
      end;
    VK_DOWN:
      begin
        SetSelectedIndex(Min(ItemCount - 1, FSelectedIndex + 1));
        AKey := 0;
      end;
    VK_RETURN:
      begin
        if Assigned(FOnItemActivate) then
          FOnItemActivate(Self);
        AKey := 0;
      end;
  end;
end;

function TThemedGridDesignerList.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer;
  AMousePos: TPoint): Boolean;
begin
  SetOffset(FOffset - Sign(AWheelDelta) * FRowHeight);
  Result := True;
end;

constructor TThemedGridDesignerRuleList.Create(AOwner: TComponent; const APixelsPerInch: Integer);
begin
  inherited Create(AOwner, APixelsPerInch);
  FItems := TList<TThemedGridFormatConditionModel>.Create;
  RowHeight := S(54);
  Color := DesignerGray(37);
  Font.Color := DesignerGray(230);
end;

destructor TThemedGridDesignerRuleList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TThemedGridDesignerRuleList.SetItems(const AItems: TList<TThemedGridFormatConditionModel>;
  const AColumns: TThemedGridColumnCollection);
var
  I: Integer;
begin
  FItems.Clear;
  if AItems <> nil then
    for I := 0 to AItems.Count - 1 do
      FItems.Add(AItems[I]);
  FColumns := AColumns;
  ItemsChanged;
end;

function TThemedGridDesignerRuleList.ItemCount: Integer;
begin
  Result := FItems.Count;
end;

function TThemedGridDesignerRuleList.ResolveStyleColor(const AItem: TThemedGridFormatConditionModel): TColor;
begin
  Result := DesignerStyleColor(AItem, DesignerGray(80));
end;

function TThemedGridDesignerRuleList.IsMissingColumn(const AColumnName: string): Boolean;
begin
  if AColumnName = '' then
    Exit(False);
  if FColumns = nil then
    Exit(True);
  Result := not DesignerColumnExists(FColumns, AColumnName);
end;

function TThemedGridDesignerRuleList.ResolveDetails(const AItem: TThemedGridFormatConditionModel): string;
var
  LSource: string;
  LTarget: string;
  LStatus: string;
begin
  if AItem = nil then
    Exit('');
  if AItem.ColumnName = '' then
    LSource := TStr.NoColumnDetail
  else
    LSource := AItem.ColumnName;
  if AItem.Scope = TThemedGridFormatConditionScope.Row then
    LTarget := TStr.RowText
  else if AItem.TargetColumnName = '' then
    LTarget := LSource
  else
    LTarget := AItem.TargetColumnName;
  if IsMissingColumn(AItem.ColumnName) or
    ((AItem.Scope <> TThemedGridFormatConditionScope.Row) and IsMissingColumn(AItem.TargetColumnName)) then
    LStatus := TStr.MissingColumnText
  else
    LStatus := TStr.OkText;
  Result := Format(TStr.DetailFormat, [LStatus, LSource, LTarget, DesignerOperatorName(AItem.Operator),
    DesignerValueText(AItem.Value)]);
end;

procedure TThemedGridDesignerRuleList.DrawItem(const ARect: TRect; const AIndex: Integer;
  const ASelected, AHot: Boolean);
var
  LItem: TThemedGridFormatConditionModel;
  LBack: TColor;
  LFore: TColor;
  LBox: TRect;
  LTitle: string;
begin
  LItem := FItems[AIndex];
  if ASelected then
    LBack := DesignerGray(62)
  else if AHot then
    LBack := DesignerGray(50)
  else
    LBack := Color;
  if (LItem <> nil) and LItem.Enabled then
    LFore := Font.Color
  else
    LFore := DesignerGray(130);
  Canvas.Brush.Color := LBack;
  Canvas.FillRect(ARect);
  LBox := Rect(ARect.Left + S(8), ARect.Top + S(12), ARect.Left + S(8) + S(22), ARect.Top + S(12) + S(22));
  Canvas.Brush.Color := ResolveStyleColor(LItem);
  Canvas.Pen.Color := DesignerGray(90);
  Canvas.Rectangle(LBox);
  if (LItem <> nil) and (LItem.Name <> '') then
    LTitle := LItem.Name
  else
    LTitle := TStr.DefaultRuleName + ' ' + IntToStr(AIndex + 1);
  DrawLabel(Rect(ARect.Left + S(40), ARect.Top + S(7), ARect.Right - S(8), ARect.Top + S(27)), LTitle, LFore);
  DrawLabel(Rect(ARect.Left + S(40), ARect.Top + S(28), ARect.Right - S(8), ARect.Top + S(46)),
    ResolveDetails(LItem), DesignerGray(170));
  Canvas.Pen.Color := DesignerGray(48);
  Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
  Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
end;

constructor TThemedGridDesignerValidationList.Create(AOwner: TComponent; const APixelsPerInch: Integer);
begin
  inherited Create(AOwner, APixelsPerInch);
  FItems := TList<TThemedGridDesignerIssueRow>.Create;
  Selectable := False;
  RowHeight := S(44);
  TabStop := False;
end;

destructor TThemedGridDesignerValidationList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TThemedGridDesignerValidationList.SetResult(const AResult: TThemedGridFormatConditionValidationResult);
var
  I: Integer;
  LIssue: TThemedGridFormatConditionValidationIssue;
  LRow: TThemedGridDesignerIssueRow;
  LName: string;
  LSource: string;
  LTarget: string;
begin
  FItems.Clear;
  if AResult <> nil then
    for I := 0 to AResult.Issues.Count - 1 do
    begin
      LIssue := AResult.Issues[I];
      if LIssue = nil then
        Continue;
      if LIssue.Name = '' then
        LName := TStr.DefaultRuleName + ' ' + IntToStr(LIssue.Index)
      else
        LName := LIssue.Name;
      if LIssue.ColumnName = '' then
        LSource := TStr.DashText
      else
        LSource := LIssue.ColumnName;
      if LIssue.TargetColumnName = '' then
        LTarget := TStr.RowText
      else
        LTarget := LIssue.TargetColumnName;
      LRow.Title := LIssue.Message;
      LRow.Details := Format(TStr.IssueDetailFormat, [LName, LSource, LTarget]);
      LRow.IsError := LIssue.IsError;
      FItems.Add(LRow);
    end;
  ItemsChanged;
end;

function TThemedGridDesignerValidationList.ItemCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TThemedGridDesignerValidationList.DrawEmpty(const ARect: TRect);
var
  LRect: TRect;
  LText: string;
begin
  LRect := ARect;
  LText := TStr.NoIssues;
  Canvas.Font.Color := TColor($0096DC96);
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(LRect, LText, [tfCenter, tfVerticalCenter, tfSingleLine, tfNoPrefix]);
  Canvas.Brush.Style := bsSolid;
end;

procedure TThemedGridDesignerValidationList.DrawItem(const ARect: TRect; const AIndex: Integer;
  const ASelected, AHot: Boolean);
var
  LRow: TThemedGridDesignerIssueRow;
  LBack: TColor;
  LMarker: TColor;
begin
  LRow := FItems[AIndex];
  if AHot then
    LBack := DesignerGray(45)
  else
    LBack := Color;
  if LRow.IsError then
    LMarker := TColor($005050DC)
  else
    LMarker := TColor($0046AADC);
  Canvas.Brush.Color := LBack;
  Canvas.FillRect(ARect);
  Canvas.Brush.Color := LMarker;
  Canvas.FillRect(Rect(ARect.Left + S(4), ARect.Top + S(8), ARect.Left + S(8), ARect.Bottom - S(8)));
  DrawLabel(Rect(ARect.Left + S(14), ARect.Top + S(5), ARect.Right - S(4), ARect.Top + S(23)), LRow.Title,
    DesignerGray(225));
  DrawLabel(Rect(ARect.Left + S(14), ARect.Top + S(24), ARect.Right - S(4), ARect.Top + S(40)), LRow.Details,
    DesignerGray(160));
  Canvas.Pen.Color := DesignerGray(48);
  Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
  Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
end;

constructor TThemedGridDesignerPresetList.Create(AOwner: TComponent; const APixelsPerInch: Integer);
begin
  inherited Create(AOwner, APixelsPerInch);
  FItems := TList<TThemedGridDesignerPreset>.Create;
  RowHeight := S(48);
end;

destructor TThemedGridDesignerPresetList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TThemedGridDesignerPresetList.SetItems(const AItems: TList<TThemedGridDesignerPreset>);
var
  I: Integer;
begin
  FItems.Clear;
  if AItems <> nil then
    for I := 0 to AItems.Count - 1 do
      if AItems[I] <> nil then
        FItems.Add(AItems[I]);
  ItemsChanged;
  if FItems.Count > 0 then
    SetSelectedIndexSilent(0)
  else
    SetSelectedIndexSilent(-1);
end;

function TThemedGridDesignerPresetList.GetSelectedPreset: TThemedGridDesignerPreset;
begin
  if (SelectedIndex < 0) or (SelectedIndex >= FItems.Count) then
    Exit(nil);
  Result := FItems[SelectedIndex];
end;

function TThemedGridDesignerPresetList.ItemCount: Integer;
begin
  Result := FItems.Count;
end;

function TThemedGridDesignerPresetList.ResolveMarkerColor(const AItem: TThemedGridDesignerPreset): TColor;
begin
  if AItem = nil then
    Exit(DesignerGray(90));
  Result := DesignerStyleColor(AItem.Model, DesignerGray(90));
end;

procedure TThemedGridDesignerPresetList.DrawEmpty(const ARect: TRect);
var
  LRect: TRect;
  LText: string;
begin
  LRect := ARect;
  LText := TStr.NoPresets;
  Canvas.Font.Color := DesignerGray(150);
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(LRect, LText, [tfCenter, tfVerticalCenter, tfSingleLine, tfNoPrefix]);
  Canvas.Brush.Style := bsSolid;
end;

procedure TThemedGridDesignerPresetList.DrawItem(const ARect: TRect; const AIndex: Integer;
  const ASelected, AHot: Boolean);
var
  LItem: TThemedGridDesignerPreset;
  LBack: TColor;
  LMarker: TRect;
begin
  LItem := FItems[AIndex];
  if ASelected then
    LBack := DesignerGray(62)
  else if AHot then
    LBack := DesignerGray(45)
  else
    LBack := Color;
  Canvas.Brush.Color := LBack;
  Canvas.FillRect(ARect);
  LMarker := Rect(ARect.Left + S(7), ARect.Top + S(11), ARect.Left + S(7) + S(18), ARect.Top + S(11) + S(18));
  Canvas.Brush.Color := ResolveMarkerColor(LItem);
  Canvas.Pen.Color := DesignerGray(85);
  Canvas.Rectangle(LMarker);
  DrawLabel(Rect(ARect.Left + S(34), ARect.Top + S(6), ARect.Right - S(6), ARect.Top + S(24)), LItem.Name,
    DesignerGray(230));
  DrawLabel(Rect(ARect.Left + S(34), ARect.Top + S(25), ARect.Right - S(6), ARect.Top + S(41)),
    LItem.Description, DesignerGray(160));
  Canvas.Pen.Color := DesignerGray(48);
  Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
  Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
end;

end.

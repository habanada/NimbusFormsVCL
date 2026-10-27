unit NimbusForms.HexEditor.InspectorControl;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Inspector,
  NimbusForms.HexEditor.RenderSurface;

type
  TCustomThemedHexInspector = class(TCustomControl, IThemeAware)
  private
    FTheme: THexTheme;
    FRows: TArray<TInspectorRow>;
    FDataSource: IHexDataSource;
    FOffset: Int64;
    FBigEndian: Boolean;
    FHoverRow: Integer;
    FNameColumnWidth: Integer;
    FShowHeader: Boolean;
    function HeaderHeight: Integer;
    function RowHeight: Integer;
    function RowAt(const AY: Integer): Integer;
    function ToggleRect: TRect;
    procedure Rebuild;
    procedure SetBigEndian(const AValue: Boolean);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    property NameColumnWidth: Integer read FNameColumnWidth write FNameColumnWidth;
    property ShowHeader: Boolean read FShowHeader write FShowHeader;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure ShowOffset(const ADataSource: IHexDataSource; const AOffset: Int64);
    procedure Clear;
    property BigEndian: Boolean read FBigEndian write SetBigEndian;
  end;

  TThemedHexInspector = class(TCustomThemedHexInspector)
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property Visible;
    property BigEndian;
    property NameColumnWidth;
    property ShowHeader;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Manager;

const
  CHeaderLabel = 'Inspector';
  CEndianLittle = 'LE';
  CEndianBig = 'BE';
  CHorizontalPadding = 8;

constructor TCustomThemedHexInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csOpaque];
  Width := 220;
  Height := 320;
  DoubleBuffered := True;
  FTheme := THexTheme.FromPalette(ThemeManager.CurrentTheme);
  FOffset := -1;
  FHoverRow := -1;
  FNameColumnWidth := 90;
  FShowHeader := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  ThemeManager.RegisterAware(Self);
end;

destructor TCustomThemedHexInspector.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  FTheme.Free;
  inherited Destroy;
end;

procedure TCustomThemedHexInspector.ApplyTheme(const APalette: TThemePalette);
begin
  FTheme.Free;
  FTheme := THexTheme.FromPalette(APalette);
  Invalidate;
end;

procedure TCustomThemedHexInspector.ShowOffset(const ADataSource: IHexDataSource;
  const AOffset: Int64);
begin
  FDataSource := ADataSource;
  FOffset := AOffset;
  Rebuild;
  Invalidate;
end;

procedure TCustomThemedHexInspector.Clear;
begin
  FDataSource := nil;
  FOffset := -1;
  SetLength(FRows, 0);
  Invalidate;
end;

procedure TCustomThemedHexInspector.Rebuild;
begin
  if (FDataSource = nil) or (FOffset < 0) then
    SetLength(FRows, 0)
  else
    FRows := THexDataInspector.Inspect(FDataSource, FOffset, FBigEndian);
end;

procedure TCustomThemedHexInspector.SetBigEndian(const AValue: Boolean);
begin
  if FBigEndian = AValue then
    Exit;
  FBigEndian := AValue;
  Rebuild;
  Invalidate;
end;

function TCustomThemedHexInspector.HeaderHeight: Integer;
begin
  if FShowHeader then
    Result := RowHeight + 4
  else
    Result := 0;
end;

function TCustomThemedHexInspector.RowHeight: Integer;
begin
  Result := Max(18, Abs(Font.Height) + 10);
end;

function TCustomThemedHexInspector.RowAt(const AY: Integer): Integer;
begin
  if AY < HeaderHeight then
    Exit(-1);
  Result := (AY - HeaderHeight) div RowHeight;
  if (Result < 0) or (Result >= Length(FRows)) then
    Result := -1;
end;

function TCustomThemedHexInspector.ToggleRect: TRect;
var
  LWidth: Integer;
begin
  LWidth := 34;
  Result := Rect(ClientWidth - LWidth - CHorizontalPadding, 2,
    ClientWidth - CHorizontalPadding, HeaderHeight - 2);
end;

procedure TCustomThemedHexInspector.Paint;
var
  LSurface: IHexRenderSurface;
  LHeader, LRowRect, LNameRect, LValueRect, LToggle: TRect;
  I, LY: Integer;
  LBack: TThemeColor;
begin
  LSurface := TGdiHexRenderSurface.Create(Canvas);
  LSurface.SetFont(Font);

  LSurface.FillRectangle(FTheme.BackColor, ClientRect);

  if FShowHeader then
  begin
    LHeader := Rect(0, 0, ClientWidth, HeaderHeight);
    LSurface.FillRectangle(FTheme.HeaderBackColor, LHeader);
    LSurface.DrawLine(FTheme.GridLineColor, 0, LHeader.Bottom - 1, ClientWidth, LHeader.Bottom - 1);
    LSurface.DrawText(CHeaderLabel, Rect(CHorizontalPadding, 0, ClientWidth, HeaderHeight),
      FTheme.HeaderForeColor, [htfVCenter, htfLeft, htfNoPadding]);
    LToggle := ToggleRect;
    LSurface.FillRoundedRectangle(FTheme.ActiveColumnBackColor, LToggle, 3);
    if FBigEndian then
      LSurface.DrawText(CEndianBig, LToggle, FTheme.HeaderForeColor, [htfVCenter, htfHCenter, htfNoPadding])
    else
      LSurface.DrawText(CEndianLittle, LToggle, FTheme.HeaderForeColor, [htfVCenter, htfHCenter, htfNoPadding]);
  end;

  for I := 0 to High(FRows) do
  begin
    LY := HeaderHeight + I * RowHeight;
    LRowRect := Rect(0, LY, ClientWidth, LY + RowHeight);
    if I = FHoverRow then
      LBack := FTheme.CursorRowBackColor
    else if (I and 1) = 1 then
      LBack := FTheme.AlternateRowBackColor
    else
      LBack := FTheme.BackColor;
    LSurface.FillRectangle(LBack, LRowRect);

    LNameRect := Rect(CHorizontalPadding, LY, FNameColumnWidth, LY + RowHeight);
    LValueRect := Rect(FNameColumnWidth + CHorizontalPadding, LY,
      ClientWidth - CHorizontalPadding, LY + RowHeight);
    LSurface.DrawText(FRows[I].Name, LNameRect, FTheme.GutterForeColor, [htfVCenter, htfLeft, htfNoPadding]);
    LSurface.DrawText(FRows[I].Value, LValueRect, FTheme.CellForeColor, [htfVCenter, htfLeft, htfNoPadding]);
    LSurface.DrawLine(FTheme.GridLineColor, FNameColumnWidth, LY, FNameColumnWidth, LY + RowHeight);
  end;

  LSurface.DrawRectangle(FTheme.BorderColor, Rect(0, 0, ClientWidth - 1, ClientHeight - 1));
end;

procedure TCustomThemedHexInspector.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LRow: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  LRow := RowAt(Y);
  if LRow <> FHoverRow then
  begin
    FHoverRow := LRow;
    Invalidate;
  end;
end;

procedure TCustomThemedHexInspector.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and FShowHeader and PtInRect(ToggleRect, Point(X, Y)) then
    SetBigEndian(not FBigEndian);
end;

procedure TCustomThemedHexInspector.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoverRow <> -1 then
  begin
    FHoverRow := -1;
    Invalidate;
  end;
end;

procedure TCustomThemedHexInspector.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

end.

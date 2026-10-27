unit NimbusForms.HexEditor.BookmarkList;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.Bookmarks,
  NimbusForms.HexEditor.ScrollBar,
  NimbusForms.HexEditor.RenderSurface;

type
  THexBookmarkEvent = procedure(Sender: TObject; const AOffset: Int64) of object;

  TBookmarkRow = record
    Offset: Int64;
    Name: string;
    HasColor: Boolean;
    Color: TThemeColor;
  end;

  TCustomThemedHexBookmarkList = class(TCustomControl, IThemeAware)
  private
    FTheme: THexTheme;
    FRenderSurface: IHexRenderSurface;
    FItems: TList<TBookmarkRow>;
    FScrollBar: THexScrollBar;
    FScrollDragging: Boolean;
    FTopRow: Integer;
    FSelectedIndex: Integer;
    FHoverIndex: Integer;
    FHoverRemove: Integer;
    FOnActivated: THexBookmarkEvent;
    FOnRemoveRequested: THexBookmarkEvent;
    FOnSelected: THexBookmarkEvent;
    function RowHeight: Integer;
    function VisibleRows: Integer;
    function RowAt(const AY: Integer): Integer;
    function RemoveButtonRect(const ARowTop: Integer): TRect;
    function ContentWidth: Integer;
    procedure UpdateScrollBar;
    procedure SetTopRow(const AValue: Integer);
    procedure DoActivated(const AIndex: Integer);
    procedure DoRemoveRequested(const AIndex: Integer);
    procedure DoSelected(const AIndex: Integer);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure SetBookmarks(const AManager: THexBookmarkManager);
    procedure ClearBookmarks;
    function SelectBookmark(const AOffset: Int64): Boolean;
    function SelectedOffset: Int64;
    property SelectedIndex: Integer read FSelectedIndex;
    property OnBookmarkActivated: THexBookmarkEvent read FOnActivated write FOnActivated;
    property OnBookmarkRemoveRequested: THexBookmarkEvent read FOnRemoveRequested write FOnRemoveRequested;
    property OnBookmarkSelected: THexBookmarkEvent read FOnSelected write FOnSelected;
  end;

  TThemedHexBookmarkList = class(TCustomThemedHexBookmarkList)
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnBookmarkActivated;
    property OnBookmarkRemoveRequested;
    property OnBookmarkSelected;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Manager;

const
  CRemoveButtonSize = 18;
  CHorizontalPadding = 8;
  CRemoveGlyph = #$00D7;

constructor TCustomThemedHexBookmarkList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  Width := 240;
  Height := 320;
  TabStop := True;
  DoubleBuffered := True;
  FTheme := THexTheme.FromPalette(ThemeManager.CurrentTheme);
  FRenderSurface := TGdiPlusHexRenderSurface.Create;
  FItems := TList<TBookmarkRow>.Create;
  FScrollBar := THexScrollBar.Create(True);
  FSelectedIndex := -1;
  FHoverIndex := -1;
  FHoverRemove := -1;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  ThemeManager.RegisterAware(Self);
end;

destructor TCustomThemedHexBookmarkList.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  FScrollBar.Free;
  FItems.Free;
  if FRenderSurface <> nil then FRenderSurface.EndRender;
  FRenderSurface := nil;
  FTheme.Free;
  inherited Destroy;
end;

procedure TCustomThemedHexBookmarkList.ApplyTheme(const APalette: TThemePalette);
begin
  FTheme.Free;
  FTheme := THexTheme.FromPalette(APalette);
  Invalidate;
end;

procedure TCustomThemedHexBookmarkList.SetBookmarks(const AManager: THexBookmarkManager);
var
  LBookmark: THexBookmark;
  LRow: TBookmarkRow;
begin
  FItems.Clear;
  if AManager <> nil then
    for LBookmark in AManager.Values do
    begin
      if LBookmark = nil then
        Continue;
      LRow.Offset := LBookmark.Offset;
      LRow.Name := LBookmark.Name;
      LRow.HasColor := LBookmark.HasColor;
      LRow.Color := LBookmark.Color;
      FItems.Add(LRow);
    end;
  FItems.Sort(TComparer<TBookmarkRow>.Construct(
    function(const L, R: TBookmarkRow): Integer
    begin
      if L.Offset < R.Offset then
        Result := -1
      else if L.Offset > R.Offset then
        Result := 1
      else
        Result := 0;
    end));
  if FSelectedIndex >= FItems.Count then
    FSelectedIndex := FItems.Count - 1;
  FTopRow := 0;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedHexBookmarkList.ClearBookmarks;
begin
  FItems.Clear;
  FSelectedIndex := -1;
  FTopRow := 0;
  UpdateScrollBar;
  Invalidate;
end;

function TCustomThemedHexBookmarkList.SelectBookmark(const AOffset: Int64): Boolean;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Offset = AOffset then
    begin
      FSelectedIndex := I;
      if I < FTopRow then
        SetTopRow(I)
      else if I >= FTopRow + VisibleRows then
        SetTopRow(I - VisibleRows + 1);
      Invalidate;
      Exit(True);
    end;
  Result := False;
end;

function TCustomThemedHexBookmarkList.SelectedOffset: Int64;
begin
  if (FSelectedIndex >= 0) and (FSelectedIndex < FItems.Count) then
    Result := FItems[FSelectedIndex].Offset
  else
    Result := -1;
end;

function TCustomThemedHexBookmarkList.RowHeight: Integer;
begin
  Result := Max(CRemoveButtonSize + 6, Abs(Font.Height) + 12);
end;

function TCustomThemedHexBookmarkList.VisibleRows: Integer;
begin
  Result := Max(1, ClientHeight div RowHeight);
end;

function TCustomThemedHexBookmarkList.ContentWidth: Integer;
begin
  if FScrollBar.Visible then
    Result := ClientWidth - FScrollBar.Thickness
  else
    Result := ClientWidth;
end;

function TCustomThemedHexBookmarkList.RowAt(const AY: Integer): Integer;
begin
  Result := FTopRow + (AY div RowHeight);
  if (Result < 0) or (Result >= FItems.Count) then
    Result := -1;
end;

function TCustomThemedHexBookmarkList.RemoveButtonRect(const ARowTop: Integer): TRect;
begin
  Result := Rect(ContentWidth - CRemoveButtonSize - CHorizontalPadding,
    ARowTop + (RowHeight - CRemoveButtonSize) div 2,
    ContentWidth - CHorizontalPadding,
    ARowTop + (RowHeight - CRemoveButtonSize) div 2 + CRemoveButtonSize);
end;

procedure TCustomThemedHexBookmarkList.UpdateScrollBar;
begin
  if not HandleAllocated then
    Exit;
  FScrollBar.Configure(FItems.Count, VisibleRows, FTopRow);
  if FScrollBar.Visible then
    FScrollBar.SetBounds(Rect(ClientWidth - FScrollBar.Thickness, 0, ClientWidth, ClientHeight))
  else
    FScrollBar.SetBounds(Rect(0, 0, 0, 0));
end;

procedure TCustomThemedHexBookmarkList.SetTopRow(const AValue: Integer);
var
  LMax, LNew: Integer;
begin
  LMax := Max(0, FItems.Count - VisibleRows);
  LNew := AValue;
  if LNew < 0 then
    LNew := 0;
  if LNew > LMax then
    LNew := LMax;
  if LNew <> FTopRow then
  begin
    FTopRow := LNew;
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TCustomThemedHexBookmarkList.DoActivated(const AIndex: Integer);
begin
  if Assigned(FOnActivated) and (AIndex >= 0) and (AIndex < FItems.Count) then
    FOnActivated(Self, FItems[AIndex].Offset);
end;

procedure TCustomThemedHexBookmarkList.DoRemoveRequested(const AIndex: Integer);
begin
  if Assigned(FOnRemoveRequested) and (AIndex >= 0) and (AIndex < FItems.Count) then
    FOnRemoveRequested(Self, FItems[AIndex].Offset);
end;

procedure TCustomThemedHexBookmarkList.DoSelected(const AIndex: Integer);
begin
  if Assigned(FOnSelected) and (AIndex >= 0) and (AIndex < FItems.Count) then
    FOnSelected(Self, FItems[AIndex].Offset);
end;

procedure TCustomThemedHexBookmarkList.Paint;
var
  I, LRowIndex, LY, LRowH, LVisible: Integer;
  LRowRect, LMarker, LTextRect, LRemove: TRect;
  LBack, LMarkerColor: TThemeColor;
  LRow: TBookmarkRow;
  LText: string;
begin
  FRenderSurface.BeginRender(Canvas);
  try
    FRenderSurface.SetFont(Font);
    FRenderSurface.FillRectangle(FTheme.BackColor, ClientRect);

    LRowH := RowHeight;
    LVisible := VisibleRows + 1;
    for I := 0 to LVisible - 1 do
    begin
      LRowIndex := FTopRow + I;
      if LRowIndex >= FItems.Count then
        Break;
      LRow := FItems[LRowIndex];
      LY := I * LRowH;
      LRowRect := Rect(0, LY, ContentWidth, LY + LRowH);

      if LRowIndex = FSelectedIndex then
        LBack := FTheme.SelectionBackColor
      else if LRowIndex = FHoverIndex then
        LBack := FTheme.CursorRowBackColor
      else if (LRowIndex and 1) = 1 then
        LBack := FTheme.AlternateRowBackColor
      else
        LBack := FTheme.BackColor;
      FRenderSurface.FillRectangle(LBack, LRowRect);

      if LRow.HasColor then
        LMarkerColor := LRow.Color
      else
        LMarkerColor := FTheme.BookmarkColor;
      LMarker := Rect(CHorizontalPadding, LY + 5, CHorizontalPadding + 5, LY + LRowH - 5);
      FRenderSurface.FillRoundedRectangle(LMarkerColor, LMarker, 2);

      if LRow.Name <> '' then
        LText := Format('%s  -  %s', [IntToHex(LRow.Offset, 8), LRow.Name])
      else
        LText := IntToHex(LRow.Offset, 8);
      LTextRect := Rect(CHorizontalPadding + 12, LY,
        ContentWidth - CRemoveButtonSize - CHorizontalPadding * 2, LY + LRowH);
      if LRowIndex = FSelectedIndex then
        FRenderSurface.DrawText(LText, LTextRect, FTheme.SelectionForeColor, [htfVCenter, htfLeft, htfNoPadding])
      else
        FRenderSurface.DrawText(LText, LTextRect, FTheme.ForeColor, [htfVCenter, htfLeft, htfNoPadding]);

      LRemove := RemoveButtonRect(LY);
      if LRowIndex = FHoverRemove then
        FRenderSurface.FillRoundedRectangle(FTheme.ModifiedByteBackColor, LRemove, 3);
      if (LRowIndex = FHoverIndex) or (LRowIndex = FSelectedIndex) then
        FRenderSurface.DrawText(CRemoveGlyph, LRemove, FTheme.GutterForeColor,
          [htfVCenter, htfHCenter, htfNoPadding]);
    end;

    FScrollBar.Paint(FRenderSurface, FTheme);
    FRenderSurface.DrawRectangle(FTheme.BorderColor, Rect(0, 0, ClientWidth - 1, ClientHeight - 1));
  finally
    FRenderSurface.EndRender;
  end;
end;

procedure TCustomThemedHexBookmarkList.Resize;
begin
  inherited Resize;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedHexBookmarkList.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if FItems.Count = 0 then
    Exit;
  case Key of
    VK_UP:
      if FSelectedIndex > 0 then
      begin
        Dec(FSelectedIndex);
        SelectBookmark(FItems[FSelectedIndex].Offset);
        DoSelected(FSelectedIndex);
        Key := 0;
      end;
    VK_DOWN:
      if FSelectedIndex < FItems.Count - 1 then
      begin
        Inc(FSelectedIndex);
        SelectBookmark(FItems[FSelectedIndex].Offset);
        DoSelected(FSelectedIndex);
        Key := 0;
      end;
    VK_RETURN:
      begin
        DoActivated(FSelectedIndex);
        Key := 0;
      end;
    VK_DELETE:
      begin
        DoRemoveRequested(FSelectedIndex);
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedHexBookmarkList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LRow, LRemove: Integer;
  LRowTop: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FScrollDragging then
  begin
    SetTopRow(FScrollBar.DragTo(X, Y));
    Exit;
  end;
  if FScrollBar.Visible and PtInRect(FScrollBar.Bounds, Point(X, Y)) then
  begin
    if (FHoverIndex <> -1) or (FHoverRemove <> -1) then
    begin
      FHoverIndex := -1;
      FHoverRemove := -1;
      Invalidate;
    end;
    Exit;
  end;
  LRow := RowAt(Y);
  LRemove := -1;
  if LRow >= 0 then
  begin
    LRowTop := (LRow - FTopRow) * RowHeight;
    if PtInRect(RemoveButtonRect(LRowTop), Point(X, Y)) then
      LRemove := LRow;
  end;
  if (LRow <> FHoverIndex) or (LRemove <> FHoverRemove) then
  begin
    FHoverIndex := LRow;
    FHoverRemove := LRemove;
    Invalidate;
  end;
end;

procedure TCustomThemedHexBookmarkList.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LRow, LRowTop: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if CanFocus then
    SetFocus;
  if Button <> mbLeft then
    Exit;
  if FScrollBar.Visible and PtInRect(FScrollBar.Bounds, Point(X, Y)) then
  begin
    case FScrollBar.HitTest(X, Y) of
      sspThumb:
        begin
          FScrollBar.BeginDrag(X, Y);
          FScrollDragging := True;
        end;
      sspTrackBefore: SetTopRow(FScrollBar.PageStep(False));
      sspTrackAfter: SetTopRow(FScrollBar.PageStep(True));
    end;
    Exit;
  end;
  LRow := RowAt(Y);
  if LRow < 0 then
    Exit;
  LRowTop := (LRow - FTopRow) * RowHeight;
  if PtInRect(RemoveButtonRect(LRowTop), Point(X, Y)) then
  begin
    DoRemoveRequested(LRow);
    Exit;
  end;
  FSelectedIndex := LRow;
  DoSelected(LRow);
  Invalidate;
end;

procedure TCustomThemedHexBookmarkList.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FScrollDragging then
  begin
    FScrollBar.EndDrag;
    FScrollDragging := False;
    Invalidate;
  end;
end;

function TCustomThemedHexBookmarkList.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  SetTopRow(FTopRow - (WheelDelta div 120) * 3);
  Result := True;
end;

procedure TCustomThemedHexBookmarkList.DblClick;
begin
  inherited DblClick;
  if FSelectedIndex >= 0 then
    DoActivated(FSelectedIndex);
end;

procedure TCustomThemedHexBookmarkList.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if (FHoverIndex <> -1) or (FHoverRemove <> -1) then
  begin
    FHoverIndex := -1;
    FHoverRemove := -1;
    Invalidate;
  end;
end;

procedure TCustomThemedHexBookmarkList.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

end.

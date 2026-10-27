unit NimbusForms.HexEditor.Control;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.ExtCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Options,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Bookmarks,
  NimbusForms.HexEditor.Search,
  NimbusForms.HexEditor.SearchService,
  NimbusForms.HexEditor.RuleEngine,
  NimbusForms.HexEditor.Pieces,
  NimbusForms.HexEditor.Document,
  NimbusForms.HexEditor.Session,
  NimbusForms.HexEditor.Patch,
  NimbusForms.HexEditor.RenderSurface,
  NimbusForms.HexEditor.RenderContext,
  NimbusForms.HexEditor.ScrollBar,
  NimbusForms.HexEditor.Tooltip,
  NimbusForms.HexEditor.Undo,
  NimbusForms.HexEditor.Renderers,
  NimbusForms.HexEditor.FindReplaceTypes,
  NimbusForms.HexEditor.FindReplaceAdapter;

type
  THexByteTooltipEvent = procedure(Sender: TObject; const AOffset: Int64;
    const AValue: Byte; var AText: string; var ACancel: Boolean) of object;

  TCustomThemedHexEditor = class(TCustomControl, IThemeAware)
  private
    FRenderer: THexRenderer;
    FOptions: THexEditorOptions;
    FTheme: THexTheme;
    FDataSource: IHexDataSource;
    FSelection: THexSelection;
    FBookmarks: THexBookmarkManager;
    FTopRow: Int64;
    FCursorOffset: Int64;
    FHoverOffset: Int64;
    FActiveEditArea: THexHitArea;
    FIsHighNibble: Boolean;
    FInsertMode: Boolean;
    FSelectionAnchor: Int64;
    FDragging: Boolean;
    FRowHeightCache: Integer;
    FModified: TDictionary<Int64, Boolean>;
    FDocument: THexDocument;
    FUndoManager: TUndoManager;
    FSearchMatches: TObjectList<THexSearchMatch>;
    FActiveMatchIndex: Integer;
    FHScroll: Integer;
    FVScrollBar: THexScrollBar;
    FHScrollBar: THexScrollBar;
    FScrollDrag: THexScrollBar;
    FOnCursorChange: TNotifyEvent;
    FOnSelectionChange: TNotifyEvent;
    FOnModifiedChange: TNotifyEvent;
    FOnUndoRedoStateChange: TNotifyEvent;
    FOnEditModeChange: TNotifyEvent;
    FOnSearchChange: TNotifyEvent;
    FOnBookmarksChange: TNotifyEvent;
    FOnDataSourceChange: TNotifyEvent;
    FOnByteTooltip: THexByteTooltipEvent;
    FTooltipTimer: TTimer;
    FTooltipControl: TThemedHexTooltip;
    FTooltipOffset: Int64;
    FTooltipMousePos: TPoint;
    FFindReplaceHost: IHexFindReplaceHost;
    FFindReplace: THexFindReplaceAdapter;
    function GetFindReplace: THexFindReplaceAdapter;
    function GetDataLength: Int64;
    function GetHasSelection: Boolean;
    function GetSelectionStart: Int64;
    function GetSelectionLength: Int64;
    procedure TooltipTimerFire(Sender: TObject);
    procedure ScheduleTooltip(const AOffset: Int64; const AX, AY: Integer);
    procedure CancelTooltip;
    procedure DoCursorChange;
    procedure DoSelectionChange;
    procedure DoModifiedChange;
    procedure DoUndoRedoStateChange;
    procedure DoEditModeChange;
    procedure DoSearchChange;
    procedure DoBookmarksChange;
    procedure DoDataSourceChange;
    procedure SetInsertMode(const AValue: Boolean);
    procedure SetActiveEditArea(const AValue: THexHitArea);
    procedure NavigateToActiveMatch;
    function GatherBookmarks: TObjectList<THexBookmarkData>;
    procedure RestoreBookmarks(const ABookmarks: TObjectList<THexBookmarkData>);
    procedure RestoreFromSession(const ASession: THexSessionData);
    procedure UpdateHScrollBar;
    procedure SetHScroll(const AValue: Integer);
    function AcquireContentWidth: Integer;
    procedure CopySelection(const ADelete: Boolean);
    procedure PasteClipboard;
    function CanEdit: Boolean;
    function ReadByteAt(const AOffset: Int64; out AValue: Byte): Boolean;
    procedure MarkModified(const AOffset: Int64);
    procedure ShiftModifiedAfterInsert(const AOffset, ACount: Int64);
    procedure ShiftModifiedAfterDelete(const AOffset, ACount: Int64);
    procedure ApplyOverwrite(const AOffset: Int64; const ANewData: TBytes; const ARecord: Boolean);
    procedure ApplyInsert(const AOffset: Int64; const AData: TBytes; const ARecord: Boolean);
    procedure ApplyDelete(const AOffset, ALength: Int64; const ARecord: Boolean);
    procedure InputHexDigit(const ADigit: Byte);
    procedure InputAsciiByte(const AValue: Byte);
    procedure DeleteSelectionOrByte(const ABackspace: Boolean);
    procedure UpdateScrollBar;
    procedure UpdateScrollbars;
    function ContentRect: TRect;
    function PointInScrollBars(const AX, AY: Integer): THexScrollBar;
    procedure SetTopRow(const AValue: Int64);
    function TotalRows: Int64;
    function VisibleRows: Integer;
    function AcquireMetrics: THexRenderMetrics;
    function EffectiveGroupSize: Integer;
    function HitTest(const AX, AY: Integer): THexHitInfo;
    procedure EnsureCursorVisible;
    procedure SetCursorOffset(const AValue: Int64);
    function ClampOffset(const AValue: Int64): Int64;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function BuildTooltipText(const AOffset: Int64): string; virtual;
    procedure DoShowTooltip(const AText: string; const AScreenPos: TPoint); virtual;
    procedure DoHideTooltip; virtual;
    property Options: THexEditorOptions read FOptions;
    property CursorOffset: Int64 read FCursorOffset write SetCursorOffset;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure LoadBytes(const AData: TBytes);
    procedure LoadFromDataSource(const ADataSource: IHexDataSource);
    procedure Clear;
    procedure LoadDocument(const ADocument: THexDocument);
    procedure SaveProjectToFile(const AFilePath: string);
    procedure LoadProjectFromFile(const AFilePath: string);
    procedure SaveSessionToFile(const AFilePath: string);
    procedure LoadSessionFromFile(const AFilePath: string);
    procedure Undo;
    procedure Redo;
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    procedure Search(const AText: string; const AKind: THexSearchKind);
    procedure SearchRule(const ARule: THexSearchRule);
    function FindNext: Boolean;
    function FindPrevious: Boolean;
    function ReadBytes(const AOffset: Int64; const ACount: Integer): TBytes;
    function InsertBytes(const AOffset: Int64; const AData: TBytes): Boolean;
    function DeleteBytes(const AOffset, ALength: Int64): Boolean;
    procedure ShowFindDialog;
    procedure ShowReplaceDialog;
    function FindReplaceNext: Boolean;
    function FindReplacePrevious: Boolean;
    procedure ClearSearch;
    function SearchMatchCount: Integer;
    procedure GotoOffset(const AOffset: Int64);
    procedure SelectRange(const AStart, ALength: Int64);
    procedure ToggleBookmark(const AOffset: Int64);
    function CreatePatch: THexPatchFile;
    procedure SavePatch(const AFilePath: string);
    procedure ApplyPatch(const APatch: THexPatchFile);
    function ReadAllBytes: TBytes;
    function GetModifiedCount: Integer;
    property InsertMode: Boolean read FInsertMode write SetInsertMode;
    property ActiveEditArea: THexHitArea read FActiveEditArea write SetActiveEditArea;
    property OnCursorChange: TNotifyEvent read FOnCursorChange write FOnCursorChange;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property OnModifiedChange: TNotifyEvent read FOnModifiedChange write FOnModifiedChange;
    property OnUndoRedoStateChange: TNotifyEvent read FOnUndoRedoStateChange write FOnUndoRedoStateChange;
    property OnEditModeChange: TNotifyEvent read FOnEditModeChange write FOnEditModeChange;
    property OnSearchChange: TNotifyEvent read FOnSearchChange write FOnSearchChange;
    property OnBookmarksChange: TNotifyEvent read FOnBookmarksChange write FOnBookmarksChange;
    property OnDataSourceChange: TNotifyEvent read FOnDataSourceChange write FOnDataSourceChange;
    property OnByteTooltip: THexByteTooltipEvent read FOnByteTooltip write FOnByteTooltip;
    property DataSource: IHexDataSource read FDataSource;
    property Selection: THexSelection read FSelection;
    property Bookmarks: THexBookmarkManager read FBookmarks;
    property CursorPosition: Int64 read FCursorOffset;
    property DataLength: Int64 read GetDataLength;
    property HasSelection: Boolean read GetHasSelection;
    property SelectionStart: Int64 read GetSelectionStart;
    property SelectionLength: Int64 read GetSelectionLength;
    property FindReplace: THexFindReplaceAdapter read GetFindReplace;
    property Theme: THexTheme read FTheme;
  end;

  TThemedHexEditor = class(TCustomThemedHexEditor)
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property PopupMenu;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnCursorChange;
    property OnSelectionChange;
    property OnModifiedChange;
    property OnUndoRedoStateChange;
    property OnEditModeChange;
    property OnSearchChange;
    property OnBookmarksChange;
    property OnDataSourceChange;
    property OnByteTooltip;
  end;

implementation

uses
  System.Math,
  Vcl.Clipbrd,
  NimbusForms.Theming.Manager,
  NimbusForms.HexEditor.Strings,
  NimbusForms.HexEditor.ProjectSerializer,
  NimbusForms.HexEditor.SessionSerializer;

type
  THexEditorFindReplaceHost = class(TInterfacedObject, IHexFindReplaceHost)
  private
    FEditor: TCustomThemedHexEditor;
  public
    constructor Create(const AEditor: TCustomThemedHexEditor);
    function GetDataLength: Int64;
    function ReadBytes(const AOffset: Int64; const ACount: Integer): TBytes;
    function InsertBytes(const AOffset: Int64; const AData: TBytes): Boolean;
    function DeleteBytes(const AOffset, ALength: Int64): Boolean;
    function GetHasSelection: Boolean;
    function GetSelectionStart: Int64;
    function GetSelectionLength: Int64;
    function GetCursorOffset: Int64;
    procedure GoToOffset(const AOffset, ALength: Int64);
    function GetOwnerForm: TCustomForm;
    function GetPixelsPerInch: Integer;
    function GetTheme: THexTheme;
  end;

constructor THexEditorFindReplaceHost.Create(const AEditor: TCustomThemedHexEditor);
begin
  inherited Create;
  FEditor := AEditor;
end;

function THexEditorFindReplaceHost.GetDataLength: Int64;
begin
  Result := FEditor.DataLength;
end;

function THexEditorFindReplaceHost.ReadBytes(const AOffset: Int64; const ACount: Integer): TBytes;
begin
  Result := FEditor.ReadBytes(AOffset, ACount);
end;

function THexEditorFindReplaceHost.InsertBytes(const AOffset: Int64; const AData: TBytes): Boolean;
begin
  Result := FEditor.InsertBytes(AOffset, AData);
end;

function THexEditorFindReplaceHost.DeleteBytes(const AOffset, ALength: Int64): Boolean;
begin
  Result := FEditor.DeleteBytes(AOffset, ALength);
end;

function THexEditorFindReplaceHost.GetHasSelection: Boolean;
begin
  Result := FEditor.HasSelection;
end;

function THexEditorFindReplaceHost.GetSelectionStart: Int64;
begin
  Result := FEditor.SelectionStart;
end;

function THexEditorFindReplaceHost.GetSelectionLength: Int64;
begin
  Result := FEditor.SelectionLength;
end;

function THexEditorFindReplaceHost.GetCursorOffset: Int64;
begin
  Result := FEditor.CursorPosition;
end;

procedure THexEditorFindReplaceHost.GoToOffset(const AOffset, ALength: Int64);
begin
  FEditor.SelectRange(AOffset, ALength);
end;

function THexEditorFindReplaceHost.GetOwnerForm: TCustomForm;
begin
  Result := GetParentForm(FEditor);
end;

function THexEditorFindReplaceHost.GetPixelsPerInch: Integer;
begin
  Result := FEditor.CurrentPPI;
end;

function THexEditorFindReplaceHost.GetTheme: THexTheme;
begin
  Result := FEditor.Theme;
end;

constructor TCustomThemedHexEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  Width := 640;
  Height := 400;
  TabStop := True;
  DoubleBuffered := True;

  FRenderer := THexRenderer.Create;
  FOptions := THexEditorOptions.Create;
  FSelection := THexSelection.Create;
  FBookmarks := THexBookmarkManager.Create;
  FModified := TDictionary<Int64, Boolean>.Create;
  FUndoManager := TUndoManager.Create;
  FSearchMatches := TObjectList<THexSearchMatch>.Create(True);
  FActiveMatchIndex := -1;
  FVScrollBar := THexScrollBar.Create(True);
  FHScrollBar := THexScrollBar.Create(False);
  FTooltipOffset := -1;
  FTooltipTimer := TTimer.Create(Self);
  FTooltipTimer.Enabled := False;
  FTooltipTimer.Interval := 500;
  FTooltipTimer.OnTimer := TooltipTimerFire;
  FTheme := THexTheme.FromPalette(ThemeManager.CurrentTheme);
  FCursorOffset := -1;
  FHoverOffset := -1;
  FActiveEditArea := hhaHexCell;
  FIsHighNibble := True;
  FSelectionAnchor := -1;
  FRowHeightCache := 18;

  Font.Name := 'Consolas';
  Font.Size := 10;

  ThemeManager.RegisterAware(Self);
end;

destructor TCustomThemedHexEditor.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  if FTooltipControl <> nil then
    FTooltipControl.Free;
  FFindReplace.Free;
  FFindReplaceHost := nil;
  FHScrollBar.Free;
  FVScrollBar.Free;
  FSearchMatches.Free;
  FUndoManager.Free;
  FModified.Free;
  FBookmarks.Free;
  FSelection.Free;
  FTheme.Free;
  FOptions.Free;
  FRenderer.Free;
  inherited Destroy;
end;

procedure TCustomThemedHexEditor.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_TABSTOP;
  Params.WindowClass.style := Params.WindowClass.style or CS_DBLCLKS;
end;

procedure TCustomThemedHexEditor.ApplyTheme(const APalette: TThemePalette);
begin
  FTheme.Free;
  FTheme := THexTheme.FromPalette(APalette);
  if FFindReplace <> nil then
    FFindReplace.RefreshTheme;
  Invalidate;
end;

procedure TCustomThemedHexEditor.LoadBytes(const AData: TBytes);
begin
  FDocument := nil;
  FDataSource := TBytesHexDataSource.Create(AData);
  FTopRow := 0;
  FCursorOffset := -1;
  FSelection.Clear(0);
  FModified.Clear;
  FUndoManager.Clear;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  FHScroll := 0;
  UpdateScrollBar;
  UpdateHScrollBar;
  DoDataSourceChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.LoadFromDataSource(const ADataSource: IHexDataSource);
begin
  FDocument := nil;
  FDataSource := ADataSource;
  FTopRow := 0;
  FCursorOffset := -1;
  FSelection.Clear(0);
  FModified.Clear;
  FUndoManager.Clear;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  FHScroll := 0;
  UpdateScrollBar;
  UpdateHScrollBar;
  DoDataSourceChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Clear;
begin
  FDocument := nil;
  FDataSource := nil;
  FTopRow := 0;
  FCursorOffset := -1;
  FSelection.Clear(0);
  FModified.Clear;
  FUndoManager.Clear;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  FHScroll := 0;
  UpdateScrollBar;
  UpdateHScrollBar;
  DoDataSourceChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

function TCustomThemedHexEditor.AcquireMetrics: THexRenderMetrics;
var
  LBitmap: TBitmap;
  LSurface: IHexRenderSurface;
  LContext: THexRenderContext;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(8, 8);
    LBitmap.Canvas.Font.Assign(Font);
    LSurface := TGdiHexRenderSurface.Create(LBitmap.Canvas);
    LSurface.SetFont(Font);
    LContext := THexRenderContext.Create;
    try
      LContext.Surface := LSurface;
      LContext.Options := FOptions;
      LContext.Theme := FTheme;
      LContext.DataSource := FDataSource;
      LContext.Bounds := ContentRect;
      LContext.HorizontalScrollValue := FHScroll;
      Result := FRenderer.Measure(LContext);
    finally
      LContext.Free;
    end;
  finally
    LBitmap.Free;
  end;
end;

function TCustomThemedHexEditor.ContentRect: TRect;
begin
  Result := ClientRect;
  if FVScrollBar.Visible then
    Dec(Result.Right, FVScrollBar.Thickness);
  if FHScrollBar.Visible then
    Dec(Result.Bottom, FHScrollBar.Thickness);
  if Result.Right < Result.Left then
    Result.Right := Result.Left;
  if Result.Bottom < Result.Top then
    Result.Bottom := Result.Top;
end;

function TCustomThemedHexEditor.PointInScrollBars(const AX, AY: Integer): THexScrollBar;
begin
  if FVScrollBar.Visible and PtInRect(FVScrollBar.Bounds, Point(AX, AY)) then
    Exit(FVScrollBar);
  if FHScrollBar.Visible and PtInRect(FHScrollBar.Bounds, Point(AX, AY)) then
    Exit(FHScrollBar);
  Result := nil;
end;

function TCustomThemedHexEditor.EffectiveGroupSize: Integer;
begin
  if not FOptions.ShowByteGroups then
    Exit(MaxInt);
  if FOptions.ByteGroupSize < 1 then
    Exit(1);
  Result := FOptions.ByteGroupSize;
end;

function TCustomThemedHexEditor.TotalRows: Int64;
begin
  if (FDataSource = nil) or (FDataSource.Length <= 0) then
    Exit(0);
  Result := (FDataSource.Length + FOptions.BytesPerRow - 1) div FOptions.BytesPerRow;
end;

function TCustomThemedHexEditor.VisibleRows: Integer;
var
  LMetrics: THexRenderMetrics;
begin
  LMetrics := AcquireMetrics;
  try
    FRowHeightCache := Max(1, LMetrics.RowHeight);
    Result := Max(1, (LMetrics.ContentBounds.Bottom - LMetrics.ContentBounds.Top) div FRowHeightCache);
  finally
    LMetrics.Free;
  end;
end;

procedure TCustomThemedHexEditor.UpdateScrollBar;
begin
  UpdateScrollbars;
end;

procedure TCustomThemedHexEditor.UpdateScrollbars;
var
  LMetrics: THexRenderMetrics;
  LRowHeight, LHeaderHeight, LContentWidth, LThickness: Integer;
  LClientW, LClientH, LVisibleRows, LContentHeight, LVisibleWidth: Integer;
  LVNeeded, LHNeeded: Boolean;
  LTotalRows: Int64;
begin
  if not HandleAllocated then
    Exit;
  LMetrics := AcquireMetrics;
  try
    LRowHeight := Max(1, LMetrics.RowHeight);
    LHeaderHeight := LMetrics.HeaderHeight;
  finally
    LMetrics.Free;
  end;
  LContentWidth := AcquireContentWidth;
  LThickness := FVScrollBar.Thickness;
  LClientW := ClientWidth;
  LClientH := ClientHeight;
  LTotalRows := TotalRows;

  LVNeeded := LTotalRows > Max(1, (LClientH - LHeaderHeight) div LRowHeight);
  if LVNeeded then
    LVisibleWidth := LClientW - LThickness
  else
    LVisibleWidth := LClientW;
  LHNeeded := LContentWidth > LVisibleWidth;
  if LHNeeded then
    LContentHeight := LClientH - LHeaderHeight - LThickness
  else
    LContentHeight := LClientH - LHeaderHeight;
  LVisibleRows := Max(1, LContentHeight div LRowHeight);
  LVNeeded := LTotalRows > LVisibleRows;

  FVScrollBar.Configure(Integer(Min(Int64(MaxInt), LTotalRows)), LVisibleRows,
    Integer(Min(Int64(MaxInt), FTopRow)));
  if LVNeeded then
    FVScrollBar.SetBounds(Rect(LClientW - LThickness, 0, LClientW,
      LClientH - IfThen(LHNeeded, LThickness, 0)))
  else
    FVScrollBar.SetBounds(Rect(0, 0, 0, 0));

  if LVNeeded then
    LVisibleWidth := LClientW - LThickness
  else
    LVisibleWidth := LClientW;
  FHScrollBar.Configure(LContentWidth, Max(1, LVisibleWidth), FHScroll);
  if LHNeeded then
    FHScrollBar.SetBounds(Rect(0, LClientH - LThickness, LVisibleWidth, LClientH))
  else
    FHScrollBar.SetBounds(Rect(0, 0, 0, 0));
end;

procedure TCustomThemedHexEditor.SetTopRow(const AValue: Int64);
var
  LMax: Int64;
  LNew: Int64;
begin
  LMax := Max(Int64(0), TotalRows - VisibleRows);
  LNew := AValue;
  if LNew < 0 then
    LNew := 0;
  if LNew > LMax then
    LNew := LMax;
  if LNew <> FTopRow then
  begin
    FTopRow := LNew;
    UpdateScrollbars;
    CancelTooltip;
    Invalidate;
  end;
end;

procedure TCustomThemedHexEditor.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCustomThemedHexEditor.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TCustomThemedHexEditor.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomThemedHexEditor.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateScrollBar;
  Invalidate;
end;

function TCustomThemedHexEditor.ClampOffset(const AValue: Int64): Int64;
begin
  if FDataSource = nil then
    Exit(-1);
  Result := AValue;
  if Result < 0 then
    Result := 0;
  if Result > FDataSource.Length - 1 then
    Result := FDataSource.Length - 1;
end;

function TCustomThemedHexEditor.HitTest(const AX, AY: Integer): THexHitInfo;
var
  LMetrics: THexRenderMetrics;
  LRow: Integer;
  LRowOffset: Int64;
  LGroupSize, I, LCellX: Integer;
begin
  Result.Area := hhaNone;
  Result.Offset := -1;
  Result.RowIndex := -1;
  Result.ColumnIndex := -1;
  if FDataSource = nil then
    Exit;

  LMetrics := AcquireMetrics;
  try
    if AY < LMetrics.HeaderHeight then
    begin
      Result.Area := hhaHeader;
      Exit;
    end;
    LRow := (AY - LMetrics.ContentBounds.Top) div Max(1, LMetrics.RowHeight);
    if LRow < 0 then
      Exit;
    Result.RowIndex := LRow;
    LRowOffset := (FTopRow + LRow) * FOptions.BytesPerRow;
    if LRowOffset >= FDataSource.Length then
      Exit;

    if AX < LMetrics.GutterWidth then
    begin
      Result.Area := hhaGutter;
      Result.Offset := LRowOffset;
      Exit;
    end;

    LGroupSize := EffectiveGroupSize;
    for I := 0 to FOptions.BytesPerRow - 1 do
    begin
      LCellX := LMetrics.GetHexCellX(I, LGroupSize);
      if (AX >= LCellX) and (AX < LCellX + LMetrics.CellWidth) then
      begin
        Result.Area := hhaHexCell;
        Result.ColumnIndex := I;
        Result.Offset := ClampOffset(LRowOffset + I);
        Result.RowIndex := LRow;
        Exit;
      end;
    end;

    if FOptions.ShowAscii and (AX >= LMetrics.AsciiStartX) then
    begin
      I := (AX - LMetrics.AsciiStartX) div Max(1, LMetrics.AsciiCellWidth);
      if (I >= 0) and (I < FOptions.BytesPerRow) then
      begin
        Result.Area := hhaAsciiCell;
        Result.ColumnIndex := I;
        Result.Offset := ClampOffset(LRowOffset + I);
        Result.RowIndex := LRow;
      end;
    end;
  finally
    LMetrics.Free;
  end;
end;

function TCustomThemedHexEditor.BuildTooltipText(const AOffset: Int64): string;
var
  LValue: Byte;
  LChar: string;
begin
  if not ReadByteAt(AOffset, LValue) then
    Exit('');
  if (LValue >= 32) and (LValue <= 126) then
    LChar := Char(LValue)
  else
    LChar := '.';
  Result := Format('Offset: 0x%s (%d)'#13#10'Byte: 0x%s (%d)'#13#10'Char: %s'#13#10'Bits: %s',
    [IntToHex(AOffset, 8), AOffset, IntToHex(LValue, 2), LValue, LChar,
     IntToHex(LValue, 2)]);
end;

procedure TCustomThemedHexEditor.DoShowTooltip(const AText: string;
  const AScreenPos: TPoint);
begin
  if AText = '' then
    Exit;
  if FTooltipControl = nil then
    FTooltipControl := TThemedHexTooltip.Create(Self);
  FTooltipControl.ShowText(AText, Point(AScreenPos.X + 16, AScreenPos.Y + 16));
end;

procedure TCustomThemedHexEditor.DoHideTooltip;
begin
  if FTooltipControl <> nil then
    FTooltipControl.HideTooltip;
end;

procedure TCustomThemedHexEditor.ScheduleTooltip(const AOffset: Int64;
  const AX, AY: Integer);
begin
  if not FOptions.ShowByteToolTip then
    Exit;
  if AOffset = FTooltipOffset then
    Exit;
  CancelTooltip;
  FTooltipOffset := AOffset;
  FTooltipMousePos := ClientToScreen(Point(AX, AY));
  FTooltipTimer.Enabled := True;
end;

procedure TCustomThemedHexEditor.CancelTooltip;
begin
  FTooltipTimer.Enabled := False;
  FTooltipOffset := -1;
  DoHideTooltip;
end;

procedure TCustomThemedHexEditor.TooltipTimerFire(Sender: TObject);
var
  LText: string;
  LValue: Byte;
  LCancel: Boolean;
begin
  FTooltipTimer.Enabled := False;
  if FTooltipOffset < 0 then
    Exit;
  LText := BuildTooltipText(FTooltipOffset);
  if Assigned(FOnByteTooltip) and ReadByteAt(FTooltipOffset, LValue) then
  begin
    LCancel := False;
    FOnByteTooltip(Self, FTooltipOffset, LValue, LText, LCancel);
    if LCancel then
      Exit;
  end;
  DoShowTooltip(LText, FTooltipMousePos);
end;

procedure TCustomThemedHexEditor.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHoverOffset := -1;
  FVScrollBar.SetHovered(False);
  FHScrollBar.SetHovered(False);
  CancelTooltip;
  Invalidate;
end;

procedure TCustomThemedHexEditor.DoCursorChange;
begin
  if Assigned(FOnCursorChange) then
    FOnCursorChange(Self);
end;

procedure TCustomThemedHexEditor.DoSelectionChange;
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
end;

procedure TCustomThemedHexEditor.DoModifiedChange;
begin
  if Assigned(FOnModifiedChange) then
    FOnModifiedChange(Self);
end;

procedure TCustomThemedHexEditor.DoUndoRedoStateChange;
begin
  if Assigned(FOnUndoRedoStateChange) then
    FOnUndoRedoStateChange(Self);
end;

procedure TCustomThemedHexEditor.DoEditModeChange;
begin
  if Assigned(FOnEditModeChange) then
    FOnEditModeChange(Self);
end;

procedure TCustomThemedHexEditor.DoSearchChange;
begin
  if Assigned(FOnSearchChange) then
    FOnSearchChange(Self);
end;

procedure TCustomThemedHexEditor.DoBookmarksChange;
begin
  if Assigned(FOnBookmarksChange) then
    FOnBookmarksChange(Self);
end;

procedure TCustomThemedHexEditor.DoDataSourceChange;
begin
  if Assigned(FOnDataSourceChange) then
    FOnDataSourceChange(Self);
end;

procedure TCustomThemedHexEditor.SetInsertMode(const AValue: Boolean);
begin
  if FInsertMode = AValue then
    Exit;
  FInsertMode := AValue;
  DoEditModeChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SetActiveEditArea(const AValue: THexHitArea);
begin
  if FActiveEditArea = AValue then
    Exit;
  FActiveEditArea := AValue;
  DoEditModeChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.GotoOffset(const AOffset: Int64);
begin
  SetCursorOffset(AOffset);
end;

procedure TCustomThemedHexEditor.SelectRange(const AStart, ALength: Int64);
begin
  FSelection.SetRange(AStart, ALength);
  FCursorOffset := ClampOffset(AStart);
  EnsureCursorVisible;
  DoSelectionChange;
  DoCursorChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.ToggleBookmark(const AOffset: Int64);
var
  LBookmark: THexBookmark;
begin
  if AOffset < 0 then
    Exit;
  if FBookmarks.Contains(AOffset) then
    FBookmarks.Remove(AOffset)
  else
  begin
    LBookmark := THexBookmark.Create;
    LBookmark.Offset := AOffset;
    LBookmark.HasColor := False;
    FBookmarks.Add(LBookmark);
  end;
  DoBookmarksChange;
  Invalidate;
end;

function TCustomThemedHexEditor.ReadAllBytes: TBytes;
begin
  Result := THexSearchService.ReadAll(FDataSource);
end;

function TCustomThemedHexEditor.GetModifiedCount: Integer;
begin
  Result := FModified.Count;
end;

function TCustomThemedHexEditor.CreatePatch: THexPatchFile;
var
  LCommand: TEditCommand;
  LOp: THexPatchOperation;
begin
  Result := THexPatchFile.Create;
  if FDataSource <> nil then
    Result.OriginalLength := FDataSource.Length;
  for LCommand in FUndoManager.UndoCommands do
  begin
    LOp := THexPatchOperation.Create;
    case LCommand.Kind of
      ekOverwrite:
        begin
          LOp.OperationType := hpoWrite;
          LOp.Data := LCommand.NewData;
          LOp.Length := Length(LCommand.NewData);
        end;
      ekInsert:
        begin
          LOp.OperationType := hpoInsert;
          LOp.Data := LCommand.NewData;
          LOp.Length := Length(LCommand.NewData);
        end;
      ekDelete:
        begin
          LOp.OperationType := hpoDelete;
          LOp.Length := Length(LCommand.OldData);
        end;
    end;
    LOp.Offset := LCommand.Offset;
    Result.Operations.Add(LOp);
  end;
end;

procedure TCustomThemedHexEditor.SavePatch(const AFilePath: string);
var
  LPatch: THexPatchFile;
begin
  LPatch := CreatePatch;
  try
    THexPatchSerializer.Save(AFilePath, LPatch);
  finally
    LPatch.Free;
  end;
end;

procedure TCustomThemedHexEditor.ApplyPatch(const APatch: THexPatchFile);
var
  LOp: THexPatchOperation;
begin
  if (APatch = nil) or (not CanEdit) then
    Exit;
  for LOp in APatch.Operations do
    case LOp.OperationType of
      hpoWrite: ApplyOverwrite(LOp.Offset, LOp.Data, True);
      hpoInsert: ApplyInsert(LOp.Offset, LOp.Data, True);
      hpoDelete: ApplyDelete(LOp.Offset, LOp.Length, True);
    end;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SetCursorOffset(const AValue: Int64);
begin
  FCursorOffset := ClampOffset(AValue);
  EnsureCursorVisible;
  DoCursorChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.EnsureCursorVisible;
var
  LRow: Int64;
  LVisible: Integer;
begin
  if (FDataSource = nil) or (FCursorOffset < 0) then
    Exit;
  LRow := FCursorOffset div FOptions.BytesPerRow;
  LVisible := VisibleRows;
  if LRow < FTopRow then
    SetTopRow(LRow)
  else if LRow >= FTopRow + LVisible then
    SetTopRow(LRow - LVisible + 1);
end;

procedure TCustomThemedHexEditor.KeyDown(var Key: Word; Shift: TShiftState);
var
  LHandled: Boolean;
begin
  if FDataSource = nil then
  begin
    inherited KeyDown(Key, Shift);
    Exit;
  end;

  if ssCtrl in Shift then
  begin
    case Key of
      Ord('Z'):
        begin
          Undo;
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
      Ord('Y'):
        begin
          Redo;
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
      Ord('C'):
        begin
          CopySelection(False);
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
      Ord('X'):
        begin
          CopySelection(True);
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
      Ord('V'):
        begin
          PasteClipboard;
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
      Ord('F'):
        begin
          ShowFindDialog;
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
      Ord('H'):
        begin
          ShowReplaceDialog;
          Key := 0;
          inherited KeyDown(Key, Shift);
          Exit;
        end;
    end;
  end;

  if Key = VK_F3 then
  begin
    if ssShift in Shift then
      FindReplacePrevious
    else
      FindReplaceNext;
    Key := 0;
    inherited KeyDown(Key, Shift);
    Exit;
  end;

  if Key = VK_INSERT then
  begin
    SetInsertMode(not FInsertMode);
    Key := 0;
    inherited KeyDown(Key, Shift);
    Exit;
  end;

  if Key = VK_DELETE then
  begin
    DeleteSelectionOrByte(False);
    Key := 0;
    inherited KeyDown(Key, Shift);
    Exit;
  end;

  if Key = VK_BACK then
  begin
    DeleteSelectionOrByte(True);
    Key := 0;
    inherited KeyDown(Key, Shift);
    Exit;
  end;

  LHandled := True;
  case Key of
    VK_LEFT: SetCursorOffset(FCursorOffset - 1);
    VK_RIGHT: SetCursorOffset(FCursorOffset + 1);
    VK_UP: SetCursorOffset(FCursorOffset - FOptions.BytesPerRow);
    VK_DOWN: SetCursorOffset(FCursorOffset + FOptions.BytesPerRow);
    VK_PRIOR: SetCursorOffset(FCursorOffset - FOptions.BytesPerRow * VisibleRows);
    VK_NEXT: SetCursorOffset(FCursorOffset + FOptions.BytesPerRow * VisibleRows);
    VK_HOME:
      if ssCtrl in Shift then
        SetCursorOffset(0)
      else
        SetCursorOffset((FCursorOffset div FOptions.BytesPerRow) * FOptions.BytesPerRow);
    VK_END:
      if ssCtrl in Shift then
        SetCursorOffset(FDataSource.Length - 1)
      else
        SetCursorOffset((FCursorOffset div FOptions.BytesPerRow) * FOptions.BytesPerRow + FOptions.BytesPerRow - 1);
    VK_TAB:
      if FActiveEditArea = hhaAsciiCell then
        SetActiveEditArea(hhaHexCell)
      else
        SetActiveEditArea(hhaAsciiCell);
  else
    LHandled := False;
  end;
  if LHandled then
  begin
    FSelection.Clear(FCursorOffset);
    Key := 0;
    Invalidate;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TCustomThemedHexEditor.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LHit: THexHitInfo;
  LScrollBar: THexScrollBar;
begin
  inherited MouseDown(Button, Shift, X, Y);
  CancelTooltip;
  if CanFocus then
    SetFocus;
  if Button <> mbLeft then
    Exit;
  LScrollBar := PointInScrollBars(X, Y);
  if LScrollBar <> nil then
  begin
    case LScrollBar.HitTest(X, Y) of
      sspThumb:
        begin
          LScrollBar.BeginDrag(X, Y);
          FScrollDrag := LScrollBar;
        end;
      sspTrackBefore:
        if LScrollBar = FVScrollBar then
          SetTopRow(FVScrollBar.PageStep(False))
        else
          SetHScroll(FHScrollBar.PageStep(False));
      sspTrackAfter:
        if LScrollBar = FVScrollBar then
          SetTopRow(FVScrollBar.PageStep(True))
        else
          SetHScroll(FHScrollBar.PageStep(True));
    end;
    Invalidate;
    Exit;
  end;
  LHit := HitTest(X, Y);
  if LHit.IsByte then
  begin
    FActiveEditArea := LHit.Area;
    FCursorOffset := LHit.Offset;
    FIsHighNibble := True;
    FSelectionAnchor := LHit.Offset;
    FDragging := True;
    FSelection.Clear(FCursorOffset);
    DoCursorChange;
    Invalidate;
  end;
end;

procedure TCustomThemedHexEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LHit: THexHitInfo;
  LStart, LLength: Int64;
  LNewPos: Integer;
  LOverV, LOverH: Boolean;
begin
  inherited MouseMove(Shift, X, Y);

  if FScrollDrag <> nil then
  begin
    LNewPos := FScrollDrag.DragTo(X, Y);
    if FScrollDrag = FVScrollBar then
      SetTopRow(LNewPos)
    else
      SetHScroll(LNewPos);
    Exit;
  end;

  LOverV := FVScrollBar.Visible and PtInRect(FVScrollBar.Bounds, Point(X, Y));
  LOverH := FHScrollBar.Visible and PtInRect(FHScrollBar.Bounds, Point(X, Y));
  if (LOverV <> FVScrollBar.Hovered) or (LOverH <> FHScrollBar.Hovered) then
  begin
    FVScrollBar.SetHovered(LOverV);
    FHScrollBar.SetHovered(LOverH);
    Invalidate;
  end;
  if LOverV or LOverH then
  begin
    CancelTooltip;
    Exit;
  end;

  LHit := HitTest(X, Y);
  if FOptions.ShowHoverHighlight then
  begin
    if LHit.IsByte then
      FHoverOffset := LHit.Offset
    else
      FHoverOffset := -1;
    Invalidate;
  end;
  if LHit.IsByte then
    ScheduleTooltip(LHit.Offset, X, Y)
  else
    CancelTooltip;
  if FDragging and LHit.IsByte and (FSelectionAnchor >= 0) then
  begin
    if LHit.Offset >= FSelectionAnchor then
    begin
      LStart := FSelectionAnchor;
      LLength := LHit.Offset - FSelectionAnchor + 1;
    end
    else
    begin
      LStart := LHit.Offset;
      LLength := FSelectionAnchor - LHit.Offset + 1;
    end;
    FSelection.SetRange(LStart, LLength);
    FCursorOffset := LHit.Offset;
    DoCursorChange;
    DoSelectionChange;
    Invalidate;
  end;
end;

procedure TCustomThemedHexEditor.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FScrollDrag <> nil then
  begin
    FScrollDrag.EndDrag;
    FScrollDrag := nil;
    Invalidate;
  end;
  FDragging := False;
end;

function TCustomThemedHexEditor.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  SetTopRow(FTopRow - (WheelDelta div 120) * 3);
  Result := True;
end;

procedure TCustomThemedHexEditor.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedHexEditor.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Resize;
begin
  inherited Resize;
  UpdateScrollBar;
  UpdateHScrollBar;
  Invalidate;
end;

function TCustomThemedHexEditor.CanEdit: Boolean;
begin
  Result := (FDataSource <> nil) and FDataSource.CanWrite and (not FOptions.ReadOnly);
end;

function TCustomThemedHexEditor.ReadByteAt(const AOffset: Int64; out AValue: Byte): Boolean;
var
  LBuffer: TBytes;
begin
  AValue := 0;
  if (FDataSource = nil) or (AOffset < 0) or (AOffset >= FDataSource.Length) then
    Exit(False);
  SetLength(LBuffer, 1);
  if FDataSource.Read(AOffset, LBuffer, 1) <> 1 then
    Exit(False);
  AValue := LBuffer[0];
  Result := True;
end;

procedure TCustomThemedHexEditor.MarkModified(const AOffset: Int64);
begin
  FModified.AddOrSetValue(AOffset, True);
end;

procedure TCustomThemedHexEditor.ShiftModifiedAfterInsert(const AOffset, ACount: Int64);
var
  LKeys: TArray<Int64>;
  LKey: Int64;
begin
  LKeys := FModified.Keys.ToArray;
  FModified.Clear;
  for LKey in LKeys do
    if LKey >= AOffset then
      FModified.AddOrSetValue(LKey + ACount, True)
    else
      FModified.AddOrSetValue(LKey, True);
end;

procedure TCustomThemedHexEditor.ShiftModifiedAfterDelete(const AOffset, ACount: Int64);
var
  LKeys: TArray<Int64>;
  LKey: Int64;
begin
  LKeys := FModified.Keys.ToArray;
  FModified.Clear;
  for LKey in LKeys do
  begin
    if (LKey >= AOffset) and (LKey < AOffset + ACount) then
      Continue;
    if LKey >= AOffset + ACount then
      FModified.AddOrSetValue(LKey - ACount, True)
    else
      FModified.AddOrSetValue(LKey, True);
  end;
end;

procedure TCustomThemedHexEditor.ApplyOverwrite(const AOffset: Int64;
  const ANewData: TBytes; const ARecord: Boolean);
var
  LOld: TBytes;
  I: Integer;
  LValue: Byte;
begin
  SetLength(LOld, Length(ANewData));
  for I := 0 to High(ANewData) do
  begin
    if ReadByteAt(AOffset + I, LValue) then
      LOld[I] := LValue
    else
      LOld[I] := 0;
  end;
  FDataSource.Write(AOffset, ANewData);
  for I := 0 to High(ANewData) do
    MarkModified(AOffset + I);
  if ARecord then
  begin
    FUndoManager.Push(TEditCommand.Create(ekOverwrite, AOffset, LOld, ANewData));
    DoModifiedChange;
    DoUndoRedoStateChange;
  end;
end;

procedure TCustomThemedHexEditor.ApplyInsert(const AOffset: Int64;
  const AData: TBytes; const ARecord: Boolean);
var
  I: Integer;
begin
  FDataSource.Insert(AOffset, AData);
  ShiftModifiedAfterInsert(AOffset, Length(AData));
  for I := 0 to High(AData) do
    MarkModified(AOffset + I);
  if ARecord then
  begin
    FUndoManager.Push(TEditCommand.Create(ekInsert, AOffset, nil, AData));
    DoModifiedChange;
    DoUndoRedoStateChange;
  end;
  UpdateScrollBar;
end;

procedure TCustomThemedHexEditor.ApplyDelete(const AOffset, ALength: Int64;
  const ARecord: Boolean);
var
  LOld, LBuffer: TBytes;
  LCount, LRead: Integer;
begin
  if (FDataSource = nil) or (ALength <= 0) then
    Exit;
  LCount := Integer(Min(ALength, FDataSource.Length - AOffset));
  if LCount <= 0 then
    Exit;
  SetLength(LBuffer, LCount);
  LRead := FDataSource.Read(AOffset, LBuffer, LCount);
  SetLength(LOld, LRead);
  if LRead > 0 then
    Move(LBuffer[0], LOld[0], LRead);
  FDataSource.Delete(AOffset, LCount);
  ShiftModifiedAfterDelete(AOffset, LCount);
  if ARecord then
  begin
    FUndoManager.Push(TEditCommand.Create(ekDelete, AOffset, LOld, nil));
    DoModifiedChange;
    DoUndoRedoStateChange;
  end;
  UpdateScrollBar;
end;

procedure TCustomThemedHexEditor.InputHexDigit(const ADigit: Byte);
var
  LOffset: Int64;
  LByte: Byte;
  LNew: TBytes;
begin
  if not CanEdit then
    Exit;
  LOffset := FCursorOffset;
  if LOffset < 0 then
    LOffset := 0;

  if FInsertMode and FIsHighNibble then
  begin
    SetLength(LNew, 1);
    LNew[0] := 0;
    ApplyInsert(LOffset, LNew, True);
  end;

  if not ReadByteAt(LOffset, LByte) then
    LByte := 0;
  if FIsHighNibble then
    LByte := (LByte and $0F) or (ADigit shl 4)
  else
    LByte := (LByte and $F0) or ADigit;

  SetLength(LNew, 1);
  LNew[0] := LByte;
  ApplyOverwrite(LOffset, LNew, True);

  if FIsHighNibble then
    FIsHighNibble := False
  else
  begin
    FIsHighNibble := True;
    SetCursorOffset(LOffset + 1);
  end;
  Invalidate;
end;

procedure TCustomThemedHexEditor.InputAsciiByte(const AValue: Byte);
var
  LNew: TBytes;
begin
  if not CanEdit then
    Exit;
  SetLength(LNew, 1);
  LNew[0] := AValue;
  if FInsertMode then
    ApplyInsert(FCursorOffset, LNew, True)
  else
    ApplyOverwrite(FCursorOffset, LNew, True);
  SetCursorOffset(FCursorOffset + 1);
  Invalidate;
end;

procedure TCustomThemedHexEditor.DeleteSelectionOrByte(const ABackspace: Boolean);
begin
  if not CanEdit then
    Exit;
  if not FSelection.IsEmpty then
  begin
    ApplyDelete(FSelection.Start, FSelection.Length, True);
    SetCursorOffset(FSelection.Start);
    FSelection.Clear(FCursorOffset);
    FIsHighNibble := True;
    Invalidate;
    Exit;
  end;
  if not FInsertMode then
    Exit;
  if ABackspace then
  begin
    if FCursorOffset <= 0 then
      Exit;
    ApplyDelete(FCursorOffset - 1, 1, True);
    SetCursorOffset(FCursorOffset - 1);
  end
  else
    ApplyDelete(FCursorOffset, 1, True);
  FIsHighNibble := True;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Undo;
var
  LCommand: TEditCommand;
begin
  LCommand := FUndoManager.PopUndo;
  if LCommand = nil then
    Exit;
  case LCommand.Kind of
    ekOverwrite: ApplyOverwrite(LCommand.Offset, LCommand.OldData, False);
    ekInsert: ApplyDelete(LCommand.Offset, Length(LCommand.NewData), False);
    ekDelete: ApplyInsert(LCommand.Offset, LCommand.OldData, False);
  end;
  FUndoManager.PushRedo(LCommand);
  SetCursorOffset(LCommand.Offset);
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Redo;
var
  LCommand: TEditCommand;
begin
  LCommand := FUndoManager.PopRedo;
  if LCommand = nil then
    Exit;
  case LCommand.Kind of
    ekOverwrite: ApplyOverwrite(LCommand.Offset, LCommand.NewData, False);
    ekInsert: ApplyInsert(LCommand.Offset, LCommand.NewData, False);
    ekDelete: ApplyDelete(LCommand.Offset, Length(LCommand.OldData), False);
  end;
  FUndoManager.Push(LCommand);
  SetCursorOffset(LCommand.Offset);
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

function TCustomThemedHexEditor.CanUndo: Boolean;
begin
  Result := FUndoManager.CanUndo;
end;

function TCustomThemedHexEditor.CanRedo: Boolean;
begin
  Result := FUndoManager.CanRedo;
end;

procedure TCustomThemedHexEditor.KeyPress(var Key: Char);
var
  LDigit: Byte;
begin
  inherited KeyPress(Key);
  if not CanEdit then
    Exit;
  if FActiveEditArea = hhaAsciiCell then
  begin
    if Ord(Key) >= 32 then
    begin
      InputAsciiByte(Byte(Ord(Key)));
      Key := #0;
    end;
    Exit;
  end;
  case Key of
    '0'..'9': LDigit := Byte(Ord(Key) - Ord('0'));
    'a'..'f': LDigit := Byte(Ord(Key) - Ord('a') + 10);
    'A'..'F': LDigit := Byte(Ord(Key) - Ord('A') + 10);
  else
    Exit;
  end;
  InputHexDigit(LDigit);
  Key := #0;
end;

function TCustomThemedHexEditor.AcquireContentWidth: Integer;
var
  LBitmap: TBitmap;
  LSurface: IHexRenderSurface;
  LContext: THexRenderContext;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(8, 8);
    LBitmap.Canvas.Font.Assign(Font);
    LSurface := TGdiHexRenderSurface.Create(LBitmap.Canvas);
    LSurface.SetFont(Font);
    LContext := THexRenderContext.Create;
    try
      LContext.Surface := LSurface;
      LContext.Options := FOptions;
      LContext.Theme := FTheme;
      LContext.DataSource := FDataSource;
      LContext.Bounds := ContentRect;
      LContext.HorizontalScrollValue := 0;
      Result := FRenderer.MeasureContentWidth(LContext);
    finally
      LContext.Free;
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure TCustomThemedHexEditor.UpdateHScrollBar;
begin
  UpdateScrollbars;
end;

procedure TCustomThemedHexEditor.SetHScroll(const AValue: Integer);
var
  LContentWidth, LVisibleWidth, LMax, LNew: Integer;
begin
  LContentWidth := AcquireContentWidth;
  LVisibleWidth := ContentRect.Right - ContentRect.Left;
  LMax := Max(0, LContentWidth - LVisibleWidth);
  LNew := AValue;
  if LNew < 0 then
    LNew := 0;
  if LNew > LMax then
    LNew := LMax;
  if LNew <> FHScroll then
  begin
    FHScroll := LNew;
    UpdateScrollbars;
    CancelTooltip;
    Invalidate;
  end;
end;

procedure TCustomThemedHexEditor.CopySelection(const ADelete: Boolean);
var
  LBuffer: TBytes;
  LCount, LRead, I: Integer;
  LText: string;
begin
  if (FDataSource = nil) or FSelection.IsEmpty then
    Exit;
  LCount := Integer(Min(FSelection.Length, FDataSource.Length - FSelection.Start));
  if LCount <= 0 then
    Exit;
  SetLength(LBuffer, LCount);
  LRead := FDataSource.Read(FSelection.Start, LBuffer, LCount);
  LText := '';
  for I := 0 to LRead - 1 do
  begin
    if I > 0 then
      LText := LText + ' ';
    LText := LText + IntToHex(LBuffer[I], 2);
  end;
  Clipboard.AsText := LText;
  if ADelete and CanEdit then
  begin
    ApplyDelete(FSelection.Start, LRead, True);
    SetCursorOffset(FSelection.Start);
    FSelection.Clear(FCursorOffset);
    FIsHighNibble := True;
    Invalidate;
  end;
end;

procedure TCustomThemedHexEditor.PasteClipboard;
var
  LText: string;
  LBytes: TBytes;
begin
  if not CanEdit then
    Exit;
  LText := Clipboard.AsText;
  if Trim(LText) = '' then
    Exit;
  if not THexSearchService.TryParseHexBytes(LText, LBytes) then
    LBytes := TEncoding.ANSI.GetBytes(LText);
  if Length(LBytes) = 0 then
    Exit;
  if FInsertMode then
    ApplyInsert(FCursorOffset, LBytes, True)
  else
    ApplyOverwrite(FCursorOffset, LBytes, True);
  SetCursorOffset(FCursorOffset + Length(LBytes));
  FIsHighNibble := True;
  Invalidate;
end;

procedure TCustomThemedHexEditor.NavigateToActiveMatch;
var
  LMatch: THexSearchMatch;
begin
  if (FActiveMatchIndex < 0) or (FActiveMatchIndex >= FSearchMatches.Count) then
    Exit;
  LMatch := FSearchMatches[FActiveMatchIndex];
  FCursorOffset := ClampOffset(LMatch.Offset);
  FSelection.SetRange(LMatch.Offset, LMatch.Length);
  FIsHighNibble := True;
  EnsureCursorVisible;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Search(const AText: string; const AKind: THexSearchKind);
var
  I: Integer;
begin
  THexSearchService.Find(FDataSource, AText, AKind, FSearchMatches);
  FActiveMatchIndex := -1;
  if FSearchMatches.Count > 0 then
  begin
    FActiveMatchIndex := 0;
    for I := 0 to FSearchMatches.Count - 1 do
      if FSearchMatches[I].Offset >= FCursorOffset then
      begin
        FActiveMatchIndex := I;
        Break;
      end;
    NavigateToActiveMatch;
  end;
  DoSearchChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SearchRule(const ARule: THexSearchRule);
var
  LEngine: THexSearchRuleEngine;
  LMatches: TObjectList<THexSearchRuleMatch>;
  I: Integer;
begin
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  if (FDataSource <> nil) and (ARule <> nil) then
  begin
    LEngine := THexSearchRuleEngine.Create;
    try
      LMatches := LEngine.Search(FDataSource, ARule);
      try
        for I := 0 to LMatches.Count - 1 do
          FSearchMatches.Add(THexSearchMatch.Create(LMatches[I].Offset, LMatches[I].Length));
      finally
        LMatches.Free;
      end;
    finally
      LEngine.Free;
    end;
  end;
  if FSearchMatches.Count > 0 then
  begin
    FActiveMatchIndex := 0;
    NavigateToActiveMatch;
  end;
  DoSearchChange;
  Invalidate;
end;

function TCustomThemedHexEditor.GetFindReplace: THexFindReplaceAdapter;
begin
  if FFindReplace = nil then
  begin
    FFindReplaceHost := THexEditorFindReplaceHost.Create(Self);
    FFindReplace := THexFindReplaceAdapter.Create(FFindReplaceHost);
  end;
  Result := FFindReplace;
end;

function TCustomThemedHexEditor.GetDataLength: Int64;
begin
  if FDataSource = nil then
    Exit(0);
  Result := FDataSource.Length;
end;

function TCustomThemedHexEditor.GetHasSelection: Boolean;
begin
  Result := not FSelection.IsEmpty;
end;

function TCustomThemedHexEditor.GetSelectionStart: Int64;
begin
  Result := FSelection.Start;
end;

function TCustomThemedHexEditor.GetSelectionLength: Int64;
begin
  Result := FSelection.Length;
end;

function TCustomThemedHexEditor.ReadBytes(const AOffset: Int64; const ACount: Integer): TBytes;
var
  LRead: Integer;
begin
  SetLength(Result, 0);
  if (FDataSource = nil) or (AOffset < 0) or (ACount <= 0) then
    Exit;
  SetLength(Result, ACount);
  LRead := FDataSource.Read(AOffset, Result, ACount);
  if LRead < 0 then
    LRead := 0;
  SetLength(Result, LRead);
end;

function TCustomThemedHexEditor.InsertBytes(const AOffset: Int64; const AData: TBytes): Boolean;
begin
  if (not CanEdit) or (Length(AData) = 0) or (AOffset < 0) or (AOffset > FDataSource.Length) then
    Exit(False);
  ApplyInsert(AOffset, AData, True);
  FSelection.Clear(ClampOffset(AOffset));
  Invalidate;
  Result := True;
end;

function TCustomThemedHexEditor.DeleteBytes(const AOffset, ALength: Int64): Boolean;
begin
  if (not CanEdit) or (ALength <= 0) or (AOffset < 0) or (AOffset + ALength > FDataSource.Length) then
    Exit(False);
  ApplyDelete(AOffset, ALength, True);
  FSelection.Clear(ClampOffset(AOffset));
  Invalidate;
  Result := True;
end;

procedure TCustomThemedHexEditor.ShowFindDialog;
begin
  GetFindReplace.ShowFind(GetParentForm(Self));
end;

procedure TCustomThemedHexEditor.ShowReplaceDialog;
begin
  GetFindReplace.ShowReplace(GetParentForm(Self));
end;

function TCustomThemedHexEditor.FindReplaceNext: Boolean;
begin
  Result := GetFindReplace.FindNext;
end;

function TCustomThemedHexEditor.FindReplacePrevious: Boolean;
begin
  Result := GetFindReplace.FindPrevious;
end;

function TCustomThemedHexEditor.FindNext: Boolean;
begin
  if FSearchMatches.Count = 0 then
    Exit(False);
  FActiveMatchIndex := (FActiveMatchIndex + 1) mod FSearchMatches.Count;
  NavigateToActiveMatch;
  DoSearchChange;
  Result := True;
end;

function TCustomThemedHexEditor.FindPrevious: Boolean;
begin
  if FSearchMatches.Count = 0 then
    Exit(False);
  Dec(FActiveMatchIndex);
  if FActiveMatchIndex < 0 then
    FActiveMatchIndex := FSearchMatches.Count - 1;
  NavigateToActiveMatch;
  DoSearchChange;
  Result := True;
end;

procedure TCustomThemedHexEditor.ClearSearch;
begin
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  DoSearchChange;
  Invalidate;
end;

function TCustomThemedHexEditor.SearchMatchCount: Integer;
begin
  Result := FSearchMatches.Count;
end;

function TCustomThemedHexEditor.GatherBookmarks: TObjectList<THexBookmarkData>;
var
  LBookmark: THexBookmark;
  LData: THexBookmarkData;
begin
  Result := TObjectList<THexBookmarkData>.Create(True);
  for LBookmark in FBookmarks.Values do
  begin
    if LBookmark = nil then
      Continue;
    LData := THexBookmarkData.Create;
    LData.Offset := LBookmark.Offset;
    LData.Name := LBookmark.Name;
    if LBookmark.HasColor then
      LData.Argb := Integer(LBookmark.Color)
    else
      LData.Argb := 0;
    Result.Add(LData);
  end;
end;

procedure TCustomThemedHexEditor.RestoreBookmarks(const ABookmarks: TObjectList<THexBookmarkData>);
var
  LData: THexBookmarkData;
  LBookmark: THexBookmark;
begin
  FBookmarks.Clear;
  if ABookmarks = nil then
    Exit;
  for LData in ABookmarks do
  begin
    LBookmark := THexBookmark.Create;
    LBookmark.Offset := LData.Offset;
    LBookmark.Name := LData.Name;
    LBookmark.HasColor := LData.Argb <> 0;
    if LBookmark.HasColor then
      LBookmark.Color := TThemeColor(Cardinal(LData.Argb));
    FBookmarks.Add(LBookmark);
  end;
end;

procedure TCustomThemedHexEditor.LoadDocument(const ADocument: THexDocument);
begin
  if ADocument = nil then
    raise EArgumentNilException.Create('document');
  LoadFromDataSource(ADocument);
  FDocument := ADocument;
end;

procedure TCustomThemedHexEditor.RestoreFromSession(const ASession: THexSessionData);
var
  LDocument: THexDocument;
  LKeepAlive: IHexDataSource;
begin
  if ASession = nil then
    raise EArgumentNilException.Create('session');
  if ASession.OriginalFilePath = '' then
    raise EInvalidOpException.Create(HexEditorTexts.ErrSessionWithoutFile);
  LDocument := THexDocument.Create(ASession.OriginalFilePath);
  LKeepAlive := LDocument;
  LDocument.RestoreSessionData(ASession);
  LoadDocument(LDocument);
  RestoreBookmarks(ASession.Bookmarks);
  FSelection.SetRange(ASession.SelectionStart, ASession.SelectionLength);
  if ASession.CursorOffset >= 0 then
    FCursorOffset := ClampOffset(ASession.CursorOffset)
  else
    FCursorOffset := -1;
  EnsureCursorVisible;
  DoBookmarksChange;
  DoSelectionChange;
  DoCursorChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SaveProjectToFile(const AFilePath: string);
var
  LProject: THexProjectData;
  LBookmarks: TObjectList<THexBookmarkData>;
begin
  if FDocument = nil then
    raise EInvalidOpException.Create(HexEditorTexts.ErrNoDocument);
  LProject := THexProjectData.Create;
  try
    LProject.ProjectName := ChangeFileExt(ExtractFileName(AFilePath), '');
    LBookmarks := GatherBookmarks;
    try
      LProject.Session := FDocument.CreateSessionData(nil, nil, FCursorOffset,
        FSelection.Start, FSelection.Length, LBookmarks);
    finally
      LBookmarks.Free;
    end;
    THexProjectSerializer.Save(AFilePath, LProject);
  finally
    LProject.Free;
  end;
end;

procedure TCustomThemedHexEditor.LoadProjectFromFile(const AFilePath: string);
var
  LProject: THexProjectData;
begin
  LProject := THexProjectSerializer.Load(AFilePath);
  try
    RestoreFromSession(LProject.Session);
  finally
    LProject.Free;
  end;
end;

procedure TCustomThemedHexEditor.SaveSessionToFile(const AFilePath: string);
var
  LSession: THexSessionData;
  LBookmarks: TObjectList<THexBookmarkData>;
begin
  if FDocument = nil then
    raise EInvalidOpException.Create(HexEditorTexts.ErrNoDocument);
  LBookmarks := GatherBookmarks;
  try
    LSession := FDocument.CreateSessionData(nil, nil, FCursorOffset,
      FSelection.Start, FSelection.Length, LBookmarks);
  finally
    LBookmarks.Free;
  end;
  try
    THexSessionSerializer.Save(AFilePath, LSession);
  finally
    LSession.Free;
  end;
end;

procedure TCustomThemedHexEditor.LoadSessionFromFile(const AFilePath: string);
var
  LSession: THexSessionData;
begin
  LSession := THexSessionSerializer.Load(AFilePath);
  try
    RestoreFromSession(LSession);
  finally
    LSession.Free;
  end;
end;

procedure TCustomThemedHexEditor.Paint;
var
  LSurface: IHexRenderSurface;
  LContext: THexRenderContext;
begin
  UpdateScrollbars;
  LSurface := TGdiHexRenderSurface.Create(Canvas);
  LSurface.SetFont(Font);
  LContext := THexRenderContext.Create;
  try
    LContext.Surface := LSurface;
    LContext.Bounds := ContentRect;
    LContext.DataSource := FDataSource;
    LContext.Options := FOptions;
    LContext.Theme := FTheme;
    LContext.Selection := FSelection;
    LContext.Bookmarks := FBookmarks;
    LContext.ModifiedOffsets := FModified;
    LContext.AdvancedSearchMatches := FSearchMatches;
    if (FActiveMatchIndex >= 0) and (FActiveMatchIndex < FSearchMatches.Count) then
      LContext.ActiveSearchMatch := FSearchMatches[FActiveMatchIndex];
    LContext.FirstVisibleOffset := FTopRow * FOptions.BytesPerRow;
    LContext.HorizontalScrollValue := FHScroll;
    LContext.CursorOffset := FCursorOffset;
    LContext.HoverOffset := FHoverOffset;
    LContext.Focused := Focused;
    LContext.Enabled := Enabled;
    LContext.IsHighNibble := FIsHighNibble;
    LContext.InsertMode := FInsertMode;
    LContext.ActiveEditArea := FActiveEditArea;
    FRenderer.Render(LContext);
    FVScrollBar.Paint(LSurface, FTheme);
    FHScrollBar.Paint(LSurface, FTheme);
    if FVScrollBar.Visible and FHScrollBar.Visible then
      LSurface.FillRectangle(FTheme.ScrollBarTrackColor,
        Rect(ClientWidth - FVScrollBar.Thickness, ClientHeight - FHScrollBar.Thickness,
          ClientWidth, ClientHeight));
  finally
    LContext.Free;
  end;
end;

end.

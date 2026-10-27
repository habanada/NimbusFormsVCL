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
  NimbusForms.HexEditor.SearchProviders,
  NimbusForms.HexEditor.Session,
  NimbusForms.HexEditor.Inspector,
  NimbusForms.HexEditor.Encoding,
  NimbusForms.HexEditor.RuleEngine,
  NimbusForms.HexEditor.Patch,
  NimbusForms.HexEditor.RenderSurface,
  NimbusForms.HexEditor.RenderContext,
  NimbusForms.HexEditor.ScrollBar,
  NimbusForms.HexEditor.Tooltip,
  NimbusForms.HexEditor.Undo,
  NimbusForms.HexEditor.Renderers;

type
  THexDataSourceInfo = record
    DataSource: IHexDataSource;
    DataLength: Int64;
    CanWrite, HasData: Boolean;
  end;
  THexDataSourceInfoEvent = procedure(Sender: TObject; const AInfo: THexDataSourceInfo) of object;

  THexSelectionInfo = record
    SelectionStart, SelectionLength, SelectionEnd, CursorOffset: Int64;
    HasSelection: Boolean;
  end;
  THexSelectionInfoEvent = procedure(Sender: TObject; const AInfo: THexSelectionInfo) of object;

  THexCursorOffsetInfo = record
    CursorOffset: Int64;
    ActiveEditArea: THexHitArea;
    IsHighNibble: Boolean;
  end;
  THexCursorOffsetInfoEvent = procedure(Sender: TObject; const AInfo: THexCursorOffsetInfo) of object;

  THexUndoRedoStateInfo = record
    CanUndo, CanRedo: Boolean;
  end;
  THexUndoRedoStateInfoEvent = procedure(Sender: TObject; const AInfo: THexUndoRedoStateInfo) of object;

  THexSearchInfo = record
    MatchCount, ActiveMatchIndex: Integer;
    HasSearch, HasActiveMatch: Boolean;
    Offset: Int64;
    Length, PatternIndex, HammingDistance: Integer;
  end;
  THexSearchInfoEvent = procedure(Sender: TObject; const AInfo: THexSearchInfo) of object;

  THexEditModeInfo = record
    InsertMode: Boolean;
    ActiveEditArea: THexHitArea;
    EditModeText, ActiveAreaText: string;
  end;
  THexEditModeInfoEvent = procedure(Sender: TObject; const AInfo: THexEditModeInfo) of object;

  THexModifiedInfo = record
    Modified, CanSave: Boolean;
  end;
  THexModifiedInfoEvent = procedure(Sender: TObject; const AInfo: THexModifiedInfo) of object;

  THexByteTooltipEvent = procedure(Sender: TObject; const AOffset: Int64;
    const AValue: Byte; var AText: string; var ACancel: Boolean) of object;

  TCustomThemedHexEditor = class(TCustomControl, IThemeAware)
  private
    FRenderer: THexRenderer;
    FRenderSurface: IHexRenderSurface;
    FMeasureSurface: IHexRenderSurface;
    FRenderContext: THexRenderContext;
    FMeasureContext: THexRenderContext;
    FRenderMetrics: THexRenderMetrics;
    FMeasureMetrics: THexRenderMetrics;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
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
    FSearchProviders: THexSearchProviderCollection;
    FTextEncoding: THexTextEncoding;
    FEncodingName: string;
    FFindDialog: TCustomForm;
    FLastFind: TBytes;
    FOnDataSourceInfoChanged: THexDataSourceInfoEvent;
    FOnSelectionInfoChanged: THexSelectionInfoEvent;
    FOnCursorOffsetInfoChanged: THexCursorOffsetInfoEvent;
    FOnUndoRedoStateInfoChanged: THexUndoRedoStateInfoEvent;
    FOnSearchInfoChanged: THexSearchInfoEvent;
    FOnEditModeInfoChanged: THexEditModeInfoEvent;
    FOnModifiedInfoChanged: THexModifiedInfoEvent;
    FOnRequestFind: TNotifyEvent;
    FOnRequestReplace: TNotifyEvent;
    FOnRequestFindNext: TNotifyEvent;
    FOnRequestFindPrevious: TNotifyEvent;
    FOnRequestGotoOffset: TNotifyEvent;
    FUseIntegratedFindReplaceDialog: Boolean;
    procedure SetUseIntegratedFindReplaceDialog(const AValue: Boolean);
    function GetActiveSearchMatch: THexSearchMatch;
    function GetDataLength: Int64;
    function GetModified: Boolean;
    function GetSelectedBytes: TBytes;
    procedure SetEncodingName(const AName: string);
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
    procedure UpdateHScrollBar;
    procedure SetHScroll(const AValue: Integer);
    function AcquireContentWidth: Integer;
    procedure UpdateMeasureMetrics(const AHorizontalScroll: Integer);
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
    procedure ApplyReplaceRange(const AOffset: Int64; const ALength: Integer; const ABytes: TBytes; const ARecord: Boolean);
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
    property CursorOffset: Int64 read FCursorOffset write SetCursorOffset;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure LoadBytes(const AData: TBytes);
    procedure LoadFromDataSource(const ADataSource: IHexDataSource);
    procedure Clear;
    procedure Undo;
    procedure Redo;
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    procedure Search(const AText: string; const AKind: THexSearchKind);
    procedure SearchRule(const ARule: THexSearchRule);
    function FindNext: Boolean;
    function FindPrevious: Boolean;
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
    procedure LoadFile(const APath: string);
    procedure Save;
    procedure SaveAs(const APath: string);
    function CanSave: Boolean;
    function TryReadBytes(const AOffset: Int64; const ACount: Integer; out ABytes: TBytes): Boolean;
    procedure InsertBytes(const AOffset: Int64; const ABytes: TBytes);
    procedure OverwriteBytes(const AOffset: Int64; const ABytes: TBytes);
    procedure DeleteBytes(const AOffset, ALength: Int64);
    procedure DeleteSelection;
    procedure ClearSelection;
    procedure SelectAllBytes;
    procedure ClearUndoRedo;
    function ExportUndoStack: TObjectList<TEditCommand>;
    function ExportRedoStack: TObjectList<TEditCommand>;
    procedure ImportUndoRedoStacks(const AUndo, ARedo: TList<TEditCommand>);
    procedure CopyRawSelection;
    procedure CopyHexSelection;
    procedure CopyAsciiSelection;
    procedure PasteInsert;
    procedure PasteOverwrite;
    function ExportSelection(const AFormat: string): string;
    function ExportRange(const AOffset: Int64; const ALength: Integer; const AFormat: string): string;
    function AddBookmark(const AOffset: Int64; const AName: string; const AColor: TThemeColor): THexBookmark;
    function RemoveBookmark(const AOffset: Int64): Boolean;
    procedure RenameBookmark(const AOffset: Int64; const AName: string);
    procedure UpdateBookmark(const AOffset: Int64; const AName: string; const AColor: TThemeColor); overload;
    function UpdateBookmark(const AOffset: Int64; const AName: string; const ANewOffset: Int64; const AColor: TThemeColor): Boolean; overload;
    function MoveBookmark(const AOffset, ANewOffset: Int64): Boolean;
    procedure ClearBookmarks;
    function TryGetBookmark(const AOffset: Int64; out ABookmark: THexBookmark): Boolean;
    function GetBookmarkList: TArray<THexBookmark>;
    function GoToBookmark(const AOffset: Int64): Boolean;
    function GoToNextBookmark: Boolean;
    function GoToPreviousBookmark: Boolean;
    function InspectSelection(const ABigEndian: Boolean = False): TArray<TInspectorRow>;
    function SearchWithProvider(const AName: string; const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
    procedure SetAdvancedSearchMatches(const AMatches: TList<THexSearchMatch>);
    function GetAdvancedSearchMatches: TObjectList<THexSearchMatch>;
    function SetActiveAdvancedSearchMatchIndex(const AIndex: Integer): Boolean;
    procedure ClearAdvancedSearchMatches;
    function GoToNextAdvancedSearchMatch: Boolean;
    function GoToPreviousAdvancedSearchMatch: Boolean;
    function SearchPattern(const AText: string; const AStartOffset: Int64 = 0; const AEndOffset: Int64 = -1; const AMaxHammingDistance: Integer = 0): TObjectList<THexSearchMatch>;
    function SearchAny(const APatterns: TArray<TBytes>): TObjectList<THexSearchMatch>;
    function SearchAnyText(const ATexts: TArray<string>; const AEncoding: TEncoding = nil): TObjectList<THexSearchMatch>;
    function SearchApproximate(const APattern: TBytes; const AMaxHammingDistance: Integer): TObjectList<THexSearchMatch>;
    function FindText(const AText: string; const AEncoding: TEncoding = nil): THexSearchMatch;
    function DetectFileEncoding: THexTextEncoding;
    function DetectEncodingName: string;
    function GetSupportedEncodings: TArray<string>;
    function CreateSessionData: THexSessionData;
    function CreateSessionJson: string;
    procedure SaveSession(const APath: string);
    procedure RestoreSessionData(const ASession: THexSessionData);
    procedure RestoreSessionJson(const AJson: string);
    procedure RestoreSessionFile(const APath: string);
    function CreateProjectData(const AName: string = ''): THexProjectData;
    procedure SaveProject(const APath: string; const AName: string = '');
    procedure RestoreProjectData(const AProject: THexProjectData);
    procedure RestoreProjectFile(const APath: string);
    function CreateProjectBytes(const AName: string = ''): TBytes;
    procedure RestoreProjectBytes(const ABytes: TBytes);
    function FindBytes(const APattern: TBytes; const AForward: Boolean; const AWrap: Boolean = True): Boolean;
    function ReplaceSelection(const AFind, AReplacement: TBytes): Boolean;
    function ReplaceAll(const AFind, AReplacement: TBytes): Integer;
    procedure ShowFindDialog;
    procedure ShowReplaceDialog;
    procedure RequestFind;
    procedure RequestReplace;
    procedure RequestFindNext;
    procedure RequestFindPrevious;
    procedure RequestGotoOffset;
    function FindNextFromIntegratedDialog: Boolean;
    function FindPreviousFromIntegratedDialog: Boolean;
    procedure RefreshLayout;
    function ExportSelectionAsCSharpArray: string;
    function ExportRangeAsCSharpArray(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsCSharpArray;
    function ExportSelectionAsCSharpReadOnlyArray: string;
    function ExportRangeAsCSharpReadOnlyArray(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsCSharpReadOnlyArray;
    function ExportSelectionAsTextDump: string;
    function ExportRangeAsTextDump(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsTextDump;
    function ExportSelectionAsHtmlTable: string;
    function ExportRangeAsHtmlTable(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsHtmlTable;
    function ExportSelectionAsJsonArray: string;
    function ExportRangeAsJsonArray(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsJsonArray;
    function ExportSelectionAsBase64: string;
    function ExportRangeAsBase64(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsBase64;
    function ExportSelectionAsSqlVarBinary: string;
    function ExportRangeAsSqlVarBinary(const AOffset: Int64; const ALength: Integer): string;
    procedure CopySelectionAsSqlVarBinary;
    property Options: THexEditorOptions read FOptions;
    property DataLength: Int64 read GetDataLength;
    property Modified: Boolean read GetModified;
    property SelectedBytes: TBytes read GetSelectedBytes;
    property EncodingName: string read FEncodingName write SetEncodingName;
    property TextEncoding: THexTextEncoding read FTextEncoding;
    property SearchProviders: THexSearchProviderCollection read FSearchProviders;
    property ActiveAdvancedSearchMatchIndex: Integer read FActiveMatchIndex;
    property ActiveSearchMatch: THexSearchMatch read GetActiveSearchMatch;
    property UseIntegratedFindReplaceDialog: Boolean read FUseIntegratedFindReplaceDialog write SetUseIntegratedFindReplaceDialog default True;
    property OnDataSourceInfoChanged: THexDataSourceInfoEvent read FOnDataSourceInfoChanged write FOnDataSourceInfoChanged;
    property OnSelectionInfoChanged: THexSelectionInfoEvent read FOnSelectionInfoChanged write FOnSelectionInfoChanged;
    property OnCursorOffsetInfoChanged: THexCursorOffsetInfoEvent read FOnCursorOffsetInfoChanged write FOnCursorOffsetInfoChanged;
    property OnUndoRedoStateInfoChanged: THexUndoRedoStateInfoEvent read FOnUndoRedoStateInfoChanged write FOnUndoRedoStateInfoChanged;
    property OnSearchInfoChanged: THexSearchInfoEvent read FOnSearchInfoChanged write FOnSearchInfoChanged;
    property OnEditModeInfoChanged: THexEditModeInfoEvent read FOnEditModeInfoChanged write FOnEditModeInfoChanged;
    property OnModifiedInfoChanged: THexModifiedInfoEvent read FOnModifiedInfoChanged write FOnModifiedInfoChanged;
    property OnRequestFind: TNotifyEvent read FOnRequestFind write FOnRequestFind;
    property OnRequestReplace: TNotifyEvent read FOnRequestReplace write FOnRequestReplace;
    property OnRequestFindNext: TNotifyEvent read FOnRequestFindNext write FOnRequestFindNext;
    property OnRequestFindPrevious: TNotifyEvent read FOnRequestFindPrevious write FOnRequestFindPrevious;
    property OnRequestGotoOffset: TNotifyEvent read FOnRequestGotoOffset write FOnRequestGotoOffset;
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
  end;

  TThemedHexEditor = class(TCustomThemedHexEditor)
  published
    property UseIntegratedFindReplaceDialog;
    property OnDataSourceInfoChanged;
    property OnSelectionInfoChanged;
    property OnCursorOffsetInfoChanged;
    property OnUndoRedoStateInfoChanged;
    property OnSearchInfoChanged;
    property OnEditModeInfoChanged;
    property OnModifiedInfoChanged;
    property OnRequestFind;
    property OnRequestReplace;
    property OnRequestFindNext;
    property OnRequestFindPrevious;
    property OnRequestGotoOffset;
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
  System.Generics.Defaults,
  System.IOUtils,
  NimbusForms.HexEditor.Document,
  NimbusForms.HexEditor.Export,
  NimbusForms.HexEditor.Clipboard,
  NimbusForms.HexEditor.FindReplace,
  Vcl.Clipbrd,
  NimbusForms.Theming.Manager;

constructor TCustomThemedHexEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSearchProviders := THexSearchProviderCollection.Create;
  FTextEncoding := THexTextEncoding.Create;
  FUseIntegratedFindReplaceDialog := True;
  FEncodingName := 'UTF-8';
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  Width := 640;
  Height := 400;
  TabStop := True;
  DoubleBuffered := True;

  FRenderer := THexRenderer.Create;
  FRenderSurface := TGdiPlusHexRenderSurface.Create;
  FMeasureSurface := TGdiPlusHexRenderSurface.Create;
  FRenderContext := THexRenderContext.Create;
  FMeasureContext := THexRenderContext.Create;
  FRenderMetrics := THexRenderMetrics.Create;
  FMeasureMetrics := THexRenderMetrics.Create;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.PixelFormat := pf32bit;
  FMeasureBitmap.SetSize(8, 8);
  FMeasureSurface.BeginRender(FMeasureBitmap.Canvas);
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
  FreeAndNil(FFindDialog);
  FSearchProviders.Free;
  FTextEncoding.Free;
  ThemeManager.UnregisterAware(Self);
  if FTooltipControl <> nil then
    FTooltipControl.Free;
  FHScrollBar.Free;
  FVScrollBar.Free;
  FSearchMatches.Free;
  FUndoManager.Free;
  FModified.Free;
  FBookmarks.Free;
  FSelection.Free;
  FTheme.Free;
  FOptions.Free;
  FRenderContext.Free;
  FMeasureContext.Free;
  FRenderMetrics.Free;
  FMeasureMetrics.Free;
  if FMeasureSurface <> nil then FMeasureSurface.EndRender;
  if FRenderSurface <> nil then FRenderSurface.EndRender;
  FRenderSurface := nil;
  FMeasureSurface := nil;
  FMeasureBitmap.Free;
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
  Invalidate;
end;

procedure TCustomThemedHexEditor.LoadBytes(const AData: TBytes);
begin
  FDataSource := THexDocument.Create(TBytesHexDataSource.Create(AData));
  FTopRow := 0;
  FBookmarks.Clear;
  FLastFind := nil;
  FCursorOffset := -1;
  FSelection.Clear(0);
  FModified.Clear;
  FUndoManager.Clear;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  FHScroll := 0;
  UpdateScrollBar;
  UpdateHScrollBar;
  DoBookmarksChange;
  DoSelectionChange;
  DoCursorChange;
  DoSearchChange;
  DoDataSourceChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.LoadFromDataSource(const ADataSource: IHexDataSource);
begin
  FDataSource := ADataSource;
  FTopRow := 0;
  FBookmarks.Clear;
  FLastFind := nil;
  FCursorOffset := -1;
  FSelection.Clear(0);
  FModified.Clear;
  FUndoManager.Clear;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  FHScroll := 0;
  UpdateScrollBar;
  UpdateHScrollBar;
  DoBookmarksChange;
  DoSelectionChange;
  DoCursorChange;
  DoSearchChange;
  DoDataSourceChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Clear;
begin
  FDataSource := nil;
  FTopRow := 0;
  FBookmarks.Clear;
  FLastFind := nil;
  FCursorOffset := -1;
  FSelection.Clear(0);
  FModified.Clear;
  FUndoManager.Clear;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  FHScroll := 0;
  UpdateScrollBar;
  UpdateHScrollBar;
  DoBookmarksChange;
  DoSelectionChange;
  DoCursorChange;
  DoSearchChange;
  DoDataSourceChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.UpdateMeasureMetrics(const AHorizontalScroll: Integer);
begin
  FMeasureSurface.SetFont(Font);
  FMeasureContext.Surface := FMeasureSurface;
  FMeasureContext.Options := FOptions;
  FMeasureContext.Theme := FTheme;
  FMeasureContext.DataSource := FDataSource;
  FMeasureContext.Bounds := ContentRect;
  FMeasureContext.HorizontalScrollValue := AHorizontalScroll;
  FRenderer.Measure(FMeasureContext, FMeasureMetrics);
end;

function TCustomThemedHexEditor.ContentRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
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
begin
  UpdateMeasureMetrics(FHScroll);
  FRowHeightCache := Max(1, FMeasureMetrics.RowHeight);
  Result := Max(1, (FMeasureMetrics.ContentBounds.Bottom - FMeasureMetrics.ContentBounds.Top) div FRowHeightCache);
end;

procedure TCustomThemedHexEditor.UpdateScrollBar;
begin
  UpdateScrollbars;
end;

procedure TCustomThemedHexEditor.UpdateScrollbars;
var
  LRowHeight, LHeaderHeight, LContentWidth, LThickness: Integer;
  LClientW, LClientH, LVisibleRows, LContentHeight, LVisibleWidth: Integer;
  LVNeeded, LHNeeded: Boolean;
  LTotalRows: Int64;
begin
  if not HandleAllocated then
    Exit;
  UpdateMeasureMetrics(FHScroll);
  LRowHeight := Max(1, FMeasureMetrics.RowHeight);
  LHeaderHeight := FMeasureMetrics.HeaderHeight;
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

  UpdateMeasureMetrics(FHScroll);
  if AY < FMeasureMetrics.HeaderHeight then
  begin
    Result.Area := hhaHeader;
    Exit;
  end;
  LRow := (AY - FMeasureMetrics.ContentBounds.Top) div Max(1, FMeasureMetrics.RowHeight);
  if LRow < 0 then
    Exit;
  Result.RowIndex := LRow;
  LRowOffset := (FTopRow + LRow) * FOptions.BytesPerRow;
  if LRowOffset >= FDataSource.Length then
    Exit;

  if AX < FMeasureMetrics.GutterWidth then
  begin
    Result.Area := hhaGutter;
    Result.Offset := LRowOffset;
    Exit;
  end;

  LGroupSize := EffectiveGroupSize;
  for I := 0 to FOptions.BytesPerRow - 1 do
  begin
    LCellX := FMeasureMetrics.GetHexCellX(I, LGroupSize);
    if (AX >= LCellX) and (AX < LCellX + FMeasureMetrics.CellWidth) then
    begin
      Result.Area := hhaHexCell;
      Result.ColumnIndex := I;
      Result.Offset := ClampOffset(LRowOffset + I);
      Result.RowIndex := LRow;
      Exit;
    end;
  end;

  if FOptions.ShowAscii and (AX >= FMeasureMetrics.AsciiStartX) then
  begin
    I := (AX - FMeasureMetrics.AsciiStartX) div Max(1, FMeasureMetrics.AsciiCellWidth);
    if (I >= 0) and (I < FOptions.BytesPerRow) then
    begin
      Result.Area := hhaAsciiCell;
      Result.ColumnIndex := I;
      Result.Offset := ClampOffset(LRowOffset + I);
      Result.RowIndex := LRow;
    end;
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
var
  LInfo: THexCursorOffsetInfo;
begin
  LInfo.CursorOffset := FCursorOffset;
  LInfo.ActiveEditArea := FActiveEditArea;
  LInfo.IsHighNibble := FIsHighNibble;
  if Assigned(FOnCursorChange) then
    FOnCursorChange(Self);
  if Assigned(FOnCursorOffsetInfoChanged) then FOnCursorOffsetInfoChanged(Self, LInfo);
end;

procedure TCustomThemedHexEditor.DoSelectionChange;
var
  LInfo: THexSelectionInfo;
begin
  LInfo.SelectionStart := FSelection.Start;
  LInfo.SelectionLength := FSelection.Length;
  LInfo.CursorOffset := FCursorOffset;
  LInfo.HasSelection := FSelection.Length > 0;
  LInfo.SelectionEnd := FSelection.Start;
  if LInfo.HasSelection then Inc(LInfo.SelectionEnd, FSelection.Length - 1);
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
  if Assigned(FOnSelectionInfoChanged) then FOnSelectionInfoChanged(Self, LInfo);
end;

procedure TCustomThemedHexEditor.DoModifiedChange;
var
  LInfo: THexModifiedInfo;
begin
  LInfo.Modified := GetModified;
  LInfo.CanSave := CanSave;
  if Assigned(FOnModifiedChange) then
    FOnModifiedChange(Self);
  if Assigned(FOnModifiedInfoChanged) then FOnModifiedInfoChanged(Self, LInfo);
end;

procedure TCustomThemedHexEditor.DoUndoRedoStateChange;
var
  LInfo: THexUndoRedoStateInfo;
begin
  LInfo.CanUndo := CanUndo;
  LInfo.CanRedo := CanRedo;
  if Assigned(FOnUndoRedoStateChange) then
    FOnUndoRedoStateChange(Self);
  if Assigned(FOnUndoRedoStateInfoChanged) then FOnUndoRedoStateInfoChanged(Self, LInfo);
end;

procedure TCustomThemedHexEditor.DoEditModeChange;
var
  LInfo: THexEditModeInfo;
begin
  LInfo.InsertMode := FInsertMode;
  LInfo.ActiveEditArea := FActiveEditArea;
  if FInsertMode then LInfo.EditModeText := 'Insert' else LInfo.EditModeText := 'Overwrite';
  if FActiveEditArea = hhaAsciiCell then LInfo.ActiveAreaText := 'ASCII' else LInfo.ActiveAreaText := 'Hex';
  if Assigned(FOnEditModeChange) then
    FOnEditModeChange(Self);
  if Assigned(FOnEditModeInfoChanged) then FOnEditModeInfoChanged(Self, LInfo);
end;

procedure TCustomThemedHexEditor.DoSearchChange;
var
  LInfo: THexSearchInfo;
begin
  LInfo := Default(THexSearchInfo);
  LInfo.MatchCount := FSearchMatches.Count;
  LInfo.ActiveMatchIndex := FActiveMatchIndex;
  LInfo.HasSearch := LInfo.MatchCount > 0;
  LInfo.HasActiveMatch := GetActiveSearchMatch <> nil;
  LInfo.Offset := -1;
  if LInfo.HasActiveMatch then
  begin
    LInfo.Offset := ActiveSearchMatch.Offset;
    LInfo.Length := ActiveSearchMatch.Length;
    LInfo.PatternIndex := ActiveSearchMatch.PatternIndex;
    LInfo.HammingDistance := ActiveSearchMatch.HammingDistance;
  end;
  if Assigned(FOnSearchChange) then
    FOnSearchChange(Self);
  if Assigned(FOnSearchInfoChanged) then FOnSearchInfoChanged(Self, LInfo);
end;

procedure TCustomThemedHexEditor.DoBookmarksChange;
begin
  if Assigned(FOnBookmarksChange) then
    FOnBookmarksChange(Self);
end;

procedure TCustomThemedHexEditor.DoDataSourceChange;
var
  LInfo: THexDataSourceInfo;
begin
  LInfo.DataSource := FDataSource;
  LInfo.DataLength := GetDataLength;
  LInfo.CanWrite := (FDataSource <> nil) and FDataSource.CanWrite;
  LInfo.HasData := LInfo.DataLength > 0;
  if Assigned(FOnDataSourceChange) then
    FOnDataSourceChange(Self);
  if Assigned(FOnDataSourceInfoChanged) then FOnDataSourceInfoChanged(Self, LInfo);
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
  DoCursorChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.GotoOffset(const AOffset: Int64);
begin
  SetCursorOffset(AOffset);
end;

procedure TCustomThemedHexEditor.SelectRange(const AStart, ALength: Int64);
begin
  if (AStart < 0) or (ALength < 0) or (AStart > DataLength) or (ALength > DataLength - AStart) then
    raise EArgumentOutOfRangeException.Create('Selection range');
  FSelection.SetRange(AStart, ALength);
  FIsHighNibble := True;
  FSelectionAnchor := AStart;
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
  LDocument: IHexDocumentAccess;
  LCommand: TEditCommand;
  LOp: THexPatchOperation;
begin
  if Supports(FDataSource, IHexDocumentAccess, LDocument) then Exit(LDocument.CreatePatch);
  Result := THexPatchFile.Create;
  if FDataSource <> nil then
    Result.OriginalLength := FDataSource.Length;
  for LCommand in FUndoManager.UndoCommands do
  begin
    Result.OriginalLength := Result.OriginalLength + Length(LCommand.OldData) - Length(LCommand.NewData);
    if LCommand.Kind = ekReplace then
    begin
      if Length(LCommand.OldData) > 0 then
      begin
        LOp := THexPatchOperation.Create;
        LOp.OperationType := hpoDelete;
        LOp.Offset := LCommand.Offset;
        LOp.Length := Length(LCommand.OldData);
        Result.Operations.Add(LOp);
      end;
      if Length(LCommand.NewData) > 0 then
      begin
        LOp := THexPatchOperation.Create;
        LOp.OperationType := hpoInsert;
        LOp.Offset := LCommand.Offset;
        LOp.Data := Copy(LCommand.NewData);
        LOp.Length := Length(LCommand.NewData);
        Result.Operations.Add(LOp);
      end;
      Continue;
    end;
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
  if Key = VK_F3 then
  begin
    if ssShift in Shift then RequestFindPrevious else RequestFindNext;
    Key := 0;
    Exit;
  end;
  if ssCtrl in Shift then
    case Key of
      Ord('F'): begin RequestFind; Key := 0; Exit; end;
      Ord('H'): begin RequestReplace; Key := 0; Exit; end;
      Ord('G'): begin RequestGotoOffset; Key := 0; Exit; end;
    end;
  if FDataSource = nil then
  begin
    inherited KeyDown(Key, Shift);
    Exit;
  end;
  if ssCtrl in Shift then
  begin
    case Key of
      Ord('A'): begin SelectAllBytes; Key := 0; Exit; end;
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
    end;
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
    DoSelectionChange;
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
    SetActiveEditArea(LHit.Area);
    FCursorOffset := LHit.Offset;
    FIsHighNibble := True;
    FSelectionAnchor := LHit.Offset;
    FDragging := True;
    FSelection.Clear(FCursorOffset);
    DoCursorChange;
    DoSelectionChange;
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
var
  LDocument: IHexDocumentAccess;
begin
  if Supports(FDataSource, IHexDocumentAccess, LDocument) and not LDocument.IsOffsetModified(AOffset) then
    FModified.Remove(AOffset)
  else FModified.AddOrSetValue(AOffset, True);
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
    ClearSearch;
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
    ClearSearch;
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
    ClearSearch;
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
  begin
    FIsHighNibble := False;
    DoCursorChange;
  end
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
    DoSelectionChange;
    DoCursorChange;
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
  if not CanEdit then Exit;
  LCommand := FUndoManager.PopUndo;
  if LCommand = nil then
    Exit;
  try
  case LCommand.Kind of
    ekOverwrite: ApplyOverwrite(LCommand.Offset, LCommand.OldData, False);
    ekInsert: ApplyDelete(LCommand.Offset, Length(LCommand.NewData), False);
    ekDelete: ApplyInsert(LCommand.Offset, LCommand.OldData, False);
      ekReplace: ApplyReplaceRange(LCommand.Offset, Length(LCommand.NewData), LCommand.OldData, False);
  end;
  except
    FUndoManager.PushUndo(LCommand);
    raise;
  end;
  FUndoManager.PushRedo(LCommand);
  if not Modified then FModified.Clear;
  ClearSearch;
  SetCursorOffset(LCommand.Offset);
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Redo;
var
  LCommand: TEditCommand;
begin
  if not CanEdit then Exit;
  LCommand := FUndoManager.PopRedo;
  if LCommand = nil then
    Exit;
  try
  case LCommand.Kind of
    ekOverwrite: ApplyOverwrite(LCommand.Offset, LCommand.NewData, False);
    ekInsert: ApplyInsert(LCommand.Offset, LCommand.NewData, False);
    ekDelete: ApplyDelete(LCommand.Offset, Length(LCommand.OldData), False);
      ekReplace: ApplyReplaceRange(LCommand.Offset, Length(LCommand.OldData), LCommand.NewData, False);
  end;
  except
    FUndoManager.PushRedo(LCommand);
    raise;
  end;
  FUndoManager.PushUndo(LCommand);
  ClearSearch;
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
begin
  UpdateMeasureMetrics(0);
  Result := FRenderer.MeasureContentWidth(FMeasureContext, FMeasureMetrics);
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
begin
  if (FDataSource = nil) or FSelection.IsEmpty then Exit;
  if FActiveEditArea = hhaAsciiCell then CopyAsciiSelection else CopyHexSelection;
  if ADelete and CanEdit then DeleteSelection;
end;

procedure TCustomThemedHexEditor.PasteClipboard;
var
  LText: string;
  LBytes: TBytes;
  LOffset: Int64;
  LReplaceLength: Integer;
begin
  if not CanEdit then Exit;
  if not THexClipboard.TryReadBytes(LBytes) then
  begin
    LText := Clipboard.AsText;
    if LText = '' then Exit;
    if not THexSearchService.TryParseHexBytes(LText, LBytes) then LBytes := FTextEncoding.GetBytes(LText);
  end;
  if Length(LBytes) = 0 then Exit;
  LOffset := Max(Int64(0), FCursorOffset);
  if not FSelection.IsEmpty then
  begin
    if FSelection.Length > MaxInt then raise ERangeError.Create('Selection is too large');
    LOffset := FSelection.Start;
    LReplaceLength := Integer(FSelection.Length);
  end
  else if FInsertMode then LReplaceLength := 0
  else LReplaceLength := Integer(Min(Int64(Length(LBytes)), DataLength - LOffset));
  ApplyReplaceRange(LOffset, LReplaceLength, LBytes, True);
  ClearSelection;
  SetCursorOffset(LOffset + Length(LBytes));
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
  DoSelectionChange;
  DoCursorChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.Search(const AText: string; const AKind: THexSearchKind);
var
  LQuery: THexSearchQuery;
  LMatches: TObjectList<THexSearchMatch>;
begin
  LQuery := THexSearchQuery.Create;
  try
    LQuery.Text := AText;
    LQuery.EncodingName := FEncodingName;
    LQuery.MaxResults := 0;
    case AKind of
      hskText: LQuery.Mode := hsmText;
      hskSignature, hskPattern: LQuery.Mode := hsmPattern;
    else
      LQuery.Mode := hsmHex;
    end;
    LMatches := SearchWithProvider('Native', LQuery);
    try
      SetAdvancedSearchMatches(LMatches);
    finally
      LMatches.Free;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TCustomThemedHexEditor.SearchRule(const ARule: THexSearchRule);
var
  LEngine: THexSearchRuleEngine;
  LMatches: TObjectList<THexSearchRuleMatch>;
  I: Integer;
begin
  FLastFind := nil;
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
  if (FSearchMatches.Count = 0) and (FActiveMatchIndex = -1) then Exit;
  FSearchMatches.Clear;
  FActiveMatchIndex := -1;
  DoSearchChange;
  Invalidate;
end;

function TCustomThemedHexEditor.SearchMatchCount: Integer;
begin
  Result := FSearchMatches.Count;
end;

procedure TCustomThemedHexEditor.Paint;
begin
  UpdateScrollbars;
  FRenderSurface.BeginRender(Canvas);
  try
    FRenderSurface.SetFont(Font);
    FRenderContext.Surface := FRenderSurface;
    FRenderContext.Bounds := ContentRect;
    FRenderContext.DataSource := FDataSource;
    FRenderContext.Options := FOptions;
    FRenderContext.Theme := FTheme;
    FRenderContext.Selection := FSelection;
    FRenderContext.Bookmarks := FBookmarks;
    FRenderContext.ModifiedOffsets := FModified;
    FRenderContext.AdvancedSearchMatches := FSearchMatches;
    FRenderContext.ActiveSearchMatch := nil;
    if (FActiveMatchIndex >= 0) and (FActiveMatchIndex < FSearchMatches.Count) then
      FRenderContext.ActiveSearchMatch := FSearchMatches[FActiveMatchIndex];
    FRenderContext.FirstVisibleOffset := FTopRow * FOptions.BytesPerRow;
    FRenderContext.HorizontalScrollValue := FHScroll;
    FRenderContext.CursorOffset := FCursorOffset;
    FRenderContext.HoverOffset := FHoverOffset;
    FRenderContext.Focused := Focused;
    FRenderContext.Enabled := Enabled;
    FRenderContext.IsHighNibble := FIsHighNibble;
    FRenderContext.InsertMode := FInsertMode;
    FRenderContext.ActiveEditArea := FActiveEditArea;
    FRenderer.Measure(FRenderContext, FRenderMetrics);
    FRenderer.Render(FRenderContext, FRenderMetrics);
    FVScrollBar.Paint(FRenderSurface, FTheme);
    FHScrollBar.Paint(FRenderSurface, FTheme);
    if FVScrollBar.Visible and FHScrollBar.Visible then
      FRenderSurface.FillRectangle(FTheme.ScrollBarTrackColor,
        Rect(ClientWidth - FVScrollBar.Thickness, ClientHeight - FHScrollBar.Thickness,
          ClientWidth, ClientHeight));
  finally
    FRenderSurface.EndRender;
  end;
end;

function TCustomThemedHexEditor.GetDataLength: Int64;
begin
  if FDataSource = nil then Result := 0 else Result := FDataSource.Length;
end;

function TCustomThemedHexEditor.GetModified: Boolean;
var
  LDocument: IHexDocumentAccess;
begin
  if Supports(FDataSource, IHexDocumentAccess, LDocument) then Result := LDocument.GetDirty
  else Result := FModified.Count > 0;
end;

function TCustomThemedHexEditor.TryReadBytes(const AOffset: Int64; const ACount: Integer; out ABytes: TBytes): Boolean;
var
  LBuffer: TBytes;
  LRead, LCount: Integer;
begin
  ABytes := nil;
  Result := (FDataSource <> nil) and (AOffset >= 0) and (ACount >= 0) and
    (AOffset <= DataLength) and (Int64(ACount) <= DataLength - AOffset);
  if not Result then Exit;
  SetLength(ABytes, ACount);
  SetLength(LBuffer, Min(65536, ACount));
  LRead := 0;
  while LRead < ACount do
  begin
    LCount := FDataSource.Read(AOffset + LRead, LBuffer, Min(65536, ACount - LRead));
    if (LCount <= 0) or (LCount > ACount - LRead) or (Length(LBuffer) < LCount) then
    begin
      ABytes := nil;
      Exit(False);
    end;
    Move(LBuffer[0], ABytes[LRead], LCount);
    Inc(LRead, LCount);
  end;
end;

function TCustomThemedHexEditor.GetSelectedBytes: TBytes;
begin
  if FSelection.Length > MaxInt then raise ERangeError.Create('Selection exceeds the byte-array size limit');
  if not TryReadBytes(FSelection.Start, Integer(FSelection.Length), Result) then
    raise EReadError.Create('The selection could not be read');
end;

procedure TCustomThemedHexEditor.LoadFile(const APath: string);
begin
  LoadFromDataSource(THexDocument.Create(APath));
  if DataLength > 0 then GotoOffset(0);
end;

function TCustomThemedHexEditor.CanSave: Boolean;
var
  LDocument: IHexDocumentAccess;
begin
  Result := Supports(FDataSource, IHexDocumentAccess, LDocument);
  if Result then Result := LDocument.GetFilePath <> '';
end;

procedure TCustomThemedHexEditor.Save;
var
  LDocument: IHexDocumentAccess;
begin
  if not Supports(FDataSource, IHexDocumentAccess, LDocument) then
    raise EInvalidOperation.Create('Use SaveAs to save this data source');
  LDocument.Save;
  FModified.Clear;
  DoModifiedChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SaveAs(const APath: string);
var
  LDocument: IHexDocumentAccess;
  LSource: IHexDataSource;
begin
  if FDataSource = nil then raise EInvalidOperation.Create('No document is loaded');
  if Supports(FDataSource, IHexDocumentAccess, LDocument) then LDocument.SaveAs(APath)
  else
  begin
    LSource := THexDocument.Create(FDataSource);
    Supports(LSource, IHexDocumentAccess, LDocument);
    LDocument.SaveAs(APath);
    FDataSource := LSource;
    DoDataSourceChange;
  end;
  FModified.Clear;
  DoModifiedChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.InsertBytes(const AOffset: Int64; const ABytes: TBytes);
begin
  if not CanEdit then raise EInvalidOperation.Create('The editor is read only');
  if (AOffset < 0) or (AOffset > DataLength) then raise EArgumentOutOfRangeException.Create('AOffset');
  if Length(ABytes) = 0 then Exit;
  ApplyInsert(AOffset, ABytes, True);
  ClearSearch;
  SetCursorOffset(AOffset);
  Invalidate;
end;

procedure TCustomThemedHexEditor.OverwriteBytes(const AOffset: Int64; const ABytes: TBytes);
begin
  if not CanEdit then raise EInvalidOperation.Create('The editor is read only');
  if (AOffset < 0) or (AOffset > DataLength) or (Length(ABytes) > DataLength - AOffset) then
    raise EArgumentOutOfRangeException.Create('Write range');
  if Length(ABytes) = 0 then Exit;
  ApplyOverwrite(AOffset, ABytes, True);
  ClearSearch;
  SetCursorOffset(AOffset);
  Invalidate;
end;

procedure TCustomThemedHexEditor.DeleteBytes(const AOffset, ALength: Int64);
begin
  if not CanEdit then raise EInvalidOperation.Create('The editor is read only');
  if (AOffset < 0) or (ALength < 0) or (AOffset > DataLength) or (ALength > DataLength - AOffset) or
    (ALength > MaxInt) then raise EArgumentOutOfRangeException.Create('Delete range');
  if ALength = 0 then Exit;
  ApplyDelete(AOffset, ALength, True);
  ClearSearch;
  ClearSelection;
  SetCursorOffset(AOffset);
  Invalidate;
end;

procedure TCustomThemedHexEditor.DeleteSelection;
begin
  if not FSelection.IsEmpty then DeleteBytes(FSelection.Start, FSelection.Length);
end;

procedure TCustomThemedHexEditor.ClearSelection;
begin
  FSelection.Clear(FCursorOffset);
  DoSelectionChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SelectAllBytes;
begin
  SelectRange(0, DataLength);
end;

procedure TCustomThemedHexEditor.ClearUndoRedo;
begin
  FUndoManager.Clear;
  DoUndoRedoStateChange;
end;

function TCustomThemedHexEditor.ExportUndoStack: TObjectList<TEditCommand>;
var
  LCommand: TEditCommand;
begin
  Result := TObjectList<TEditCommand>.Create(True);
  try
    for LCommand in FUndoManager.UndoCommands do
      Result.Add(TEditCommand.Create(LCommand.Kind, LCommand.Offset, LCommand.OldData, LCommand.NewData));
  except
    Result.Free;
    raise;
  end;
end;

function TCustomThemedHexEditor.ExportRedoStack: TObjectList<TEditCommand>;
var
  LCommand: TEditCommand;
begin
  Result := TObjectList<TEditCommand>.Create(True);
  try
    for LCommand in FUndoManager.RedoCommands do
      Result.Add(TEditCommand.Create(LCommand.Kind, LCommand.Offset, LCommand.OldData, LCommand.NewData));
  except
    Result.Free;
    raise;
  end;
end;

procedure TCustomThemedHexEditor.ImportUndoRedoStacks(const AUndo, ARedo: TList<TEditCommand>);
var
  LSession: THexSessionData;
  LCommand: TEditCommand;
begin
  LSession := CreateSessionData;
  try
    LSession.UndoStack.Clear;
    LSession.RedoStack.Clear;
    if AUndo <> nil then
      for LCommand in AUndo do
        LSession.UndoStack.Add(TEditCommand.Create(LCommand.Kind, LCommand.Offset, LCommand.OldData, LCommand.NewData));
    if ARedo <> nil then
      for LCommand in ARedo do
        LSession.RedoStack.Add(TEditCommand.Create(LCommand.Kind, LCommand.Offset, LCommand.OldData, LCommand.NewData));
    LSession.Validate;
    FUndoManager.Restore(LSession.UndoStack.ToArray, LSession.RedoStack.ToArray);
    DoUndoRedoStateChange;
  finally
    LSession.Free;
  end;
end;

procedure TCustomThemedHexEditor.CopyRawSelection;
begin
  if not FSelection.IsEmpty then THexClipboard.WriteBytes(SelectedBytes);
end;

procedure TCustomThemedHexEditor.CopyHexSelection;
begin
  if not FSelection.IsEmpty then Clipboard.AsText := THexExporter.ToPlainHex(SelectedBytes);
end;

procedure TCustomThemedHexEditor.CopyAsciiSelection;
begin
  if not FSelection.IsEmpty then Clipboard.AsText := FTextEncoding.GetString(SelectedBytes);
end;

procedure TCustomThemedHexEditor.PasteInsert;
var
  LMode: Boolean;
begin
  LMode := FInsertMode;
  try
    FInsertMode := True;
    PasteClipboard;
  finally
    FInsertMode := LMode;
  end;
end;

procedure TCustomThemedHexEditor.PasteOverwrite;
var
  LMode: Boolean;
begin
  LMode := FInsertMode;
  try
    FInsertMode := False;
    PasteClipboard;
  finally
    FInsertMode := LMode;
  end;
end;

function TCustomThemedHexEditor.ExportRange(const AOffset: Int64; const ALength: Integer; const AFormat: string): string;
var
  LBytes: TBytes;
begin
  if not TryReadBytes(AOffset, ALength, LBytes) then raise EArgumentOutOfRangeException.Create('Export range');
  if SameText(AFormat, 'hex') then Result := THexExporter.ToPlainHex(LBytes)
  else if SameText(AFormat, 'ascii') then Result := FTextEncoding.GetString(LBytes)
  else if SameText(AFormat, 'base64') then Result := THexExporter.ToBase64(LBytes)
  else if SameText(AFormat, 'csharp') then Result := THexExporter.ToCSharpArray(LBytes)
  else if SameText(AFormat, 'csharp-readonly') then Result := THexExporter.ToCSharpReadOnlyArray(LBytes)
  else if SameText(AFormat, 'html') then Result := THexExporter.ToHtmlTable(LBytes, AOffset, Options.BytesPerRow)
  else if SameText(AFormat, 'json') then Result := THexExporter.ToJsonArray(LBytes)
  else if SameText(AFormat, 'sql') then Result := THexExporter.ToSqlVarBinary(LBytes)
  else if SameText(AFormat, 'dump') then Result := THexExporter.ToTextDump(LBytes, AOffset, Options.BytesPerRow)
  else raise EArgumentException.Create('Unknown export format: ' + AFormat);
end;

function TCustomThemedHexEditor.ExportSelection(const AFormat: string): string;
begin
  if FSelection.Length > MaxInt then raise ERangeError.Create('Selection is too large');
  Result := ExportRange(FSelection.Start, Integer(FSelection.Length), AFormat);
end;

function TCustomThemedHexEditor.AddBookmark(const AOffset: Int64; const AName: string;
  const AColor: TThemeColor): THexBookmark;
begin
  if (AOffset < 0) or (AOffset >= DataLength) then raise EArgumentOutOfRangeException.Create('Bookmark offset');
  Result := THexBookmark.Create;
  Result.Offset := AOffset;
  Result.Name := AName;
  Result.Color := AColor;
  Result.HasColor := True;
  FBookmarks.Add(Result);
  DoBookmarksChange;
  Invalidate;
end;

function TCustomThemedHexEditor.RemoveBookmark(const AOffset: Int64): Boolean;
begin
  Result := FBookmarks.Remove(AOffset);
  if Result then
  begin
    DoBookmarksChange;
    Invalidate;
  end;
end;

procedure TCustomThemedHexEditor.RenameBookmark(const AOffset: Int64; const AName: string);
var
  LBookmark: THexBookmark;
begin
  if not FBookmarks.TryGet(AOffset, LBookmark) then raise EArgumentException.Create('Bookmark not found');
  LBookmark.Name := AName;
  DoBookmarksChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.UpdateBookmark(const AOffset: Int64; const AName: string;
  const AColor: TThemeColor);
var
  LBookmark: THexBookmark;
begin
  if not FBookmarks.TryGet(AOffset, LBookmark) then raise EArgumentException.Create('Bookmark not found');
  LBookmark.Name := AName;
  LBookmark.Color := AColor;
  LBookmark.HasColor := True;
  DoBookmarksChange;
  Invalidate;
end;

function TCustomThemedHexEditor.TryGetBookmark(const AOffset: Int64; out ABookmark: THexBookmark): Boolean;
begin
  Result := FBookmarks.TryGet(AOffset, ABookmark);
end;

function TCustomThemedHexEditor.GetBookmarkList: TArray<THexBookmark>;
begin
  Result := FBookmarks.Values;
  TArray.Sort<THexBookmark>(Result, TComparer<THexBookmark>.Construct(
    function(const ALeft, ARight: THexBookmark): Integer
    begin
      if ALeft.Offset < ARight.Offset then Result := -1
      else if ALeft.Offset > ARight.Offset then Result := 1
      else Result := 0;
    end));
end;

function TCustomThemedHexEditor.GoToBookmark(const AOffset: Int64): Boolean;
begin
  Result := FBookmarks.Contains(AOffset);
  if Result then GotoOffset(AOffset);
end;

function TCustomThemedHexEditor.GoToNextBookmark: Boolean;
var
  LBookmark: THexBookmark;
  LBest, LFirst: Int64;
begin
  LBest := High(Int64);
  LFirst := High(Int64);
  for LBookmark in FBookmarks.Values do
  begin
    LFirst := Min(LFirst, LBookmark.Offset);
    if LBookmark.Offset > FCursorOffset then LBest := Min(LBest, LBookmark.Offset);
  end;
  if LBest = High(Int64) then LBest := LFirst;
  Result := LBest <> High(Int64);
  if Result then GotoOffset(LBest);
end;

function TCustomThemedHexEditor.GoToPreviousBookmark: Boolean;
var
  LBookmark: THexBookmark;
  LBest, LLast: Int64;
begin
  LBest := -1;
  LLast := -1;
  for LBookmark in FBookmarks.Values do
  begin
    LLast := Max(LLast, LBookmark.Offset);
    if LBookmark.Offset < FCursorOffset then LBest := Max(LBest, LBookmark.Offset);
  end;
  if LBest < 0 then LBest := LLast;
  Result := LBest >= 0;
  if Result then GotoOffset(LBest);
end;

function TCustomThemedHexEditor.InspectSelection(const ABigEndian: Boolean): TArray<TInspectorRow>;
var
  LOffset: Int64;
begin
  LOffset := FCursorOffset;
  if not FSelection.IsEmpty then LOffset := FSelection.Start;
  Result := THexDataInspector.Inspect(FDataSource, LOffset, ABigEndian);
end;

function TCustomThemedHexEditor.SearchWithProvider(const AName: string;
  const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
var
  LProvider: IHexSearchProvider;
begin
  LProvider := FSearchProviders.Find(AName);
  if LProvider = nil then raise EArgumentException.Create('Search provider not found: ' + AName);
  Result := LProvider.Search(FDataSource, AQuery);
end;

procedure TCustomThemedHexEditor.SetAdvancedSearchMatches(const AMatches: TList<THexSearchMatch>);
var
  LMatches, LOld: TObjectList<THexSearchMatch>;
  LMatch: THexSearchMatch;
begin
  LMatches := TObjectList<THexSearchMatch>.Create(True);
  try
    if AMatches <> nil then
      for LMatch in AMatches do
      begin
        if (LMatch.Offset < 0) or (LMatch.Length <= 0) or (LMatch.Offset > DataLength) or
          (LMatch.Length > DataLength - LMatch.Offset) then raise EArgumentException.Create('Invalid search match');
        LMatches.Add(LMatch.Clone);
      end;
    LOld := FSearchMatches;
    FSearchMatches := LMatches;
    LMatches := LOld;
    FActiveMatchIndex := -1;
    FLastFind := nil;
    if FSearchMatches.Count > 0 then
    begin
      FActiveMatchIndex := 0;
      NavigateToActiveMatch;
    end;
    DoSearchChange;
    Invalidate;
  finally
    LMatches.Free;
  end;
end;

function TCustomThemedHexEditor.SearchAny(const APatterns: TArray<TBytes>): TObjectList<THexSearchMatch>;
var
  LQuery: THexSearchQuery;
begin
  LQuery := THexSearchQuery.Create;
  try
    LQuery.Patterns := APatterns;
    LQuery.MaxResults := 0;
    Result := SearchWithProvider('Native', LQuery);
  finally
    LQuery.Free;
  end;
end;

function TCustomThemedHexEditor.SearchAnyText(const ATexts: TArray<string>;
  const AEncoding: TEncoding): TObjectList<THexSearchMatch>;
var
  LPatterns: TArray<TBytes>;
  LEncoding: TEncoding;
  I: Integer;
begin
  LEncoding := AEncoding;

  SetLength(LPatterns, Length(ATexts));
  for I := 0 to High(ATexts) do
    if LEncoding = nil then LPatterns[I] := FTextEncoding.GetBytes(ATexts[I])
    else LPatterns[I] := LEncoding.GetBytes(ATexts[I]);
  Result := SearchAny(LPatterns);
end;

function TCustomThemedHexEditor.SearchApproximate(const APattern: TBytes;
  const AMaxHammingDistance: Integer): TObjectList<THexSearchMatch>;
var
  LQuery: THexSearchQuery;
begin
  LQuery := THexSearchQuery.Create;
  try
    LQuery.Mode := hsmApproximate;
    LQuery.RawBytes := APattern;
    LQuery.MaxHammingDistance := AMaxHammingDistance;
    LQuery.MaxResults := 0;
    Result := SearchWithProvider('Native', LQuery);
  finally
    LQuery.Free;
  end;
end;

function TCustomThemedHexEditor.FindText(const AText: string; const AEncoding: TEncoding): THexSearchMatch;
var
  LQuery: THexSearchQuery;
  LMatches: TObjectList<THexSearchMatch>;
begin
  Result := nil;
  LQuery := THexSearchQuery.Create;
  try
    LQuery.Text := AText;
    LQuery.Encoding := AEncoding;
    if LQuery.Encoding = nil then LQuery.EncodingName := FEncodingName;
    LQuery.MaxResults := 1;
    LMatches := SearchWithProvider('Native', LQuery);
    try
      if LMatches.Count > 0 then Result := LMatches[0].Clone;
    finally
      LMatches.Free;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TCustomThemedHexEditor.SetEncodingName(const AName: string);
begin
  FTextEncoding.SetName(AName);
  FEncodingName := FTextEncoding.Name;
end;

function TCustomThemedHexEditor.GetSupportedEncodings: TArray<string>;
begin
  Result := TArray<string>.Create('UTF-8', 'UTF-16LE', 'UTF-16BE', 'UTF-32LE', 'UTF-32BE', 'ISO-8859-1', 'ASCII', 'ANSI');
end;

function TCustomThemedHexEditor.DetectFileEncoding: THexTextEncoding;
begin
  Result := THexTextEncoding.Create(DetectEncodingName);
end;

function TCustomThemedHexEditor.DetectEncodingName: string;
var
  LBytes: TBytes;
  I, J, LCount, LNeeded: Integer;
  LCodePoint: Cardinal;
  LValid: Boolean;
begin
  Result := 'ANSI';
  if not TryReadBytes(0, Integer(Min(Int64(65536), DataLength)), LBytes) then Exit;
  LCount := Length(LBytes);
  if (LCount >= 4) and (LBytes[0] = $FF) and (LBytes[1] = $FE) and (LBytes[2] = 0) and (LBytes[3] = 0) then Exit('UTF-32LE');
  if (LCount >= 4) and (LBytes[0] = 0) and (LBytes[1] = 0) and (LBytes[2] = $FE) and (LBytes[3] = $FF) then Exit('UTF-32BE');
  if (LCount >= 3) and (LBytes[0] = $EF) and (LBytes[1] = $BB) and (LBytes[2] = $BF) then begin Result := 'UTF-8'; Exit; end;
  if (LCount >= 2) and (LBytes[0] = $FF) and (LBytes[1] = $FE) then begin Result := 'UTF-16LE'; Exit; end;
  if (LCount >= 2) and (LBytes[0] = $FE) and (LBytes[1] = $FF) then begin Result := 'UTF-16BE'; Exit; end;
  I := 0;
  LValid := True;
  while I < LCount do
  begin
    if LBytes[I] < $80 then
    begin
      Inc(I);
      Continue;
    end;
    if (LBytes[I] >= $C2) and (LBytes[I] <= $DF) then
    begin LNeeded := 1; LCodePoint := LBytes[I] and $1F; end
    else if (LBytes[I] >= $E0) and (LBytes[I] <= $EF) then
    begin LNeeded := 2; LCodePoint := LBytes[I] and $0F; end
    else if (LBytes[I] >= $F0) and (LBytes[I] <= $F4) then
    begin LNeeded := 3; LCodePoint := LBytes[I] and $07; end
    else begin LValid := False; Break; end;
    if I + LNeeded >= LCount then
    begin
      LValid := DataLength > LCount;
      Break;
    end;
    for J := 1 to LNeeded do
    begin
      if (LBytes[I + J] and $C0) <> $80 then LValid := False;
      LCodePoint := (LCodePoint shl 6) or (LBytes[I + J] and $3F);
    end;
    if ((LNeeded = 1) and (LCodePoint < $80)) or ((LNeeded = 2) and (LCodePoint < $800)) or
      ((LNeeded = 3) and (LCodePoint < $10000)) or (LCodePoint > $10FFFF) or
      ((LCodePoint >= $D800) and (LCodePoint <= $DFFF)) then LValid := False;
    if not LValid then Break;
    Inc(I, LNeeded + 1);
  end;
  if LValid then Result := 'UTF-8';
end;

function TCustomThemedHexEditor.CreateSessionData: THexSessionData;
var
  LCommand: TEditCommand;
  LBookmarks: TArray<THexBookmark>;
  I: Integer;
begin
  Result := THexSessionData.Capture(FDataSource);
  try
    Result.CursorOffset := FCursorOffset;
    Result.SelectionStart := FSelection.Start;
    Result.SelectionLength := FSelection.Length;
    Result.TopRow := FTopRow;
    Result.HorizontalOffset := FHScroll;
    Result.InsertMode := FInsertMode;
    Result.AsciiArea := FActiveEditArea = hhaAsciiCell;
    Result.ReadOnly := FOptions.ReadOnly or not FDataSource.CanWrite;
    Result.BytesPerRow := FOptions.BytesPerRow;
    Result.ByteGroupSize := FOptions.ByteGroupSize;
    Result.EncodingName := FEncodingName;
    Result.ModifiedOffsets := FModified.Keys.ToArray;
    for LCommand in FUndoManager.UndoCommands do
      Result.UndoStack.Add(TEditCommand.Create(LCommand.Kind, LCommand.Offset, LCommand.OldData, LCommand.NewData));
    for LCommand in FUndoManager.RedoCommands do
      Result.RedoStack.Add(TEditCommand.Create(LCommand.Kind, LCommand.Offset, LCommand.OldData, LCommand.NewData));
    LBookmarks := FBookmarks.Values;
    SetLength(Result.Bookmarks, Length(LBookmarks));
    for I := 0 to High(LBookmarks) do
    begin
      Result.Bookmarks[I].Offset := LBookmarks[I].Offset;
      Result.Bookmarks[I].Name := LBookmarks[I].Name;
      Result.Bookmarks[I].Color := LBookmarks[I].Color;
      Result.Bookmarks[I].HasColor := LBookmarks[I].HasColor;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TCustomThemedHexEditor.CreateSessionJson: string;
var
  LSession: THexSessionData;
begin
  LSession := CreateSessionData;
  try Result := THexSessionSerializer.ToJson(LSession); finally LSession.Free; end;
end;

procedure TCustomThemedHexEditor.SaveSession(const APath: string);
begin
  TFile.WriteAllText(APath, CreateSessionJson, TEncoding.UTF8);
end;

procedure TCustomThemedHexEditor.RestoreSessionData(const ASession: THexSessionData);
var
  LSource: IHexDataSource;
  LBookmark: THexBookmark;
  LOffset: Int64;
  I: Integer;
begin
  if ASession = nil then raise EArgumentNilException.Create('ASession');
  ASession.Validate;
  LSource := ASession.RestoreSource;
  if (ASession.SelectionStart < 0) or (ASession.SelectionStart > LSource.Length) or
    (ASession.SelectionLength < 0) or (ASession.SelectionLength > LSource.Length - ASession.SelectionStart) or
    (ASession.CursorOffset < -1) or (ASession.CursorOffset > LSource.Length) then
    raise EArgumentException.Create('Session selection is outside the document');
  for I := 0 to High(ASession.Bookmarks) do
    if (ASession.Bookmarks[I].Offset < 0) or (ASession.Bookmarks[I].Offset >= LSource.Length) then
      raise EArgumentException.Create('Session bookmark is outside the document');
  LoadFromDataSource(LSource);
  FOptions.BytesPerRow := ASession.BytesPerRow;
  FOptions.ByteGroupSize := ASession.ByteGroupSize;
  FOptions.ReadOnly := ASession.ReadOnly;
  SetEncodingName(ASession.EncodingName);
  FUndoManager.Restore(ASession.UndoStack.ToArray, ASession.RedoStack.ToArray);
  FBookmarks.Clear;
  for I := 0 to High(ASession.Bookmarks) do
  begin
    LBookmark := THexBookmark.Create;
    LBookmark.Offset := ASession.Bookmarks[I].Offset;
    LBookmark.Name := ASession.Bookmarks[I].Name;
    LBookmark.Color := ASession.Bookmarks[I].Color;
    LBookmark.HasColor := ASession.Bookmarks[I].HasColor;
    FBookmarks.Add(LBookmark);
  end;
  FModified.Clear;
  for LOffset in ASession.ModifiedOffsets do
    if (LOffset >= 0) and (LOffset < DataLength) then FModified.AddOrSetValue(LOffset, True);
  SetInsertMode(ASession.InsertMode);
  if ASession.AsciiArea then SetActiveEditArea(hhaAsciiCell) else SetActiveEditArea(hhaHexCell);
  SelectRange(ASession.SelectionStart, ASession.SelectionLength);
  SetCursorOffset(ASession.CursorOffset);
  SetTopRow(ASession.TopRow);
  SetHScroll(ASession.HorizontalOffset);
  DoBookmarksChange;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.RestoreSessionJson(const AJson: string);
var
  LSession: THexSessionData;
begin
  LSession := THexSessionSerializer.FromJson(AJson);
  try RestoreSessionData(LSession); finally LSession.Free; end;
end;

procedure TCustomThemedHexEditor.RestoreSessionFile(const APath: string);
begin
  RestoreSessionJson(TFile.ReadAllText(APath, TEncoding.UTF8));
end;

function TCustomThemedHexEditor.CreateProjectData(const AName: string): THexProjectData;
begin
  Result := THexProjectData.Create;
  try
    Result.ProjectName := AName;
    Result.Session.Free;
    Result.Session := nil;
    Result.Session := CreateSessionData;
  except
    Result.Free;
    raise;
  end;
end;

procedure TCustomThemedHexEditor.SaveProject(const APath, AName: string);
var
  LProject: THexProjectData;
begin
  LProject := CreateProjectData(AName);
  try THexProjectSerializer.Save(APath, LProject); finally LProject.Free; end;
end;

procedure TCustomThemedHexEditor.RestoreProjectData(const AProject: THexProjectData);
begin
  if AProject = nil then raise EArgumentNilException.Create('AProject');
  RestoreSessionData(AProject.Session);
end;

procedure TCustomThemedHexEditor.RestoreProjectFile(const APath: string);
var
  LProject: THexProjectData;
begin
  LProject := THexProjectSerializer.Load(APath);
  try RestoreProjectData(LProject); finally LProject.Free; end;
end;

function TCustomThemedHexEditor.CreateProjectBytes(const AName: string): TBytes;
var
  LProject: THexProjectData;
begin
  LProject := CreateProjectData(AName);
  try Result := TEncoding.UTF8.GetBytes(THexProjectSerializer.ToJson(LProject)); finally LProject.Free; end;
end;

procedure TCustomThemedHexEditor.RestoreProjectBytes(const ABytes: TBytes);
var
  LProject: THexProjectData;
begin
  LProject := THexProjectSerializer.FromJson(TEncoding.UTF8.GetString(ABytes));
  try RestoreProjectData(LProject); finally LProject.Free; end;
end;

function TCustomThemedHexEditor.FindBytes(const APattern: TBytes; const AForward, AWrap: Boolean): Boolean;
var
  LQuery: THexSearchQuery;
  LMatches: TObjectList<THexSearchMatch>;
  LMatch, LChosen: THexSearchMatch;
  LStart: Int64;
begin
  LQuery := THexSearchQuery.Create;
  try
    LQuery.RawBytes := APattern;
    LQuery.MaxResults := 0;
    if AForward then
    begin
      if FSelection.IsEmpty then LStart := Max(Int64(0), FCursorOffset)
      else LStart := FSelection.Start + FSelection.Length;
      LQuery.StartOffset := LStart;
      LQuery.MaxResults := 1;
    end
    else LQuery.EndOffset := Max(Int64(0), FCursorOffset);
    LMatches := SearchWithProvider('Native', LQuery);
    try
      if (LMatches.Count = 0) and AWrap then
      begin
        LMatches.Free;
        LMatches := nil;
        LQuery.StartOffset := 0;
        LQuery.EndOffset := -1;
        LMatches := SearchWithProvider('Native', LQuery);
      end;
      LChosen := nil;
      for LMatch in LMatches do
      begin
        LChosen := LMatch;
        if AForward then Break;
      end;
      Result := LChosen <> nil;
      if Result then
      begin
        ClearSearch;
        FLastFind := Copy(APattern);
        SelectRange(LChosen.Offset, LChosen.Length);
      end;
    finally
      LMatches.Free;
    end;
  finally
    LQuery.Free;
  end;
end;

function TCustomThemedHexEditor.ReplaceSelection(const AFind, AReplacement: TBytes): Boolean;
var
  LSelected: TBytes;
  LOffset: Int64;
begin
  Result := False;
  if not CanEdit or (Length(AFind) = 0) or (FSelection.Length <> Length(AFind)) then Exit;
  LSelected := SelectedBytes;
  if not CompareMem(@LSelected[0], @AFind[0], Length(AFind)) then Exit;
  LOffset := FSelection.Start;
  ApplyReplaceRange(LOffset, Length(AFind), AReplacement, True);
  SelectRange(LOffset, Length(AReplacement));
  Result := True;
end;

procedure TCustomThemedHexEditor.ApplyReplaceRange(const AOffset: Int64; const ALength: Integer;
  const ABytes: TBytes; const ARecord: Boolean);
var
  LOld: TBytes;
  LDocument: IHexDocumentAccess;
  I: Integer;
begin
  if not CanEdit then raise EInvalidOperation.Create('The editor is read only');
  if not TryReadBytes(AOffset, ALength, LOld) then raise EArgumentOutOfRangeException.Create('Replace range');
  if Supports(FDataSource, IHexDocumentAccess, LDocument) then LDocument.ReplaceBytes(AOffset, ALength, ABytes)
  else if ALength = Length(ABytes) then FDataSource.Write(AOffset, ABytes)
  else
  begin
    FDataSource.Delete(AOffset, ALength);
    try
      FDataSource.Insert(AOffset, ABytes);
    except
      FDataSource.Insert(AOffset, LOld);
      raise;
    end;
  end;
  ShiftModifiedAfterDelete(AOffset, ALength);
  ShiftModifiedAfterInsert(AOffset, Length(ABytes));
  for I := 0 to High(ABytes) do MarkModified(AOffset + I);
  if ARecord then FUndoManager.Push(TEditCommand.Create(ekReplace, AOffset, LOld, ABytes));
  UpdateScrollbars;
  ClearSearch;
  DoModifiedChange;
  DoUndoRedoStateChange;
  Invalidate;
end;

function TCustomThemedHexEditor.ReplaceAll(const AFind, AReplacement: TBytes): Integer;
var
  LQuery: THexSearchQuery;
  LMatches: TObjectList<THexSearchMatch>;
  I: Integer;
  LNextEnd: Int64;
  LIndices: TList<Integer>;
begin
  if not CanEdit then raise EInvalidOperation.Create('The editor is read only');
  LQuery := THexSearchQuery.Create;
  try
    LQuery.RawBytes := AFind;
    LQuery.MaxResults := 0;
    LMatches := SearchWithProvider('Native', LQuery);
    LIndices := TList<Integer>.Create;
    try
      LNextEnd := 0;
      for I := 0 to LMatches.Count - 1 do
        if LMatches[I].Offset >= LNextEnd then
        begin
          LIndices.Add(I);
          LNextEnd := LMatches[I].Offset + LMatches[I].Length;
        end;
      Result := 0;
      for I := LIndices.Count - 1 downto 0 do
        begin
          SelectRange(LMatches[LIndices[I]].Offset, LMatches[LIndices[I]].Length);
          if ReplaceSelection(AFind, AReplacement) then Inc(Result);
        end;
    finally
      LIndices.Free;
      LMatches.Free;
    end;
  finally
    LQuery.Free;
  end;
end;

function TCustomThemedHexEditor.FindNextFromIntegratedDialog: Boolean;
begin
  if Length(FLastFind) > 0 then Result := FindBytes(FLastFind, True) else Result := FindNext;
end;

function TCustomThemedHexEditor.FindPreviousFromIntegratedDialog: Boolean;
begin
  if Length(FLastFind) > 0 then Result := FindBytes(FLastFind, False) else Result := FindPrevious;
end;

procedure TCustomThemedHexEditor.RefreshLayout;
begin
  if HandleAllocated then
  begin
    UpdateScrollbars;
    EnsureCursorVisible;
  end;
  Invalidate;
end;

procedure TCustomThemedHexEditor.SetUseIntegratedFindReplaceDialog(const AValue: Boolean);
begin
  if FUseIntegratedFindReplaceDialog = AValue then Exit;
  FUseIntegratedFindReplaceDialog := AValue;
  if not AValue and (FFindDialog <> nil) then FFindDialog.Hide;
end;

function TCustomThemedHexEditor.GetActiveSearchMatch: THexSearchMatch;
begin
  Result := nil;
  if (FActiveMatchIndex >= 0) and (FActiveMatchIndex < FSearchMatches.Count) then
    Result := FSearchMatches[FActiveMatchIndex];
end;

function TCustomThemedHexEditor.GetAdvancedSearchMatches: TObjectList<THexSearchMatch>;
var
  LMatch: THexSearchMatch;
begin
  Result := TObjectList<THexSearchMatch>.Create(True);
  try
    for LMatch in FSearchMatches do Result.Add(LMatch.Clone);
  except
    Result.Free;
    raise;
  end;
end;

function TCustomThemedHexEditor.SetActiveAdvancedSearchMatchIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FSearchMatches.Count);
  if not Result then Exit;
  FLastFind := nil;
  FActiveMatchIndex := AIndex;
  NavigateToActiveMatch;
  DoSearchChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.ClearAdvancedSearchMatches;
begin
  ClearSearch;
end;

function TCustomThemedHexEditor.GoToNextAdvancedSearchMatch: Boolean;
begin
  Result := FindNext;
end;

function TCustomThemedHexEditor.GoToPreviousAdvancedSearchMatch: Boolean;
begin
  Result := FindPrevious;
end;

function TCustomThemedHexEditor.SearchPattern(const AText: string; const AStartOffset,
  AEndOffset: Int64; const AMaxHammingDistance: Integer): TObjectList<THexSearchMatch>;
var
  LQuery: THexSearchQuery;
begin
  LQuery := THexSearchQuery.Create;
  try
    LQuery.Mode := hsmPattern;
    LQuery.Text := AText;
    LQuery.StartOffset := AStartOffset;
    LQuery.EndOffset := AEndOffset;
    LQuery.MaxHammingDistance := AMaxHammingDistance;
    LQuery.MaxResults := 0;
    Result := SearchWithProvider('Native', LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TCustomThemedHexEditor.RequestFind;
begin
  if FUseIntegratedFindReplaceDialog then ShowFindDialog
  else if Assigned(FOnRequestFind) then FOnRequestFind(Self);
end;

procedure TCustomThemedHexEditor.RequestReplace;
begin
  if FUseIntegratedFindReplaceDialog then ShowReplaceDialog
  else if Assigned(FOnRequestReplace) then FOnRequestReplace(Self);
end;

procedure TCustomThemedHexEditor.RequestFindNext;
begin
  if FUseIntegratedFindReplaceDialog then FindNextFromIntegratedDialog
  else if Assigned(FOnRequestFindNext) then FOnRequestFindNext(Self);
end;

procedure TCustomThemedHexEditor.RequestFindPrevious;
begin
  if FUseIntegratedFindReplaceDialog then FindPreviousFromIntegratedDialog
  else if Assigned(FOnRequestFindPrevious) then FOnRequestFindPrevious(Self);
end;

procedure TCustomThemedHexEditor.RequestGotoOffset;
begin
  if Assigned(FOnRequestGotoOffset) then FOnRequestGotoOffset(Self);
end;

function TCustomThemedHexEditor.MoveBookmark(const AOffset, ANewOffset: Int64): Boolean;
begin
  Result := (ANewOffset >= 0) and (ANewOffset <= DataLength);
  if Result then Result := FBookmarks.Move(AOffset, ANewOffset);
  if Result then
  begin
    DoBookmarksChange;
    Invalidate;
  end;
end;

function TCustomThemedHexEditor.UpdateBookmark(const AOffset: Int64; const AName: string;
  const ANewOffset: Int64; const AColor: TThemeColor): Boolean;
var
  LBookmark: THexBookmark;
begin
  Result := (ANewOffset >= 0) and (ANewOffset <= DataLength);
  if Result then Result := FBookmarks.Move(AOffset, ANewOffset);
  if not Result then Exit;
  FBookmarks.TryGet(ANewOffset, LBookmark);
  LBookmark.Name := AName;
  LBookmark.Color := AColor;
  LBookmark.HasColor := True;
  DoBookmarksChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.ClearBookmarks;
begin
  if FBookmarks.Count = 0 then Exit;
  FBookmarks.Clear;
  DoBookmarksChange;
  Invalidate;
end;

procedure TCustomThemedHexEditor.ShowFindDialog;
begin
  if FFindDialog = nil then FFindDialog := TThemedHexFindReplaceForm.CreateForEditor(Self);
  TThemedHexFindReplaceForm(FFindDialog).Open(False);
end;

procedure TCustomThemedHexEditor.ShowReplaceDialog;
begin
  if FFindDialog = nil then FFindDialog := TThemedHexFindReplaceForm.CreateForEditor(Self);
  TThemedHexFindReplaceForm(FFindDialog).Open(True);
end;

function TCustomThemedHexEditor.ExportSelectionAsCSharpArray: string;
begin
  Result := ExportSelection('csharp');
end;

function TCustomThemedHexEditor.ExportRangeAsCSharpArray(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'csharp');
end;

procedure TCustomThemedHexEditor.CopySelectionAsCSharpArray;
begin
  Clipboard.AsText := ExportSelection('csharp');
end;

function TCustomThemedHexEditor.ExportSelectionAsCSharpReadOnlyArray: string;
begin
  Result := ExportSelection('csharp-readonly');
end;

function TCustomThemedHexEditor.ExportRangeAsCSharpReadOnlyArray(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'csharp-readonly');
end;

procedure TCustomThemedHexEditor.CopySelectionAsCSharpReadOnlyArray;
begin
  Clipboard.AsText := ExportSelection('csharp-readonly');
end;

function TCustomThemedHexEditor.ExportSelectionAsTextDump: string;
begin
  Result := ExportSelection('dump');
end;

function TCustomThemedHexEditor.ExportRangeAsTextDump(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'dump');
end;

procedure TCustomThemedHexEditor.CopySelectionAsTextDump;
begin
  Clipboard.AsText := ExportSelection('dump');
end;

function TCustomThemedHexEditor.ExportSelectionAsHtmlTable: string;
begin
  Result := ExportSelection('html');
end;

function TCustomThemedHexEditor.ExportRangeAsHtmlTable(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'html');
end;

procedure TCustomThemedHexEditor.CopySelectionAsHtmlTable;
begin
  Clipboard.AsText := ExportSelection('html');
end;

function TCustomThemedHexEditor.ExportSelectionAsJsonArray: string;
begin
  Result := ExportSelection('json');
end;

function TCustomThemedHexEditor.ExportRangeAsJsonArray(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'json');
end;

procedure TCustomThemedHexEditor.CopySelectionAsJsonArray;
begin
  Clipboard.AsText := ExportSelection('json');
end;

function TCustomThemedHexEditor.ExportSelectionAsBase64: string;
begin
  Result := ExportSelection('base64');
end;

function TCustomThemedHexEditor.ExportRangeAsBase64(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'base64');
end;

procedure TCustomThemedHexEditor.CopySelectionAsBase64;
begin
  Clipboard.AsText := ExportSelection('base64');
end;

function TCustomThemedHexEditor.ExportSelectionAsSqlVarBinary: string;
begin
  Result := ExportSelection('sql');
end;

function TCustomThemedHexEditor.ExportRangeAsSqlVarBinary(const AOffset: Int64; const ALength: Integer): string;
begin
  Result := ExportRange(AOffset, ALength, 'sql');
end;

procedure TCustomThemedHexEditor.CopySelectionAsSqlVarBinary;
begin
  Clipboard.AsText := ExportSelection('sql');
end;

end.

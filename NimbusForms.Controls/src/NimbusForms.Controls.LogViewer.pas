{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.LogViewer;

interface

uses Winapi.Messages, System.Classes, System.SysUtils, System.SyncObjs, System.Generics.Collections,
  NimbusForms.Theming.Types, Vcl.Controls, Vcl.ActnList, Vcl.ExtCtrls, Vcl.Dialogs,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types, NimbusForms.Controls.ToolBar,
  NimbusForms.Controls.ToolButton, NimbusForms.Controls.TextBox, NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.ThemedLabel, NimbusForms.Controls.Panel, NimbusForms.Controls.RichEdit,
  NimbusForms.Controls.Splitter, NimbusForms.Controls.LogViewer.Types,
  NimbusForms.Controls.LogViewer.Model, NimbusForms.Controls.LogViewer.Monitor,
  NimbusForms.Controls.LogViewer.View, NimbusForms.Controls.LogViewer.IndexedFile,
  NimbusForms.Controls.LogViewer.Bookmarks, NimbusForms.Controls.LogViewer.Links,
  NimbusForms.Controls.LogViewer.Export, NimbusForms.Rendering.LogViewer, NimbusForms.Rendering.Canvas;

type
  TNimbusLogErrorEvent = procedure(Sender: TObject; const AMessage: string) of object;
  TNimbusLogSourceLinkClickEvent = procedure(Sender: TObject; ALine: TNimbusLogLine;
    const ALocation: TNimbusLogSourceLocation; const ASourceIndex, AVisibleIndex: Int64) of object;
  TNimbusQueuedLog = record Text: string; Level: TNimbusLogLevel; end;

  TCustomThemedLogViewer = class(TCustomNimbusControl)
  private
    FModel: TNimbusLogModel;
    FIndexedFile: TNimbusIndexedLogFile;
    FActiveSource: TNimbusCustomLogSource;
    FHighlights: TNimbusLogHighlightOptions;
    FMonitor: TNimbusLogFileMonitor;
    FBookmarks: TNimbusLogBookmarks;
    FQueue: TQueue<TNimbusQueuedLog>;
    FQueueLock: TCriticalSection;
    FQueueDropped: UInt64;
    FTimer: TTimer;
    FView: TCustomNimbusLogView;
    FToolBar: TThemedToolBar;
    FSearch: TThemedTextBox;
    FQueryBox: TThemedTextBox;
    FLevelBox: TThemedComboBox;
    FEncodingBox: TThemedComboBox;
    FFileEncoding: TNimbusLogFileEncoding;
    FWriteBOM: Boolean;
    FStatus: TThemedLabel;
    FDetailsPanel: TThemedPanel;
    FDetailsSplitter: TThemedSplitter;
    FDetailsEdit: TThemedRichEdit;
    FActions: TActionList;
    FOpen: TOpenDialog;
    FSave: TSaveDialog;
    FBuilding, FShowToolbar, FShowStatusBar, FShowDetails, FPaused, FFollowTail, FLineNumbers: Boolean;
    FCaseSensitive, FRegex, FOnlyMatches, FUseIndexedFiles: Boolean;
    FSearchText, FStructuredQuery, FFileName, FLastError: string;
    FLevels: TNimbusLogLevels;
    FScrollBarLevels: TNimbusLogLevels;
    FOnMarkerClick: TNimbusLogMarkerClickEvent;
    FOnInteractiveClick: TNimbusLogInteractiveClickEvent;
    FOnSourceLinkClick: TNimbusLogSourceLinkClickEvent;
    FMonitorInterval, FDetailsWidth: Integer;
    FLargeFileThreshold: Int64;
    FLastPoll: UInt64;
    FLastIndexedVersion, FLastSearchVersion: Int64;
    FPendingIndexedSearch: Boolean;
    FOnDataChanged, FOnViewChanged, FOnSearchChanged, FOnMonitorChanged: TNotifyEvent;
    FOnError: TNimbusLogErrorEvent;
    FOnDrawRow: TNimbusLogDrawRowEvent;
    FOnRowColors: TNimbusLogRowColorsEvent;
    procedure BuildControls;
    procedure ModelChanged(Sender: TObject);
    procedure HighlightsChanged(Sender: TObject);
    procedure ViewChanged(Sender: TObject);
    procedure ViewSelectionChanged(Sender: TObject; ALine: TNimbusLogLine; const ASourceIndex, AVisibleIndex: Int64);
    procedure InteractiveClick(Sender: TObject; ALine: TNimbusLogLine; ARun: TNimbusLogInteractiveRun;
      const ASourceIndex, AVisibleIndex: Int64);
    procedure MarkerClick(Sender: TObject; ALine: TNimbusLogLine; const ASourceIndex, AVisibleIndex: Integer);
    procedure BookmarksChanged(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure DrainQueue(const AMaximum: Integer);
    procedure MonitorLine(const AText: string);
    procedure CommandExecute(Sender: TObject);
    procedure CommandUpdate(Sender: TObject);
    procedure SearchChanged(Sender: TObject);
    procedure QueryChanged(Sender: TObject);
    procedure SearchEnter(Sender: TObject);
    procedure QueryEnter(Sender: TObject);
    procedure LevelChanged(Sender: TObject);
    procedure EncodingChanged(Sender: TObject);
    procedure SetFileEncoding(const AValue: TNimbusLogFileEncoding);
    procedure SetWriteBOM(const AValue: Boolean);
    function GetDetectedFileEncoding: TNimbusLogFileEncoding;
    procedure ViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DrawRow(Sender: TObject; const ACanvas: INimbusRenderCanvas;
      const AInfo: TNimbusLogRowInfo; var AHandled: Boolean);
    procedure RowColors(Sender: TObject; const AInfo: TNimbusLogRowInfo;
      var ABackColor, AForeColor: TThemeColor);
    procedure UpdateStatus;
    procedure UpdateDetails(ALine: TNimbusLogLine; const ASourceIndex: Int64);
    procedure ApplySearch;
    procedure ApplyIndexedSearchResults;
    procedure ProcessIndexedState;
    procedure ReportError(const AMessage: string);
    procedure CheckUIThread;
    procedure ActivateSource(ASource: TNimbusCustomLogSource);
    procedure ActivateMemorySource;
    function IndexedMode: Boolean;
    function NeedsIndexedSearch: Boolean;
    function NeedsIndexedResultRows: Boolean;
    function AllLevels: TNimbusLogLevels;
    procedure SetHighlights(const AValue: TNimbusLogHighlightOptions);
    procedure SetMaxLines(const AValue: Integer);
    function GetMaxLines: Integer;
    procedure SetInsertMode(const AValue: TNimbusLogInsertMode);
    function GetInsertMode: TNimbusLogInsertMode;
    procedure SetPaused(const AValue: Boolean);
    procedure SetFollowTail(const AValue: Boolean);
    function GetFollowTail: Boolean;
    procedure SetShowToolbar(const AValue: Boolean);
    procedure SetShowStatusBar(const AValue: Boolean);
    procedure SetShowDetails(const AValue: Boolean);
    procedure SetDetailsWidth(const AValue: Integer);
    procedure SetLineNumbers(const AValue: Boolean);
    procedure SetSearchText(const AValue: string);
    procedure SetStructuredQuery(const AValue: string);
    procedure SetCaseSensitive(const AValue: Boolean);
    procedure SetUseRegex(const AValue: Boolean);
    procedure SetFilterMatches(const AValue: Boolean);
    procedure SetLevels(const AValue: TNimbusLogLevels);
    procedure SetScrollBarLevels(const AValue: TNimbusLogLevels);
    procedure SetMonitorInterval(const AValue: Integer);
    procedure SetLargeFileThreshold(const AValue: Int64);
    procedure SetOnDrawRow(const AValue: TNimbusLogDrawRowEvent);
    procedure SetOnRowColors(const AValue: TNimbusLogRowColorsEvent);
    function GetMonitoring: Boolean;
    function GetMonitorFileName: string;
    function GetDroppedLogCount: UInt64;
    function GetIndexedFileOptions: TNimbusIndexedLogFileOptions;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Paint; override;
    procedure StyleModeChanged; override;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AppendLog(const AText: string; const ALevel: TNimbusLogLevel = nllUnknown);
    function QueueLog(const AText: string; const ALevel: TNimbusLogLevel = nllUnknown): Boolean;
    procedure Clear;
    procedure LoadFile(const APath: string); overload;
    procedure LoadFile(const APath: string; const AEncoding: TNimbusLogFileEncoding); overload;
    procedure SaveFile(const APath: string); overload;
    procedure SaveFile(const APath: string; const AEncoding: TNimbusLogFileEncoding; const AWriteBOM: Boolean = True); overload;
    procedure StartMonitoring(const APath: string; const AFromEnd: Boolean = True); overload;
    procedure StartMonitoring(const APath: string; const AFromEnd: Boolean; const AEncoding: TNimbusLogFileEncoding); overload;
    procedure StopMonitoring;
    function FindNext(const AForward: Boolean = True): Boolean;
    procedure CopySelection;
    procedure SelectAll;
    procedure RefreshView;
    function VisibleLineCount: Integer;
    function VisibleLineCount64: Int64;
    function SearchMatchCount: Integer;
    function PendingLogCount: Integer;
    procedure FlushPendingLogs;
    function AddBookmark(const ALabelText: string = ''; const ANote: string = ''): TNimbusLogBookmark;
    function RemoveBookmarkAtSelection: Boolean;
    procedure ClearBookmarks;
    procedure ExportAll(const APath: string; const AFormat: TNimbusLogExportFormat = nlefText);
    procedure ExportVisible(const APath: string; const AFormat: TNimbusLogExportFormat = nlefText);
    procedure ExportSelection(const APath: string; const AFormat: TNimbusLogExportFormat = nlefText);
    procedure ExportBookmarks(const APath: string; const AFormat: TNimbusLogExportFormat = nlefText);
    property Model: TNimbusLogModel read FModel;
    property ActiveSource: TNimbusCustomLogSource read FActiveSource;
    property IndexedFile: TNimbusIndexedLogFile read FIndexedFile;
    property IndexedFileOptions: TNimbusIndexedLogFileOptions read GetIndexedFileOptions;
    property Bookmarks: TNimbusLogBookmarks read FBookmarks;
    property Monitoring: Boolean read GetMonitoring;
    property MonitorFileName: string read GetMonitorFileName;
    property FileName: string read FFileName;
    property LastError: string read FLastError;
    property DetectedFileEncoding: TNimbusLogFileEncoding read GetDetectedFileEncoding;
    property FileEncoding: TNimbusLogFileEncoding read FFileEncoding write SetFileEncoding default nlfeAuto;
    property WriteBOM: Boolean read FWriteBOM write SetWriteBOM default True;
    property DroppedLogCount: UInt64 read GetDroppedLogCount;
    property Highlights: TNimbusLogHighlightOptions read FHighlights write SetHighlights;
    property MaxLines: Integer read GetMaxLines write SetMaxLines default 100000;
    property InsertMode: TNimbusLogInsertMode read GetInsertMode write SetInsertMode default nlimBottom;
    property Paused: Boolean read FPaused write SetPaused default False;
    property FollowTail: Boolean read GetFollowTail write SetFollowTail default True;
    property ShowToolbar: Boolean read FShowToolbar write SetShowToolbar default True;
    property ShowStatusBar: Boolean read FShowStatusBar write SetShowStatusBar default True;
    property ShowDetails: Boolean read FShowDetails write SetShowDetails default True;
    property DetailsWidth: Integer read FDetailsWidth write SetDetailsWidth default 340;
    property ShowLineNumbers: Boolean read FLineNumbers write SetLineNumbers default True;
    property SearchText: string read FSearchText write SetSearchText;
    property StructuredQuery: string read FStructuredQuery write SetStructuredQuery;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive default False;
    property UseRegex: Boolean read FRegex write SetUseRegex default False;
    property FilterMatches: Boolean read FOnlyMatches write SetFilterMatches default False;
    property UseIndexedFiles: Boolean read FUseIndexedFiles write FUseIndexedFiles default True;
    property LargeFileThreshold: Int64 read FLargeFileThreshold write SetLargeFileThreshold default 16777216;
    property Levels: TNimbusLogLevels read FLevels write SetLevels default [nllUnknown, nllTrace, nllDebug, nllInfo, nllSuccess, nllWarning, nllError, nllFatal];
    property ScrollBarLevels: TNimbusLogLevels read FScrollBarLevels write SetScrollBarLevels default [nllWarning, nllError, nllFatal];
    property OnMarkerClick: TNimbusLogMarkerClickEvent read FOnMarkerClick write FOnMarkerClick;
    property OnInteractiveClick: TNimbusLogInteractiveClickEvent read FOnInteractiveClick write FOnInteractiveClick;
    property OnSourceLinkClick: TNimbusLogSourceLinkClickEvent read FOnSourceLinkClick write FOnSourceLinkClick;
    property MonitorInterval: Integer read FMonitorInterval write SetMonitorInterval default 250;
    property OnDataChanged: TNotifyEvent read FOnDataChanged write FOnDataChanged;
    property OnViewChanged: TNotifyEvent read FOnViewChanged write FOnViewChanged;
    property OnSearchChanged: TNotifyEvent read FOnSearchChanged write FOnSearchChanged;
    property OnMonitorChanged: TNotifyEvent read FOnMonitorChanged write FOnMonitorChanged;
    property OnError: TNimbusLogErrorEvent read FOnError write FOnError;
    property OnDrawRow: TNimbusLogDrawRowEvent read FOnDrawRow write SetOnDrawRow;
    property OnRowColors: TNimbusLogRowColorsEvent read FOnRowColors write SetOnRowColors;
  end;

  TThemedLogViewer = class(TCustomThemedLogViewer)
  published
    property Align;
    property Anchors;
    property Constraints;
    property StyleMode;
    property Enabled;
    property Font;
    property ParentFont;
    property Visible;
    property Highlights;
    property MaxLines;
    property InsertMode;
    property Paused;
    property FollowTail;
    property ShowToolbar;
    property ShowStatusBar;
    property ShowDetails;
    property DetailsWidth;
    property ShowLineNumbers;
    property SearchText;
    property StructuredQuery;
    property CaseSensitive;
    property UseRegex;
    property FilterMatches;
    property UseIndexedFiles;
    property LargeFileThreshold;
    property Levels;
    property ScrollBarLevels;
    property OnMarkerClick;
    property OnInteractiveClick;
    property OnSourceLinkClick;
    property MonitorInterval;
    property FileEncoding;
    property WriteBOM;
    property OnDataChanged;
    property OnViewChanged;
    property OnSearchChanged;
    property OnMonitorChanged;
    property OnError;
    property OnDrawRow;
    property OnRowColors;
  end;

implementation

uses Winapi.Windows, Winapi.ShellAPI, System.Actions, System.Math, System.Types, Vcl.StdCtrls,
  System.RegularExpressions, System.IOUtils, System.DateUtils, System.Generics.Defaults,
  NimbusForms.Rendering.Types, NimbusForms.Controls.LogViewer.Encoding,
  NimbusForms.Controls.LogViewer.Structured, NimbusForms.Controls.LogViewer.Query;

constructor TCustomThemedLogViewer.Create(AOwner: TComponent);
begin
  inherited;
  TabStop := False;
  Font.Name := 'Consolas';
  Font.Size := 9;
  FModel := TNimbusLogModel.Create(ModelChanged);
  FIndexedFile := TNimbusIndexedLogFile.Create(nil);
  FActiveSource := FModel;
  FHighlights := TNimbusLogHighlightOptions.Create(HighlightsChanged);
  FMonitor := TNimbusLogFileMonitor.Create;
  FBookmarks := TNimbusLogBookmarks.Create(BookmarksChanged);
  FQueue := TQueue<TNimbusQueuedLog>.Create;
  FQueueLock := TCriticalSection.Create;
  FActions := TActionList.Create(Self);
  FOpen := TOpenDialog.Create(Self);
  FOpen.Filter := 'Log files|*.log;*.txt;*.json;*.jsonl|All files|*.*';
  FOpen.Options := FOpen.Options + [ofFileMustExist, ofPathMustExist];
  FSave := TSaveDialog.Create(Self);
  FSave.Filter := 'Log files|*.log;*.txt|JSON lines|*.jsonl|All files|*.*';
  FSave.DefaultExt := 'log';
  FSave.Options := FSave.Options + [ofOverwritePrompt, ofPathMustExist];
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 50;
  FTimer.OnTimer := TimerTick;
  FShowToolbar := True;
  FShowStatusBar := True;
  FShowDetails := True;
  FDetailsWidth := 340;
  FFollowTail := True;
  FLineNumbers := True;
  FUseIndexedFiles := True;
  FLargeFileThreshold := 16 * 1024 * 1024;
  FLevels := [Low(TNimbusLogLevel)..High(TNimbusLogLevel)];
  FScrollBarLevels := [nllWarning, nllError, nllFatal];
  FMonitorInterval := 250;
  FWriteBOM := True;
  Width := 1000;
  Height := 500;
end;

destructor TCustomThemedLogViewer.Destroy;
begin
  if FTimer <> nil then
  begin
    FTimer.Enabled := False;
    FTimer.OnTimer := nil;
  end;
  FreeAndNil(FView);
  FIndexedFile.Free;
  FMonitor.Free;
  FModel.Free;
  FHighlights.Free;
  FBookmarks.Free;
  FQueue.Free;
  FQueueLock.Free;
  inherited;
end;

function TCustomThemedLogViewer.AllLevels: TNimbusLogLevels;
begin
  Result := [Low(TNimbusLogLevel)..High(TNimbusLogLevel)];
end;

procedure TCustomThemedLogViewer.CheckUIThread;
begin
  if GetCurrentThreadID <> MainThreadID then raise EInvalidOpException.Create('Use QueueLog from background threads');
end;

procedure TCustomThemedLogViewer.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent <> nil) and (FView = nil) and not FBuilding and not (csDestroying in ComponentState) then
  begin
    FBuilding := True;
    try BuildControls; finally FBuilding := False; end;
  end;
end;

procedure TCustomThemedLogViewer.BuildControls;
const
  Captions: array[0..16] of string = ('Open', 'Save', 'Copy', 'Clear', 'Follow', 'Pause', 'Top', 'Compact',
    Char($2039), Char($203A), 'Watch', 'Aa', '.*', 'Filter', 'BOM', 'Details', 'Bookmark');
  Hints: array[0..16] of string = ('Load log file', 'Save all log lines', 'Copy selected lines', 'Clear log',
    'Follow new log lines', 'Pause queued logs and file monitoring', 'Insert new lines at top',
    'Compact spacing', 'Previous search match', 'Next search match', 'Monitor or stop watching a log file',
    'Case sensitive search', 'Regular expression search', 'Show only matching lines',
    'Write Unicode byte order mark when saving', 'Show structured details', 'Toggle bookmark on selected row');
var I: Integer; A: TAction; B: TThemedToolButton; E: TNimbusLogFileEncoding;
begin
  FStatus := TThemedLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.Align := alBottom;
  FStatus.AutoSize := False;
  FStatus.Height := ScaleValue(24);
  FStatus.Visible := FShowStatusBar;

  FToolBar := TThemedToolBar.Create(Self);
  FToolBar.Parent := Self;
  FToolBar.Align := alTop;
  FToolBar.ShowGrip := False;
  FToolBar.ShowOverflow := True;
  FToolBar.Height := ScaleValue(34);
  FToolBar.Font.Name := 'Segoe UI';
  FToolBar.Font.Size := 9;
  FToolBar.Visible := FShowToolbar;

  FEncodingBox := TThemedComboBox.Create(Self);
  FEncodingBox.Parent := FToolBar;
  FEncodingBox.Width := ScaleValue(126);
  FEncodingBox.Style := csDropDownList;
  for E := Low(TNimbusLogFileEncoding) to High(TNimbusLogFileEncoding) do FEncodingBox.Items.Add(TNimbusLogTextCodec.Name(E));
  FEncodingBox.ItemIndex := Ord(FFileEncoding);
  FEncodingBox.OnChange := EncodingChanged;
  FEncodingBox.Hint := 'Encoding for opening, saving and file monitoring';
  FEncodingBox.ShowHint := True;

  for I := 0 to High(Captions) do
  begin
    if I = 8 then
    begin
      FSearch := TThemedTextBox.Create(Self);
      FSearch.Parent := FToolBar;
      FSearch.Width := ScaleValue(180);
      FSearch.Text := FSearchText;
      FSearch.OnChange := SearchChanged;
      FSearch.OnEnterPressed := SearchEnter;
      FSearch.Hint := 'Text search';
      FSearch.ShowHint := True;
    end;
    A := TAction.Create(Self);
    A.ActionList := FActions;
    A.Caption := Captions[I];
    A.Hint := Hints[I];
    A.Tag := I;
    A.OnExecute := CommandExecute;
    A.OnUpdate := CommandUpdate;
    B := TThemedToolButton.Create(Self);
    B.Parent := FToolBar;
    B.Width := ScaleValue(52);
    if I in [8, 9, 11, 12] then B.Width := ScaleValue(30);
    B.Action := A;
    B.ShowHint := True;
  end;

  FLevelBox := TThemedComboBox.Create(Self);
  FLevelBox.Parent := FToolBar;
  FLevelBox.Width := ScaleValue(116);
  FLevelBox.Style := csDropDownList;
  FLevelBox.Items.Add('All levels');
  FLevelBox.Items.Add('Warnings / errors');
  FLevelBox.Items.Add('Errors');
  FLevelBox.Items.Add('Debug / trace');
  FLevelBox.Items.Add('Custom levels');
  FLevelBox.ItemIndex := 0;
  FLevelBox.OnChange := LevelChanged;

  FQueryBox := TThemedTextBox.Create(Self);
  FQueryBox.Parent := FToolBar;
  FQueryBox.Width := ScaleValue(220);
  FQueryBox.Text := FStructuredQuery;
  FQueryBox.OnChange := QueryChanged;
  FQueryBox.OnEnterPressed := QueryEnter;
  FQueryBox.Hint := 'Structured query, e.g. level>=warning AND TraceId="abc"';
  FQueryBox.ShowHint := True;

  FDetailsPanel := TThemedPanel.Create(Self);
  FDetailsPanel.Parent := Self;
  FDetailsPanel.Align := alRight;
  FDetailsPanel.Width := ScaleValue(FDetailsWidth);
  FDetailsPanel.Visible := FShowDetails;

  FDetailsEdit := TThemedRichEdit.Create(Self);
  FDetailsEdit.Parent := FDetailsPanel;
  FDetailsEdit.Align := alClient;
  FDetailsEdit.ReadOnly := True;
  FDetailsEdit.PlainText := True;
  FDetailsEdit.WordWrap := False;
  FDetailsEdit.ParentFont := True;

  FDetailsSplitter := TThemedSplitter.Create(Self);
  FDetailsSplitter.Parent := Self;
  FDetailsSplitter.Align := alRight;
  FDetailsSplitter.ResizeControl := FDetailsPanel;
  FDetailsSplitter.Visible := FShowDetails;

  FView := TCustomNimbusLogView.Create(Self);
  FView.Parent := Self;
  FView.Align := alClient;
  FView.ParentFont := True;
  FView.AttachSource(FActiveSource, FHighlights);
  FView.OnStateChanged := ViewChanged;
  FView.OnKeyDown := ViewKeyDown;
  FView.OnMarkerClick := MarkerClick;
  FView.OnInteractiveClick := InteractiveClick;
  FView.OnSelectionChanged := ViewSelectionChanged;
  FView.SetScrollBarLevels(FScrollBarLevels);
  FView.Enabled := Enabled;
  FToolBar.Enabled := Enabled;
  FView.OnDrawRow := DrawRow;
  FView.OnRowColors := RowColors;
  FView.SetLevels(FLevels);
  FView.SetLineNumbers(FLineNumbers);
  FView.SetFollow(FFollowTail);
  ApplySearch;
  StyleModeChanged;
  UpdateStatus;
end;

procedure TCustomThemedLogViewer.CreateWnd;
begin
  inherited;
  if FTimer <> nil then FTimer.Enabled := not (csDesigning in ComponentState);
end;

procedure TCustomThemedLogViewer.DestroyWnd;
begin
  if FTimer <> nil then FTimer.Enabled := False;
  inherited;
end;

procedure TCustomThemedLogViewer.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try RenderCanvas.FillRectangle(NimbusInputBackColor(Palette), ClientRect); finally RenderCanvas.EndRender; end;
end;

procedure TCustomThemedLogViewer.StyleModeChanged;
begin
  inherited;
  if FView <> nil then FView.StyleMode := StyleMode;
  if FToolBar <> nil then
  begin
    FToolBar.StyleMode := StyleMode;
    if StyleMode = stCompact then FToolBar.Height := ScaleValue(28) else FToolBar.Height := ScaleValue(34);
  end;
  if FDetailsEdit <> nil then FDetailsEdit.StyleMode := StyleMode;
end;

procedure TCustomThemedLogViewer.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if FView <> nil then FView.Enabled := Enabled;
  if FToolBar <> nil then FToolBar.Enabled := Enabled;
end;

function TCustomThemedLogViewer.IndexedMode: Boolean;
begin
  Result := FActiveSource = FIndexedFile;
end;

procedure TCustomThemedLogViewer.ActivateSource(ASource: TNimbusCustomLogSource);
begin
  if ASource = nil then ASource := FModel;
  FActiveSource := ASource;
  if FView <> nil then
  begin
    FView.AttachSource(FActiveSource, FHighlights);
    FView.SetLevels(FLevels, IndexedMode);
    FView.SetLineNumbers(FLineNumbers);
    FView.SetFollow(FFollowTail);
  end;
  UpdateDetails(nil, -1);
end;

procedure TCustomThemedLogViewer.ActivateMemorySource;
begin
  if IndexedMode then
  begin
    FIndexedFile.CancelSearch;
    ActivateSource(FModel);
  end;
end;

procedure TCustomThemedLogViewer.ModelChanged(Sender: TObject);
begin
  if csDestroying in ComponentState then Exit;
  if (FView <> nil) and (FActiveSource = FModel) then FView.Rebuild;
  UpdateStatus;
  if Assigned(FOnDataChanged) then FOnDataChanged(Self);
end;

procedure TCustomThemedLogViewer.HighlightsChanged(Sender: TObject);
begin
  if FView <> nil then FView.Invalidate;
end;

procedure TCustomThemedLogViewer.ViewChanged(Sender: TObject);
begin
  if FView <> nil then FFollowTail := FView.FollowTail;
  UpdateStatus;
  if Assigned(FOnViewChanged) then FOnViewChanged(Self);
end;

procedure TCustomThemedLogViewer.ViewSelectionChanged(Sender: TObject; ALine: TNimbusLogLine;
  const ASourceIndex, AVisibleIndex: Int64);
begin
  UpdateDetails(ALine, ASourceIndex);
end;

procedure TCustomThemedLogViewer.InteractiveClick(Sender: TObject; ALine: TNimbusLogLine;
  ARun: TNimbusLogInteractiveRun; const ASourceIndex, AVisibleIndex: Int64);
var Location: TNimbusLogSourceLocation; Handled: Boolean;
begin
  Handled := False;
  if (ARun <> nil) and (ARun.Kind = nlikSourceLocation) and Assigned(FOnSourceLinkClick) then
  begin
    Location := ARun.SourceLocation;
    FOnSourceLinkClick(Self, ALine, Location, ASourceIndex, AVisibleIndex);
    Handled := True;
  end;
  if Assigned(FOnInteractiveClick) then
  begin
    FOnInteractiveClick(Self, ALine, ARun, ASourceIndex, AVisibleIndex);
    Handled := True;
  end;
  if not Handled and (ARun <> nil) and (ARun.Kind = nlikURL) then
    ShellExecute(Handle, 'open', PChar(ARun.Target), nil, nil, SW_SHOWNORMAL);
end;

procedure TCustomThemedLogViewer.BookmarksChanged(Sender: TObject);
begin
  UpdateStatus;
  if FView <> nil then FView.Invalidate;
end;

procedure TCustomThemedLogViewer.UpdateDetails(ALine: TNimbusLogLine; const ASourceIndex: Int64);
var E: TNimbusStructuredLogEntry; B: TStringBuilder; Pair: TPair<string, string>;
  Run: TNimbusLogInteractiveRun;
begin
  if FDetailsEdit = nil then Exit;
  if ALine = nil then
  begin
    FDetailsEdit.Text := '';
    Exit;
  end;
  E := ALine.Structured;
  B := TStringBuilder.Create;
  try
    B.AppendLine('Line: ' + IntToStr(ASourceIndex + 1));
    B.AppendLine('ID: ' + UIntToStr(ALine.ID));
    B.AppendLine('Level: ' + NimbusLogLevelText(ALine.Level));
    if E.HasTimestamp then B.AppendLine('Timestamp: ' + DateToISO8601(E.Timestamp, False));
    if E.LoggerName <> '' then B.AppendLine('Logger: ' + E.LoggerName);
    if E.SourceContext <> '' then B.AppendLine('SourceContext: ' + E.SourceContext);
    if E.Category <> '' then B.AppendLine('Category: ' + E.Category);
    if E.HasThreadID then B.AppendLine('ThreadId: ' + IntToStr(E.ThreadID));
    if E.ThreadName <> '' then B.AppendLine('ThreadName: ' + E.ThreadName);
    if E.HasProcessID then B.AppendLine('ProcessId: ' + IntToStr(E.ProcessID));
    if E.ProcessName <> '' then B.AppendLine('ProcessName: ' + E.ProcessName);
    if E.TraceID <> '' then B.AppendLine('TraceId: ' + E.TraceID);
    if E.SpanID <> '' then B.AppendLine('SpanId: ' + E.SpanID);
    if E.CorrelationID <> '' then B.AppendLine('CorrelationId: ' + E.CorrelationID);
    if E.MessageTemplate <> '' then B.AppendLine('MessageTemplate: ' + E.MessageTemplate);
    B.AppendLine('Message: ' + E.DisplayText);
    if E.Properties.Count > 0 then
    begin
      B.AppendLine;
      B.AppendLine('Properties');
      for Pair in E.Properties do B.AppendLine(Pair.Key + ': ' + Pair.Value);
    end;
    if E.ExceptionInfo <> nil then
    begin
      B.AppendLine;
      B.AppendLine('Exception');
      if E.ExceptionInfo.TypeName <> '' then B.AppendLine('Type: ' + E.ExceptionInfo.TypeName);
      if E.ExceptionInfo.Message <> '' then B.AppendLine('Message: ' + E.ExceptionInfo.Message);
      if E.ExceptionInfo.StackTrace <> '' then B.AppendLine(E.ExceptionInfo.StackTrace);
    end;
    if ALine.InteractiveRuns.Count > 0 then
    begin
      B.AppendLine;
      B.AppendLine('Links');
      for Run in ALine.InteractiveRuns do
      begin
        case Run.Kind of
          nlikSourceLocation:
            B.AppendLine(Format('%s | line %d | column %d | end line %d | end column %d',
              [Run.FilePath, Run.LineNumber, Run.ColumnNumber, Run.EndLineNumber, Run.EndColumnNumber]));
          nlikFilePath: B.AppendLine('File: ' + Run.FilePath);
          nlikURL: B.AppendLine('URL: ' + Run.Target);
        end;
      end;
    end;
    B.AppendLine;
    B.AppendLine('Raw');
    B.Append(ALine.Text);
    FDetailsEdit.Text := B.ToString;
  finally
    B.Free;
  end;
end;

procedure TCustomThemedLogViewer.UpdateStatus;
var S: string; Count, Visible: Int64; Progress: Double;
begin
  if FStatus = nil then Exit;
  if FActiveSource <> nil then Count := FActiveSource.Count64 else Count := 0;
  if FView <> nil then Visible := FView.VisibleCount64 else Visible := Count;
  S := Format('%s lines | %s visible | %d matches | %d pending | %s dropped',
    [IntToStr(Count), IntToStr(Visible), SearchMatchCount, PendingLogCount, UIntToStr(GetDroppedLogCount)]);
  if IndexedMode then
  begin
    if FIndexedFile.Indexing then
    begin
      if FIndexedFile.FileLength > 0 then Progress := FIndexedFile.IndexedBytes / FIndexedFile.FileLength * 100 else Progress := 0;
      S := S + Format(' | Indexing %.1f%%', [Progress]);
    end
    else if FIndexedFile.IndexComplete then S := S + ' | Indexed';
    if FIndexedFile.Searching then S := S + ' | Searching';
    if FIndexedFile.SearchTruncated then S := S + ' | Search results truncated';
  end;
  if FBookmarks.Count > 0 then S := S + ' | ' + IntToStr(FBookmarks.Count) + ' bookmarks';
  if FPaused then S := S + ' | PAUSED';
  if Monitoring then S := S + ' | Watching: ' + FMonitor.Path;
  if FLastError <> '' then S := S + ' | ' + FLastError;
  S := S + ' | ' + TNimbusLogTextCodec.Name(GetDetectedFileEncoding);
  FStatus.Caption := S;
end;

procedure TCustomThemedLogViewer.ReportError(const AMessage: string);
begin
  if FLastError = AMessage then Exit;
  FLastError := AMessage;
  UpdateStatus;
  if Assigned(FOnError) then FOnError(Self, AMessage);
end;

procedure TCustomThemedLogViewer.AppendLog(const AText: string; const ALevel: TNimbusLogLevel);
begin
  CheckUIThread;
  ActivateMemorySource;
  FModel.AddText(AText, ALevel);
end;

function TCustomThemedLogViewer.QueueLog(const AText: string; const ALevel: TNimbusLogLevel): Boolean;
var Entry: TNimbusQueuedLog;
begin
  Entry.Text := AText;
  Entry.Level := ALevel;
  FQueueLock.Acquire;
  try
    Result := FQueue.Count < 50000;
    if Result then FQueue.Enqueue(Entry) else Inc(FQueueDropped);
  finally
    FQueueLock.Release;
  end;
end;

function TCustomThemedLogViewer.PendingLogCount: Integer;
begin
  FQueueLock.Acquire;
  try Result := FQueue.Count; finally FQueueLock.Release; end;
end;

function TCustomThemedLogViewer.GetDroppedLogCount: UInt64;
begin
  FQueueLock.Acquire;
  try Result := FQueueDropped; finally FQueueLock.Release; end;
  Inc(Result, FModel.DroppedLines);
end;

procedure TCustomThemedLogViewer.MonitorLine(const AText: string);
begin
  FModel.AddLine(AText);
end;

procedure TCustomThemedLogViewer.DrainQueue(const AMaximum: Integer);
var Batch: TList<TNimbusQueuedLog>; Entry: TNimbusQueuedLog; I: Integer;
begin
  Batch := TList<TNimbusQueuedLog>.Create;
  try
    FQueueLock.Acquire;
    try
      for I := 1 to Min(AMaximum, FQueue.Count) do Batch.Add(FQueue.Dequeue);
    finally
      FQueueLock.Release;
    end;
    if Batch.Count = 0 then Exit;
    if IndexedMode then ActivateMemorySource;
    FModel.BeginUpdate;
    try
      for Entry in Batch do FModel.AddText(Entry.Text, Entry.Level);
    finally
      FModel.EndUpdate;
    end;
  finally
    Batch.Free;
  end;
end;

procedure TCustomThemedLogViewer.FlushPendingLogs;
begin
  CheckUIThread;
  DrainQueue(50000);
end;

procedure TCustomThemedLogViewer.ProcessIndexedState;
var Version, SearchVersion: Int64;
begin
  if not IndexedMode then Exit;
  Version := FIndexedFile.Version;
  if Version <> FLastIndexedVersion then
  begin
    FLastIndexedVersion := Version;
    if FIndexedFile.LastError <> '' then ReportError(FIndexedFile.LastError);
    if FView <> nil then
    begin
      if NeedsIndexedSearch then FView.ConfigureSearchDeferred(FSearchText, FCaseSensitive, FRegex, FOnlyMatches)
      else FView.Rebuild;
    end;
    if FIndexedFile.IndexComplete and FPendingIndexedSearch then ApplySearch;
    UpdateStatus;
    if Assigned(FOnDataChanged) then FOnDataChanged(Self);
  end;
  SearchVersion := FIndexedFile.SearchVersion;
  if SearchVersion <> FLastSearchVersion then
  begin
    FLastSearchVersion := SearchVersion;
    if not FIndexedFile.Searching then
    begin
      if FIndexedFile.SearchError <> '' then ReportError(FIndexedFile.SearchError)
      else ApplyIndexedSearchResults;
    end;
    UpdateStatus;
  end;
end;

procedure TCustomThemedLogViewer.TimerTick(Sender: TObject);
var Tick: UInt64;
begin
  ProcessIndexedState;
  if FPaused then
  begin
    UpdateStatus;
    Exit;
  end;
  DrainQueue(1000);
  if not IndexedMode then
  begin
    Tick := GetTickCount64;
    if Monitoring and (Tick - FLastPoll >= UInt64(FMonitorInterval)) then
    begin
      FLastPoll := Tick;
      FModel.BeginUpdate;
      try
        try
          FMonitor.Poll(MonitorLine);
          FModel.AdoptEncoding(FMonitor.DetectedEncoding);
          if FLastError <> '' then begin FLastError := ''; UpdateStatus; end;
        except
          on E: Exception do ReportError(E.Message);
        end;
      finally
        FModel.EndUpdate;
      end;
    end;
  end;
end;

procedure TCustomThemedLogViewer.Clear;
begin
  CheckUIThread;
  FQueueLock.Acquire;
  try
    FQueue.Clear;
    FQueueDropped := 0;
  finally
    FQueueLock.Release;
  end;
  if IndexedMode then FIndexedFile.Close;
  ActivateSource(FModel);
  FModel.Clear;
  FBookmarks.Clear;
  FFileName := '';
end;

procedure TCustomThemedLogViewer.LoadFile(const APath: string);
begin
  LoadFile(APath, FFileEncoding);
end;

procedure TCustomThemedLogViewer.LoadFile(const APath: string; const AEncoding: TNimbusLogFileEncoding);
var Size: Int64;
begin
  CheckUIThread;
  if not TFile.Exists(APath) then raise EFileNotFoundException.Create(APath);
  StopMonitoring;
  Size := TFile.GetSize(APath);
  FBookmarks.Clear;
  FLastError := '';
  FFileName := APath;
  if FUseIndexedFiles and (Size >= FLargeFileThreshold) then
  begin
    FModel.Clear;
    FIndexedFile.Open(APath, AEncoding);
    FLastIndexedVersion := FIndexedFile.Version;
    FLastSearchVersion := FIndexedFile.SearchVersion;
    FPendingIndexedSearch := NeedsIndexedSearch;
    ActivateSource(FIndexedFile);
    if FView <> nil then FView.ConfigureSearchDeferred(FSearchText, FCaseSensitive, FRegex, FOnlyMatches);
  end
  else
  begin
    FIndexedFile.Close;
    ActivateSource(FModel);
    FModel.LoadFile(APath, AEncoding);
    ApplySearch;
  end;
  UpdateStatus;
end;

procedure TCustomThemedLogViewer.SaveFile(const APath: string);
begin
  SaveFile(APath, FFileEncoding, FWriteBOM);
end;

procedure TCustomThemedLogViewer.SaveFile(const APath: string; const AEncoding: TNimbusLogFileEncoding;
  const AWriteBOM: Boolean);
begin
  CheckUIThread;
  if IndexedMode then FIndexedFile.SaveToFile(APath, AEncoding, AWriteBOM)
  else FModel.SaveFile(APath, AEncoding, AWriteBOM);
  FLastError := '';
  UpdateStatus;
end;

procedure TCustomThemedLogViewer.StartMonitoring(const APath: string; const AFromEnd: Boolean);
begin
  StartMonitoring(APath, AFromEnd, FFileEncoding);
end;

procedure TCustomThemedLogViewer.StartMonitoring(const APath: string; const AFromEnd: Boolean;
  const AEncoding: TNimbusLogFileEncoding);
begin
  CheckUIThread;
  ActivateMemorySource;
  FMonitor.Start(APath, AFromEnd, AEncoding);
  FModel.BeginUpdate;
  try
    try
      FMonitor.Poll(MonitorLine);
      FModel.AdoptEncoding(FMonitor.DetectedEncoding);
      FLastError := '';
    except
      on E: Exception do ReportError(E.Message);
    end;
  finally
    FModel.EndUpdate;
  end;
  SetFollowTail(True);
  UpdateStatus;
  if Assigned(FOnMonitorChanged) then FOnMonitorChanged(Self);
end;

procedure TCustomThemedLogViewer.StopMonitoring;
begin
  CheckUIThread;
  FMonitor.Stop;
  UpdateStatus;
  if Assigned(FOnMonitorChanged) then FOnMonitorChanged(Self);
end;

function TCustomThemedLogViewer.GetMonitoring: Boolean;
begin
  Result := FMonitor.Running;
end;

function TCustomThemedLogViewer.GetMonitorFileName: string;
begin
  Result := FMonitor.Path;
end;

function TCustomThemedLogViewer.FindNext(const AForward: Boolean): Boolean;
begin
  Result := (FView <> nil) and FView.FindNext(AForward);
end;

procedure TCustomThemedLogViewer.CopySelection;
begin
  if FView <> nil then FView.CopySelection;
end;

procedure TCustomThemedLogViewer.SelectAll;
begin
  if FView <> nil then FView.SelectAll;
end;

procedure TCustomThemedLogViewer.RefreshView;
begin
  if FView <> nil then FView.Invalidate;
end;

function TCustomThemedLogViewer.VisibleLineCount: Integer;
begin
  if FView <> nil then Result := FView.VisibleCount
  else if FActiveSource <> nil then Result := Integer(Min(Int64(MaxInt), FActiveSource.Count64))
  else Result := 0;
end;

function TCustomThemedLogViewer.VisibleLineCount64: Int64;
begin
  if FView <> nil then Result := FView.VisibleCount64
  else if FActiveSource <> nil then Result := FActiveSource.Count64
  else Result := 0;
end;

function TCustomThemedLogViewer.SearchMatchCount: Integer;
begin
  if FView <> nil then Result := FView.MatchCount else Result := 0;
end;

function TCustomThemedLogViewer.NeedsIndexedSearch: Boolean;
begin
  Result := (FSearchText <> '') or (Trim(FStructuredQuery) <> '') or (FLevels <> AllLevels);
end;

function TCustomThemedLogViewer.NeedsIndexedResultRows: Boolean;
begin
  Result := ((FSearchText <> '') and FOnlyMatches) or (Trim(FStructuredQuery) <> '') or (FLevels <> AllLevels);
end;

procedure TCustomThemedLogViewer.ApplySearch;
var Pattern: TRegEx; Options: TRegExOptions; Query: TNimbusLogQuery; IncludeNonTextRows: Boolean;
begin
  if FRegex and (FSearchText <> '') then
  begin
    Options := [];
    if not FCaseSensitive then Include(Options, roIgnoreCase);
    Pattern := TRegEx.Create(FSearchText, Options);
    Pattern.IsMatch('');
  end;
  if Trim(FStructuredQuery) <> '' then
  begin
    Query := TNimbusLogQuery.Parse(FStructuredQuery);
    Query.Free;
  end;
  if FView <> nil then
  begin
    if IndexedMode then
    begin
      FView.ConfigureSearchDeferred(FSearchText, FCaseSensitive, FRegex, FOnlyMatches);
      FView.ConfigureStructuredQuery(FStructuredQuery, True);
      FView.SetLevels(FLevels, True);
      if not NeedsIndexedSearch then
      begin
        FPendingIndexedSearch := False;
        FIndexedFile.CancelSearch;
        FView.Rebuild;
      end
      else if FIndexedFile.IndexComplete then
      begin
        FPendingIndexedSearch := False;
        IncludeNonTextRows := NeedsIndexedResultRows and (FSearchText <> '') and not FOnlyMatches;
        FIndexedFile.BeginSearch(FSearchText, FStructuredQuery, FCaseSensitive, FRegex, FLevels, IncludeNonTextRows);
        FLastSearchVersion := FIndexedFile.SearchVersion;
      end
      else FPendingIndexedSearch := True;
    end
    else
    begin
      FView.ConfigureStructuredQuery(FStructuredQuery, False);
      FView.ConfigureSearch(FSearchText, FCaseSensitive, FRegex, FOnlyMatches);
      FView.SetLevels(FLevels, False);
    end;
  end;
  UpdateStatus;
  if Assigned(FOnSearchChanged) then FOnSearchChanged(Self);
end;

procedure TCustomThemedLogViewer.ApplyIndexedSearchResults;
var SourceHits: TNimbusIndexedSearchHits; Hits: TArray<TNimbusLogSearchHit>; I: Integer;
begin
  if not IndexedMode or (FView = nil) then Exit;
  SourceHits := FIndexedFile.SearchResults;
  SetLength(Hits, Length(SourceHits));
  for I := 0 to High(SourceHits) do
  begin
    Hits[I] := Default(TNimbusLogSearchHit);
    Hits[I].LineID := UInt64(SourceHits[I].SourceIndex + 1);
    Hits[I].SourceIndex64 := SourceHits[I].SourceIndex;
    Hits[I].Column := SourceHits[I].Column;
    Hits[I].Length := SourceHits[I].Length;
    Hits[I].IsTextMatch := SourceHits[I].TextMatch;
  end;
  FView.ApplyExternalSearchResults(Hits, NeedsIndexedResultRows);
end;

procedure TCustomThemedLogViewer.SearchChanged(Sender: TObject);
begin
  try
    SetSearchText(FSearch.Text);
    FLastError := '';
    UpdateStatus;
  except
    on E: Exception do ReportError(E.Message);
  end;
end;

procedure TCustomThemedLogViewer.QueryChanged(Sender: TObject);
begin
  try
    SetStructuredQuery(FQueryBox.Text);
    FLastError := '';
    UpdateStatus;
  except
    on E: Exception do ReportError(E.Message);
  end;
end;

procedure TCustomThemedLogViewer.SearchEnter(Sender: TObject);
begin
  FindNext;
end;

procedure TCustomThemedLogViewer.QueryEnter(Sender: TObject);
begin
  ApplySearch;
end;

procedure TCustomThemedLogViewer.LevelChanged(Sender: TObject);
begin
  case FLevelBox.ItemIndex of
    1: SetLevels([nllWarning, nllError, nllFatal]);
    2: SetLevels([nllError, nllFatal]);
    3: SetLevels([nllDebug, nllTrace]);
    4: Exit;
  else
    SetLevels(AllLevels);
  end;
end;

procedure TCustomThemedLogViewer.EncodingChanged(Sender: TObject);
begin
  if FEncodingBox.ItemIndex >= 0 then SetFileEncoding(TNimbusLogFileEncoding(FEncodingBox.ItemIndex));
end;

procedure TCustomThemedLogViewer.SetFileEncoding(const AValue: TNimbusLogFileEncoding);
begin
  FFileEncoding := AValue;
  if FEncodingBox <> nil then FEncodingBox.ItemIndex := Ord(AValue);
  UpdateStatus;
end;

procedure TCustomThemedLogViewer.SetWriteBOM(const AValue: Boolean);
begin
  FWriteBOM := AValue;
end;

function TCustomThemedLogViewer.GetDetectedFileEncoding: TNimbusLogFileEncoding;
begin
  if IndexedMode then Result := FIndexedFile.Encoding
  else
  begin
    Result := FModel.LoadedEncoding;
    if Monitoring and (FMonitor.DetectedEncoding <> nlfeAuto) then Result := FMonitor.DetectedEncoding;
  end;
end;

procedure TCustomThemedLogViewer.ViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (ssCtrl in Shift) and (FSearch <> nil) then
  begin
    if not FShowToolbar then ShowToolbar := True;
    if FSearch.CanFocus then FSearch.SetFocus;
    Key := 0;
  end;
  if (Key = Ord('B')) and (ssCtrl in Shift) then
  begin
    if not RemoveBookmarkAtSelection then AddBookmark;
    Key := 0;
  end;
end;

procedure TCustomThemedLogViewer.CommandExecute(Sender: TObject);
var SourceIndex: Int64;
begin
  try
    case TAction(Sender).Tag of
      0: if FOpen.Execute then LoadFile(FOpen.FileName, FFileEncoding);
      1: if FSave.Execute then SaveFile(FSave.FileName, FFileEncoding, FWriteBOM);
      2: CopySelection;
      3: Clear;
      4: FollowTail := not FollowTail;
      5: Paused := not Paused;
      6: if InsertMode = nlimBottom then InsertMode := nlimTop else InsertMode := nlimBottom;
      7: if StyleMode = stNormal then StyleMode := stCompact else StyleMode := stNormal;
      8: FindNext(False);
      9: FindNext(True);
      10: if Monitoring then StopMonitoring else if FOpen.Execute then StartMonitoring(FOpen.FileName, False, FFileEncoding);
      11: CaseSensitive := not CaseSensitive;
      12: UseRegex := not UseRegex;
      13: FilterMatches := not FilterMatches;
      14: WriteBOM := not WriteBOM;
      15: ShowDetails := not ShowDetails;
      16:
        begin
          SourceIndex := -1;
          if FView <> nil then SourceIndex := FView.SelectedSourceIndex;
          if SourceIndex >= 0 then
            if not FBookmarks.RemoveBySourceIndex(SourceIndex) then AddBookmark;
        end;
    end;
  except
    on E: Exception do ReportError(E.Message);
  end;
end;

procedure TCustomThemedLogViewer.CommandUpdate(Sender: TObject);
var A: TAction; Encoding: TNimbusLogFileEncoding;
begin
  A := TAction(Sender);
  Encoding := FFileEncoding;
  if Encoding = nlfeAuto then Encoding := GetDetectedFileEncoding;
  A.Enabled := Enabled;
  if A.Tag in [8, 9] then A.Enabled := Enabled and (SearchMatchCount > 0);
  if A.Tag = 6 then A.Enabled := Enabled and not IndexedMode;
  if A.Tag = 16 then A.Enabled := Enabled and (FView <> nil) and (FView.SelectedSourceIndex >= 0);
  case A.Tag of
    4: A.Checked := FollowTail;
    5: A.Checked := Paused;
    6: A.Checked := InsertMode = nlimTop;
    7: A.Checked := StyleMode = stCompact;
    10: A.Checked := Monitoring;
    11: A.Checked := CaseSensitive;
    12: A.Checked := UseRegex;
    13: A.Checked := FilterMatches;
    14:
      begin
        A.Checked := WriteBOM;
        A.Enabled := Enabled and not (Encoding in [nlfeASCII, nlfeANSI, nlfeLatin1, nlfeWindows1252]);
      end;
    15: A.Checked := ShowDetails;
  end;
end;

procedure TCustomThemedLogViewer.SetHighlights(const AValue: TNimbusLogHighlightOptions);
begin
  FHighlights.Assign(AValue);
end;

function TCustomThemedLogViewer.GetMaxLines: Integer;
begin
  Result := FModel.MaxLines;
end;

procedure TCustomThemedLogViewer.SetMaxLines(const AValue: Integer);
begin
  FModel.MaxLines := AValue;
end;

function TCustomThemedLogViewer.GetInsertMode: TNimbusLogInsertMode;
begin
  Result := FModel.InsertMode;
end;

procedure TCustomThemedLogViewer.SetInsertMode(const AValue: TNimbusLogInsertMode);
begin
  FModel.InsertMode := AValue;
  if (FView <> nil) and not IndexedMode then FView.Rebuild;
end;

procedure TCustomThemedLogViewer.SetPaused(const AValue: Boolean);
begin
  FPaused := AValue;
  UpdateStatus;
  if Assigned(FOnMonitorChanged) then FOnMonitorChanged(Self);
end;

function TCustomThemedLogViewer.GetFollowTail: Boolean;
begin
  if FView <> nil then Result := FView.FollowTail else Result := FFollowTail;
end;

procedure TCustomThemedLogViewer.SetFollowTail(const AValue: Boolean);
begin
  FFollowTail := AValue;
  if FView <> nil then FView.SetFollow(AValue);
  UpdateStatus;
end;

procedure TCustomThemedLogViewer.SetShowToolbar(const AValue: Boolean);
begin
  FShowToolbar := AValue;
  if FToolBar <> nil then FToolBar.Visible := AValue;
end;

procedure TCustomThemedLogViewer.SetShowStatusBar(const AValue: Boolean);
begin
  FShowStatusBar := AValue;
  if FStatus <> nil then FStatus.Visible := AValue;
end;

procedure TCustomThemedLogViewer.SetShowDetails(const AValue: Boolean);
begin
  FShowDetails := AValue;
  if FDetailsPanel <> nil then FDetailsPanel.Visible := AValue;
  if FDetailsSplitter <> nil then FDetailsSplitter.Visible := AValue;
end;

procedure TCustomThemedLogViewer.SetDetailsWidth(const AValue: Integer);
begin
  if (AValue < 160) or (AValue > 1600) then raise EArgumentOutOfRangeException.Create('DetailsWidth');
  FDetailsWidth := AValue;
  if FDetailsPanel <> nil then FDetailsPanel.Width := ScaleValue(AValue);
end;

procedure TCustomThemedLogViewer.SetLineNumbers(const AValue: Boolean);
begin
  FLineNumbers := AValue;
  if FView <> nil then FView.SetLineNumbers(AValue);
end;

procedure TCustomThemedLogViewer.SetSearchText(const AValue: string);
var Old: string;
begin
  if FSearchText = AValue then Exit;
  Old := FSearchText;
  FSearchText := AValue;
  try ApplySearch; except FSearchText := Old; raise; end;
  if (FSearch <> nil) and (FSearch.Text <> AValue) then FSearch.Text := AValue;
end;

procedure TCustomThemedLogViewer.SetStructuredQuery(const AValue: string);
var Old: string; Q: TNimbusLogQuery;
begin
  if FStructuredQuery = AValue then Exit;
  if Trim(AValue) <> '' then
  begin
    Q := TNimbusLogQuery.Parse(AValue);
    Q.Free;
  end;
  Old := FStructuredQuery;
  FStructuredQuery := AValue;
  try ApplySearch; except FStructuredQuery := Old; raise; end;
  if (FQueryBox <> nil) and (FQueryBox.Text <> AValue) then FQueryBox.Text := AValue;
end;

procedure TCustomThemedLogViewer.SetCaseSensitive(const AValue: Boolean);
var Old: Boolean;
begin
  Old := FCaseSensitive;
  FCaseSensitive := AValue;
  try ApplySearch; except FCaseSensitive := Old; raise; end;
end;

procedure TCustomThemedLogViewer.SetUseRegex(const AValue: Boolean);
var Old: Boolean;
begin
  Old := FRegex;
  FRegex := AValue;
  try ApplySearch; except FRegex := Old; raise; end;
end;

procedure TCustomThemedLogViewer.SetFilterMatches(const AValue: Boolean);
begin
  FOnlyMatches := AValue;
  ApplySearch;
end;

procedure TCustomThemedLogViewer.SetLevels(const AValue: TNimbusLogLevels);
begin
  FLevels := AValue;
  if FLevelBox <> nil then
    if AValue = AllLevels then FLevelBox.ItemIndex := 0
    else if AValue = [nllWarning, nllError, nllFatal] then FLevelBox.ItemIndex := 1
    else if AValue = [nllError, nllFatal] then FLevelBox.ItemIndex := 2
    else if AValue = [nllDebug, nllTrace] then FLevelBox.ItemIndex := 3
    else FLevelBox.ItemIndex := 4;
  if IndexedMode then ApplySearch
  else if FView <> nil then FView.SetLevels(AValue, False);
  UpdateStatus;
end;

procedure TCustomThemedLogViewer.SetMonitorInterval(const AValue: Integer);
begin
  if (AValue < 50) or (AValue > 60000) then raise EArgumentOutOfRangeException.Create('MonitorInterval');
  FMonitorInterval := AValue;
end;

procedure TCustomThemedLogViewer.SetLargeFileThreshold(const AValue: Int64);
begin
  if AValue < 1024 * 1024 then raise EArgumentOutOfRangeException.Create('LargeFileThreshold');
  FLargeFileThreshold := AValue;
end;

procedure TCustomThemedLogViewer.SetScrollBarLevels(const AValue: TNimbusLogLevels);
begin
  FScrollBarLevels := AValue;
  if FView <> nil then FView.SetScrollBarLevels(AValue);
end;

procedure TCustomThemedLogViewer.MarkerClick(Sender: TObject; ALine: TNimbusLogLine;
  const ASourceIndex, AVisibleIndex: Integer);
begin
  if Assigned(FOnMarkerClick) then FOnMarkerClick(Self, ALine, ASourceIndex, AVisibleIndex);
end;

procedure TCustomThemedLogViewer.DrawRow(Sender: TObject; const ACanvas: INimbusRenderCanvas;
  const AInfo: TNimbusLogRowInfo; var AHandled: Boolean);
begin
  if Assigned(FOnDrawRow) then FOnDrawRow(Self, ACanvas, AInfo, AHandled);
end;

procedure TCustomThemedLogViewer.RowColors(Sender: TObject; const AInfo: TNimbusLogRowInfo;
  var ABackColor, AForeColor: TThemeColor);
begin
  if (FBookmarks <> nil) and (AInfo.Line <> nil) and
    (FBookmarks.FindByLineID(AInfo.Line.ID) <> nil) then
    ABackColor := NimbusBlendColor(ABackColor, NimbusAccentColor(Palette), 24);
  if Assigned(FOnRowColors) then FOnRowColors(Self, AInfo, ABackColor, AForeColor);
end;

procedure TCustomThemedLogViewer.SetOnDrawRow(const AValue: TNimbusLogDrawRowEvent);
begin
  FOnDrawRow := AValue;
  if FView <> nil then FView.Invalidate;
end;

procedure TCustomThemedLogViewer.SetOnRowColors(const AValue: TNimbusLogRowColorsEvent);
begin
  FOnRowColors := AValue;
  if FView <> nil then FView.Invalidate;
end;

function TCustomThemedLogViewer.GetIndexedFileOptions: TNimbusIndexedLogFileOptions;
begin
  Result := FIndexedFile.Options;
end;

procedure TCustomThemedLogViewer.ExportAll(const APath: string; const AFormat: TNimbusLogExportFormat);
var Writer: TNimbusLogExportWriter; I, Count: Int64; Line: TNimbusLogLine;
begin
  CheckUIThread;
  if FActiveSource = nil then Exit;
  Writer := TNimbusLogExportWriter.Create(APath, AFormat);
  try
    Count := FActiveSource.Count64;
    for I := 0 to Count - 1 do
    begin
      if (I and 255) = 0 then FActiveSource.EnsureRange(I, Integer(Min(Int64(256), Count - I)));
      if FActiveSource.TryGetLine(I, Line) then Writer.WriteLine(Line);
    end;
  finally Writer.Free; end;
end;

procedure TCustomThemedLogViewer.ExportVisible(const APath: string; const AFormat: TNimbusLogExportFormat);
var Writer: TNimbusLogExportWriter; I, SourceIndex: Int64; Line: TNimbusLogLine;
begin
  CheckUIThread;
  if (FActiveSource = nil) or (FView = nil) then Exit;
  Writer := TNimbusLogExportWriter.Create(APath, AFormat);
  try
    for I := 0 to FView.VisibleCount64 - 1 do
    begin
      SourceIndex := FView.VisibleSourceIndex(I);
      if (SourceIndex >= 0) and FActiveSource.TryGetLine(SourceIndex, Line) then Writer.WriteLine(Line);
    end;
  finally Writer.Free; end;
end;

procedure TCustomThemedLogViewer.ExportSelection(const APath: string; const AFormat: TNimbusLogExportFormat);
var Writer: TNimbusLogExportWriter; I, First, Last, SourceIndex: Int64; Line: TNimbusLogLine;
begin
  CheckUIThread;
  if (FActiveSource = nil) or (FView = nil) or not FView.SelectionRange(First, Last) then Exit;
  Writer := TNimbusLogExportWriter.Create(APath, AFormat);
  try
    for I := First to Last do
    begin
      SourceIndex := FView.VisibleSourceIndex(I);
      if (SourceIndex >= 0) and FActiveSource.TryGetLine(SourceIndex, Line) then Writer.WriteLine(Line);
    end;
  finally Writer.Free; end;
end;

procedure TCustomThemedLogViewer.ExportBookmarks(const APath: string; const AFormat: TNimbusLogExportFormat);
var Writer: TNimbusLogExportWriter; I: Integer; SourceIndex: Int64; Line: TNimbusLogLine;
begin
  CheckUIThread;
  if FActiveSource = nil then Exit;
  Writer := TNimbusLogExportWriter.Create(APath, AFormat);
  try
    for I := 0 to FBookmarks.Count - 1 do
    begin
      SourceIndex := FBookmarks[I].SourceIndex;
      Line := nil;
      if FActiveSource = FModel then Line := FModel.FindID(FBookmarks[I].LineID)
      else if SourceIndex >= 0 then FActiveSource.TryGetLine(SourceIndex, Line);
      if Line <> nil then Writer.WriteLine(Line);
    end;
  finally Writer.Free; end;
end;

function TCustomThemedLogViewer.AddBookmark(const ALabelText, ANote: string): TNimbusLogBookmark;
var Line: TNimbusLogLine; SourceIndex: Int64;
begin
  Result := nil;
  if FView = nil then Exit;
  SourceIndex := FView.SelectedSourceIndex;
  Line := FView.SelectedLine;
  if (SourceIndex < 0) or (Line = nil) then Exit;
  Result := FBookmarks.Add(SourceIndex, Line.ID, ALabelText, ANote);
end;

function TCustomThemedLogViewer.RemoveBookmarkAtSelection: Boolean;
var SourceIndex: Int64; Line: TNimbusLogLine;
begin
  Result := False;
  if FView = nil then Exit;
  SourceIndex := FView.SelectedSourceIndex;
  Line := FView.SelectedLine;
  if Line <> nil then Result := FBookmarks.RemoveByLineID(Line.ID);
  if not Result and (SourceIndex >= 0) then Result := FBookmarks.RemoveBySourceIndex(SourceIndex);
end;

procedure TCustomThemedLogViewer.ClearBookmarks;
begin
  FBookmarks.Clear;
end;

end.

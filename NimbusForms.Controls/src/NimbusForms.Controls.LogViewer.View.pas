{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.LogViewer.View;

interface

uses Winapi.Messages, System.Classes, System.SysUtils, System.Types, System.Generics.Collections,
  Vcl.Controls, NimbusForms.Controls.Base, NimbusForms.Controls.Types,
  NimbusForms.Controls.IDEScrollBar, NimbusForms.Controls.HScrollBar,
  NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Model,
  NimbusForms.Controls.LogViewer.Links, NimbusForms.Rendering.LogViewer,
  NimbusForms.Rendering.LogViewer.Source;

type
  TNimbusLogMarkerClickEvent = procedure(Sender: TObject; ALine: TNimbusLogLine;
    const ASourceIndex, AVisibleIndex: Integer) of object;
  TNimbusLogInteractiveClickEvent = procedure(Sender: TObject; ALine: TNimbusLogLine;
    ARun: TNimbusLogInteractiveRun; const ASourceIndex, AVisibleIndex: Int64) of object;
  TNimbusLogSelectionChangedEvent = procedure(Sender: TObject; ALine: TNimbusLogLine;
    const ASourceIndex, AVisibleIndex: Int64) of object;

  TCustomNimbusLogView = class(TCustomNimbusControl)
  private
    FSource: TNimbusCustomLogSource;
    FModel: TNimbusLogModel;
    FOptions: TNimbusLogHighlightOptions;
    FIndices: TArray<Int64>;
    FIdentityMap: Boolean;
    FVisibleCount: Int64;
    FHits: TArray<TNimbusLogSearchHit>;
    FMetrics: TNimbusLogMetrics;
    FV: TThemedIDEScrollBar;
    FH: TThemedHScrollBar;
    FQuery: string;
    FStructuredQuery: string;
    FCaseSensitive, FRegex, FOnlyMatches, FLineNumbers, FFollowTail: Boolean;
    FLevels: TNimbusLogLevels;
    FScrollBarLevels: TNimbusLogLevels;
    FOnMarkerClick: TNimbusLogMarkerClickEvent;
    FOnInteractiveClick: TNimbusLogInteractiveClickEvent;
    FOnSelectionChanged: TNimbusLogSelectionChangedEvent;
    FTopRow: Int64;
    FHOffset, FActiveHit, FMaxColumns: Integer;
    FAnchor, FSelectionEnd: Int64;
    FAnchorID, FSelectionID, FTopLineID: UInt64;
    FSyncing, FDragging: Boolean;
    FOnStateChanged: TNotifyEvent;
    FOnDraw: TNimbusLogDrawRowEvent;
    FOnColors: TNimbusLogRowColorsEvent;
    procedure BuildScrollBars;
    procedure SyncScrollBars;
    procedure RebuildMarkers;
    procedure MarkerClick(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
    procedure MarkerEnter(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
    procedure ScrollChanged(Sender: TObject);
    procedure EnsureSelectedVisible(const ARow: Int64);
    procedure SelectRow(const ARow: Int64; const AExtend: Boolean);
    procedure ResetIdentityMap;
    function SourceIndexAt(const AVisibleIndex: Int64): Int64;
    function InteractiveAt(const X, Y: Integer; out ALine: TNimbusLogLine;
      out ARun: TNimbusLogInteractiveRun; out ASourceIndex, AVisibleIndex: Int64): Boolean;
    function ScrollMaximum(const APage: Integer): Int64;
    function ScrollValueFromRow(const ARow, AMaximum: Int64): Integer;
    function RowFromScrollValue(const AValue: Integer; const AMaximum: Int64): Int64;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure StateChanged;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure StyleModeChanged; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Attach(AModel: TNimbusLogModel; AOptions: TNimbusLogHighlightOptions);
    procedure AttachSource(ASource: TNimbusCustomLogSource; AOptions: TNimbusLogHighlightOptions);
    procedure Rebuild;
    procedure ConfigureSearch(const AQuery: string; const ACaseSensitive, ARegex, AOnlyMatches: Boolean);
    procedure ConfigureSearchDeferred(const AQuery: string; const ACaseSensitive, ARegex, AOnlyMatches: Boolean);
    procedure ConfigureStructuredQuery(const AQuery: string; const ADeferred: Boolean = False);
    procedure ApplyExternalSearchResults(const AHits: TArray<TNimbusLogSearchHit>; const AUseResultRows: Boolean);
    procedure SetLevels(const ALevels: TNimbusLogLevels; const ADeferred: Boolean = False);
    procedure SetScrollBarLevels(const ALevels: TNimbusLogLevels);
    function MarkerRows: TArray<Integer>;
    procedure SetFollow(const AValue: Boolean);
    procedure SetLineNumbers(const AValue: Boolean);
    function FindNext(const AForward: Boolean = True): Boolean;
    procedure CopySelection;
    procedure SelectAll;
    function SelectionText: string;
    function VisibleCount: Integer;
    function VisibleCount64: Int64;
    function MatchCount: Integer;
    function SelectedLine: TNimbusLogLine;
    function SelectedSourceIndex: Int64;
    function VisibleSourceIndex(const AVisibleIndex: Int64): Int64;
    function SelectionRange(out AFirst, ALast: Int64): Boolean;
    property Source: TNimbusCustomLogSource read FSource;
    property FollowTail: Boolean read FFollowTail;
    property OnStateChanged: TNotifyEvent read FOnStateChanged write FOnStateChanged;
    property OnDrawRow: TNimbusLogDrawRowEvent read FOnDraw write FOnDraw;
    property OnRowColors: TNimbusLogRowColorsEvent read FOnColors write FOnColors;
    property OnMarkerClick: TNimbusLogMarkerClickEvent read FOnMarkerClick write FOnMarkerClick;
    property OnInteractiveClick: TNimbusLogInteractiveClickEvent read FOnInteractiveClick write FOnInteractiveClick;
    property OnSelectionChanged: TNimbusLogSelectionChangedEvent read FOnSelectionChanged write FOnSelectionChanged;
    property StyleMode;
    property ParentFont;
    property OnKeyDown;
  end;

implementation

uses Winapi.Windows, System.Math, System.RegularExpressions, Vcl.Clipbrd,
  NimbusForms.Rendering.Types, NimbusForms.Rendering.IDEScrollBar,
  NimbusForms.Controls.LogViewer.Query;

const
  NimbusVirtualScrollMaximum = 1000000;
  NimbusMarkerScanLimit = 200000;
  NimbusSelectionCopyLimit = 16 * 1024 * 1024;

constructor TCustomNimbusLogView.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  Font.Name := 'Consolas';
  Font.Size := 9;
  TabStop := True;
  FLineNumbers := True;
  FFollowTail := True;
  FLevels := [Low(TNimbusLogLevel)..High(TNimbusLogLevel)];
  FScrollBarLevels := [nllWarning, nllError, nllFatal];
  FAnchor := -1;
  FSelectionEnd := -1;
  FActiveHit := -1;
  FMetrics.RowHeight := 20;
  FMetrics.CharWidth := 8;
end;

procedure TCustomNimbusLogView.Attach(AModel: TNimbusLogModel; AOptions: TNimbusLogHighlightOptions);
begin
  AttachSource(AModel, AOptions);
end;

procedure TCustomNimbusLogView.AttachSource(ASource: TNimbusCustomLogSource; AOptions: TNimbusLogHighlightOptions);
begin
  FSource := ASource;
  if ASource is TNimbusLogModel then FModel := TNimbusLogModel(ASource) else FModel := nil;
  FOptions := AOptions;
  FTopRow := 0;
  FAnchor := -1;
  FSelectionEnd := -1;
  FAnchorID := 0;
  FSelectionID := 0;
  Rebuild;
end;

procedure TCustomNimbusLogView.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent <> nil) and (FV = nil) and not (csDestroying in ComponentState) then BuildScrollBars;
end;

procedure TCustomNimbusLogView.BuildScrollBars;
begin
  FV := TThemedIDEScrollBar.Create(Self);
  FV.Parent := Self;
  FV.TabStop := False;
  FH := TThemedHScrollBar.Create(Self);
  FH.Parent := Self;
  FH.TabStop := False;
  FV.OnValueChanged := ScrollChanged;
  FH.OnValueChanged := ScrollChanged;
  FV.OnMarkerClick := MarkerClick;
  FV.OnMarkerEnter := MarkerEnter;
  FV.ShowHint := True;
  RebuildMarkers;
  SyncScrollBars;
end;

procedure TCustomNimbusLogView.CreateWnd;
begin
  inherited;
  SyncScrollBars;
end;

procedure TCustomNimbusLogView.StateChanged;
begin
  Invalidate;
  if Assigned(FOnStateChanged) then FOnStateChanged(Self);
end;

procedure TCustomNimbusLogView.ConfigureSearch(const AQuery: string; const ACaseSensitive, ARegex, AOnlyMatches: Boolean);
var Pattern: TRegEx; Options: TRegExOptions;
begin
  if ARegex and (AQuery <> '') then
  begin
    Options := [];
    if not ACaseSensitive then Include(Options, roIgnoreCase);
    Pattern := TRegEx.Create(AQuery, Options);
    Pattern.IsMatch('');
  end;
  FQuery := AQuery;
  FCaseSensitive := ACaseSensitive;
  FRegex := ARegex;
  FOnlyMatches := AOnlyMatches;
  Rebuild;
end;

procedure TCustomNimbusLogView.ConfigureSearchDeferred(const AQuery: string; const ACaseSensitive,
  ARegex, AOnlyMatches: Boolean);
var Pattern: TRegEx; Options: TRegExOptions;
begin
  if ARegex and (AQuery <> '') then
  begin
    Options := [];
    if not ACaseSensitive then Include(Options, roIgnoreCase);
    Pattern := TRegEx.Create(AQuery, Options);
    Pattern.IsMatch('');
  end;
  FQuery := AQuery;
  FCaseSensitive := ACaseSensitive;
  FRegex := ARegex;
  FOnlyMatches := AOnlyMatches;
  FHits := nil;
  FActiveHit := -1;
  ResetIdentityMap;
  RebuildMarkers;
  SyncScrollBars;
  StateChanged;
end;

procedure TCustomNimbusLogView.ConfigureStructuredQuery(const AQuery: string; const ADeferred: Boolean);
var Q: TNimbusLogQuery;
begin
  if Trim(AQuery) <> '' then
  begin
    Q := TNimbusLogQuery.Parse(AQuery);
    Q.Free;
  end;
  FStructuredQuery := AQuery;
  if ADeferred then
  begin
    FHits := nil;
    FActiveHit := -1;
    ResetIdentityMap;
    RebuildMarkers;
    SyncScrollBars;
    StateChanged;
  end
  else Rebuild;
end;

procedure TCustomNimbusLogView.ResetIdentityMap;
begin
  FIndices := nil;
  FIdentityMap := True;
  if FSource <> nil then FVisibleCount := FSource.Count64 else FVisibleCount := 0;
  if FSource <> nil then FMaxColumns := Integer(Min(Int64(MaxInt div 4), FSource.MaxTextLength)) else FMaxColumns := 0;
  if FVisibleCount = 0 then
  begin
    FTopRow := 0;
    FAnchor := -1;
    FSelectionEnd := -1;
  end;
end;

function TCustomNimbusLogView.SourceIndexAt(const AVisibleIndex: Int64): Int64;
begin
  if (AVisibleIndex < 0) or (AVisibleIndex >= FVisibleCount) then Exit(-1);
  if FIdentityMap then Result := AVisibleIndex
  else if AVisibleIndex < Length(FIndices) then Result := FIndices[AVisibleIndex]
  else Result := -1;
end;

procedure TCustomNimbusLogView.Rebuild;
var
  Indices: TList<Int64>;
  Hits: TList<TNimbusLogSearchHit>;
  I: Int64;
  J, ColumnCount, VisibleIndex: Integer;
  Line: TNimbusLogLine;
  Hit, OldHit: TNimbusLogSearchHit;
  Matches: TMatchCollection;
  Match: TMatch;
  Pattern: TRegEx;
  Options: TRegExOptions;
  OldTopID: UInt64;
  HasMatch, StructuredMatch: Boolean;
  HadActiveHit: Boolean;
  Structured: TNimbusLogQuery;
  AllLevels: TNimbusLogLevels;
begin
  if FSource = nil then Exit;
  AllLevels := [Low(TNimbusLogLevel)..High(TNimbusLogLevel)];
  if (FQuery = '') and (Trim(FStructuredQuery) = '') and (FLevels = AllLevels) and not FOnlyMatches then
  begin
    ResetIdentityMap;
    FHits := nil;
    FActiveHit := -1;
    RebuildMarkers;
    SyncScrollBars;
    StateChanged;
    Exit;
  end;
  OldTopID := FTopLineID;
  HadActiveHit := (FActiveHit >= 0) and (FActiveHit < Length(FHits));
  OldHit := Default(TNimbusLogSearchHit);
  if HadActiveHit then OldHit := FHits[FActiveHit];
  Indices := TList<Int64>.Create;
  Hits := TList<TNimbusLogSearchHit>.Create;
  Structured := nil;
  try
    if Trim(FStructuredQuery) <> '' then Structured := TNimbusLogQuery.Parse(FStructuredQuery);
    Options := [];
    if not FCaseSensitive then Include(Options, roIgnoreCase);
    if FQuery <> '' then
      if FRegex then Pattern := TRegEx.Create(FQuery, Options)
      else Pattern := TRegEx.Create(TRegEx.Escape(FQuery), Options);
    FMaxColumns := 0;
    FActiveHit := -1;
    FAnchor := -1;
    FSelectionEnd := -1;
    for I := 0 to FSource.Count64 - 1 do
    begin
      Line := FSource.Lines64[I];
      if not (Line.Level in FLevels) then Continue;
      StructuredMatch := (Structured = nil) or Structured.Matches(Line.Structured);
      if not StructuredMatch then Continue;
      HasMatch := FQuery = '';
      VisibleIndex := Indices.Count;
      if FQuery <> '' then
      begin
        Matches := Pattern.Matches(Line.Text);
        HasMatch := Matches.Count > 0;
        for Match in Matches do
          if Hits.Count < 100000 then
          begin
            Hit := Default(TNimbusLogSearchHit);
            Hit.LineID := Line.ID;
            Hit.SourceIndex64 := I;
            Hit.VisibleIndex64 := VisibleIndex;
            Hit.VisibleIndex := VisibleIndex;
            Hit.Column := Match.Index;
            Hit.Length := Match.Length;
            Hit.IsTextMatch := True;
            Hits.Add(Hit);
          end;
      end;
      if FOnlyMatches and (FQuery <> '') and not HasMatch then Continue;
      Indices.Add(I);
      ColumnCount := Length(Line.Text);
      for J := 1 to Length(Line.Text) do if Line.Text[J] = #9 then Inc(ColumnCount, 3);
      FMaxColumns := Max(FMaxColumns, ColumnCount);
      if Line.ID = FAnchorID then FAnchor := Indices.Count - 1;
      if Line.ID = FSelectionID then FSelectionEnd := Indices.Count - 1;
      if not FFollowTail and (Line.ID = OldTopID) then FTopRow := Indices.Count - 1;
    end;
    FIndices := Indices.ToArray;
    FIdentityMap := False;
    FVisibleCount := Length(FIndices);
    FHits := Hits.ToArray;
    if HadActiveHit then
      for J := 0 to High(FHits) do
        if (FHits[J].LineID = OldHit.LineID) and (FHits[J].Column = OldHit.Column) then
        begin
          FActiveHit := J;
          Break;
        end;
    if (FAnchor < 0) or (FSelectionEnd < 0) then
    begin
      FAnchor := -1;
      FSelectionEnd := -1;
      FAnchorID := 0;
      FSelectionID := 0;
    end;
  finally
    Structured.Free;
    Hits.Free;
    Indices.Free;
  end;
  RebuildMarkers;
  SyncScrollBars;
  StateChanged;
end;

procedure TCustomNimbusLogView.ApplyExternalSearchResults(const AHits: TArray<TNimbusLogSearchHit>;
  const AUseResultRows: Boolean);
var I: Integer; SourceIndex, PreviousSource: Int64; Rows: TList<Int64>;
  RealHits: TList<TNimbusLogSearchHit>; VisibleRow: Int64; Hit: TNimbusLogSearchHit;
begin
  FActiveHit := -1;
  RealHits := TList<TNimbusLogSearchHit>.Create;
  try
    if not AUseResultRows then
    begin
      ResetIdentityMap;
      for I := 0 to High(AHits) do
        if AHits[I].IsTextMatch then
        begin
          Hit := AHits[I];
          Hit.VisibleIndex64 := Hit.SourceIndex64;
          if Hit.VisibleIndex64 <= MaxInt then Hit.VisibleIndex := Integer(Hit.VisibleIndex64)
          else Hit.VisibleIndex := MaxInt;
          RealHits.Add(Hit);
        end;
    end
    else
    begin
      Rows := TList<Int64>.Create;
      try
        PreviousSource := -1;
        VisibleRow := -1;
        for I := 0 to High(AHits) do
        begin
          SourceIndex := AHits[I].SourceIndex64;
          if SourceIndex <> PreviousSource then
          begin
            Rows.Add(SourceIndex);
            PreviousSource := SourceIndex;
            VisibleRow := Rows.Count - 1;
          end;
          if AHits[I].IsTextMatch then
          begin
            Hit := AHits[I];
            Hit.VisibleIndex64 := VisibleRow;
            if VisibleRow <= MaxInt then Hit.VisibleIndex := Integer(VisibleRow) else Hit.VisibleIndex := MaxInt;
            RealHits.Add(Hit);
          end;
        end;
        FIndices := Rows.ToArray;
        FIdentityMap := False;
        FVisibleCount := Length(FIndices);
      finally
        Rows.Free;
      end;
    end;
    FHits := RealHits.ToArray;
  finally
    RealHits.Free;
  end;
  FTopRow := 0;
  FAnchor := -1;
  FSelectionEnd := -1;
  RebuildMarkers;
  SyncScrollBars;
  StateChanged;
end;

function TCustomNimbusLogView.MarkerRows: TArray<Integer>;
var Rows: array[TNimbusLogLevel, 0..511] of Integer;
  Level: TNimbusLogLevel; I, Bucket: Integer; SourceIndex: Int64; List: TList<Integer>;
begin
  Result := nil;
  if (FSource = nil) or (FVisibleCount = 0) or (FVisibleCount > NimbusMarkerScanLimit) then Exit;
  FillChar(Rows, SizeOf(Rows), $FF);
  for I := 0 to Integer(FVisibleCount) - 1 do
  begin
    SourceIndex := SourceIndexAt(I);
    if SourceIndex < 0 then Continue;
    Level := FSource.Lines64[SourceIndex].Level;
    if not (Level in FScrollBarLevels) then Continue;
    Bucket := Integer(Int64(I) * 512 div FVisibleCount);
    if Rows[Level, Bucket] < 0 then Rows[Level, Bucket] := I;
  end;
  List := TList<Integer>.Create;
  try
    for Level := Low(TNimbusLogLevel) to High(TNimbusLogLevel) do
      for Bucket := 0 to 511 do
        if Rows[Level, Bucket] >= 0 then List.Add(Rows[Level, Bucket]);
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

procedure TCustomNimbusLogView.RebuildMarkers;
const Tones: array[TNimbusLogLevel] of TNimbusIDEMarkerTone =
  (imtMuted, imtMuted, imtAccent, imtInfo, imtSuccess, imtWarning, imtError, imtError);
var Row: Integer; SourceIndex: Int64; Line: TNimbusLogLine; Marker: TThemedIDEScrollBarMarker;
begin
  if FV = nil then Exit;
  FV.Markers.BeginUpdate;
  try
    FV.ClearMarkers;
    FV.Hint := '';
    for Row in MarkerRows do
    begin
      SourceIndex := SourceIndexAt(Row);
      if SourceIndex < 0 then Continue;
      Line := FSource.Lines64[SourceIndex];
      Marker := FV.Markers.Add;
      Marker.First := Row;
      Marker.Last := Row;
      Marker.Tag := Row;
      Marker.Tone := Tones[Line.Level];
      if Line.Level in [nllWarning, nllError, nllFatal] then Marker.Lane := imlLeft else Marker.Lane := imlRight;
      if Line.Level = nllFatal then Marker.Shape := imsRectangle else Marker.Shape := imsBar;
      Marker.Hint := Format('Line %s: %s', [IntToStr(SourceIndex + 1), Copy(Line.Text, 1, 240)]);
    end;
  finally
    FV.Markers.EndUpdate;
  end;
end;

procedure TCustomNimbusLogView.SetScrollBarLevels(const ALevels: TNimbusLogLevels);
begin
  if FScrollBarLevels = ALevels then Exit;
  FScrollBarLevels := ALevels;
  RebuildMarkers;
  Invalidate;
end;

procedure TCustomNimbusLogView.MarkerEnter(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
begin
  FV.Hint := AMarker.Hint;
end;

procedure TCustomNimbusLogView.MarkerClick(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
var Row: Int64; SourceIndex: Int64; Line: TNimbusLogLine;
begin
  Row := AMarker.Tag;
  if (Row < 0) or (Row >= FVisibleCount) then Exit;
  SourceIndex := SourceIndexAt(Row);
  if (SourceIndex < 0) or not FSource.TryGetLine(SourceIndex, Line) then Exit;
  SelectRow(Row, False);
  if CanFocus then SetFocus;
  if Assigned(FOnMarkerClick) then
    FOnMarkerClick(Self, Line, Integer(Min(Int64(MaxInt), SourceIndex)), Integer(Min(Int64(MaxInt), Row)));
end;

function TCustomNimbusLogView.ScrollMaximum(const APage: Integer): Int64;
begin
  Result := Max(Int64(0), FVisibleCount - Max(1, APage));
end;

function TCustomNimbusLogView.ScrollValueFromRow(const ARow, AMaximum: Int64): Integer;
begin
  if AMaximum <= NimbusVirtualScrollMaximum then Exit(Integer(EnsureRange(ARow, Int64(0), AMaximum)));
  if AMaximum <= 0 then Exit(0);
  Result := Round(EnsureRange(ARow, Int64(0), AMaximum) / AMaximum * NimbusVirtualScrollMaximum);
end;

function TCustomNimbusLogView.RowFromScrollValue(const AValue: Integer; const AMaximum: Int64): Int64;
begin
  if AMaximum <= NimbusVirtualScrollMaximum then Exit(EnsureRange(Int64(AValue), Int64(0), AMaximum));
  Result := Round(EnsureRange(AValue, 0, NimbusVirtualScrollMaximum) / NimbusVirtualScrollMaximum * AMaximum);
end;

procedure TCustomNimbusLogView.SyncScrollBars;
var BarSize, W, H, Page, MaxX: Integer; MaxTop: Int64; Vertical, Horizontal: Boolean;
begin
  if FSyncing or (FV = nil) or not HandleAllocated then Exit;
  FSyncing := True;
  try
    BarSize := ScaleValue(18);
    if StyleMode = stCompact then BarSize := ScaleValue(14);
    W := ClientWidth;
    H := ClientHeight;
    Horizontal := FMetrics.GutterWidth + Int64(FMaxColumns) * Ceil(FMetrics.CharWidth) > W;
    if Horizontal then Dec(H, BarSize);
    Page := Max(1, H div Max(1, FMetrics.RowHeight));
    Vertical := (FVisibleCount > Page) or ((FVisibleCount > 1) and (FV.Markers.Count > 0));
    if Vertical then Dec(W, BarSize);
    if not Horizontal and (FMetrics.GutterWidth + Int64(FMaxColumns) * Ceil(FMetrics.CharWidth) > W) then
    begin
      Horizontal := True;
      Dec(H, BarSize);
      Page := Max(1, H div Max(1, FMetrics.RowHeight));
    end;
    Vertical := (FVisibleCount > Page) or ((FVisibleCount > 1) and (FV.Markers.Count > 0));
    W := ClientWidth - Ord(Vertical) * BarSize;
    H := ClientHeight - Ord(Horizontal) * BarSize;
    FMetrics.Bounds := Rect(0, 0, Max(0, W), Max(0, H));
    Page := Max(1, H div Max(1, FMetrics.RowHeight));
    MaxTop := ScrollMaximum(Page);
    if FFollowTail then
      if (FModel <> nil) and (FModel.InsertMode = nlimTop) then FTopRow := 0 else FTopRow := MaxTop;
    FTopRow := EnsureRange(FTopRow, Int64(0), MaxTop);
    FTopLineID := 0;
    if (FTopRow < FVisibleCount) and (FSource <> nil) then FTopLineID := FSource.Lines64[SourceIndexAt(FTopRow)].ID;
    MaxX := Min(MaxInt div 2, Ceil(Min(Int64(MaxInt div 4), Int64(FMaxColumns)) * FMetrics.CharWidth));
    FHOffset := EnsureRange(FHOffset, 0, Max(0, MaxX + FMetrics.GutterWidth - W));
    FV.SetBounds(ClientWidth - BarSize, 0, BarSize, Max(0, H));
    FV.Visible := Vertical;
    FH.SetBounds(0, ClientHeight - BarSize, Max(0, W), BarSize);
    FH.Visible := Horizontal;
    if MaxTop <= NimbusVirtualScrollMaximum then FV.Maximum := Integer(MaxTop) else FV.Maximum := NimbusVirtualScrollMaximum;
    if MaxTop <= NimbusVirtualScrollMaximum then FV.LargeChange := Page
    else FV.LargeChange := Max(1, Round(Page / Max(Int64(1), FVisibleCount) * NimbusVirtualScrollMaximum));
    FV.Value := ScrollValueFromRow(FTopRow, MaxTop);
    FH.Maximum := Max(0, MaxX + FMetrics.GutterWidth - 1);
    FH.LargeChange := Max(1, W);
    FH.Value := FHOffset;
  finally
    FSyncing := False;
  end;
end;

procedure TCustomNimbusLogView.ScrollChanged(Sender: TObject);
var Page: Integer; MaxTop: Int64;
begin
  if FSyncing then Exit;
  if Sender = FV then
  begin
    Page := Max(1, FMetrics.Bounds.Height div Max(1, FMetrics.RowHeight));
    MaxTop := ScrollMaximum(Page);
    FTopRow := RowFromScrollValue(FV.Value, MaxTop);
    FFollowTail := False;
  end
  else FHOffset := FH.Value;
  StateChanged;
end;

procedure TCustomNimbusLogView.Paint;
var First, Last, SourceFirst: Int64; Page: Integer;
begin
  if (FSource = nil) or (FOptions = nil) then Exit;
  RenderCanvas.BeginRender(Canvas);
  try
    FMetrics := TThemedVirtualLogViewerRenderer.Measure64(RenderCanvas, Font, ClientRect, CurrentPPI,
      StyleMode = stCompact, FLineNumbers, FSource.Count64);
    if FSource.MaxTextLength > FMaxColumns then FMaxColumns := Integer(Min(Int64(MaxInt div 4), FSource.MaxTextLength));
    SyncScrollBars;
    RenderCanvas.FillRectangle(NimbusInputBackColor(Palette), ClientRect);
    Page := Max(1, FMetrics.Bounds.Height div Max(1, FMetrics.RowHeight)) + 2;
    SourceFirst := SourceIndexAt(FTopRow);
    if SourceFirst >= 0 then FSource.EnsureRange(SourceFirst, Page);
    First := -1;
    Last := -1;
    if FAnchor >= 0 then
    begin
      First := Min(FAnchor, FSelectionEnd);
      Last := Max(FAnchor, FSelectionEnd);
    end;
    TThemedVirtualLogViewerRenderer.RenderSource(RenderCanvas, Font, Palette, FSource, FIndices, FIdentityMap,
      FVisibleCount, FMetrics, FOptions, FTopRow, FHOffset, First, Last, FHits, FActiveHit,
      Enabled, Self, FOnDraw, FOnColors);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomNimbusLogView.Resize;
begin
  inherited;
  SyncScrollBars;
  Invalidate;
end;

procedure TCustomNimbusLogView.StyleModeChanged;
begin
  inherited;
  SyncScrollBars;
  Invalidate;
end;

procedure TCustomNimbusLogView.SetLevels(const ALevels: TNimbusLogLevels; const ADeferred: Boolean);
begin
  FLevels := ALevels;
  if ADeferred then
  begin
    FHits := nil;
    FActiveHit := -1;
    ResetIdentityMap;
    RebuildMarkers;
    SyncScrollBars;
    StateChanged;
  end
  else Rebuild;
end;

procedure TCustomNimbusLogView.SetFollow(const AValue: Boolean);
begin
  FFollowTail := AValue;
  SyncScrollBars;
  StateChanged;
end;

procedure TCustomNimbusLogView.SetLineNumbers(const AValue: Boolean);
begin
  FLineNumbers := AValue;
  Invalidate;
end;

procedure TCustomNimbusLogView.EnsureSelectedVisible(const ARow: Int64);
var Page: Integer;
begin
  Page := Max(1, FMetrics.Bounds.Height div Max(1, FMetrics.RowHeight));
  if ARow < FTopRow then FTopRow := ARow
  else if ARow >= FTopRow + Page then FTopRow := ARow - Page + 1;
  SyncScrollBars;
end;

procedure TCustomNimbusLogView.SelectRow(const ARow: Int64; const AExtend: Boolean);
var SourceIndex: Int64; Line: TNimbusLogLine;
begin
  if (ARow < 0) or (ARow >= FVisibleCount) then Exit;
  SourceIndex := SourceIndexAt(ARow);
  if (SourceIndex < 0) or not FSource.TryGetLine(SourceIndex, Line) then Exit;
  if not AExtend or (FAnchor < 0) then
  begin
    FAnchor := ARow;
    FAnchorID := Line.ID;
  end;
  FSelectionEnd := ARow;
  FSelectionID := Line.ID;
  FFollowTail := False;
  EnsureSelectedVisible(ARow);
  StateChanged;
  if Assigned(FOnSelectionChanged) then FOnSelectionChanged(Self, Line, SourceIndex, ARow);
end;

function TCustomNimbusLogView.FindNext(const AForward: Boolean): Boolean;
var Hit: TNimbusLogSearchHit; X: Integer; SourceIndex: Int64;
begin
  Result := Length(FHits) > 0;
  if not Result then Exit;
  if AForward then FActiveHit := (FActiveHit + 1) mod Length(FHits)
  else if FActiveHit < 0 then FActiveHit := High(FHits)
  else FActiveHit := (FActiveHit + Length(FHits) - 1) mod Length(FHits);
  Hit := FHits[FActiveHit];
  SelectRow(Hit.VisibleIndex64, False);
  SourceIndex := SourceIndexAt(Hit.VisibleIndex64);
  if SourceIndex >= 0 then
  begin
    X := TThemedLogViewerRenderer.ColumnX(FSource.Lines64[SourceIndex].Text, Hit.Column, FMetrics);
    if (X < FHOffset) or (X > FHOffset + FMetrics.Bounds.Width - FMetrics.GutterWidth - 30) then FHOffset := Max(0, X - 20);
  end;
  SyncScrollBars;
  StateChanged;
end;

function TCustomNimbusLogView.SelectionText: string;
var Builder: TStringBuilder; I, First, Last, SourceIndex: Int64; Text: string;
begin
  Result := '';
  if (FAnchor < 0) or (FSelectionEnd < 0) then Exit;
  First := Min(FAnchor, FSelectionEnd);
  Last := Max(FAnchor, FSelectionEnd);
  Builder := TStringBuilder.Create;
  try
    for I := First to Last do
    begin
      SourceIndex := SourceIndexAt(I);
      if SourceIndex < 0 then Continue;
      Text := FSource.Lines64[SourceIndex].Text;
      if Builder.Length + Length(Text) + 2 > NimbusSelectionCopyLimit then
        raise ERangeError.Create('Selection exceeds the 16 MB copy limit');
      if I > First then Builder.Append(sLineBreak);
      Builder.Append(Text);
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

procedure TCustomNimbusLogView.CopySelection;
begin
  if FAnchor >= 0 then Clipboard.AsText := SelectionText;
end;

procedure TCustomNimbusLogView.SelectAll;
begin
  if FVisibleCount = 0 then Exit;
  SelectRow(0, False);
  SelectRow(FVisibleCount - 1, True);
end;

function TCustomNimbusLogView.VisibleCount: Integer;
begin
  Result := Integer(Min(Int64(MaxInt), FVisibleCount));
end;

function TCustomNimbusLogView.VisibleCount64: Int64;
begin
  Result := FVisibleCount;
end;

function TCustomNimbusLogView.MatchCount: Integer;
begin
  Result := Length(FHits);
end;

function TCustomNimbusLogView.SelectedSourceIndex: Int64;
begin
  Result := SourceIndexAt(FSelectionEnd);
end;

function TCustomNimbusLogView.VisibleSourceIndex(const AVisibleIndex: Int64): Int64;
begin
  Result := SourceIndexAt(AVisibleIndex);
end;

function TCustomNimbusLogView.SelectionRange(out AFirst, ALast: Int64): Boolean;
begin
  Result := (FAnchor >= 0) and (FSelectionEnd >= 0);
  if not Result then
  begin
    AFirst := -1;
    ALast := -1;
    Exit;
  end;
  AFirst := Min(FAnchor, FSelectionEnd);
  ALast := Max(FAnchor, FSelectionEnd);
end;

function TCustomNimbusLogView.SelectedLine: TNimbusLogLine;
var Index: Int64;
begin
  Result := nil;
  if FSource = nil then Exit;
  Index := SelectedSourceIndex;
  if Index >= 0 then FSource.TryGetLine(Index, Result);
end;

function TCustomNimbusLogView.InteractiveAt(const X, Y: Integer; out ALine: TNimbusLogLine;
  out ARun: TNimbusLogInteractiveRun; out ASourceIndex, AVisibleIndex: Int64): Boolean;
var Column: Integer; Run: TNimbusLogInteractiveRun;
begin
  Result := False;
  ALine := nil;
  ARun := nil;
  ASourceIndex := -1;
  AVisibleIndex := TThemedVirtualLogViewerRenderer.RowAt64(Point(X, Y), FMetrics, FTopRow, FVisibleCount);
  if AVisibleIndex < 0 then Exit;
  ASourceIndex := SourceIndexAt(AVisibleIndex);
  if (ASourceIndex < 0) or not FSource.TryGetLine(ASourceIndex, ALine) then Exit;
  Column := TThemedVirtualLogViewerRenderer.ColumnAtX(ALine.Text, X, FHOffset, FMetrics);
  if Column < 0 then Exit;
  for Run in ALine.InteractiveRuns do
    if (Column >= Run.Start) and (Column < Run.Start + Max(1, Run.Length)) then
    begin
      ARun := Run;
      Exit(True);
    end;
end;

procedure TCustomNimbusLogView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Line: TNimbusLogLine; Run: TNimbusLogInteractiveRun; SourceIndex, VisibleIndex: Int64;
begin
  inherited;
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  if InteractiveAt(X, Y, Line, Run, SourceIndex, VisibleIndex) then
  begin
    SelectRow(VisibleIndex, ssShift in Shift);
    if Assigned(FOnInteractiveClick) then FOnInteractiveClick(Self, Line, Run, SourceIndex, VisibleIndex);
    Exit;
  end;
  SelectRow(TThemedVirtualLogViewerRenderer.RowAt64(Point(X, Y), FMetrics, FTopRow, FVisibleCount), ssShift in Shift);
  FDragging := True;
  MouseCapture := True;
end;

procedure TCustomNimbusLogView.MouseMove(Shift: TShiftState; X, Y: Integer);
var Line: TNimbusLogLine; Run: TNimbusLogInteractiveRun; SourceIndex, VisibleIndex: Int64;
begin
  inherited;
  if FDragging then
  begin
    SelectRow(TThemedVirtualLogViewerRenderer.RowAt64(Point(X, Y), FMetrics, FTopRow, FVisibleCount), True);
    Exit;
  end;
  if InteractiveAt(X, Y, Line, Run, SourceIndex, VisibleIndex) then Cursor := crHandPoint else Cursor := crDefault;
end;

procedure TCustomNimbusLogView.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FDragging := False;
    MouseCapture := False;
  end;
end;

procedure TCustomNimbusLogView.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  FDragging := False;
end;

procedure TCustomNimbusLogView.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

function TCustomNimbusLogView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  FFollowTail := False;
  FTopRow := Max(Int64(0), FTopRow - Int64(WheelDelta div 120) * 3);
  SyncScrollBars;
  StateChanged;
  Result := True;
end;

procedure TCustomNimbusLogView.KeyDown(var Key: Word; Shift: TShiftState);
var Row: Int64; Page: Integer;
begin
  inherited;
  if not Enabled or (Key = 0) then Exit;
  if ssCtrl in Shift then
    case Key of
      Ord('C'): begin CopySelection; Key := 0; Exit; end;
      Ord('A'): begin SelectAll; Key := 0; Exit; end;
    end;
  if Key = VK_F3 then
  begin
    FindNext(not (ssShift in Shift));
    Key := 0;
    Exit;
  end;
  Row := Max(Int64(0), FSelectionEnd);
  Page := Max(1, FMetrics.Bounds.Height div Max(1, FMetrics.RowHeight));
  case Key of
    VK_UP: Dec(Row);
    VK_DOWN: Inc(Row);
    VK_PRIOR: Dec(Row, Page);
    VK_NEXT: Inc(Row, Page);
    VK_HOME: Row := 0;
    VK_END: Row := FVisibleCount - 1;
  else
    Exit;
  end;
  SelectRow(EnsureRange(Row, Int64(0), Max(Int64(0), FVisibleCount - 1)), ssShift in Shift);
  Key := 0;
end;

end.

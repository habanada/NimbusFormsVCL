unit NimbusForms.Grid.ControlMouse;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Math,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.ExtCtrls,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.FilterDescriptor,
  NimbusForms.Grid.ToolTipHost,
  NimbusForms.Grid.ControlHit;

type
  TThemedGridCellMouseKind = (Down, Up, Move, Click, DoubleClick);

  TThemedGridControlMouse = class(TThemedGridControlHit)
  private
    FDragSelecting: Boolean;
    FDragSelectStartRow: Integer;
    FDragSelectStartColumn: Integer;
    FLastDragSelectLocation: TPoint;
    FDragAutoScrollTimer: TTimer;
    FScrollDragStartMouse: Integer;
    FScrollDragStartValue: Integer;
    FResizingColumn: Boolean;
    FResizeColumnIndex: Integer;
    FResizeStartX: Integer;
    FResizeStartWidth: Integer;
    FColumnHeaderMouseDown: Boolean;
    FColumnHeaderMouseDownIndex: Integer;
    FColumnHeaderMouseDownLocation: TPoint;
    FDragStartX: Integer;
    FDragCandidate: Boolean;
    FDragCandidateLocation: TPoint;
    FDragCandidateRowIndex: Integer;
    FDragCandidateColumnIndex: Integer;
    FRowDragCandidate: Boolean;
    FRowDragCandidateLocation: TPoint;
    FRowDragCandidateRowIndex: Integer;
    FSuppressNextCellDoubleClickAction: Boolean;
    FToolTipHost: TThemedGridToolTipHost;
    FToolTipRowIndex: Integer;
    FToolTipColumnIndex: Integer;
    FToolTipText: string;
    FToolTipDetailItemKey: string;
    FOnCellMouseDown: TThemedGridCellMouseEvent;
    FOnCellMouseUp: TThemedGridCellMouseEvent;
    FOnCellMouseMove: TThemedGridCellMouseEvent;
    FOnCellClick: TThemedGridCellMouseEvent;
    FOnCellDoubleClick: TThemedGridCellMouseEvent;
    FOnCellContentClick: TThemedGridCellContentClickEvent;
    FOnCellToolTipNeeded: TThemedGridCellToolTipNeededEvent;
    FOnColumnHeaderClick: TThemedGridColumnEvent;
    FOnColumnSortRequested: TThemedGridColumnSortRequestedEvent;
    FOnColumnFilterRequested: TThemedGridColumnFilterEvent;
    FOnColumnReorderStarted: TThemedGridColumnEvent;
    FOnColumnReorderCanceled: TThemedGridColumnEvent;
    FOnColumnDisplayIndexChanged: TThemedGridColumnDisplayIndexChangedEvent;
    FOnDetailRowClick: TThemedGridDetailRowEvent;
    FOnDetailRowDoubleClick: TThemedGridDetailRowEvent;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure ProcessMouseDown(const AButton: TMouseButton; const AShift: TShiftState; const AX, AY: Integer);
    procedure ProcessMouseUp(const AButton: TMouseButton; const AShift: TShiftState; const AX, AY: Integer);
    procedure ProcessMouseMove(const AShift: TShiftState; const AX, AY: Integer);
    procedure ProcessDoubleClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint);
    procedure ClearPressedState;
    procedure BeginColumnResize(const AColumnIndex: Integer; const ALocation: TPoint);
    procedure UpdateColumnResize(const ALocation: TPoint);
    procedure BeginColumnHeaderDrag(const AColumnIndex: Integer; const ALocation: TPoint);
    procedure CancelColumnHeaderDrag;
    procedure UpdateColumnHeaderDrag(const ALocation: TPoint);
    procedure CompleteColumnHeaderDrag(const ALocation: TPoint);
    procedure ReorderColumn(const ASourceIndex, ATargetIndex: Integer);
    procedure HandleColumnHeaderClick(const AColumnIndex: Integer);
    procedure HandleColumnFilterButtonClick(const AColumnIndex: Integer);
    procedure BeginVerticalScrollDrag(const ALocation: TPoint);
    procedure BeginHorizontalScrollDrag(const ALocation: TPoint);
    procedure UpdateVerticalScrollDrag(const ALocation: TPoint);
    procedure UpdateHorizontalScrollDrag(const ALocation: TPoint);
    procedure DragAutoScrollTick(ASender: TObject);
    procedure UpdateCellToolTip(const AHit: TThemedGridHitInfo; const ALocation: TPoint);
    function GetToolTipText(const ACell: TThemedGridCell): string;
    function CreateMouseEventArgs(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
      const AClicks: Integer; const ALocation: TPoint; const ADelta: Integer): TThemedGridCellMouseEventArgs;
    function CreateContentClickEventArgs(const AHit: TThemedGridHitInfo;
      const ALocation: TPoint): TThemedGridCellContentClickEventArgs;
    function CreateDetailRowEventArgs(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
      const AClicks: Integer; const ALocation: TPoint): TThemedGridDetailRowEventArgs;
    procedure RaiseCellMouse(const AKind: TThemedGridCellMouseKind; const AHit: TThemedGridHitInfo;
      const AButton: TMouseButton; const AClicks: Integer; const ALocation: TPoint);
    procedure SetCursorIfChanged(const ACursor: TCursor);
  protected
    procedure HideCellToolTip;
    procedure ClearDragCandidate;
    procedure ClearRowDragCandidate;
    function IsCommandRenderColumn(const AColumn: TThemedGridColumn): Boolean;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseMove(AShift: TShiftState; AX, AY: Integer); override;
    procedure DblClick; override;
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
    procedure DoCellMouseDown(const AArgs: TThemedGridCellMouseEventArgs); virtual;
    procedure DoCellMouseUp(const AArgs: TThemedGridCellMouseEventArgs); virtual;
    procedure DoCellMouseMove(const AArgs: TThemedGridCellMouseEventArgs); virtual;
    procedure DoCellClick(const AArgs: TThemedGridCellMouseEventArgs); virtual;
    procedure DoCellDoubleClick(const AArgs: TThemedGridCellMouseEventArgs); virtual;
    procedure DoCellContentClick(const AArgs: TThemedGridCellContentClickEventArgs); virtual;
    procedure DoCellToolTipNeeded(const AArgs: TThemedGridCellToolTipNeededEventArgs); virtual;
    procedure DoColumnHeaderClick(const AColumn: TThemedGridColumn; const AColumnIndex: Integer); virtual;
    procedure DoColumnSortRequested(const AColumn: TThemedGridColumn; const AColumnIndex: Integer;
      const ADirection: TThemedGridSortDirection); virtual;
    procedure DoColumnFilterRequested(const AArgs: TThemedGridColumnFilterEventArgs); virtual;
    procedure DoColumnReorderStarted(const AColumn: TThemedGridColumn; const AColumnIndex: Integer); virtual;
    procedure DoColumnReorderCanceled(const AColumn: TThemedGridColumn; const AColumnIndex: Integer); virtual;
    procedure DoColumnDisplayIndexChanged(const AColumn: TThemedGridColumn; const AColumnIndex: Integer;
      const AOldDisplayIndex, ANewDisplayIndex: Integer); virtual;
    function DetailRowMouseDown(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
      const ALocation: TPoint): Boolean; virtual;
    function DetailRowMouseUp(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
      const ALocation: TPoint): Boolean; virtual;
    function DetailRowMouseMove(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; virtual;
    function DetailRowDoubleClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; virtual;
    procedure DetailRowMouseLeave; virtual;
    function VisualMouseDown(const ALocation: TPoint; const AButton: TMouseButton;
      const AShift: TShiftState): Boolean; virtual;
    function VisualMouseUp(const ALocation: TPoint; const AButton: TMouseButton;
      const AShift: TShiftState): Boolean; virtual;
    function VisualDoubleClick(const ALocation: TPoint): Boolean; virtual;
    procedure VisualMouseMove(const ALocation: TPoint); virtual;
    procedure ShowToolTipFor(const ARowIndex, AColumnIndex: Integer; const AItemKey, AText: string;
      const ALocation: TPoint);
    property ToolTipDetailItemKey: string read FToolTipDetailItemKey;
    procedure DoDetailRowClick(const AArgs: TThemedGridDetailRowEventArgs); virtual;
    procedure DoDetailRowDoubleClick(const AArgs: TThemedGridDetailRowEventArgs); virtual;
    procedure ShowColumnFilterPopup(const AColumnIndex: Integer; const AColumn: TThemedGridColumn;
      const AFilter: TThemedGridFilterDescriptor); virtual;
    function CanStartCellDrag(const AHit: TThemedGridHitInfo): Boolean; virtual;
    function CanStartRowMove(const AHit: TThemedGridHitInfo): Boolean; virtual;
    procedure BeginCellDrag; virtual;
    procedure BeginRowMoveDrag(const ARowIndex: Integer); virtual;
    function HitTestDirectValueGlyph(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; virtual;
    function TryHandleDirectValueClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; virtual;
    function CanBeginEditFromHit(const AHit: TThemedGridHitInfo): Boolean; virtual;
    procedure BeginEditCurrentCell; virtual;
    function ResolveCellCursor(const AHit: TThemedGridHitInfo; const ALocation: TPoint): TCursor; virtual;
    property DragSelecting: Boolean read FDragSelecting write FDragSelecting;
    property SuppressNextCellDoubleClickAction: Boolean
      read FSuppressNextCellDoubleClickAction write FSuppressNextCellDoubleClickAction;
    property ToolTipHost: TThemedGridToolTipHost read FToolTipHost;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnCellMouseDown: TThemedGridCellMouseEvent read FOnCellMouseDown write FOnCellMouseDown;
    property OnCellMouseUp: TThemedGridCellMouseEvent read FOnCellMouseUp write FOnCellMouseUp;
    property OnCellMouseMove: TThemedGridCellMouseEvent read FOnCellMouseMove write FOnCellMouseMove;
    property OnCellClick: TThemedGridCellMouseEvent read FOnCellClick write FOnCellClick;
    property OnCellDoubleClick: TThemedGridCellMouseEvent read FOnCellDoubleClick write FOnCellDoubleClick;
    property OnCellContentClick: TThemedGridCellContentClickEvent read FOnCellContentClick write FOnCellContentClick;
    property OnCellToolTipNeeded: TThemedGridCellToolTipNeededEvent
      read FOnCellToolTipNeeded write FOnCellToolTipNeeded;
    property OnColumnHeaderClick: TThemedGridColumnEvent read FOnColumnHeaderClick write FOnColumnHeaderClick;
    property OnColumnSortRequested: TThemedGridColumnSortRequestedEvent
      read FOnColumnSortRequested write FOnColumnSortRequested;
    property OnColumnFilterRequested: TThemedGridColumnFilterEvent
      read FOnColumnFilterRequested write FOnColumnFilterRequested;
    property OnColumnReorderStarted: TThemedGridColumnEvent read FOnColumnReorderStarted write FOnColumnReorderStarted;
    property OnColumnReorderCanceled: TThemedGridColumnEvent
      read FOnColumnReorderCanceled write FOnColumnReorderCanceled;
    property OnColumnDisplayIndexChanged: TThemedGridColumnDisplayIndexChangedEvent
      read FOnColumnDisplayIndexChanged write FOnColumnDisplayIndexChanged;
    property OnDetailRowClick: TThemedGridDetailRowEvent read FOnDetailRowClick write FOnDetailRowClick;
    property OnDetailRowDoubleClick: TThemedGridDetailRowEvent
      read FOnDetailRowDoubleClick write FOnDetailRowDoubleClick;
  end;

implementation

uses
  NimbusForms.Grid.ViewRow;

const
  DragAutoScrollIntervalMs = 60;
  ColumnHeaderDragThreshold = 6;
  ToolTipOffsetX = 16;
  ToolTipOffsetY = 18;

constructor TThemedGridControlMouse.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDragSelectStartRow := -1;
  FDragSelectStartColumn := -1;
  FResizeColumnIndex := -1;
  FColumnHeaderMouseDownIndex := -1;
  FDragCandidateRowIndex := -1;
  FDragCandidateColumnIndex := -1;
  FRowDragCandidateRowIndex := -1;
  FToolTipRowIndex := -1;
  FToolTipColumnIndex := -1;
  FToolTipHost := TThemedGridToolTipHost.Create(Self);
  FDragAutoScrollTimer := TTimer.Create(Self);
  FDragAutoScrollTimer.Enabled := False;
  FDragAutoScrollTimer.Interval := DragAutoScrollIntervalMs;
  FDragAutoScrollTimer.OnTimer := DragAutoScrollTick;
end;

destructor TThemedGridControlMouse.Destroy;
begin
  FDragAutoScrollTimer.Enabled := False;
  FToolTipHost.Free;
  inherited Destroy;
end;

procedure TThemedGridControlMouse.SetCursorIfChanged(const ACursor: TCursor);
begin
  if Cursor <> ACursor then
    Cursor := ACursor;
end;

function TThemedGridControlMouse.IsCommandRenderColumn(const AColumn: TThemedGridColumn): Boolean;
begin
  if AColumn = nil then
    Exit(False);
  Result := AColumn.RenderKind in [TThemedGridCellRenderKind.Command, TThemedGridCellRenderKind.Button,
    TThemedGridCellRenderKind.Link, TThemedGridCellRenderKind.Image, TThemedGridCellRenderKind.Icon];
end;

function TThemedGridControlMouse.CanStartCellDrag(const AHit: TThemedGridHitInfo): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.CanStartRowMove(const AHit: TThemedGridHitInfo): Boolean;
begin
  Result := False;
end;

procedure TThemedGridControlMouse.BeginCellDrag;
begin
end;

procedure TThemedGridControlMouse.BeginRowMoveDrag(const ARowIndex: Integer);
begin
end;

function TThemedGridControlMouse.HitTestDirectValueGlyph(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.TryHandleDirectValueClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.CanBeginEditFromHit(const AHit: TThemedGridHitInfo): Boolean;
begin
  Result := False;
end;

procedure TThemedGridControlMouse.BeginEditCurrentCell;
begin
end;

function TThemedGridControlMouse.ResolveCellCursor(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): TCursor;
begin
  if (AHit <> nil) and (AHit.HitArea = TThemedGridHitArea.Editor) then
    Result := crHandPoint
  else
    Result := crDefault;
end;

procedure TThemedGridControlMouse.ShowColumnFilterPopup(const AColumnIndex: Integer;
  const AColumn: TThemedGridColumn; const AFilter: TThemedGridFilterDescriptor);
begin
end;

procedure TThemedGridControlMouse.DoCellMouseDown(const AArgs: TThemedGridCellMouseEventArgs);
begin
  if Assigned(FOnCellMouseDown) then
    FOnCellMouseDown(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoCellMouseUp(const AArgs: TThemedGridCellMouseEventArgs);
begin
  if Assigned(FOnCellMouseUp) then
    FOnCellMouseUp(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoCellMouseMove(const AArgs: TThemedGridCellMouseEventArgs);
begin
  if Assigned(FOnCellMouseMove) then
    FOnCellMouseMove(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoCellClick(const AArgs: TThemedGridCellMouseEventArgs);
begin
  if Assigned(FOnCellClick) then
    FOnCellClick(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoCellDoubleClick(const AArgs: TThemedGridCellMouseEventArgs);
begin
  if Assigned(FOnCellDoubleClick) then
    FOnCellDoubleClick(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoCellContentClick(const AArgs: TThemedGridCellContentClickEventArgs);
begin
  if Assigned(FOnCellContentClick) then
    FOnCellContentClick(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoCellToolTipNeeded(const AArgs: TThemedGridCellToolTipNeededEventArgs);
begin
  if Assigned(FOnCellToolTipNeeded) then
    FOnCellToolTipNeeded(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoColumnHeaderClick(const AColumn: TThemedGridColumn; const AColumnIndex: Integer);
var
  LArgs: TThemedGridColumnEventArgs;
begin
  if not Assigned(FOnColumnHeaderClick) then
    Exit;
  LArgs := TThemedGridColumnEventArgs.Create(AColumn, AColumnIndex);
  try
    FOnColumnHeaderClick(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.DoColumnSortRequested(const AColumn: TThemedGridColumn;
  const AColumnIndex: Integer; const ADirection: TThemedGridSortDirection);
var
  LArgs: TThemedGridColumnSortRequestedEventArgs;
begin
  if not Assigned(FOnColumnSortRequested) then
    Exit;
  LArgs := TThemedGridColumnSortRequestedEventArgs.Create(AColumn, AColumnIndex, ADirection);
  try
    FOnColumnSortRequested(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.DoColumnFilterRequested(const AArgs: TThemedGridColumnFilterEventArgs);
begin
  if Assigned(FOnColumnFilterRequested) then
    FOnColumnFilterRequested(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoColumnReorderStarted(const AColumn: TThemedGridColumn;
  const AColumnIndex: Integer);
var
  LArgs: TThemedGridColumnEventArgs;
begin
  if not Assigned(FOnColumnReorderStarted) then
    Exit;
  LArgs := TThemedGridColumnEventArgs.Create(AColumn, AColumnIndex);
  try
    FOnColumnReorderStarted(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.DoColumnReorderCanceled(const AColumn: TThemedGridColumn;
  const AColumnIndex: Integer);
var
  LArgs: TThemedGridColumnEventArgs;
begin
  if not Assigned(FOnColumnReorderCanceled) then
    Exit;
  LArgs := TThemedGridColumnEventArgs.Create(AColumn, AColumnIndex);
  try
    FOnColumnReorderCanceled(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.DoColumnDisplayIndexChanged(const AColumn: TThemedGridColumn;
  const AColumnIndex: Integer; const AOldDisplayIndex, ANewDisplayIndex: Integer);
var
  LArgs: TThemedGridColumnDisplayIndexChangedEventArgs;
begin
  if not Assigned(FOnColumnDisplayIndexChanged) then
    Exit;
  LArgs := TThemedGridColumnDisplayIndexChangedEventArgs.Create(AColumn, AColumnIndex, AOldDisplayIndex,
    ANewDisplayIndex);
  try
    FOnColumnDisplayIndexChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.DoDetailRowClick(const AArgs: TThemedGridDetailRowEventArgs);
begin
  if Assigned(FOnDetailRowClick) then
    FOnDetailRowClick(Self, AArgs);
end;

procedure TThemedGridControlMouse.DoDetailRowDoubleClick(const AArgs: TThemedGridDetailRowEventArgs);
begin
  if Assigned(FOnDetailRowDoubleClick) then
    FOnDetailRowDoubleClick(Self, AArgs);
end;

function TThemedGridControlMouse.CreateMouseEventArgs(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
  const AClicks: Integer; const ALocation: TPoint; const ADelta: Integer): TThemedGridCellMouseEventArgs;
begin
  Result := TThemedGridCellMouseEventArgs.Create;
  Result.RowIndex := AHit.RowIndex;
  Result.ColumnIndex := AHit.ColumnIndex;
  Result.DataSourceIndex := AHit.DataSourceIndex;
  Result.Column := AHit.Column;
  Result.Row := AHit.Row;
  Result.Cell := AHit.Cell;
  if AHit.Cell <> nil then
  begin
    Result.RowObject := AHit.Cell.RowObject;
    Result.Value := AHit.Cell.Value;
    Result.CellTag := AHit.Cell.Tag;
  end;
  Result.Bounds := AHit.Bounds;
  Result.Button := [AButton];
  Result.Clicks := AClicks;
  Result.Location := ALocation;
  Result.Delta := ADelta;
  Result.HitInfo := AHit;
end;

function TThemedGridControlMouse.CreateContentClickEventArgs(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): TThemedGridCellContentClickEventArgs;
begin
  Result := TThemedGridCellContentClickEventArgs.Create;
  Result.RowIndex := AHit.RowIndex;
  Result.ColumnIndex := AHit.ColumnIndex;
  Result.DataSourceIndex := AHit.DataSourceIndex;
  Result.Column := AHit.Column;
  Result.Row := AHit.Row;
  Result.Cell := AHit.Cell;
  if AHit.Cell <> nil then
  begin
    Result.RowObject := AHit.Cell.RowObject;
    Result.Value := AHit.Cell.Value;
    Result.CellTag := AHit.Cell.Tag;
  end;
  Result.Bounds := AHit.Bounds;
  Result.Location := ALocation;
  Result.HitInfo := AHit;
end;

function TThemedGridControlMouse.CreateDetailRowEventArgs(const AHit: TThemedGridHitInfo;
  const AButton: TMouseButton; const AClicks: Integer; const ALocation: TPoint): TThemedGridDetailRowEventArgs;
var
  LDetailRow: TThemedGridViewRow;
begin
  Result := TThemedGridDetailRowEventArgs.Create;
  if AHit = nil then
    Exit;
  LDetailRow := GetViewRow(AHit.RowIndex);
  Result.ViewRowIndex := AHit.RowIndex;
  Result.ParentViewRowIndex := -1;
  Result.ParentDataSourceIndex := -1;
  Result.Bounds := GetRowBounds(AHit.RowIndex);
  Result.Button := [AButton];
  Result.Clicks := AClicks;
  Result.Location := ALocation;
  Result.Delta := 0;
  Result.HitInfo := AHit;
  if LDetailRow <> nil then
    Result.DetailText := LDetailRow.DisplayText;
  if (LDetailRow <> nil) and LDetailRow.IsDetailRow then
  begin
    Result.ParentDataSourceIndex := LDetailRow.ParentDataSourceIndex;
    Result.ParentViewRowIndex := FindDataViewRowByDataSourceIndex(LDetailRow.ParentDataSourceIndex);
    if LDetailRow.ParentDataSourceIndex >= 0 then
      Result.ParentRowObject := DataController.GetRowObject(LDetailRow.ParentDataSourceIndex);
  end;
end;

procedure TThemedGridControlMouse.RaiseCellMouse(const AKind: TThemedGridCellMouseKind;
  const AHit: TThemedGridHitInfo; const AButton: TMouseButton; const AClicks: Integer; const ALocation: TPoint);
var
  LArgs: TThemedGridCellMouseEventArgs;
begin
  LArgs := CreateMouseEventArgs(AHit, AButton, AClicks, ALocation, 0);
  try
    case AKind of
      TThemedGridCellMouseKind.Down: DoCellMouseDown(LArgs);
      TThemedGridCellMouseKind.Up: DoCellMouseUp(LArgs);
      TThemedGridCellMouseKind.Move: DoCellMouseMove(LArgs);
      TThemedGridCellMouseKind.Click: DoCellClick(LArgs);
    else
      DoCellDoubleClick(LArgs);
    end;
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.ClearDragCandidate;
begin
  FDragCandidate := False;
  FDragCandidateRowIndex := -1;
  FDragCandidateColumnIndex := -1;
  FDragCandidateLocation := Point(0, 0);
end;

procedure TThemedGridControlMouse.ClearRowDragCandidate;
begin
  FRowDragCandidate := False;
  FRowDragCandidateRowIndex := -1;
  FRowDragCandidateLocation := Point(0, 0);
end;

procedure TThemedGridControlMouse.ClearPressedState;
var
  LPressedRow, LPressedColumn: Integer;
begin
  LPressedRow := PressedRowIndex;
  LPressedColumn := PressedColumnIndex;
  PressedRowIndex := -1;
  PressedColumnIndex := -1;
  PressedContent := False;
  if (LPressedRow >= 0) and (LPressedColumn >= 0) then
    InvalidateCell(LPressedRow, LPressedColumn);
end;

procedure TThemedGridControlMouse.HideCellToolTip;
begin
  if (FToolTipRowIndex < 0) and (FToolTipColumnIndex < 0) and (FToolTipDetailItemKey = '') then
    Exit;
  FToolTipRowIndex := -1;
  FToolTipColumnIndex := -1;
  FToolTipDetailItemKey := '';
  FToolTipText := '';
  FToolTipHost.Hide;
end;

procedure TThemedGridControlMouse.ShowToolTipFor(const ARowIndex, AColumnIndex: Integer; const AItemKey,
  AText: string; const ALocation: TPoint);
begin
  if (FToolTipRowIndex = ARowIndex) and (FToolTipColumnIndex = AColumnIndex) and
    (FToolTipDetailItemKey = AItemKey) and (FToolTipText = AText) then
    Exit;
  FToolTipRowIndex := ARowIndex;
  FToolTipColumnIndex := AColumnIndex;
  FToolTipDetailItemKey := AItemKey;
  FToolTipText := AText;
  FToolTipHost.Show(AText, ALocation.X + ToolTipOffsetX, ALocation.Y + ToolTipOffsetY);
end;

function TThemedGridControlMouse.DetailRowMouseDown(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.DetailRowMouseUp(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.VisualMouseDown(const ALocation: TPoint; const AButton: TMouseButton;
  const AShift: TShiftState): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.VisualMouseUp(const ALocation: TPoint; const AButton: TMouseButton;
  const AShift: TShiftState): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.VisualDoubleClick(const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

procedure TThemedGridControlMouse.VisualMouseMove(const ALocation: TPoint);
begin
end;

function TThemedGridControlMouse.DetailRowMouseMove(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

function TThemedGridControlMouse.DetailRowDoubleClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
end;

procedure TThemedGridControlMouse.DetailRowMouseLeave;
begin
end;

function TThemedGridControlMouse.GetToolTipText(const ACell: TThemedGridCell): string;
var
  LArgs: TThemedGridCellToolTipNeededEventArgs;
begin
  Result := '';
  if ACell = nil then
    Exit;
  if ACell.Metadata <> nil then
  begin
    if ACell.Metadata.ErrorText <> '' then
      Result := ACell.Metadata.ErrorText
    else if ACell.Metadata.ToolTipText <> '' then
      Result := ACell.Metadata.ToolTipText;
  end;
  if not Assigned(FOnCellToolTipNeeded) then
    Exit;
  LArgs := TThemedGridCellToolTipNeededEventArgs.Create;
  try
    LArgs.RowIndex := ACell.RowIndex;
    LArgs.ColumnIndex := ACell.ColumnIndex;
    LArgs.DataSourceIndex := ACell.DataSourceIndex;
    LArgs.Column := ACell.Column;
    LArgs.Row := ACell.Row;
    LArgs.Cell := ACell;
    LArgs.RowObject := ACell.RowObject;
    LArgs.Value := ACell.Value;
    LArgs.CellTag := ACell.Tag;
    LArgs.Bounds := ACell.Bounds;
    LArgs.ToolTipText := Result;
    LArgs.IsMarkup := True;
    DoCellToolTipNeeded(LArgs);
    Result := LArgs.ToolTipText;
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMouse.UpdateCellToolTip(const AHit: TThemedGridHitInfo; const ALocation: TPoint);
var
  LText: string;
begin
  if (AHit = nil) or (AHit.Cell = nil) then
  begin
    HideCellToolTip;
    Exit;
  end;
  LText := GetToolTipText(AHit.Cell);
  if LText = '' then
  begin
    HideCellToolTip;
    Exit;
  end;
  if (FToolTipRowIndex = AHit.RowIndex) and (FToolTipColumnIndex = AHit.ColumnIndex) and
    (FToolTipText = LText) then
    Exit;
  FToolTipRowIndex := AHit.RowIndex;
  FToolTipColumnIndex := AHit.ColumnIndex;
  FToolTipText := LText;
  FToolTipHost.Show(LText, ALocation.X + ToolTipOffsetX, ALocation.Y + ToolTipOffsetY);
end;

procedure TThemedGridControlMouse.BeginVerticalScrollDrag(const ALocation: TPoint);
var
  LMaxFirst, LPageRows: Integer;
begin
  if IsEditing and EditOptions.CommitOnScroll then
    CommitEdit;
  FToolTipHost.Hide;
  LMaxFirst := GetMaxFirstVisibleRow;
  if LMaxFirst <= 0 then
    Exit;
  if PtInRect(VerticalScrollThumbBounds, ALocation) then
  begin
    DraggingVerticalScrollThumb := True;
    FScrollDragStartMouse := ALocation.Y;
    FScrollDragStartValue := FirstVisibleRowIndex;
    MouseCapture := True;
    Invalidate;
    Exit;
  end;
  LPageRows := Max(1, GetVerticalScrollLargeChange);
  if ALocation.Y < VerticalScrollThumbBounds.Top then
    FirstVisibleRowIndex := FirstVisibleRowIndex - LPageRows
  else
    FirstVisibleRowIndex := FirstVisibleRowIndex + LPageRows;
  NormalizeScrollValues;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TThemedGridControlMouse.BeginHorizontalScrollDrag(const ALocation: TPoint);
begin
  if IsEditing and EditOptions.CommitOnScroll then
    CommitEdit;
  FToolTipHost.Hide;
  if PtInRect(HorizontalScrollThumbBounds, ALocation) then
  begin
    DraggingHorizontalScrollThumb := True;
    FScrollDragStartMouse := ALocation.X;
    FScrollDragStartValue := HorizontalOffset;
    MouseCapture := True;
    Invalidate;
    Exit;
  end;
  if ALocation.X < HorizontalScrollThumbBounds.Left then
    HorizontalOffset := HorizontalOffset - Max(20, DataBounds.Width)
  else
    HorizontalOffset := HorizontalOffset + Max(20, DataBounds.Width);
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlMouse.UpdateVerticalScrollDrag(const ALocation: TPoint);
var
  LMaxFirst, LMovable, LDelta: Integer;
  LValue: Int64;
begin
  LMaxFirst := GetMaxFirstVisibleRow;
  if LMaxFirst <= 0 then
    Exit;
  LMovable := Max(1, VerticalScrollBarBounds.Height - VerticalScrollThumbBounds.Height);
  LDelta := ALocation.Y - FScrollDragStartMouse;
  LValue := Int64(FScrollDragStartValue) + Int64(LDelta) * LMaxFirst div LMovable;
  if LValue < 0 then
    LValue := 0;
  if LValue > LMaxFirst then
    LValue := LMaxFirst;
  FirstVisibleRowIndex := Integer(LValue);
  NormalizeScrollValues;
  UpdateEditorBounds;
  FToolTipHost.Hide;
  Invalidate;
end;

procedure TThemedGridControlMouse.UpdateHorizontalScrollDrag(const ALocation: TPoint);
var
  LMaxOffset, LTrackWidth, LDelta: Integer;
begin
  LMaxOffset := GetMaxHorizontalOffset;
  if LMaxOffset <= 0 then
    Exit;
  LTrackWidth := Max(1, HorizontalScrollBarBounds.Width - HorizontalScrollThumbBounds.Width);
  LDelta := ALocation.X - FScrollDragStartMouse;
  HorizontalOffset := FScrollDragStartValue + LDelta * LMaxOffset div LTrackWidth;
  NormalizeScrollValues;
  UpdateEditorBounds;
  FToolTipHost.Hide;
  Invalidate;
end;

procedure TThemedGridControlMouse.BeginColumnResize(const AColumnIndex: Integer; const ALocation: TPoint);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit;
  FResizingColumn := True;
  FResizeColumnIndex := AColumnIndex;
  FResizeStartX := ALocation.X;
  FResizeStartWidth := LColumn.Width;
  MouseCapture := True;
  Cursor := crHSplit;
end;

procedure TThemedGridControlMouse.UpdateColumnResize(const ALocation: TPoint);
var
  LColumn: TThemedGridColumn;
  LWidth: Integer;
begin
  if not FResizingColumn or (FResizeColumnIndex < 0) then
    Exit;
  LColumn := GetColumn(FResizeColumnIndex);
  if LColumn = nil then
    Exit;
  LWidth := FResizeStartWidth + ALocation.X - FResizeStartX;
  if LWidth < LColumn.MinWidth then
    LWidth := LColumn.MinWidth;
  if LWidth > LColumn.MaxWidth then
    LWidth := LColumn.MaxWidth;
  if LColumn.Width = LWidth then
    Exit;
  LColumn.Width := LWidth;
  AutoSizePending := False;
  NormalizeScrollValues;
  Invalidate;
  CheckColumnWidthChanges;
end;

procedure TThemedGridControlMouse.BeginColumnHeaderDrag(const AColumnIndex: Integer; const ALocation: TPoint);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit;
  FColumnHeaderMouseDown := False;
  FColumnHeaderMouseDownIndex := -1;
  DraggingColumnHeader := True;
  DragColumnIndex := AColumnIndex;
  DragTargetColumnIndex := AColumnIndex;
  FDragStartX := ALocation.X;
  MouseCapture := True;
  Cursor := crSizeWE;
  DoColumnReorderStarted(LColumn, AColumnIndex);
  InvalidateBounds(HeaderBounds);
end;

procedure TThemedGridControlMouse.CancelColumnHeaderDrag;
var
  LColumnIndex: Integer;
  LColumn: TThemedGridColumn;
begin
  LColumnIndex := DragColumnIndex;
  LColumn := nil;
  if LColumnIndex >= 0 then
    LColumn := GetColumn(LColumnIndex);
  DraggingColumnHeader := False;
  DragColumnIndex := -1;
  DragTargetColumnIndex := -1;
  FDragStartX := 0;
  MouseCapture := False;
  Cursor := crDefault;
  if LColumn <> nil then
    DoColumnReorderCanceled(LColumn, LColumnIndex);
  InvalidateBounds(HeaderBounds);
end;

procedure TThemedGridControlMouse.UpdateColumnHeaderDrag(const ALocation: TPoint);
var
  LTargetIndex: Integer;
begin
  LTargetIndex := GetColumnIndexAtX(ALocation.X);
  if LTargetIndex < 0 then
    LTargetIndex := DragTargetColumnIndex;
  if LTargetIndex <> DragTargetColumnIndex then
  begin
    DragTargetColumnIndex := LTargetIndex;
    InvalidateBounds(HeaderBounds);
  end;
  Cursor := crSizeWE;
end;

procedure TThemedGridControlMouse.CompleteColumnHeaderDrag(const ALocation: TPoint);
var
  LSourceIndex, LTargetIndex: Integer;
begin
  LSourceIndex := DragColumnIndex;
  LTargetIndex := GetColumnIndexAtX(ALocation.X);
  if LTargetIndex < 0 then
    LTargetIndex := DragTargetColumnIndex;
  DraggingColumnHeader := False;
  DragColumnIndex := -1;
  DragTargetColumnIndex := -1;
  MouseCapture := False;
  Cursor := crDefault;
  if (LSourceIndex >= 0) and (LTargetIndex >= 0) and (LSourceIndex <> LTargetIndex) then
    ReorderColumn(LSourceIndex, LTargetIndex);
  InvalidateBounds(HeaderBounds);
end;

procedure TThemedGridControlMouse.ReorderColumn(const ASourceIndex, ATargetIndex: Integer);
var
  LVisible: TList<TThemedGridColumn>;
  LSource: TThemedGridColumn;
  LOldDisplayIndex, I: Integer;
begin
  LVisible := TList<TThemedGridColumn>.Create(GetVisibleColumns);
  try
    if (ASourceIndex < 0) or (ASourceIndex >= LVisible.Count) then
      Exit;
    if (ATargetIndex < 0) or (ATargetIndex >= LVisible.Count) then
      Exit;
    LSource := LVisible[ASourceIndex];
    LOldDisplayIndex := LSource.VisibleIndex;
    LVisible.Delete(ASourceIndex);
    LVisible.Insert(ATargetIndex, LSource);
    for I := 0 to LVisible.Count - 1 do
      LVisible[I].VisibleIndex := I;
  finally
    LVisible.Free;
  end;
  NormalizeScrollValues;
  Invalidate;
  DoColumnDisplayIndexChanged(LSource, ATargetIndex, LOldDisplayIndex, ATargetIndex);
end;

procedure TThemedGridControlMouse.HandleColumnFilterButtonClick(const AColumnIndex: Integer);
var
  LColumn: TThemedGridColumn;
  LFilter: TThemedGridFilterDescriptor;
  LArgs: TThemedGridColumnFilterEventArgs;
begin
  LColumn := GetColumn(AColumnIndex);
  if (LColumn = nil) or not LColumn.AllowFilter then
    Exit;
  LFilter := nil;
  if LColumn.Filter is TThemedGridFilterDescriptor then
    LFilter := TThemedGridFilterDescriptor(LColumn.Filter).Clone;
  LArgs := TThemedGridColumnFilterEventArgs.Create(LColumn, AColumnIndex, LFilter);
  try
    DoColumnFilterRequested(LArgs);
    if not LArgs.Cancel then
      ShowColumnFilterPopup(AColumnIndex, LColumn, LArgs.Filter);
  finally
    LArgs.Free;
    LFilter.Free;
  end;
end;

procedure TThemedGridControlMouse.HandleColumnHeaderClick(const AColumnIndex: Integer);
var
  LColumn: TThemedGridColumn;
  LNext: TThemedGridSortDirection;
  LVisible: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit;
  DoColumnHeaderClick(LColumn, AColumnIndex);

  if SelectionOptions.AllowColumnSelection and
    (SelectionMode in [TThemedGridSelectionMode.Column, TThemedGridSelectionMode.ColumnRange]) then
  begin
    SelectionModel.SelectColumn(AColumnIndex);
    CurrentRowIndex := 0;
    CurrentColumnIndex := AColumnIndex;
    Invalidate;
  end;

  if not AllowColumnSort then
    Exit;

  case LColumn.SortDirection of
    TThemedGridSortDirection.None: LNext := TThemedGridSortDirection.Ascending;
    TThemedGridSortDirection.Ascending: LNext := TThemedGridSortDirection.Descending;
  else
    LNext := TThemedGridSortDirection.None;
  end;

  LVisible := GetVisibleColumns;
  for I := 0 to LVisible.Count - 1 do
    if LVisible[I] <> LColumn then
      LVisible[I].SortDirection := TThemedGridSortDirection.None;
  LColumn.SortDirection := LNext;

  if DataController <> nil then
  begin
    if LNext = TThemedGridSortDirection.None then
      DataController.ClearSort
    else
      DataController.ApplySort(LColumn, LNext);
    FirstVisibleRowIndex := 0;
    CurrentRowIndex := -1;
    CurrentColumnIndex := -1;
  end;

  DoColumnSortRequested(LColumn, AColumnIndex, LNext);
  CheckRowsChanged;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlMouse.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  ProcessMouseDown(AButton, AShift, AX, AY);
  inherited MouseDown(AButton, AShift, AX, AY);
end;

procedure TThemedGridControlMouse.ProcessMouseDown(const AButton: TMouseButton; const AShift: TShiftState;
  const AX, AY: Integer);
var
  LHit: TThemedGridHitInfo;
  LLocation: TPoint;
  LShift, LControl, LWasCurrent, LPrimary, LGlyphHit: Boolean;
  LClicks: Integer;
  LArgs: TThemedGridDetailRowEventArgs;
  LCellArgs: TThemedGridCellMouseEventArgs;
begin
  if CanFocus and not Focused then
    SetFocus;
  if IsEditing then
    CommitEdit;

  LLocation := Point(AX, AY);
  LShift := ssShift in AShift;
  LControl := ssCtrl in AShift;
  if ssDouble in AShift then
    LClicks := 2
  else
    LClicks := 1;
  FSuppressNextCellDoubleClickAction := False;

  LHit := HitTest(LLocation);
  try
    if VisualMouseDown(LLocation, AButton, AShift) then
      Exit;

    if (LHit.HitArea = TThemedGridHitArea.GroupRow) and (LHit.RowIndex >= 0) then
    begin
      CurrentRowIndex := LHit.RowIndex;
      CurrentColumnIndex := -1;
      if SelectionOptions.AllowRowSelection then
        ApplyMouseRowSelection(LHit.RowIndex, LShift, LControl);
      if AButton = mbLeft then
        TryToggleGroupRow(LHit.RowIndex, LLocation);
      Invalidate;
      Exit;
    end;

    if LHit.IsDetailRow and (LHit.RowIndex >= 0) then
    begin
      SelectDetailParentRow(LHit.RowIndex);
      if DetailRowMouseDown(LHit, AButton, LLocation) then
        Exit;
      LArgs := CreateDetailRowEventArgs(LHit, AButton, LClicks, LLocation);
      try
        DoDetailRowClick(LArgs);
      finally
        LArgs.Free;
      end;
      Invalidate;
      Exit;
    end;

    if (LHit.HitArea = TThemedGridHitArea.FilterButton) and (LHit.ColumnIndex >= 0) then
    begin
      PressedFilterButtonColumnIndex := LHit.ColumnIndex;
      HoverFilterButtonColumnIndex := LHit.ColumnIndex;
      MouseCapture := True;
      InvalidateBounds(LHit.Bounds);
      Exit;
    end;

    if (LHit.HitArea = TThemedGridHitArea.ResizeGrip) and AllowColumnResize then
    begin
      BeginColumnResize(LHit.ColumnIndex, LLocation);
      Exit;
    end;

    if (LHit.HitArea = TThemedGridHitArea.ColumnHeader) and (LHit.ColumnIndex >= 0) then
    begin
      if SelectionOptions.AllowColumnSelection and
        (SelectionMode in [TThemedGridSelectionMode.Column, TThemedGridSelectionMode.ColumnRange]) then
      begin
        if LControl then
          SelectionModel.ToggleColumn(LHit.ColumnIndex)
        else
          SelectionModel.SelectColumn(LHit.ColumnIndex);
        if RowCount > 0 then
          CurrentRowIndex := NormalizeCellRowIndex(0, 1)
        else
          CurrentRowIndex := NormalizeCellRowIndex(-1, 1);
        CurrentColumnIndex := LHit.ColumnIndex;
        Invalidate;
      end;
      FColumnHeaderMouseDown := True;
      FColumnHeaderMouseDownIndex := LHit.ColumnIndex;
      FColumnHeaderMouseDownLocation := LLocation;
      MouseCapture := True;
      Exit;
    end;

    if (LHit.HitArea = TThemedGridHitArea.DetailExpander) and (LHit.RowIndex >= 0) then
    begin
      if (AButton = mbLeft) and (LClicks = 1) then
        ToggleDetailRow(LHit.RowIndex);
      Exit;
    end;

    if (LHit.HitArea = TThemedGridHitArea.RowHeader) and (LHit.RowIndex >= 0) then
    begin
      if (AButton = mbLeft) and (LClicks = 1) and CanStartRowMove(LHit) then
      begin
        FRowDragCandidate := True;
        FRowDragCandidateLocation := LLocation;
        FRowDragCandidateRowIndex := LHit.RowIndex;
      end;
      if SelectionOptions.AllowRowSelection then
      begin
        ApplyMouseRowSelection(LHit.RowIndex, LShift, LControl);
        CurrentRowIndex := LHit.RowIndex;
        if IsDataViewRow(LHit.RowIndex) and (GetVisibleColumns.Count > 0) then
          CurrentColumnIndex := 0
        else
          CurrentColumnIndex := -1;
        if (CurrentRowIndex >= 0) and (CurrentColumnIndex >= 0) then
          EnsureVisible(CurrentRowIndex, CurrentColumnIndex);
        Invalidate;
      end;
      Exit;
    end;

    if LHit.HitArea = TThemedGridHitArea.VerticalScrollBar then
    begin
      BeginVerticalScrollDrag(LLocation);
      Exit;
    end;

    if LHit.HitArea = TThemedGridHitArea.HorizontalScrollBar then
    begin
      BeginHorizontalScrollDrag(LLocation);
      Exit;
    end;

    if LHit.HitArea = TThemedGridHitArea.SummaryFooter then
    begin
      SummaryPressedColumnIndex := LHit.ColumnIndex;
      if SummaryPressedColumnIndex >= 0 then
        InvalidateBounds(GetSummaryFooterCellBounds(SummaryPressedColumnIndex));
      Exit;
    end;

    if LHit.IsCell or (LHit.HitArea = TThemedGridHitArea.Editor) then
    begin
      if not IsDataViewRow(LHit.RowIndex) then
        Exit;
      FocusedDetailParentDataSourceIndex := -1;
      LWasCurrent := (CurrentRowIndex = LHit.RowIndex) and (CurrentColumnIndex = LHit.ColumnIndex);
      LPrimary := (AButton = mbLeft) and not LShift and not LControl;
      LGlyphHit := LPrimary and HitTestDirectValueGlyph(LHit, LLocation);

      if LPrimary and (LClicks = 1) and not LGlyphHit and CanStartCellDrag(LHit) then
      begin
        FDragCandidate := True;
        FDragCandidateLocation := LLocation;
        FDragCandidateRowIndex := LHit.RowIndex;
        FDragCandidateColumnIndex := LHit.ColumnIndex;
        RaiseCellMouse(TThemedGridCellMouseKind.Down, LHit, AButton, LClicks, LLocation);
        Exit;
      end;

      ApplyMouseCellSelection(LHit.RowIndex, LHit.ColumnIndex, LShift, LControl);

      if LGlyphHit and (LClicks > 1) then
      begin
        FSuppressNextCellDoubleClickAction := True;
        RaiseCellMouse(TThemedGridCellMouseKind.Down, LHit, AButton, LClicks, LLocation);
        Exit;
      end;

      if LGlyphHit and TryHandleDirectValueClick(LHit, LLocation) then
      begin
        FSuppressNextCellDoubleClickAction := True;
        RaiseCellMouse(TThemedGridCellMouseKind.Down, LHit, AButton, LClicks, LLocation);
        Exit;
      end;

      if LPrimary and (LClicks = 1) and LWasCurrent and EditOptions.EditOnSingleClick and
        CanBeginEditFromHit(LHit) then
      begin
        BeginEditCurrentCell;
        RaiseCellMouse(TThemedGridCellMouseKind.Down, LHit, AButton, LClicks, LLocation);
        Exit;
      end;

      if SelectionOptions.AllowRangeSelection and (AButton = mbLeft) and not LControl then
      begin
        FDragSelecting := True;
        FDragSelectStartRow := LHit.RowIndex;
        FDragSelectStartColumn := LHit.ColumnIndex;
        FLastDragSelectLocation := LLocation;
        MouseCapture := True;
        FDragAutoScrollTimer.Enabled := True;
      end;

      PressedRowIndex := LHit.RowIndex;
      PressedColumnIndex := LHit.ColumnIndex;
      PressedContent := LHit.HitArea = TThemedGridHitArea.Editor;

      InvalidateCell(LHit.RowIndex, LHit.ColumnIndex);
      LCellArgs := CreateMouseEventArgs(LHit, AButton, LClicks, LLocation, 0);
      try
        DoCellMouseDown(LCellArgs);
      finally
        LCellArgs.Free;
      end;
    end;
  finally
    LHit.Free;
  end;
end;

procedure TThemedGridControlMouse.MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  ProcessMouseUp(AButton, AShift, AX, AY);
  inherited MouseUp(AButton, AShift, AX, AY);
end;

procedure TThemedGridControlMouse.ProcessMouseUp(const AButton: TMouseButton; const AShift: TShiftState;
  const AX, AY: Integer);
var
  LHit: TThemedGridHitInfo;
  LLocation: TPoint;
  LCandidateRow, LCandidateColumn, LPressedColumnIndex, LOldPressed, LColumnIndex: Integer;
  LPressedCellRow, LPressedColumn: Integer;
  LPressedContent: Boolean;
  LOldBounds: TRect;
  LSummaryArgs: TThemedGridSummaryCellEventArgs;
  LCellArgs: TThemedGridCellMouseEventArgs;
  LContentArgs: TThemedGridCellContentClickEventArgs;
begin
  LLocation := Point(AX, AY);
  ClearRowDragCandidate;

  if FDragCandidate then
  begin
    LCandidateRow := FDragCandidateRowIndex;
    LCandidateColumn := FDragCandidateColumnIndex;
    ClearDragCandidate;
    if (AButton = mbLeft) and (LCandidateRow >= 0) and (LCandidateColumn >= 0) then
      ApplyMouseCellSelection(LCandidateRow, LCandidateColumn, False, False);
  end;

  LHit := HitTest(LLocation);
  try
    if VisualMouseUp(LLocation, AButton, AShift) then
      Exit;

    if DetailRowMouseUp(LHit, AButton, LLocation) then
      Exit;

    if PressedFilterButtonColumnIndex >= 0 then
    begin
      LPressedColumnIndex := PressedFilterButtonColumnIndex;
      LOldBounds := GetColumnFilterButtonBounds(LPressedColumnIndex);
      PressedFilterButtonColumnIndex := -1;
      MouseCapture := False;
      if (LOldBounds.Right > LOldBounds.Left) and (LOldBounds.Bottom > LOldBounds.Top) then
        InvalidateBounds(LOldBounds);
      if (LHit.HitArea = TThemedGridHitArea.FilterButton) and (LHit.ColumnIndex = LPressedColumnIndex) then
        HandleColumnFilterButtonClick(LPressedColumnIndex);
      Exit;
    end;

    if SummaryPressedColumnIndex >= 0 then
    begin
      LOldPressed := SummaryPressedColumnIndex;
      SummaryPressedColumnIndex := -1;
      InvalidateBounds(GetSummaryFooterCellBounds(LOldPressed));
      if (LHit.HitArea = TThemedGridHitArea.SummaryFooter) and (LHit.ColumnIndex = LOldPressed) then
      begin
        LSummaryArgs := CreateSummaryCellEventArgs(LHit.ColumnIndex);
        try
          DoSummaryCellClick(LSummaryArgs);
        finally
          LSummaryArgs.Free;
        end;
      end;
      Exit;
    end;

    if FDragSelecting then
    begin
      FDragSelecting := False;
      FDragSelectStartRow := -1;
      FDragSelectStartColumn := -1;
      FDragAutoScrollTimer.Enabled := False;
      MouseCapture := False;
      Invalidate;
    end;

    if DraggingColumnHeader then
    begin
      CompleteColumnHeaderDrag(LLocation);
      Exit;
    end;

    if FColumnHeaderMouseDown then
    begin
      LColumnIndex := FColumnHeaderMouseDownIndex;
      FColumnHeaderMouseDown := False;
      FColumnHeaderMouseDownIndex := -1;
      MouseCapture := False;
      Cursor := crDefault;
      if (LHit.HitArea = TThemedGridHitArea.ColumnHeader) and (LHit.ColumnIndex = LColumnIndex) then
        HandleColumnHeaderClick(LColumnIndex);
      InvalidateBounds(HeaderBounds);
      Exit;
    end;

    if FResizingColumn then
    begin
      FResizingColumn := False;
      FResizeColumnIndex := -1;
      MouseCapture := False;
      Cursor := crDefault;
      NormalizeScrollValues;
      Invalidate;
      Exit;
    end;

    if DraggingVerticalScrollThumb or DraggingHorizontalScrollThumb then
    begin
      DraggingVerticalScrollThumb := False;
      DraggingHorizontalScrollThumb := False;
      MouseCapture := False;
      Invalidate;
      Exit;
    end;

    LPressedCellRow := PressedRowIndex;
    LPressedColumn := PressedColumnIndex;
    LPressedContent := PressedContent;
    PressedRowIndex := -1;
    PressedColumnIndex := -1;
    PressedContent := False;
    if (LPressedCellRow >= 0) and (LPressedColumn >= 0) then
      InvalidateCell(LPressedCellRow, LPressedColumn);

    if LHit.IsGroupRow or LHit.IsDetailRow then
      Exit;

    if (LHit.IsCell or (LHit.HitArea = TThemedGridHitArea.Editor)) and IsDataViewRow(LHit.RowIndex) then
    begin
      LCellArgs := CreateMouseEventArgs(LHit, AButton, 1, LLocation, 0);
      try
        DoCellMouseUp(LCellArgs);
      finally
        LCellArgs.Free;
      end;
      if LPressedContent and (LHit.HitArea = TThemedGridHitArea.Editor) and
        (LHit.RowIndex = LPressedCellRow) and (LHit.ColumnIndex = LPressedColumn) then
      begin
        LContentArgs := CreateContentClickEventArgs(LHit, LLocation);
        try
          DoCellContentClick(LContentArgs);
        finally
          LContentArgs.Free;
        end;
      end
      else
      begin
        LCellArgs := CreateMouseEventArgs(LHit, AButton, 1, LLocation, 0);
        try
          DoCellClick(LCellArgs);
        finally
          LCellArgs.Free;
        end;
      end;
    end;
  finally
    LHit.Free;
  end;
end;

procedure TThemedGridControlMouse.DblClick;
var
  LLocation: TPoint;
  LHit: TThemedGridHitInfo;
begin
  LLocation := ScreenToClient(Mouse.CursorPos);
  LHit := HitTest(LLocation);
  try
    ProcessDoubleClick(LHit, LLocation);
  finally
    LHit.Free;
  end;
  inherited DblClick;
end;

procedure TThemedGridControlMouse.ProcessDoubleClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint);
var
  LArgs: TThemedGridDetailRowEventArgs;
  LSummaryArgs: TThemedGridSummaryCellEventArgs;
  LCellArgs: TThemedGridCellMouseEventArgs;
  LSuppressed, LCanShowDetail, LCanBeginEdit, LDetailWins: Boolean;
begin
  if VisualDoubleClick(ALocation) then
    Exit;

  if AHit.IsGroupRow then
  begin
    TryToggleGroupRow(AHit.RowIndex, ALocation);
    Exit;
  end;

  if AHit.IsDetailRow then
  begin
    SelectDetailParentRow(AHit.RowIndex);
    if DetailRowDoubleClick(AHit, ALocation) then
      Exit;
    LArgs := CreateDetailRowEventArgs(AHit, mbLeft, 2, ALocation);
    try
      DoDetailRowDoubleClick(LArgs);
    finally
      LArgs.Free;
    end;
    Invalidate;
    Exit;
  end;

  if AHit.HitArea = TThemedGridHitArea.DetailExpander then
    Exit;

  if (AHit.HitArea = TThemedGridHitArea.RowHeader) and (AHit.RowIndex >= 0) and
    CanExpandDetailRow(AHit.RowIndex) and
    DetailOptions.HasExpandTrigger(TThemedGridDetailExpandTrigger.DoubleClick) then
  begin
    ToggleDetailRow(AHit.RowIndex);
    Exit;
  end;

  if AHit.HitArea = TThemedGridHitArea.SummaryFooter then
  begin
    LSummaryArgs := CreateSummaryCellEventArgs(AHit.ColumnIndex);
    try
      DoSummaryCellDoubleClick(LSummaryArgs);
    finally
      LSummaryArgs.Free;
    end;
    Exit;
  end;

  if (AHit.HitArea = TThemedGridHitArea.ResizeGrip) and (AHit.ColumnIndex >= 0) then
  begin
    BestFitColumn(AHit.ColumnIndex);
    Exit;
  end;

  if (AHit.IsCell or (AHit.HitArea = TThemedGridHitArea.Editor)) and IsDataViewRow(AHit.RowIndex) then
  begin
    LSuppressed := FSuppressNextCellDoubleClickAction;
    FSuppressNextCellDoubleClickAction := False;
    FocusedDetailParentDataSourceIndex := -1;
    ApplyMouseCellSelection(AHit.RowIndex, AHit.ColumnIndex, False, False);

    if LSuppressed or IsCommandRenderColumn(AHit.Column) then
    begin
      RaiseCellMouse(TThemedGridCellMouseKind.DoubleClick, AHit, mbLeft, 2, ALocation);
      Exit;
    end;

    LCanShowDetail := CanExpandDetailRow(AHit.RowIndex) and
      DetailOptions.HasExpandTrigger(TThemedGridDetailExpandTrigger.DoubleClick);
    LCanBeginEdit := EditOptions.EditOnDoubleClick and CanBeginEditFromHit(AHit);
    LDetailWins := LCanShowDetail and (not LCanBeginEdit or
      (DetailOptions.DoubleClickPriority = TThemedGridDetailDoubleClickPriority.Detail));

    if LDetailWins then
      ToggleDetailRow(AHit.RowIndex)
    else if LCanBeginEdit then
      BeginEditCurrentCell;

    LCellArgs := CreateMouseEventArgs(AHit, mbLeft, 2, ALocation, 0);
    try
      DoCellDoubleClick(LCellArgs);
    finally
      LCellArgs.Free;
    end;
  end;
end;

procedure TThemedGridControlMouse.MouseMove(AShift: TShiftState; AX, AY: Integer);
begin
  ProcessMouseMove(AShift, AX, AY);
  inherited MouseMove(AShift, AX, AY);
end;

procedure TThemedGridControlMouse.ProcessMouseMove(const AShift: TShiftState; const AX, AY: Integer);
var
  LLocation: TPoint;
  LHit, LDragHit: TThemedGridHitInfo;
  LDragSize: TSize;
  LDragBounds: TRect;
  LRowIndex, LDistance: Integer;
  LOldHoverRow, LOldHoverColumn, LOldSummaryHover, LOldExpanderRow, LOldFilterHover: Integer;
  LStillOnPressed: Boolean;
  LCellArgs: TThemedGridCellMouseEventArgs;
begin
  LLocation := Point(AX, AY);
  LDragSize := TSize.Create(GetSystemMetrics(SM_CXDRAG), GetSystemMetrics(SM_CYDRAG));

  if FRowDragCandidate then
  begin
    if not (ssLeft in AShift) then
      ClearRowDragCandidate
    else
    begin
      LDragBounds := Rect(FRowDragCandidateLocation.X - LDragSize.cx div 2,
        FRowDragCandidateLocation.Y - LDragSize.cy div 2,
        FRowDragCandidateLocation.X - LDragSize.cx div 2 + LDragSize.cx,
        FRowDragCandidateLocation.Y - LDragSize.cy div 2 + LDragSize.cy);
      if not PtInRect(LDragBounds, LLocation) then
      begin
        LRowIndex := FRowDragCandidateRowIndex;
        ClearRowDragCandidate;
        BeginRowMoveDrag(LRowIndex);
        Exit;
      end;
    end;
  end;

  if FDragCandidate then
  begin
    if not (ssLeft in AShift) then
      ClearDragCandidate
    else
    begin
      LDragBounds := Rect(FDragCandidateLocation.X - LDragSize.cx div 2,
        FDragCandidateLocation.Y - LDragSize.cy div 2,
        FDragCandidateLocation.X - LDragSize.cx div 2 + LDragSize.cx,
        FDragCandidateLocation.Y - LDragSize.cy div 2 + LDragSize.cy);
      if not PtInRect(LDragBounds, LLocation) then
      begin
        ClearDragCandidate;
        BeginCellDrag;
        Exit;
      end;
    end;
  end;

  if FDragSelecting then
  begin
    FLastDragSelectLocation := LLocation;
    LDragHit := HitTest(LLocation);
    try
      if (LDragHit.IsCell or (LDragHit.HitArea = TThemedGridHitArea.Editor)) and (FDragSelectStartRow >= 0) and
        (FDragSelectStartColumn >= 0) and IsDataViewRow(LDragHit.RowIndex) then
      begin
        SelectionModel.SelectRange(FDragSelectStartRow, FDragSelectStartColumn, LDragHit.RowIndex,
          LDragHit.ColumnIndex);
        CurrentRowIndex := LDragHit.RowIndex;
        CurrentColumnIndex := LDragHit.ColumnIndex;
        EnsureVisible(CurrentRowIndex, CurrentColumnIndex);
        Invalidate;
      end;
    finally
      LDragHit.Free;
    end;
    HideCellToolTip;
    Exit;
  end;

  if FColumnHeaderMouseDown and not DraggingColumnHeader and AllowColumnReorder then
  begin
    LDistance := Abs(LLocation.X - FColumnHeaderMouseDownLocation.X);
    if LDistance >= ColumnHeaderDragThreshold then
      BeginColumnHeaderDrag(FColumnHeaderMouseDownIndex, FColumnHeaderMouseDownLocation);
  end;

  if DraggingColumnHeader then
  begin
    HideCellToolTip;
    UpdateColumnHeaderDrag(LLocation);
    Exit;
  end;

  if FResizingColumn then
  begin
    HideCellToolTip;
    UpdateColumnResize(LLocation);
    Exit;
  end;

  if DraggingVerticalScrollThumb then
  begin
    HideCellToolTip;
    UpdateVerticalScrollDrag(LLocation);
    Exit;
  end;

  if DraggingHorizontalScrollThumb then
  begin
    HideCellToolTip;
    UpdateHorizontalScrollDrag(LLocation);
    Exit;
  end;

  LHit := HitTest(LLocation);
  try
    if PressedContent then
    begin
      LStillOnPressed := (ssLeft in AShift) and (LHit.HitArea = TThemedGridHitArea.Editor) and
        (LHit.RowIndex = PressedRowIndex) and (LHit.ColumnIndex = PressedColumnIndex);
      if not LStillOnPressed then
        ClearPressedState;
    end;

    LOldHoverRow := HoverRowIndex;
    LOldHoverColumn := HoverColumnIndex;
    LOldSummaryHover := SummaryHoverColumnIndex;
    LOldExpanderRow := HoverDetailExpanderRowIndex;
    LOldFilterHover := HoverFilterButtonColumnIndex;

    if LHit.HitArea = TThemedGridHitArea.FilterButton then
      HoverFilterButtonColumnIndex := LHit.ColumnIndex
    else
      HoverFilterButtonColumnIndex := -1;

    if LHit.HitArea = TThemedGridHitArea.SummaryFooter then
      SummaryHoverColumnIndex := LHit.ColumnIndex
    else
      SummaryHoverColumnIndex := -1;

    if LHit.HitArea = TThemedGridHitArea.DetailExpander then
      HoverDetailExpanderRowIndex := LHit.RowIndex
    else
      HoverDetailExpanderRowIndex := -1;

    if LHit.IsDetailRow then
    begin
      HoverRowIndex := LHit.RowIndex;
      HoverColumnIndex := -1;
      if not DetailRowMouseMove(LHit, LLocation) then
      begin
        SetCursorIfChanged(crDefault);
        HideCellToolTip;
      end;
    end
    else if LHit.HitArea = TThemedGridHitArea.ResizeGrip then
    begin
      HoverRowIndex := -1;
      HoverColumnIndex := LHit.ColumnIndex;
      SetCursorIfChanged(crHSplit);
      HideCellToolTip;
    end
    else if LHit.HitArea = TThemedGridHitArea.FilterButton then
    begin
      HoverRowIndex := -1;
      HoverColumnIndex := LHit.ColumnIndex;
      SetCursorIfChanged(crHandPoint);
      HideCellToolTip;
    end
    else if LHit.HitArea = TThemedGridHitArea.SummaryFooter then
    begin
      HoverRowIndex := -1;
      HoverColumnIndex := -1;
      if LHit.ColumnIndex >= 0 then
        SetCursorIfChanged(crHandPoint)
      else
        SetCursorIfChanged(crDefault);
      HideCellToolTip;
    end
    else if LHit.HitArea = TThemedGridHitArea.GroupRow then
    begin
      HoverRowIndex := LHit.RowIndex;
      HoverColumnIndex := -1;
      SetCursorIfChanged(crHandPoint);
      HideCellToolTip;
    end
    else if LHit.HitArea = TThemedGridHitArea.ColumnHeader then
    begin
      HoverRowIndex := -1;
      HoverColumnIndex := LHit.ColumnIndex;
      SetCursorIfChanged(crDefault);
      HideCellToolTip;
    end
    else if LHit.HitArea = TThemedGridHitArea.DetailExpander then
    begin
      HoverRowIndex := -1;
      HoverColumnIndex := -1;
      SetCursorIfChanged(crHandPoint);
      HideCellToolTip;
    end
    else if LHit.IsCell or (LHit.HitArea = TThemedGridHitArea.Editor) then
    begin
      HoverRowIndex := LHit.RowIndex;
      HoverColumnIndex := LHit.ColumnIndex;
      SetCursorIfChanged(ResolveCellCursor(LHit, LLocation));
      LCellArgs := CreateMouseEventArgs(LHit, mbLeft, 0, LLocation, 0);
      try
        LCellArgs.Button := [];
        DoCellMouseMove(LCellArgs);
      finally
        LCellArgs.Free;
      end;
      UpdateCellToolTip(LHit, LLocation);
    end
    else
    begin
      HoverRowIndex := -1;
      HoverColumnIndex := -1;
      SetCursorIfChanged(crDefault);
      HideCellToolTip;
    end;

    VisualMouseMove(LLocation);

    if (LOldHoverRow <> HoverRowIndex) or (LOldHoverColumn <> HoverColumnIndex) then
    begin
      if LOldHoverRow >= 0 then
      begin
        if LOldHoverColumn >= 0 then
          InvalidateCell(LOldHoverRow, LOldHoverColumn)
        else
          InvalidateRow(LOldHoverRow);
      end;
      if HoverRowIndex >= 0 then
      begin
        if HoverColumnIndex >= 0 then
          InvalidateCell(HoverRowIndex, HoverColumnIndex)
        else
          InvalidateRow(HoverRowIndex);
      end;
      InvalidateBounds(HeaderBounds);
    end;

    if LOldExpanderRow <> HoverDetailExpanderRowIndex then
    begin
      if LOldExpanderRow >= 0 then
        InvalidateRow(LOldExpanderRow);
      if HoverDetailExpanderRowIndex >= 0 then
        InvalidateRow(HoverDetailExpanderRowIndex);
    end;

    if LOldFilterHover <> HoverFilterButtonColumnIndex then
    begin
      if LOldFilterHover >= 0 then
        InvalidateBounds(GetColumnFilterButtonBounds(LOldFilterHover));
      if HoverFilterButtonColumnIndex >= 0 then
        InvalidateBounds(GetColumnFilterButtonBounds(HoverFilterButtonColumnIndex));
    end;

    if LOldSummaryHover <> SummaryHoverColumnIndex then
    begin
      if LOldSummaryHover >= 0 then
        InvalidateBounds(GetSummaryFooterCellBounds(LOldSummaryHover));
      if SummaryHoverColumnIndex >= 0 then
        InvalidateBounds(GetSummaryFooterCellBounds(SummaryHoverColumnIndex));
    end;
  finally
    LHit.Free;
  end;
end;

procedure TThemedGridControlMouse.CMMouseLeave(var AMessage: TMessage);
var
  LOldHoverRow, LOldHoverColumn, LOldSummaryHover, LOldSummaryPressed, LOldExpanderRow: Integer;
begin
  inherited;
  LOldHoverRow := HoverRowIndex;
  LOldHoverColumn := HoverColumnIndex;
  LOldSummaryHover := SummaryHoverColumnIndex;
  LOldSummaryPressed := SummaryPressedColumnIndex;
  LOldExpanderRow := HoverDetailExpanderRowIndex;

  HoverRowIndex := -1;
  HoverColumnIndex := -1;
  SummaryHoverColumnIndex := -1;
  SummaryPressedColumnIndex := -1;
  HoverDetailExpanderRowIndex := -1;
  Cursor := crDefault;

  ClearPressedState;
  FDragSelecting := False;
  FDragSelectStartRow := -1;
  FDragSelectStartColumn := -1;
  FDragAutoScrollTimer.Enabled := False;
  HideCellToolTip;
  DetailRowMouseLeave;

  if FColumnHeaderMouseDown and not DraggingColumnHeader then
  begin
    FColumnHeaderMouseDown := False;
    FColumnHeaderMouseDownIndex := -1;
    MouseCapture := False;
  end;

  if DraggingColumnHeader then
    CancelColumnHeaderDrag;

  if (LOldHoverRow >= 0) and (LOldHoverColumn >= 0) then
    InvalidateCell(LOldHoverRow, LOldHoverColumn);
  if (LOldHoverRow >= 0) and (LOldHoverColumn < 0) then
    InvalidateRow(LOldHoverRow);
  if LOldExpanderRow >= 0 then
    InvalidateRow(LOldExpanderRow);
  if LOldSummaryHover >= 0 then
    InvalidateBounds(GetSummaryFooterCellBounds(LOldSummaryHover));
  if (LOldSummaryPressed >= 0) and (LOldSummaryPressed <> LOldSummaryHover) then
    InvalidateBounds(GetSummaryFooterCellBounds(LOldSummaryPressed));
  InvalidateBounds(HeaderBounds);
end;

procedure TThemedGridControlMouse.DragAutoScrollTick(ASender: TObject);
var
  LChanged: Boolean;
  LEdge: Integer;
  LViewport: TRect;
  LHit: TThemedGridHitInfo;
begin
  if not FDragSelecting then
    Exit;
  LChanged := False;
  LEdge := Max(12, ScaleInt(24));
  if FLastDragSelectLocation.Y < DataBounds.Top + LEdge then
  begin
    FirstVisibleRowIndex := FirstVisibleRowIndex - 1;
    LChanged := True;
  end
  else if FLastDragSelectLocation.Y > DataBounds.Bottom - LEdge then
  begin
    FirstVisibleRowIndex := FirstVisibleRowIndex + 1;
    LChanged := True;
  end;

  LViewport := GetScrollableViewportBounds;
  if FLastDragSelectLocation.X < LViewport.Left + LEdge then
  begin
    HorizontalOffset := HorizontalOffset - Max(8, ScaleInt(24));
    LChanged := True;
  end
  else if FLastDragSelectLocation.X > LViewport.Right - LEdge then
  begin
    HorizontalOffset := HorizontalOffset + Max(8, ScaleInt(24));
    LChanged := True;
  end;

  if not LChanged then
    Exit;
  NormalizeScrollValues;

  LHit := HitTest(FLastDragSelectLocation);
  try
    if (LHit.IsCell or (LHit.HitArea = TThemedGridHitArea.Editor)) and (FDragSelectStartRow >= 0) and
      (FDragSelectStartColumn >= 0) then
    begin
      SelectionModel.SelectRange(FDragSelectStartRow, FDragSelectStartColumn, LHit.RowIndex, LHit.ColumnIndex);
      CurrentRowIndex := LHit.RowIndex;
      CurrentColumnIndex := LHit.ColumnIndex;
      EnsureVisible(CurrentRowIndex, CurrentColumnIndex);
    end;
  finally
    LHit.Free;
  end;
  UpdateEditorBounds;
  Invalidate;
end;

function TThemedGridControlMouse.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer;
  AMousePos: TPoint): Boolean;
var
  LLines: UINT;
  LCount: Integer;
begin
  if IsEditing then
    CommitEdit;
  LLines := 3;
  SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @LLines, 0);
  LCount := Integer(LLines);
  if (LLines = 0) or (LLines = High(UINT)) then
    LCount := 3;
  if ssCtrl in AShift then
    LCount := Max(1, GetVerticalScrollLargeChange);
  if AWheelDelta > 0 then
    FirstVisibleRowIndex := FirstVisibleRowIndex - LCount
  else
    FirstVisibleRowIndex := FirstVisibleRowIndex + LCount;
  NormalizeScrollValues;
  UpdateEditorBounds;
  Invalidate;
  Result := True;
end;

end.

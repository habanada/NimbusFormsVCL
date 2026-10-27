unit NimbusForms.Grid.ControlDrag;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  Vcl.Controls,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.Events.DragDrop,
  NimbusForms.Grid.Events.Rows,
  NimbusForms.Grid.DragDropOptions,
  NimbusForms.Grid.RowMoveOptions,
  NimbusForms.Grid.DragData,
  NimbusForms.Grid.OleDragDrop,
  NimbusForms.Grid.ClipboardParser,
  NimbusForms.Grid.ControlClipboard;

type
  TThemedGridControlDrag = class(TThemedGridControlClipboard)
  private
    FDragDropOptions: TThemedGridDragDropOptions;
    FRowMoveOptions: TThemedGridRowMoveOptions;
    FDragSourceId: TGUID;
    FDragActive: Boolean;
    FDropTarget: IDropTarget;
    FDropRegistered: Boolean;
    FCellDragFormat: Word;
    FRowMoveFormat: Word;
    FDropTargetRowIndex: Integer;
    FDropTargetColumnIndex: Integer;
    FDropTargetRowCount: Integer;
    FDropTargetColumnCount: Integer;
    FDragOverBlock: TThemedGridClipboardBlock;
    FDragOverData: TThemedGridDragData;
    FDragOverRowMove: TThemedGridRowMoveData;
    FRowMoveInsertRowIndex: Integer;
    FOnCellDragStarting: TThemedGridDragStartEvent;
    FOnCellDragOver: TThemedGridDragEvent;
    FOnCellDrop: TThemedGridDropEvent;
    FOnCellDropCompleted: TThemedGridDropCompletedEvent;
    FOnRowMoving: TThemedGridRowMovingEvent;
    FOnRowMoved: TThemedGridRowMovedEvent;
    procedure DragDropOptionsChanged(ASender: TObject);
    procedure RowMoveOptionsChanged(ASender: TObject);
    procedure UpdateDropRegistration;
    procedure OleDragEnter(const AData: IDataObject; const AKeyState: Integer; const APoint: TPoint;
      var AEffect: Integer);
    procedure OleDragOver(const AData: IDataObject; const AKeyState: Integer; const APoint: TPoint;
      var AEffect: Integer);
    procedure OleDragLeave(ASender: TObject);
    procedure OleDrop(const AData: IDataObject; const AKeyState: Integer; const APoint: TPoint;
      var AEffect: Integer);
    procedure HandleCellDragOver(const AData: IDataObject; const AKeyState: Integer; const ALocation: TPoint;
      var AEffect: Integer);
    procedure HandleRowMoveDragOver(const ALocation: TPoint; var AEffect: Integer);
    procedure HandleRowMoveDrop(const ALocation: TPoint; var AEffect: Integer);
    procedure LoadRowMoveData(const AData: IDataObject);
    procedure LoadDragBlock(const AData: IDataObject);
    procedure ClearDropTarget;
    procedure ClearRowMoveTarget;
    procedure ExecuteDrag(const AData: IDataObject; const AAllowed: TThemedGridDragDropEffects);
    procedure FillDragEventArgs(const AArgs: TThemedGridDragEventArgs; const AData: IDataObject;
      const AKeyState: Integer; const ALocation: TPoint; const AAllowed: TThemedGridDragDropEffects);
    procedure UpdateDropTarget(const AArgs: TThemedGridDragEventArgs);
    procedure PerformDragAutoScroll(const ALocation: TPoint);
    function ResolveDropEffect(const AKeyState: Integer;
      const AAllowed: TThemedGridDragDropEffects): TThemedGridDragDropEffects;
    function ResolveInsertRowIndex(const ALocation: TPoint; out AAfterTarget: Boolean): Integer;
    function ResolveInsertDataSourceIndex(const AInsertRowIndex: Integer): Integer;
    function ClearDragSourceCells(const ADragData: TThemedGridDragData;
      const AWrittenCells: TList<TThemedGridCellKey>): Integer;
    function MoveRow(const ASourceRowIndex, ASourceDataSourceIndex, ATargetRowIndex,
      AInsertBeforeDataSourceIndex: Integer; const AAfterTarget: Boolean): Boolean;
    function HasMultiCellSelection: Boolean;
    function GetCanMoveRows: Boolean;
    function GetIsDragging: Boolean;
    function IsInternalDragSource: Boolean;
    class function GetDataObjectText(const AData: IDataObject): string; static;
    class function ContainsCellKey(const AList: TList<TThemedGridCellKey>;
      const AKey: TThemedGridCellKey): Boolean; static;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    function CanStartCellDrag(const AHit: TThemedGridHitInfo): Boolean; override;
    function CanStartRowMove(const AHit: TThemedGridHitInfo): Boolean; override;
    procedure BeginCellDrag; override;
    procedure BeginRowMoveDrag(const ARowIndex: Integer); override;
    procedure DrawDropIndicator(const AContext: TThemedGridRenderContext); override;
    procedure DrawRowMoveIndicator(const AContext: TThemedGridRenderContext); override;
    procedure DoCellDragStarting(const AArgs: TThemedGridDragStartEventArgs); virtual;
    procedure DoCellDragOver(const AArgs: TThemedGridDragEventArgs); virtual;
    procedure DoCellDrop(const AArgs: TThemedGridDropEventArgs); virtual;
    procedure DoCellDropCompleted(const AArgs: TThemedGridDropCompletedEventArgs); virtual;
    procedure DoRowMoving(const AArgs: TThemedGridRowMovingEventArgs); virtual;
    procedure DoRowMoved(const AArgs: TThemedGridRowMovedEventArgs); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BuildRangeText(const ARow1, AColumn1, ARow2, AColumn2: Integer; out AColumnNames: TArray<string>;
      out ARowCount, AColumnCount: Integer; out ADataSourceIndexes: TArray<Integer>): string;
    function CreateDragData(const ARow1, AColumn1, ARow2, AColumn2: Integer): TThemedGridDragData;
    function MoveRowToDataSourceIndex(const ASourceDataSourceIndex, AInsertBeforeDataSourceIndex: Integer): Boolean;
    property DragDropOptions: TThemedGridDragDropOptions read FDragDropOptions;
    property RowMoveOptions: TThemedGridRowMoveOptions read FRowMoveOptions;
    property CanMoveRows: Boolean read GetCanMoveRows;
    property IsDragging: Boolean read GetIsDragging;
    property OnCellDragStarting: TThemedGridDragStartEvent read FOnCellDragStarting write FOnCellDragStarting;
    property OnCellDragOver: TThemedGridDragEvent read FOnCellDragOver write FOnCellDragOver;
    property OnCellDrop: TThemedGridDropEvent read FOnCellDrop write FOnCellDrop;
    property OnCellDropCompleted: TThemedGridDropCompletedEvent read FOnCellDropCompleted write FOnCellDropCompleted;
    property OnRowMoving: TThemedGridRowMovingEvent read FOnRowMoving write FOnRowMoving;
    property OnRowMoved: TThemedGridRowMovedEvent read FOnRowMoved write FOnRowMoved;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.EditStrings,
  NimbusForms.Grid.UndoStrings,
  NimbusForms.Grid.UndoTypes;

type
  TEStr = TThemedGridEditStrings;
  TUStr = TThemedGridUndoStrings;

function WithAlpha(const AColor: TThemeColor; const AAlpha: Byte): TThemeColor;
begin
  Result := ThemeColor(AAlpha, ThemeColorRed(AColor), ThemeColorGreen(AColor), ThemeColorBlue(AColor));
end;

constructor TThemedGridControlDrag.Create(AOwner: TComponent);
var
  LTarget: TThemedGridDropTarget;
begin
  inherited Create(AOwner);
  FDragSourceId := TGUID.NewGuid;
  FDropTargetRowIndex := -1;
  FDropTargetColumnIndex := -1;
  FRowMoveInsertRowIndex := -1;
  FCellDragFormat := TThemedGridOle.RegisterFormat(TThemedGridDragData.DataFormatName);
  FRowMoveFormat := TThemedGridOle.RegisterFormat(TThemedGridRowMoveData.DataFormatName);
  FDragDropOptions := TThemedGridDragDropOptions.Create;
  FDragDropOptions.OnChanged := DragDropOptionsChanged;
  FRowMoveOptions := TThemedGridRowMoveOptions.Create;
  FRowMoveOptions.OnChanged := RowMoveOptionsChanged;
  LTarget := TThemedGridDropTarget.Create;
  LTarget.OnEnter := OleDragEnter;
  LTarget.OnOver := OleDragOver;
  LTarget.OnLeave := OleDragLeave;
  LTarget.OnDrop := OleDrop;
  FDropTarget := LTarget;
end;

destructor TThemedGridControlDrag.Destroy;
begin
  FDropTarget := nil;
  FreeAndNil(FDragOverData);
  FreeAndNil(FDragOverRowMove);
  FRowMoveOptions.Free;
  FDragDropOptions.Free;
  inherited Destroy;
end;

procedure TThemedGridControlDrag.CreateWnd;
begin
  inherited CreateWnd;
  UpdateDropRegistration;
end;

procedure TThemedGridControlDrag.DestroyWnd;
begin
  if FDropRegistered then
  begin
    RevokeDragDrop(Handle);
    FDropRegistered := False;
  end;
  inherited DestroyWnd;
end;

procedure TThemedGridControlDrag.UpdateDropRegistration;
var
  LWanted: Boolean;
begin
  if not HandleAllocated then
    Exit;
  LWanted := FDragDropOptions.AllowDrop or FRowMoveOptions.AllowRowMove;
  if LWanted and not FDropRegistered then
    FDropRegistered := Succeeded(RegisterDragDrop(Handle, FDropTarget))
  else if not LWanted and FDropRegistered then
  begin
    RevokeDragDrop(Handle);
    FDropRegistered := False;
  end;
end;

procedure TThemedGridControlDrag.DragDropOptionsChanged(ASender: TObject);
begin
  UpdateDropRegistration;
  if not FDragDropOptions.ShowDropIndicator then
    ClearDropTarget;
end;

procedure TThemedGridControlDrag.RowMoveOptionsChanged(ASender: TObject);
begin
  UpdateDropRegistration;
  if not FRowMoveOptions.ShowInsertIndicator then
    ClearRowMoveTarget;
end;

function TThemedGridControlDrag.GetCanMoveRows: Boolean;
begin
  Result := False;
  if not FRowMoveOptions.AllowRowMove then
    Exit;
  if (DataController = nil) or not DataController.CanMoveRows then
    Exit;
  if IsGrouped then
    Exit;
  Result := True;
end;

function TThemedGridControlDrag.GetIsDragging: Boolean;
begin
  Result := FDragActive;
end;

function TThemedGridControlDrag.IsInternalDragSource: Boolean;
begin
  Result := (FDragOverData <> nil) and IsEqualGUID(FDragOverData.SourceId, FDragSourceId);
end;

procedure TThemedGridControlDrag.DoCellDragStarting(const AArgs: TThemedGridDragStartEventArgs);
begin
  if Assigned(FOnCellDragStarting) then
    FOnCellDragStarting(Self, AArgs);
end;

procedure TThemedGridControlDrag.DoCellDragOver(const AArgs: TThemedGridDragEventArgs);
begin
  if Assigned(FOnCellDragOver) then
    FOnCellDragOver(Self, AArgs);
end;

procedure TThemedGridControlDrag.DoCellDrop(const AArgs: TThemedGridDropEventArgs);
begin
  if Assigned(FOnCellDrop) then
    FOnCellDrop(Self, AArgs);
end;

procedure TThemedGridControlDrag.DoCellDropCompleted(const AArgs: TThemedGridDropCompletedEventArgs);
begin
  if Assigned(FOnCellDropCompleted) then
    FOnCellDropCompleted(Self, AArgs);
end;

procedure TThemedGridControlDrag.DoRowMoving(const AArgs: TThemedGridRowMovingEventArgs);
begin
  if Assigned(FOnRowMoving) then
    FOnRowMoving(Self, AArgs);
end;

procedure TThemedGridControlDrag.DoRowMoved(const AArgs: TThemedGridRowMovedEventArgs);
begin
  if Assigned(FOnRowMoved) then
    FOnRowMoved(Self, AArgs);
end;

function TThemedGridControlDrag.HasMultiCellSelection: Boolean;
var
  LRange: TThemedGridCellRange;
begin
  LRange := SelectionModel.PrimaryRange;
  Result := LRange.IsValid and ((LRange.RowCount > 1) or (LRange.ColumnCount > 1));
end;

function TThemedGridControlDrag.CanStartCellDrag(const AHit: TThemedGridHitInfo): Boolean;
begin
  Result := False;
  if not FDragDropOptions.AllowDrag then
    Exit;
  if (AHit = nil) or (AHit.Column = nil) then
    Exit;
  if (AHit.RowIndex < 0) or (AHit.ColumnIndex < 0) then
    Exit;
  if not IsDataViewRow(AHit.RowIndex) then
    Exit;
  if not HasMultiCellSelection then
    Exit;
  Result := IsCellSelected(AHit.RowIndex, AHit.ColumnIndex);
end;

function TThemedGridControlDrag.CanStartRowMove(const AHit: TThemedGridHitInfo): Boolean;
begin
  Result := False;
  if not GetCanMoveRows then
    Exit;
  if (AHit = nil) or (AHit.RowIndex < 0) then
    Exit;
  if not IsDataViewRow(AHit.RowIndex) then
    Exit;
  if FRowMoveOptions.RowHeaderOnly and (AHit.HitArea <> TThemedGridHitArea.RowHeader) then
    Exit;
  Result := GetViewRowDataSourceIndex(AHit.RowIndex) >= 0;
end;

function TThemedGridControlDrag.BuildRangeText(const ARow1, AColumn1, ARow2, AColumn2: Integer;
  out AColumnNames: TArray<string>; out ARowCount, AColumnCount: Integer;
  out ADataSourceIndexes: TArray<Integer>): string;
var
  LColumns: TList<TThemedGridColumn>;
  LLines: TList<string>;
  LIndexes: TList<Integer>;
  LValues: TArray<string>;
  LCell: TThemedGridCell;
  LMinRow, LMaxRow, LMinColumn, LMaxColumn, LRowIndex, LColumnIndex: Integer;
begin
  SetLength(AColumnNames, 0);
  SetLength(ADataSourceIndexes, 0);
  ARowCount := 0;
  AColumnCount := 0;
  Result := '';

  LColumns := GetVisibleColumns;
  if LColumns.Count = 0 then
    Exit;

  LMinRow := Min(ARow1, ARow2);
  LMaxRow := Max(ARow1, ARow2);
  LMinColumn := Max(0, Min(AColumn1, AColumn2));
  LMaxColumn := Min(LColumns.Count - 1, Max(AColumn1, AColumn2));
  if LMinColumn > LMaxColumn then
    Exit;

  SetLength(AColumnNames, LMaxColumn - LMinColumn + 1);
  for LColumnIndex := LMinColumn to LMaxColumn do
    AColumnNames[LColumnIndex - LMinColumn] := LColumns[LColumnIndex].Name;

  LLines := TList<string>.Create;
  LIndexes := TList<Integer>.Create;
  try
    SetLength(LValues, LMaxColumn - LMinColumn + 1);
    for LRowIndex := LMinRow to LMaxRow do
    begin
      if (LRowIndex < 0) or (LRowIndex >= RowCount) then
        Continue;
      if not IsDataViewRow(LRowIndex) then
        Continue;
      for LColumnIndex := LMinColumn to LMaxColumn do
      begin
        LCell := GetCell(LRowIndex, LColumnIndex);
        try
          LValues[LColumnIndex - LMinColumn] := EscapeClipboardValue(GetClipboardText(LCell));
        finally
          LCell.Free;
        end;
      end;
      LLines.Add(string.Join(ClipboardOptions.ColumnSeparator, LValues));
      LIndexes.Add(GetViewRowDataSourceIndex(LRowIndex));
    end;
    ARowCount := LLines.Count;
    AColumnCount := LMaxColumn - LMinColumn + 1;
    ADataSourceIndexes := LIndexes.ToArray;
    Result := string.Join(ClipboardOptions.RowSeparator, LLines.ToArray);
  finally
    LIndexes.Free;
    LLines.Free;
  end;
end;

function TThemedGridControlDrag.CreateDragData(const ARow1, AColumn1, ARow2, AColumn2: Integer): TThemedGridDragData;
var
  LText: string;
  LNames: TArray<string>;
  LIndexes: TArray<Integer>;
  LRowCount, LColumnCount: Integer;
begin
  LText := BuildRangeText(ARow1, AColumn1, ARow2, AColumn2, LNames, LRowCount, LColumnCount, LIndexes);
  if LText = '' then
    Exit(nil);
  Result := TThemedGridDragData.Create;
  Result.SourceId := FDragSourceId;
  Result.Text := LText;
  Result.RowCount := LRowCount;
  Result.ColumnCount := LColumnCount;
  Result.ColumnNames := LNames;
  Result.SourceRowIndex := Min(ARow1, ARow2);
  Result.SourceColumnIndex := Min(AColumn1, AColumn2);
  Result.SourceDataSourceIndexes := LIndexes;
end;

procedure TThemedGridControlDrag.ExecuteDrag(const AData: IDataObject; const AAllowed: TThemedGridDragDropEffects);
var
  LSource: IDropSource;
  LEffect: Integer;
begin
  LSource := TThemedGridDropSource.Create;
  LEffect := DROPEFFECT_NONE;
  FDragActive := True;
  try
    MouseCapture := False;
    DragSelecting := False;
    Winapi.ActiveX.DoDragDrop(AData, LSource, ThemedGridEffectsToOle(AAllowed), LEffect);
  finally
    FDragActive := False;
    PressedRowIndex := -1;
    PressedColumnIndex := -1;
    PressedContent := False;
    ClearDragCandidate;
    ClearRowDragCandidate;
    ClearDropTarget;
    ClearRowMoveTarget;
    Invalidate;
  end;
end;

procedure TThemedGridControlDrag.BeginCellDrag;
var
  LRange: TThemedGridCellRange;
  LDragData: TThemedGridDragData;
  LDataObject: TThemedGridDataObject;
  LData: IDataObject;
  LArgs: TThemedGridDragStartEventArgs;
  LAllowed: TThemedGridDragDropEffects;
begin
  if FDragActive or not FDragDropOptions.AllowDrag then
    Exit;
  LRange := SelectionModel.PrimaryRange;
  if not LRange.IsValid then
    Exit;
  LDragData := CreateDragData(LRange.Row1, LRange.Column1, LRange.Row2, LRange.Column2);
  if LDragData = nil then
    Exit;
  try
    LDataObject := TThemedGridDataObject.Create;
    LData := LDataObject;
    LDataObject.SetBytes(FCellDragFormat, LDragData.SaveToBytes);
    LDataObject.SetUnicodeText(LDragData.Text);
    LDataObject.SetAnsiText(LDragData.Text);

    LAllowed := [TThemedGridDragDropEffect.Copy];
    if FDragDropOptions.AllowInternalMove and EditOptions.AllowEdit then
      Include(LAllowed, TThemedGridDragDropEffect.Move);

    LArgs := TThemedGridDragStartEventArgs.Create;
    try
      LArgs.Range := LRange;
      LArgs.RowCount := LDragData.RowCount;
      LArgs.ColumnCount := LDragData.ColumnCount;
      LArgs.Data := LData;
      LArgs.AllowedEffects := LAllowed;
      DoCellDragStarting(LArgs);
      if LArgs.Cancel or (LArgs.Data = nil) or (LArgs.AllowedEffects = []) then
        Exit;
      LData := LArgs.Data;
      LAllowed := LArgs.AllowedEffects;
    finally
      LArgs.Free;
    end;
    ExecuteDrag(LData, LAllowed);
  finally
    LDragData.Free;
  end;
end;

procedure TThemedGridControlDrag.BeginRowMoveDrag(const ARowIndex: Integer);
var
  LDataSourceIndex: Integer;
  LMoveData: TThemedGridRowMoveData;
  LDataObject: TThemedGridDataObject;
  LData: IDataObject;
begin
  if FDragActive or not GetCanMoveRows then
    Exit;
  LDataSourceIndex := GetViewRowDataSourceIndex(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit;
  LMoveData := TThemedGridRowMoveData.Create;
  try
    LMoveData.SourceId := FDragSourceId;
    LMoveData.SourceRowIndex := ARowIndex;
    LMoveData.SourceDataSourceIndex := LDataSourceIndex;
    LMoveData.Text := BuildRowClipboardText(ARowIndex);
    LDataObject := TThemedGridDataObject.Create;
    LData := LDataObject;
    LDataObject.SetBytes(FRowMoveFormat, LMoveData.SaveToBytes);
    LDataObject.SetUnicodeText(LMoveData.Text);
  finally
    LMoveData.Free;
  end;
  ExecuteDrag(LData, [TThemedGridDragDropEffect.Move]);
end;

procedure TThemedGridControlDrag.ClearDropTarget;
var
  LHadTarget: Boolean;
begin
  LHadTarget := FDropTargetRowIndex >= 0;
  FDropTargetRowIndex := -1;
  FDropTargetColumnIndex := -1;
  FDropTargetRowCount := 0;
  FDropTargetColumnCount := 0;
  SetLength(FDragOverBlock, 0);
  FreeAndNil(FDragOverData);
  if LHadTarget then
    Invalidate;
end;

procedure TThemedGridControlDrag.ClearRowMoveTarget;
var
  LHadTarget: Boolean;
begin
  LHadTarget := FRowMoveInsertRowIndex >= 0;
  FRowMoveInsertRowIndex := -1;
  FreeAndNil(FDragOverRowMove);
  if LHadTarget then
    Invalidate;
end;

procedure TThemedGridControlDrag.LoadRowMoveData(const AData: IDataObject);
var
  LBytes: TBytes;
begin
  FreeAndNil(FDragOverRowMove);
  if (AData = nil) or not TThemedGridOle.HasFormat(AData, FRowMoveFormat) then
    Exit;
  if TThemedGridOle.TryGetBytes(AData, FRowMoveFormat, LBytes) then
    FDragOverRowMove := TThemedGridRowMoveData.TryLoadFromBytes(LBytes);
end;

class function TThemedGridControlDrag.GetDataObjectText(const AData: IDataObject): string;
var
  LText: string;
  LFiles: TArray<string>;
begin
  Result := '';
  if AData = nil then
    Exit;
  if TThemedGridOle.TryGetUnicodeText(AData, LText) then
    Exit(LText);
  if TThemedGridOle.TryGetAnsiText(AData, LText) then
    Exit(LText);
  if TThemedGridOle.TryGetFileDrop(AData, LFiles) then
    Result := string.Join(sLineBreak, LFiles);
end;

procedure TThemedGridControlDrag.LoadDragBlock(const AData: IDataObject);
var
  LBytes: TBytes;
  LText: string;
begin
  FreeAndNil(FDragOverData);
  SetLength(FDragOverBlock, 0);
  if AData = nil then
    Exit;
  if TThemedGridOle.TryGetBytes(AData, FCellDragFormat, LBytes) then
    FDragOverData := TThemedGridDragData.TryLoadFromBytes(LBytes);
  LText := '';
  if FDragOverData <> nil then
    LText := FDragOverData.Text;
  if LText = '' then
  begin
    if (FDragOverData = nil) and not FDragDropOptions.AllowExternalText then
      Exit;
    LText := GetDataObjectText(AData);
  end;
  if LText = '' then
    Exit;
  FDragOverBlock := TThemedGridClipboardParser.Parse(LText, ClipboardOptions.ColumnSeparator,
    ClipboardOptions.RowSeparator);
end;

function TThemedGridControlDrag.ResolveDropEffect(const AKeyState: Integer;
  const AAllowed: TThemedGridDragDropEffects): TThemedGridDragDropEffects;
var
  LControlPressed: Boolean;
begin
  LControlPressed := (AKeyState and MK_CONTROL) <> 0;
  if IsInternalDragSource and FDragDropOptions.AllowInternalMove and not LControlPressed and
    (TThemedGridDragDropEffect.Move in AAllowed) then
    Exit([TThemedGridDragDropEffect.Move]);
  if TThemedGridDragDropEffect.Copy in AAllowed then
    Exit([TThemedGridDragDropEffect.Copy]);
  if TThemedGridDragDropEffect.Move in AAllowed then
    Exit([TThemedGridDragDropEffect.Move]);
  Result := [];
end;

procedure TThemedGridControlDrag.FillDragEventArgs(const AArgs: TThemedGridDragEventArgs; const AData: IDataObject;
  const AKeyState: Integer; const ALocation: TPoint; const AAllowed: TThemedGridDragDropEffects);
var
  LHit: TThemedGridHitInfo;
begin
  AArgs.Location := ALocation;
  AArgs.Data := AData;
  AArgs.KeyState := AKeyState;
  AArgs.AllowedEffect := AAllowed;
  AArgs.RowIndex := -1;
  AArgs.ColumnIndex := -1;
  AArgs.DataSourceIndex := -1;
  AArgs.BlockRowCount := Length(FDragOverBlock);
  AArgs.BlockColumnCount := TThemedGridClipboardParser.GetMaxColumnCount(FDragOverBlock);
  AArgs.IsInternalSource := IsInternalDragSource;

  LHit := HitTest(ALocation);
  try
    if (LHit.IsCell or (LHit.HitArea = TThemedGridHitArea.Editor)) and IsDataViewRow(LHit.RowIndex) and
      (LHit.ColumnIndex >= 0) then
    begin
      AArgs.RowIndex := LHit.RowIndex;
      AArgs.ColumnIndex := LHit.ColumnIndex;
      AArgs.Column := LHit.Column;
      AArgs.DataSourceIndex := GetViewRowDataSourceIndex(LHit.RowIndex);
      if (AArgs.DataSourceIndex >= 0) and (DataController <> nil) then
        AArgs.RowObject := DataController.GetRowObject(AArgs.DataSourceIndex);
    end;
  finally
    LHit.Free;
  end;

  AArgs.IsValidTarget := (AArgs.RowIndex >= 0) and (AArgs.ColumnIndex >= 0) and (AArgs.BlockRowCount > 0) and
    EditOptions.AllowEdit and FDragDropOptions.AllowDrop;
  if AArgs.IsValidTarget then
    AArgs.Effect := ResolveDropEffect(AKeyState, AAllowed)
  else
    AArgs.Effect := [];
end;

procedure TThemedGridControlDrag.UpdateDropTarget(const AArgs: TThemedGridDragEventArgs);
var
  LRowIndex, LColumnIndex: Integer;
begin
  if AArgs.Effect = [] then
  begin
    LRowIndex := -1;
    LColumnIndex := -1;
  end
  else
  begin
    LRowIndex := AArgs.RowIndex;
    LColumnIndex := AArgs.ColumnIndex;
  end;
  if not FDragDropOptions.ShowDropIndicator then
  begin
    LRowIndex := -1;
    LColumnIndex := -1;
  end;
  if (FDropTargetRowIndex = LRowIndex) and (FDropTargetColumnIndex = LColumnIndex) and
    (FDropTargetRowCount = AArgs.BlockRowCount) and (FDropTargetColumnCount = AArgs.BlockColumnCount) then
    Exit;
  FDropTargetRowIndex := LRowIndex;
  FDropTargetColumnIndex := LColumnIndex;
  FDropTargetRowCount := AArgs.BlockRowCount;
  FDropTargetColumnCount := AArgs.BlockColumnCount;
  Invalidate;
end;

procedure TThemedGridControlDrag.PerformDragAutoScroll(const ALocation: TPoint);
var
  LMargin: Integer;
  LChanged: Boolean;
  LViewport: TRect;
begin
  if not FDragDropOptions.AutoScroll then
    Exit;
  LMargin := Max(CThemedGridDragMinimumAutoScrollMargin, ScaleInt(FDragDropOptions.AutoScrollMargin));
  LChanged := False;

  if (ALocation.Y < DataBounds.Top + LMargin) and (FirstVisibleRowIndex > 0) then
  begin
    FirstVisibleRowIndex := FirstVisibleRowIndex - 1;
    LChanged := True;
  end
  else if ALocation.Y > DataBounds.Bottom - LMargin then
  begin
    FirstVisibleRowIndex := FirstVisibleRowIndex + 1;
    LChanged := True;
  end;

  LViewport := GetScrollableViewportBounds;
  if (ALocation.X < LViewport.Left + LMargin) and (HorizontalOffset > 0) then
  begin
    HorizontalOffset := HorizontalOffset - Max(8, ScaleInt(24));
    LChanged := True;
  end
  else if ALocation.X > LViewport.Right - LMargin then
  begin
    HorizontalOffset := HorizontalOffset + Max(8, ScaleInt(24));
    LChanged := True;
  end;

  if not LChanged then
    Exit;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlDrag.HandleCellDragOver(const AData: IDataObject; const AKeyState: Integer;
  const ALocation: TPoint; var AEffect: Integer);
var
  LArgs: TThemedGridDragEventArgs;
begin
  LArgs := TThemedGridDragEventArgs.Create;
  try
    FillDragEventArgs(LArgs, AData, AKeyState, ALocation, ThemedGridEffectsFromOle(AEffect));
    DoCellDragOver(LArgs);
    UpdateDropTarget(LArgs);
    AEffect := ThemedGridEffectsToOle(LArgs.Effect);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlDrag.OleDragEnter(const AData: IDataObject; const AKeyState: Integer;
  const APoint: TPoint; var AEffect: Integer);
var
  LLocation: TPoint;
begin
  LLocation := ScreenToClient(APoint);
  LoadRowMoveData(AData);
  if FDragOverRowMove <> nil then
  begin
    HandleRowMoveDragOver(LLocation, AEffect);
    Exit;
  end;
  LoadDragBlock(AData);
  HandleCellDragOver(AData, AKeyState, LLocation, AEffect);
end;

procedure TThemedGridControlDrag.OleDragOver(const AData: IDataObject; const AKeyState: Integer;
  const APoint: TPoint; var AEffect: Integer);
var
  LLocation: TPoint;
begin
  LLocation := ScreenToClient(APoint);
  if FDragOverRowMove = nil then
    LoadRowMoveData(AData);
  if FDragOverRowMove <> nil then
  begin
    HandleRowMoveDragOver(LLocation, AEffect);
    Exit;
  end;
  if (Length(FDragOverBlock) = 0) and (FDragOverData = nil) then
    LoadDragBlock(AData);
  PerformDragAutoScroll(LLocation);
  HandleCellDragOver(AData, AKeyState, LLocation, AEffect);
end;

procedure TThemedGridControlDrag.OleDragLeave(ASender: TObject);
begin
  ClearDropTarget;
  ClearRowMoveTarget;
end;

procedure TThemedGridControlDrag.OleDrop(const AData: IDataObject; const AKeyState: Integer;
  const APoint: TPoint; var AEffect: Integer);
var
  LLocation: TPoint;
  LArgs: TThemedGridDropEventArgs;
  LCompleted: TThemedGridDropCompletedEventArgs;
  LDragData: TThemedGridDragData;
  LWrittenCells: TList<TThemedGridCellKey>;
  LAnchorRow, LAnchorColumn, LBlockRows, LBlockColumns, LApplied, LSkipped, LCleared: Integer;
  LEffect: TThemedGridDragDropEffects;
  LMoveCells: Boolean;
begin
  LLocation := ScreenToClient(APoint);
  if FDragOverRowMove = nil then
    LoadRowMoveData(AData);
  if FDragOverRowMove <> nil then
  begin
    HandleRowMoveDrop(LLocation, AEffect);
    Exit;
  end;

  if Length(FDragOverBlock) = 0 then
    LoadDragBlock(AData);

  LArgs := TThemedGridDropEventArgs.Create;
  try
    FillDragEventArgs(LArgs, AData, AKeyState, LLocation, ThemedGridEffectsFromOle(AEffect));
    DoCellDrop(LArgs);
    AEffect := ThemedGridEffectsToOle(LArgs.Effect);
    if LArgs.Handled or not LArgs.IsValidTarget or (LArgs.Effect = []) or (Length(FDragOverBlock) = 0) then
    begin
      ClearDropTarget;
      Exit;
    end;
    LEffect := LArgs.Effect;
    LAnchorRow := NormalizeCellRowIndex(LArgs.RowIndex, 1);
    LAnchorColumn := LArgs.ColumnIndex;
    LMoveCells := (TThemedGridDragDropEffect.Move in LArgs.Effect) and LArgs.IsInternalSource;
  finally
    LArgs.Free;
  end;

  LDragData := FDragOverData;
  LBlockRows := Length(FDragOverBlock);
  LBlockColumns := TThemedGridClipboardParser.GetMaxColumnCount(FDragOverBlock);
  LCleared := 0;
  LApplied := 0;
  LSkipped := 0;

  LWrittenCells := TList<TThemedGridCellKey>.Create;
  try
    UndoManager.BeginTransaction(TUStr.UnitNameDrop);
    BeginUpdate;
    try
      ApplyValueBlock(FDragOverBlock, LAnchorRow, LAnchorColumn, LBlockRows, LBlockColumns, False,
        TEStr.ChangeReasonDrop, TUStr.UnitNameDrop, LWrittenCells, LApplied, LSkipped);
      if LMoveCells and (LDragData <> nil) then
        LCleared := ClearDragSourceCells(LDragData, LWrittenCells);
    finally
      EndUpdate;
      UndoManager.EndTransaction;
    end;
  finally
    LWrittenCells.Free;
  end;

  ClearDropTarget;

  LCompleted := TThemedGridDropCompletedEventArgs.Create;
  try
    LCompleted.RowIndex := LAnchorRow;
    LCompleted.ColumnIndex := LAnchorColumn;
    LCompleted.AppliedCellCount := LApplied;
    LCompleted.SkippedCellCount := LSkipped;
    LCompleted.ClearedCellCount := LCleared;
    LCompleted.Effect := LEffect;
    DoCellDropCompleted(LCompleted);
  finally
    LCompleted.Free;
  end;
end;

class function TThemedGridControlDrag.ContainsCellKey(const AList: TList<TThemedGridCellKey>;
  const AKey: TThemedGridCellKey): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AList = nil then
    Exit;
  for I := 0 to AList.Count - 1 do
    if AList[I].Equals(AKey) then
      Exit(True);
end;

function TThemedGridControlDrag.ClearDragSourceCells(const ADragData: TThemedGridDragData;
  const AWrittenCells: TList<TThemedGridCellKey>): Integer;
var
  I, C, LDataSourceIndex, LRowIndex, LColumnIndex: Integer;
  LColumnName: string;
  LColumn: TThemedGridColumn;
  LApplied: TValue;
begin
  Result := 0;
  if ADragData = nil then
    Exit;
  for I := 0 to High(ADragData.SourceDataSourceIndexes) do
  begin
    LDataSourceIndex := ADragData.SourceDataSourceIndexes[I];
    if LDataSourceIndex < 0 then
      Continue;
    for C := 0 to High(ADragData.ColumnNames) do
    begin
      LColumnName := ADragData.ColumnNames[C];
      if LColumnName = '' then
        Continue;
      if ContainsCellKey(AWrittenCells, TThemedGridCellKey.Create(LDataSourceIndex, LColumnName)) then
        Continue;
      LColumn := GetColumn(LColumnName);
      if (LColumn = nil) or LColumn.ReadOnly then
        Continue;
      if (DataController = nil) or not DataController.CanSetValue(LColumn) then
        Continue;
      LRowIndex := FindDataViewRowByDataSourceIndex(LDataSourceIndex);
      if LRowIndex < 0 then
        Continue;
      LColumnIndex := GetVisibleColumns.IndexOf(LColumn);
      if LColumnIndex < 0 then
        Continue;
      if TrySetCellValue(LRowIndex, LColumnIndex, TValue.Empty, TEStr.ChangeReasonDrop, False, LApplied) then
        Inc(Result);
    end;
  end;
end;

function TThemedGridControlDrag.ResolveInsertRowIndex(const ALocation: TPoint; out AAfterTarget: Boolean): Integer;
var
  LRowCount, LRowIndex, LNext: Integer;
  LBounds: TRect;
begin
  AAfterTarget := False;
  LRowCount := RowCount;
  if LRowCount <= 0 then
    Exit(-1);
  LRowIndex := GetRowIndexAtY(ALocation.Y);
  if LRowIndex < 0 then
  begin
    if ALocation.Y <= DataBounds.Top then
      Exit(FindDataViewRow(0, 1));
    Exit(LRowCount);
  end;
  LRowIndex := NormalizeCellRowIndex(LRowIndex, 1);
  if LRowIndex < 0 then
    Exit(LRowCount);
  LBounds := GetRowBounds(LRowIndex);
  if (LBounds.Height > 0) and (ALocation.Y > LBounds.Top + LBounds.Height div 2) then
  begin
    AAfterTarget := True;
    if LRowIndex + 1 < LRowCount then
      LNext := FindDataViewRow(LRowIndex + 1, 1)
    else
      LNext := -1;
    if LNext >= 0 then
      Exit(LNext);
    Exit(LRowCount);
  end;
  Result := LRowIndex;
end;

function TThemedGridControlDrag.ResolveInsertDataSourceIndex(const AInsertRowIndex: Integer): Integer;
var
  LLastRowIndex, LLastDataSourceIndex: Integer;
begin
  if AInsertRowIndex < 0 then
    Exit(-1);
  if AInsertRowIndex >= RowCount then
  begin
    LLastRowIndex := FindDataViewRow(RowCount - 1, -1);
    if LLastRowIndex >= 0 then
      LLastDataSourceIndex := GetViewRowDataSourceIndex(LLastRowIndex)
    else
      LLastDataSourceIndex := -1;
    if LLastDataSourceIndex >= 0 then
      Exit(LLastDataSourceIndex + 1);
    Exit(0);
  end;
  Result := GetViewRowDataSourceIndex(AInsertRowIndex);
end;

procedure TThemedGridControlDrag.HandleRowMoveDragOver(const ALocation: TPoint; var AEffect: Integer);
var
  LInsertRowIndex, LNewInsertRowIndex: Integer;
  LAfterTarget, LValid: Boolean;
begin
  if FRowMoveOptions.AutoScroll then
    PerformDragAutoScroll(ALocation);
  LInsertRowIndex := ResolveInsertRowIndex(ALocation, LAfterTarget);
  LValid := GetCanMoveRows and (FDragOverRowMove <> nil) and
    IsEqualGUID(FDragOverRowMove.SourceId, FDragSourceId) and (LInsertRowIndex >= 0);
  if LValid and FRowMoveOptions.ShowInsertIndicator then
    LNewInsertRowIndex := LInsertRowIndex
  else
    LNewInsertRowIndex := -1;
  if FRowMoveInsertRowIndex <> LNewInsertRowIndex then
  begin
    FRowMoveInsertRowIndex := LNewInsertRowIndex;
    Invalidate;
  end;
  if LValid then
    AEffect := DROPEFFECT_MOVE
  else
    AEffect := DROPEFFECT_NONE;
end;

procedure TThemedGridControlDrag.HandleRowMoveDrop(const ALocation: TPoint; var AEffect: Integer);
var
  LInsertRowIndex, LTargetDataSourceIndex, LSourceRowIndex, LSourceDataSourceIndex: Integer;
  LAfterTarget, LValid: Boolean;
begin
  LInsertRowIndex := ResolveInsertRowIndex(ALocation, LAfterTarget);
  LValid := GetCanMoveRows and (FDragOverRowMove <> nil) and
    IsEqualGUID(FDragOverRowMove.SourceId, FDragSourceId) and (LInsertRowIndex >= 0);
  if not LValid then
  begin
    ClearRowMoveTarget;
    AEffect := DROPEFFECT_NONE;
    Exit;
  end;
  LSourceRowIndex := FDragOverRowMove.SourceRowIndex;
  LSourceDataSourceIndex := FDragOverRowMove.SourceDataSourceIndex;
  ClearRowMoveTarget;
  LTargetDataSourceIndex := ResolveInsertDataSourceIndex(LInsertRowIndex);
  if LTargetDataSourceIndex < 0 then
  begin
    AEffect := DROPEFFECT_NONE;
    Exit;
  end;
  AEffect := DROPEFFECT_MOVE;
  MoveRow(LSourceRowIndex, LSourceDataSourceIndex, LInsertRowIndex, LTargetDataSourceIndex, LAfterTarget);
end;

function TThemedGridControlDrag.MoveRowToDataSourceIndex(const ASourceDataSourceIndex,
  AInsertBeforeDataSourceIndex: Integer): Boolean;
begin
  Result := MoveRow(-1, ASourceDataSourceIndex, -1, AInsertBeforeDataSourceIndex, False);
end;

function TThemedGridControlDrag.MoveRow(const ASourceRowIndex, ASourceDataSourceIndex, ATargetRowIndex,
  AInsertBeforeDataSourceIndex: Integer; const AAfterTarget: Boolean): Boolean;
var
  LInsertIndex: Integer;
  LRowObject: TValue;
  LMoving: TThemedGridRowMovingEventArgs;
  LMoved: TThemedGridRowMovedEventArgs;
  LCancel, LDone: Boolean;
begin
  Result := False;
  if not GetCanMoveRows then
    Exit;
  if (ASourceDataSourceIndex < 0) or (AInsertBeforeDataSourceIndex < 0) then
    Exit;

  LInsertIndex := AInsertBeforeDataSourceIndex;
  if LInsertIndex > ASourceDataSourceIndex then
    Dec(LInsertIndex);
  if LInsertIndex < 0 then
    LInsertIndex := 0;
  if LInsertIndex = ASourceDataSourceIndex then
    Exit;

  LRowObject := DataController.GetRowObject(ASourceDataSourceIndex);

  LMoving := TThemedGridRowMovingEventArgs.Create;
  try
    LMoving.SourceRowIndex := ASourceRowIndex;
    LMoving.SourceDataSourceIndex := ASourceDataSourceIndex;
    LMoving.TargetRowIndex := ATargetRowIndex;
    LMoving.TargetDataSourceIndex := AInsertBeforeDataSourceIndex;
    LMoving.InsertIndex := LInsertIndex;
    LMoving.RowObject := LRowObject;
    LMoving.DropAfterTarget := AAfterTarget;
    DoRowMoving(LMoving);
    LCancel := LMoving.Cancel;
    LInsertIndex := LMoving.InsertIndex;
  finally
    LMoving.Free;
  end;
  if LCancel then
    Exit;
  if (LInsertIndex < 0) or (LInsertIndex = ASourceDataSourceIndex) then
    Exit;

  if IsEditing then
    CommitEdit;
  if IsRowEditing then
    EndRowEdit(True);

  UndoManager.BeginTransaction(TUStr.UnitNameRowMove);
  BeginUpdate;
  try
    LDone := DataController.MoveRow(ASourceDataSourceIndex, LInsertIndex);
    if LDone and UndoOptions.Enabled and not UndoManager.IsSuspended then
      UndoManager.RecordRowMove(TThemedGridUndoRowMove.Create(ASourceDataSourceIndex, LInsertIndex),
        TUStr.UnitNameRowMove);
  finally
    EndUpdate;
    UndoManager.EndTransaction;
  end;
  if not LDone then
    Exit;

  RefreshAfterRowStructureChanged;

  LMoved := TThemedGridRowMovedEventArgs.Create;
  try
    LMoved.SourceRowIndex := ASourceRowIndex;
    LMoved.SourceDataSourceIndex := ASourceDataSourceIndex;
    LMoved.TargetRowIndex := ATargetRowIndex;
    LMoved.TargetDataSourceIndex := AInsertBeforeDataSourceIndex;
    LMoved.InsertIndex := LInsertIndex;
    LMoved.NewDataSourceIndex := LInsertIndex;
    LMoved.RowObject := LRowObject;
    LMoved.DropAfterTarget := AAfterTarget;
    DoRowMoved(LMoved);
  finally
    LMoved.Free;
  end;
  Result := True;
end;

procedure TThemedGridControlDrag.DrawDropIndicator(const AContext: TThemedGridRenderContext);
var
  LRowCount, LColumnCount, LRowIndex, LViewRowCount, R, C: Integer;
  LBounds, LCellBounds: TRect;
  LColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (FDropTargetRowIndex < 0) or (FDropTargetColumnIndex < 0) then
    Exit;
  if not FDragDropOptions.ShowDropIndicator then
    Exit;

  LRowCount := Max(1, FDropTargetRowCount);
  LColumnCount := Max(1, FDropTargetColumnCount);
  LViewRowCount := RowCount;
  LBounds := Rect(0, 0, 0, 0);
  LRowIndex := NormalizeCellRowIndex(FDropTargetRowIndex, 1);

  R := 0;
  while (R < LRowCount) and (LRowIndex >= 0) do
  begin
    for C := 0 to LColumnCount - 1 do
    begin
      LCellBounds := GetCellBounds(LRowIndex, FDropTargetColumnIndex + C);
      if (LCellBounds.Width <= 0) or (LCellBounds.Height <= 0) then
        Continue;
      if (LBounds.Width <= 0) or (LBounds.Height <= 0) then
        LBounds := LCellBounds
      else
        LBounds := TRect.Union(LBounds, LCellBounds);
    end;
    if LRowIndex + 1 < LViewRowCount then
      LRowIndex := FindDataViewRow(LRowIndex + 1, 1)
    else
      LRowIndex := -1;
    Inc(R);
  end;

  if (LBounds.Width <= 0) or (LBounds.Height <= 0) then
    Exit;
  LBounds := TRect.Intersect(LBounds, DataBounds);
  if (LBounds.Width <= 0) or (LBounds.Height <= 0) then
    Exit;

  LColor := AContext.FocusColor;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(WithAlpha(LColor, 40)),
    LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LColor, 2.0),
    LBounds.Left + 1, LBounds.Top + 1, LBounds.Width - 3, LBounds.Height - 3);
end;

procedure TThemedGridControlDrag.DrawRowMoveIndicator(const AContext: TThemedGridRenderContext);
var
  LRowCount, LY, LWidth, LLeft, LRight, LCapHeight, LLastRowIndex: Integer;
  LBounds: TRect;
  LColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (FRowMoveInsertRowIndex < 0) or not FRowMoveOptions.ShowInsertIndicator then
    Exit;

  LRowCount := RowCount;
  if FRowMoveInsertRowIndex >= LRowCount then
  begin
    LLastRowIndex := FindDataViewRow(LRowCount - 1, -1);
    if LLastRowIndex >= 0 then
      LBounds := GetRowBounds(LLastRowIndex)
    else
      LBounds := Rect(0, 0, 0, 0);
    if LBounds.Height <= 0 then
      Exit;
    LY := LBounds.Bottom;
  end
  else
  begin
    LBounds := GetRowBounds(FRowMoveInsertRowIndex);
    if LBounds.Height <= 0 then
      Exit;
    LY := LBounds.Top;
  end;

  if (LY < DataBounds.Top) or (LY > DataBounds.Bottom) then
    Exit;

  LWidth := Max(CThemedGridRowMoveMinimumInsertLineWidth, ScaleInt(FRowMoveOptions.InsertLineWidth));
  if ShowRowHeaders then
    LLeft := 0
  else
    LLeft := DataBounds.Left;
  LRight := DataBounds.Right;
  LCapHeight := Max(4, LWidth * 3);
  LColor := AContext.FocusColor;

  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor), LLeft, LY - LWidth div 2,
    LRight - LLeft, LWidth);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor), LLeft, LY - LCapHeight div 2,
    LWidth + 1, LCapHeight);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor), LRight - LWidth - 1,
    LY - LCapHeight div 2, LWidth + 1, LCapHeight);
end;

end.

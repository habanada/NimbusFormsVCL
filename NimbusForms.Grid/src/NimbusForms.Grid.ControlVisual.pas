unit NimbusForms.Grid.ControlVisual;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.TypInfo,
  System.Math,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.CellVisual,
  NimbusForms.Grid.CellVisualRenderer,
  NimbusForms.Grid.Events.Visual,
  NimbusForms.Grid.VisualActionCommand,
  NimbusForms.Grid.ControlDrag;

type
  TThemedGridControlVisual = class(TThemedGridControlDrag)
  private
    FCellVisualRenderer: TThemedGridCellVisualRenderer;
    FRenderVisual: TThemedGridCellVisual;
    FHitInfos: TThemedGridVisualHitInfoList;
    FCellArgs: TThemedGridCellVisualNeededEventArgs;
    FVisualImageList: TCustomImageList;
    FVisualActionCommands: TThemedGridVisualActionCommandCollection;
    FOnCellVisualNeeded: TThemedGridCellVisualNeededEvent;
    FOnGroupVisualNeeded: TThemedGridGroupVisualNeededEvent;
    FOnVisualClick: TThemedGridVisualMouseEvent;
    FOnVisualDoubleClick: TThemedGridVisualMouseEvent;
    FOnVisualActionClick: TThemedGridVisualActionEvent;
    FOnVisualActionDoubleClick: TThemedGridVisualActionEvent;
    procedure SetVisualImageList(const AValue: TCustomImageList);
    function GetVisualActionCommands: TThemedGridVisualActionCommandCollection;
    function SnapshotHit(const AInfo: TThemedGridVisualHitInfo;
      const ALocal: TThemedGridVisualHitInfoList): TThemedGridVisualHitInfo;
    function DispatchVisualMouse(const ALocation: TPoint; const AButton: TMouseButton; const AClicks: Integer;
      const ADoubleClick: Boolean): Boolean;
  protected
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure BeginDetailLayout; override;
    function TryDrawCellVisual(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): Boolean; override;
    function TryDrawGroupVisual(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const ABounds: TRect; const AForeColor: TThemeColor): Boolean; override;
    function VisualMouseDown(const ALocation: TPoint; const AButton: TMouseButton;
      const AShift: TShiftState): Boolean; override;
    function VisualMouseUp(const ALocation: TPoint; const AButton: TMouseButton;
      const AShift: TShiftState): Boolean; override;
    function VisualDoubleClick(const ALocation: TPoint): Boolean; override;
    procedure VisualMouseMove(const ALocation: TPoint); override;
    procedure ResetRenderVisual(const AText: string; const AImageSize, APadding: Integer; const AEnabled: Boolean);
    procedure DrawRenderVisual(const AContext: TThemedGridRenderContext; const ABounds: TRect;
      const AForeColor: TThemeColor; const AEnabled: Boolean; const ARowIndex, AColumnIndex: Integer;
      const AGroupHeader, ADetail: Boolean);
    function GetVisualHitInfo(const ALocation: TPoint): TThemedGridVisualHitInfo;
    procedure DoCellVisualNeeded(const AArgs: TThemedGridCellVisualNeededEventArgs); virtual;
    procedure DoGroupVisualNeeded(const AArgs: TThemedGridGroupVisualNeededEventArgs); virtual;
    procedure DoVisualClick(const AArgs: TThemedGridVisualMouseEventArgs); virtual;
    procedure DoVisualDoubleClick(const AArgs: TThemedGridVisualMouseEventArgs); virtual;
    procedure DoVisualActionClick(const AArgs: TThemedGridVisualActionEventArgs); virtual;
    procedure DoVisualActionDoubleClick(const AArgs: TThemedGridVisualActionEventArgs); virtual;
    property RenderVisual: TThemedGridCellVisual read FRenderVisual;
    property CellVisualRenderer: TThemedGridCellVisualRenderer read FCellVisualRenderer;
    property VisualHitInfos: TThemedGridVisualHitInfoList read FHitInfos;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearVisualCache;
    property VisualImageList: TCustomImageList read FVisualImageList write SetVisualImageList;
    property VisualActionCommands: TThemedGridVisualActionCommandCollection read GetVisualActionCommands;
    property OnCellVisualNeeded: TThemedGridCellVisualNeededEvent read FOnCellVisualNeeded write FOnCellVisualNeeded;
    property OnGroupVisualNeeded: TThemedGridGroupVisualNeededEvent read FOnGroupVisualNeeded write FOnGroupVisualNeeded;
    property OnVisualClick: TThemedGridVisualMouseEvent read FOnVisualClick write FOnVisualClick;
    property OnVisualDoubleClick: TThemedGridVisualMouseEvent read FOnVisualDoubleClick write FOnVisualDoubleClick;
    property OnVisualActionClick: TThemedGridVisualActionEvent read FOnVisualActionClick write FOnVisualActionClick;
    property OnVisualActionDoubleClick: TThemedGridVisualActionEvent
      read FOnVisualActionDoubleClick write FOnVisualActionDoubleClick;
  end;

implementation

uses
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.CellRendererParts;

constructor TThemedGridControlVisual.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCellVisualRenderer := TThemedGridCellVisualRenderer.Create;
  FRenderVisual := TThemedGridCellVisual.Create;
  FHitInfos := TThemedGridVisualHitInfoList.Create;
  FCellArgs := TThemedGridCellVisualNeededEventArgs.Create;
end;

destructor TThemedGridControlVisual.Destroy;
begin
  if FVisualImageList <> nil then
    FVisualImageList.RemoveFreeNotification(Self);
  FCellArgs.Free;
  FHitInfos.Free;
  FRenderVisual.Free;
  FCellVisualRenderer.Free;
  FVisualActionCommands.Free;
  inherited Destroy;
end;

procedure TThemedGridControlVisual.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);
  if (AOperation = opRemove) and (AComponent = FVisualImageList) then
  begin
    FVisualImageList := nil;
    FCellVisualRenderer.ClearBitmapCache;
  end;
end;

procedure TThemedGridControlVisual.SetVisualImageList(const AValue: TCustomImageList);
begin
  if FVisualImageList = AValue then
    Exit;
  if FVisualImageList <> nil then
    FVisualImageList.RemoveFreeNotification(Self);
  FVisualImageList := AValue;
  if FVisualImageList <> nil then
    FVisualImageList.FreeNotification(Self);
  FCellVisualRenderer.ClearBitmapCache;
  Invalidate;
end;

function TThemedGridControlVisual.GetVisualActionCommands: TThemedGridVisualActionCommandCollection;
begin
  if FVisualActionCommands = nil then
    FVisualActionCommands := TThemedGridVisualActionCommandCollection.Create;
  Result := FVisualActionCommands;
end;

procedure TThemedGridControlVisual.ClearVisualCache;
begin
  FCellVisualRenderer.ClearCache;
  Invalidate;
end;

procedure TThemedGridControlVisual.BeginDetailLayout;
begin
  FHitInfos.Clear;
  inherited BeginDetailLayout;
end;

function TThemedGridControlVisual.GetVisualHitInfo(const ALocation: TPoint): TThemedGridVisualHitInfo;
begin
  Result := FHitInfos.HitTest(ALocation);
end;

procedure TThemedGridControlVisual.ResetRenderVisual(const AText: string; const AImageSize, APadding: Integer;
  const AEnabled: Boolean);
begin
  FRenderVisual.Clear;
  FRenderVisual.Text := AText;
  FRenderVisual.ImageSize := AImageSize;
  FRenderVisual.Padding := APadding;
  FRenderVisual.Enabled := AEnabled;
  FRenderVisual.ImagePlacement := TThemedGridVisualImagePlacement.Left;
  FRenderVisual.ContentAlignment := TThemedGridVisualContentAlignment.Near;
  FRenderVisual.TextTrimming := TThemedGridVisualTextTrimming.EllipsisCharacter;
end;

procedure TThemedGridControlVisual.DrawRenderVisual(const AContext: TThemedGridRenderContext; const ABounds: TRect;
  const AForeColor: TThemeColor; const AEnabled: Boolean; const ARowIndex, AColumnIndex: Integer;
  const AGroupHeader, ADetail: Boolean);
var
  LStart, I: Integer;
  LInfo: TThemedGridVisualHitInfo;
begin
  LStart := FHitInfos.Count;
  FCellVisualRenderer.Draw(AContext, ABounds, FRenderVisual, AForeColor, AEnabled, FVisualImageList, ARowIndex,
    AColumnIndex, FHitInfos);
  for I := LStart to FHitInfos.Count - 1 do
  begin
    LInfo := FHitInfos[I];
    LInfo.IsGroupHeader := AGroupHeader;
    LInfo.IsDetail := ADetail;
    LInfo.RowIndex := ARowIndex;
    LInfo.ColumnIndex := AColumnIndex;
    if LInfo.ToolTip = '' then
      LInfo.ToolTip := FRenderVisual.ToolTip;
  end;
end;

function TThemedGridControlVisual.TryDrawCellVisual(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): Boolean;
var
  LBaseRenderer: IThemedGridCellRenderer;
  LOldText: string;
  LOldDisplayValue, LOldValue: TValue;
  LText: string;
begin
  Result := False;
  if (AContext = nil) or (ACell = nil) or not Assigned(FOnCellVisualNeeded) then
    Exit;
  LText := ACell.DisplayText;
  if (LText = '') and (ACell.Value.TypeInfo <> nil) then
    LText := ACell.Value.ToString;
  ResetRenderVisual(LText, Max(1, Min(ScaleInt(24), Max(1, ACell.Bounds.Height - ScaleInt(8)))), ScaleInt(4), True);
  FillCellEventArgs(FCellArgs, ACell);
  FCellArgs.Visual := FRenderVisual;
  FCellArgs.Handled := False;
  DoCellVisualNeeded(FCellArgs);
  if (not FCellArgs.Handled) or (FCellArgs.Visual = nil) then
    Exit;
  LBaseRenderer := Renderer.ResolveCellRenderer(ACell);
  LOldText := ACell.DisplayText;
  LOldDisplayValue := ACell.DisplayValue;
  LOldValue := ACell.Value;
  try
    ACell.DisplayText := '';
    ACell.DisplayValue := TValue.Empty;
    ACell.Value := TValue.Empty;
    LBaseRenderer.Draw(AContext, ACell);
  finally
    ACell.DisplayText := LOldText;
    ACell.DisplayValue := LOldDisplayValue;
    ACell.Value := LOldValue;
  end;
  DrawRenderVisual(AContext, ACell.Bounds, TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell), True,
    ACell.RowIndex, ACell.ColumnIndex, False, False);
  Result := True;
end;

function TThemedGridControlVisual.TryDrawGroupVisual(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const ABounds: TRect;
  const AForeColor: TThemeColor): Boolean;
var
  LArgs: TThemedGridGroupVisualNeededEventArgs;
begin
  Result := False;
  if (AContext = nil) or (AViewRow = nil) or not Assigned(FOnGroupVisualNeeded) then
    Exit;
  ResetRenderVisual(AViewRow.DisplayText, Max(1, Min(24, Max(1, ABounds.Height - ScaleInt(8)))), ScaleInt(2), True);
  LArgs := TThemedGridGroupVisualNeededEventArgs.Create(ARowIndex, AViewRow, FRenderVisual);
  try
    DoGroupVisualNeeded(LArgs);
    if not LArgs.Handled then
      Exit;
  finally
    LArgs.Free;
  end;
  DrawRenderVisual(AContext, ABounds, AForeColor, True, ARowIndex, -1, True, False);
  Result := True;
end;

function TThemedGridControlVisual.SnapshotHit(const AInfo: TThemedGridVisualHitInfo;
  const ALocal: TThemedGridVisualHitInfoList): TThemedGridVisualHitInfo;
var
  LVisual: TThemedGridCellVisual;
  LActionIndex: Integer;
begin
  Result := TThemedGridVisualHitInfo.Create;
  Result.RowIndex := AInfo.RowIndex;
  Result.ColumnIndex := AInfo.ColumnIndex;
  Result.VisualIndex := AInfo.VisualIndex;
  Result.Bounds := AInfo.Bounds;
  Result.ActionKey := AInfo.ActionKey;
  Result.Tag := AInfo.Tag;
  Result.ToolTip := AInfo.ToolTip;
  Result.IsGroupHeader := AInfo.IsGroupHeader;
  Result.IsDetail := AInfo.IsDetail;
  if AInfo.Visual <> nil then
  begin
    LVisual := ALocal.AdoptVisual(AInfo.Visual.Clone);
    Result.Visual := LVisual;
    if (AInfo.VisualIndex >= 0) and (AInfo.VisualIndex < LVisual.Images.Count) then
      Result.Image := LVisual.Images[AInfo.VisualIndex];
    if AInfo.Action <> nil then
    begin
      LActionIndex := AInfo.Visual.Actions.IndexOf(AInfo.Action);
      if (LActionIndex >= 0) and (LActionIndex < LVisual.Actions.Count) then
        Result.Action := LVisual.Actions[LActionIndex];
    end;
  end;
  ALocal.Add(Result);
end;

function TThemedGridControlVisual.DispatchVisualMouse(const ALocation: TPoint; const AButton: TMouseButton;
  const AClicks: Integer; const ADoubleClick: Boolean): Boolean;
var
  LInfo, LSnapshot: TThemedGridVisualHitInfo;
  LLocal: TThemedGridVisualHitInfoList;
  LArgs: TThemedGridVisualMouseEventArgs;
begin
  Result := False;
  LInfo := FHitInfos.HitTest(ALocation);
  if LInfo = nil then
    Exit;
  LLocal := TThemedGridVisualHitInfoList.Create;
  try
    LSnapshot := SnapshotHit(LInfo, LLocal);
    LArgs := TThemedGridVisualMouseEventArgs.Create(LSnapshot, AButton, AClicks, ALocation);
    try
      if ADoubleClick then
        DoVisualDoubleClick(LArgs)
      else
        DoVisualClick(LArgs);
      Result := LArgs.Handled;
    finally
      LArgs.Free;
    end;
  finally
    LLocal.Free;
  end;
end;

function TThemedGridControlVisual.VisualMouseDown(const ALocation: TPoint; const AButton: TMouseButton;
  const AShift: TShiftState): Boolean;
var
  LInfo: TThemedGridVisualHitInfo;
begin
  Result := False;
  if AButton <> mbLeft then
    Exit;
  LInfo := FHitInfos.HitTest(ALocation);
  if (LInfo = nil) or not LInfo.IsGroupHeader then
    Exit;
  CurrentRowIndex := LInfo.RowIndex;
  CurrentColumnIndex := -1;
  if SelectionOptions.AllowRowSelection and (LInfo.RowIndex >= 0) then
    ApplyMouseRowSelection(LInfo.RowIndex, ssShift in AShift, ssCtrl in AShift);
  Invalidate;
  Result := True;
end;

function TThemedGridControlVisual.VisualMouseUp(const ALocation: TPoint; const AButton: TMouseButton;
  const AShift: TShiftState): Boolean;
begin
  Result := False;
  if AButton <> mbLeft then
    Exit;
  Result := DispatchVisualMouse(ALocation, AButton, 1, False);
  if Result then
    DragSelecting := False;
end;

function TThemedGridControlVisual.VisualDoubleClick(const ALocation: TPoint): Boolean;
begin
  Result := DispatchVisualMouse(ALocation, mbLeft, 2, True);
end;

procedure TThemedGridControlVisual.VisualMouseMove(const ALocation: TPoint);
var
  LInfo: TThemedGridVisualHitInfo;
begin
  LInfo := FHitInfos.HitTest(ALocation);
  if LInfo = nil then
    Exit;
  Cursor := crHandPoint;
  if (LInfo.ToolTip = '') or (LInfo.IsDetail and (ToolTipDetailItemKey <> '')) then
    Exit;
  ShowToolTipFor(LInfo.RowIndex, LInfo.ColumnIndex, '', LInfo.ToolTip, ALocation);
end;

procedure TThemedGridControlVisual.DoCellVisualNeeded(const AArgs: TThemedGridCellVisualNeededEventArgs);
begin
  if Assigned(FOnCellVisualNeeded) then
    FOnCellVisualNeeded(Self, AArgs);
end;

procedure TThemedGridControlVisual.DoGroupVisualNeeded(const AArgs: TThemedGridGroupVisualNeededEventArgs);
begin
  if Assigned(FOnGroupVisualNeeded) then
    FOnGroupVisualNeeded(Self, AArgs);
end;

procedure TThemedGridControlVisual.DoVisualClick(const AArgs: TThemedGridVisualMouseEventArgs);
var
  LActionArgs: TThemedGridVisualActionEventArgs;
begin
  if Assigned(FOnVisualClick) then
    FOnVisualClick(Self, AArgs);
  if (AArgs = nil) or (AArgs.HitInfo = nil) or (AArgs.HitInfo.Action = nil) then
    Exit;
  LActionArgs := TThemedGridVisualActionEventArgs.Create(AArgs.HitInfo, AArgs.Button, AArgs.Clicks, AArgs.Location);
  try
    LActionArgs.Handled := AArgs.Handled;
    DoVisualActionClick(LActionArgs);
    if LActionArgs.Handled then
      AArgs.Handled := True;
  finally
    LActionArgs.Free;
  end;
end;

procedure TThemedGridControlVisual.DoVisualDoubleClick(const AArgs: TThemedGridVisualMouseEventArgs);
var
  LActionArgs: TThemedGridVisualActionEventArgs;
begin
  if Assigned(FOnVisualDoubleClick) then
    FOnVisualDoubleClick(Self, AArgs);
  if (AArgs = nil) or (AArgs.HitInfo = nil) or (AArgs.HitInfo.Action = nil) then
    Exit;
  LActionArgs := TThemedGridVisualActionEventArgs.Create(AArgs.HitInfo, AArgs.Button, AArgs.Clicks, AArgs.Location);
  try
    LActionArgs.Handled := AArgs.Handled;
    DoVisualActionDoubleClick(LActionArgs);
    if LActionArgs.Handled then
      AArgs.Handled := True;
  finally
    LActionArgs.Free;
  end;
end;

procedure TThemedGridControlVisual.DoVisualActionClick(const AArgs: TThemedGridVisualActionEventArgs);
begin
  if Assigned(FOnVisualActionClick) then
    FOnVisualActionClick(Self, AArgs);
  if (AArgs = nil) or AArgs.Handled then
    Exit;
  if FVisualActionCommands <> nil then
    FVisualActionCommands.ExecuteClick(Self, AArgs);
end;

procedure TThemedGridControlVisual.DoVisualActionDoubleClick(const AArgs: TThemedGridVisualActionEventArgs);
begin
  if Assigned(FOnVisualActionDoubleClick) then
    FOnVisualActionDoubleClick(Self, AArgs);
  if (AArgs = nil) or AArgs.Handled then
    Exit;
  if FVisualActionCommands <> nil then
    FVisualActionCommands.ExecuteDoubleClick(Self, AArgs);
end;

end.

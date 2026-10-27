{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.SplitContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.UITypes,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, NimbusForms.Theming.Palette, NimbusForms.Controls.Base,
  NimbusForms.Rendering.SplitContainer, NimbusForms.Controls.ToolTip;

type
  TThemedSplitOrientation = (tsoVertical, tsoHorizontal);
  TThemedSplitFixedPanel = (tsfpNone, tsfpPanel1, tsfpPanel2);
  TThemedSplitterMovingEvent = procedure(Sender: TObject; var APosition: Integer; var AAllow: Boolean) of object;
  TThemedSplitterMovedEvent = procedure(Sender: TObject; const APosition: Integer) of object;

  TCustomThemedSplitContainer = class(TCustomNimbusControl)
  private
    FPanel1: TPanel;
    FPanel2: TPanel;
    FOrientation: TThemedSplitOrientation;
    FFixedPanel: TThemedSplitFixedPanel;
    FSplitterStyle: TThemedSplitterStyle;
    FSplitterDistance: Integer;
    FSplitterWidth: Integer;
    FPanel1MinSize: Integer;
    FPanel2MinSize: Integer;
    FPanel1Collapsed: Boolean;
    FPanel2Collapsed: Boolean;
    FIsSplitterFixed: Boolean;
    FShowCollapseButtons: Boolean;
    FSplitterRect: TRect;
    FFirstButtonRect: TRect;
    FSecondButtonRect: TRect;
    FDragging: Boolean;
    FHovered: Boolean;
    FHotButton: Integer;
    FCollapseToolTip: TThemedToolTip;
    FFirstButtonTarget: TLabel;
    FSecondButtonTarget: TLabel;
    FDragOffset: Integer;
    FLayouting: Boolean;
    FInitialized: Boolean;
    FLastExtent: Integer;
    FOnSplitterMoving: TThemedSplitterMovingEvent;
    FOnSplitterMoved: TThemedSplitterMovedEvent;
    procedure SetOrientation(const AValue: TThemedSplitOrientation);
    procedure SetFixedPanel(const AValue: TThemedSplitFixedPanel);
    procedure SetSplitterStyle(const AValue: TThemedSplitterStyle);
    procedure SetSplitterDistance(const AValue: Integer);
    procedure SetSplitterWidth(const AValue: Integer);
    procedure SetPanel1MinSize(const AValue: Integer);
    procedure SetPanel2MinSize(const AValue: Integer);
    procedure SetPanel1Collapsed(const AValue: Boolean);
    procedure SetPanel2Collapsed(const AValue: Boolean);
    procedure SetIsSplitterFixed(const AValue: Boolean);
    procedure SetShowCollapseButtons(const AValue: Boolean);
    function GetTotalExtent: Integer;
    function GetAvailableExtent: Integer;
    function ClampDistance(const AValue: Integer): Integer;
    procedure RecalculateLayout;
    procedure UpdateCursor(const X, Y: Integer);
    procedure UpdateCollapseToolTip;
    procedure CollapseButtonEnter(Sender: TObject);
    procedure CollapseButtonLeave(Sender: TObject);
    procedure CollapseButtonClick(Sender: TObject);
    procedure FinishDrag;
    procedure CreatePanel(var APanel: TPanel);
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    function GetChildOwner: TComponent; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure ReadState(Reader: TReader); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure Paint; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    property Orientation: TThemedSplitOrientation read FOrientation write SetOrientation default tsoVertical;
    property FixedPanel: TThemedSplitFixedPanel read FFixedPanel write SetFixedPanel default tsfpNone;
    property SplitterStyle: TThemedSplitterStyle read FSplitterStyle write SetSplitterStyle default tssGrip;
    property SplitterDistance: Integer read FSplitterDistance write SetSplitterDistance default 160;
    property SplitterWidth: Integer read FSplitterWidth write SetSplitterWidth default 7;
    property Panel1MinSize: Integer read FPanel1MinSize write SetPanel1MinSize default 25;
    property Panel2MinSize: Integer read FPanel2MinSize write SetPanel2MinSize default 25;
    property Panel1Collapsed: Boolean read FPanel1Collapsed write SetPanel1Collapsed default False;
    property Panel2Collapsed: Boolean read FPanel2Collapsed write SetPanel2Collapsed default False;
    property IsSplitterFixed: Boolean read FIsSplitterFixed write SetIsSplitterFixed default False;
    property ShowCollapseButtons: Boolean read FShowCollapseButtons write SetShowCollapseButtons default False;
    property OnSplitterMoving: TThemedSplitterMovingEvent read FOnSplitterMoving write FOnSplitterMoving;
    property OnSplitterMoved: TThemedSplitterMovedEvent read FOnSplitterMoved write FOnSplitterMoved;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure CollapsePanel(const APanelIndex: Integer);
    procedure ExpandPanels;
    property Panel1: TPanel read FPanel1;
    property Panel2: TPanel read FPanel2;
    property SplitterRect: TRect read FSplitterRect;
  end;

  TThemedSplitContainer = class(TCustomThemedSplitContainer)
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property FixedPanel;
    property Font;
    property Hint;
    property IsSplitterFixed;
    property Orientation;
    property OnClick;
    property OnDblClick;
    property OnSplitterMoving;
    property OnSplitterMoved;
    property Panel1 stored False;
    property Panel2 stored False;
    property Panel1Collapsed;
    property Panel1MinSize;
    property Panel2Collapsed;
    property Panel2MinSize;
    property ParentBiDiMode;
    property ParentFont;
    property PopupMenu;
    property ShowCollapseButtons;
    property ShowHint;
    property SplitterDistance;
    property SplitterStyle;
    property SplitterWidth;
    property TabOrder;
    property TabStop default True;
    property Visible;
  end;

implementation

uses
  System.Math, System.SysUtils, NimbusForms.Theming.Types, NimbusForms.Rendering.Types;

resourcestring
  SSplitCollapseFirst = 'Collapse first panel';
  SSplitExpandFirst = 'Expand first panel';
  SSplitCollapseSecond = 'Collapse second panel';
  SSplitExpandSecond = 'Expand second panel';

constructor TCustomThemedSplitContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOrientation := tsoVertical;
  FFixedPanel := tsfpNone;
  FSplitterStyle := tssGrip;
  FSplitterDistance := 160;
  FSplitterWidth := 7;
  FPanel1MinSize := 25;
  FPanel2MinSize := 25;
  TabStop := True;
  ShowHint := True;
  Width := 420;
  Height := 280;
  CreatePanel(FPanel1);
  CreatePanel(FPanel2);
  FCollapseToolTip := TThemedToolTip.Create(Self);
  FCollapseToolTip.UseMarkup := False;
  FFirstButtonTarget := TLabel.Create(Self);
  FFirstButtonTarget.Transparent := True;
  FFirstButtonTarget.AutoSize := False;
  FFirstButtonTarget.Caption := '';
  FFirstButtonTarget.Cursor := crHandPoint;
  FFirstButtonTarget.OnMouseEnter := CollapseButtonEnter;
  FFirstButtonTarget.OnMouseLeave := CollapseButtonLeave;
  FFirstButtonTarget.OnClick := CollapseButtonClick;
  FSecondButtonTarget := TLabel.Create(Self);
  FSecondButtonTarget.Transparent := True;
  FSecondButtonTarget.AutoSize := False;
  FSecondButtonTarget.Caption := '';
  FSecondButtonTarget.Cursor := crHandPoint;
  FSecondButtonTarget.OnMouseEnter := CollapseButtonEnter;
  FSecondButtonTarget.OnMouseLeave := CollapseButtonLeave;
  FSecondButtonTarget.OnClick := CollapseButtonClick;
  FCollapseToolTip.SetToolTip(FFirstButtonTarget, SSplitCollapseFirst);
  FCollapseToolTip.SetToolTip(FSecondButtonTarget, SSplitCollapseSecond);
  FInitialized := True;
  FLastExtent := 0;
end;

destructor TCustomThemedSplitContainer.Destroy;
begin
  FinishDrag;
  FreeAndNil(FCollapseToolTip);
  inherited Destroy;
end;

procedure TCustomThemedSplitContainer.CreatePanel(var APanel: TPanel);
begin
  APanel := TPanel.Create(Self);
  APanel.BevelOuter := bvNone;
  APanel.Caption := '';
  if Parent <> nil then APanel.Parent := Self;
end;

function TCustomThemedSplitContainer.GetChildOwner: TComponent;
begin
  Result := Self;
end;

procedure TCustomThemedSplitContainer.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
  if FPanel1 <> nil then Proc(FPanel1);
  if FPanel2 <> nil then Proc(FPanel2);
end;

procedure TCustomThemedSplitContainer.ReadState(Reader: TReader);
var
  I: Integer;
  LPanel1, LPanel2, LPrevious: TPanel;
begin
  inherited ReadState(Reader);
  LPanel1 := nil;
  LPanel2 := nil;
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TPanel) and (Components[I] <> FPanel1) and (Components[I] <> FPanel2) then
    begin
      if LPanel1 = nil then
        LPanel1 := TPanel(Components[I])
      else if LPanel2 = nil then
        LPanel2 := TPanel(Components[I]);
    end;
  if LPanel1 <> nil then
  begin
    LPrevious := FPanel1;
    FPanel1 := LPanel1;
    LPrevious.Free;
  end;
  if LPanel2 <> nil then
  begin
    LPrevious := FPanel2;
    FPanel2 := LPanel2;
    LPrevious.Free;
  end;
  if FPanel1 = nil then CreatePanel(FPanel1);
  if FPanel2 = nil then CreatePanel(FPanel2);
  if FPanel1.Parent <> Self then FPanel1.Parent := Self;
  if FPanel2.Parent <> Self then FPanel2.Parent := Self;
end;

procedure TCustomThemedSplitContainer.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FPanel1 then FPanel1 := nil;
    if AComponent = FPanel2 then FPanel2 := nil;
  end;
end;

procedure TCustomThemedSplitContainer.SetParent(AParent: TWinControl);
begin
  if AParent = nil then
  begin
    if (FPanel1 <> nil) and (FPanel1.Parent = Self) then FPanel1.Parent := nil;
    if (FPanel2 <> nil) and (FPanel2.Parent = Self) then FPanel2.Parent := nil;
    if (FFirstButtonTarget <> nil) and (FFirstButtonTarget.Parent = Self) then FFirstButtonTarget.Parent := nil;
    if (FSecondButtonTarget <> nil) and (FSecondButtonTarget.Parent = Self) then FSecondButtonTarget.Parent := nil;
  end;
  inherited SetParent(AParent);
  if AParent <> nil then
  begin
    if (FPanel1 <> nil) and (FPanel1.Parent <> Self) then FPanel1.Parent := Self;
    if (FPanel2 <> nil) and (FPanel2.Parent <> Self) then FPanel2.Parent := Self;
    if (FFirstButtonTarget <> nil) and (FFirstButtonTarget.Parent <> Self) then FFirstButtonTarget.Parent := Self;
    if (FSecondButtonTarget <> nil) and (FSecondButtonTarget.Parent <> Self) then FSecondButtonTarget.Parent := Self;
    FLastExtent := GetAvailableExtent;
    RecalculateLayout;
  end;
end;

procedure TCustomThemedSplitContainer.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCustomThemedSplitContainer.CreateWnd;
begin
  inherited CreateWnd;
  if Parent <> nil then RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.Loaded;
begin
  inherited Loaded;
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if APalette = nil then Exit;
  if FPanel1 <> nil then FPanel1.Color := ThemeColorToColor(NimbusPanelBackColor(APalette));
  if FPanel2 <> nil then FPanel2.Color := ThemeColorToColor(NimbusPanelBackColor(APalette));
end;

function TCustomThemedSplitContainer.GetTotalExtent: Integer;
begin
  if FOrientation = tsoVertical then Result := ClientWidth else Result := ClientHeight;
end;

function TCustomThemedSplitContainer.GetAvailableExtent: Integer;
begin
  Result := Max(0, GetTotalExtent - ScaleValue(FSplitterWidth));
end;

function TCustomThemedSplitContainer.ClampDistance(const AValue: Integer): Integer;
var
  LAvailable, LMin1, LMin2: Integer;
begin
  LAvailable := GetAvailableExtent;
  LMin1 := Min(LAvailable, ScaleValue(FPanel1MinSize));
  LMin2 := Min(LAvailable, ScaleValue(FPanel2MinSize));
  if LMin1 + LMin2 > LAvailable then
  begin
    LMin1 := LAvailable div 2;
    LMin2 := LAvailable - LMin1;
  end;
  Result := EnsureRange(AValue, LMin1, LAvailable - LMin2);
end;

procedure TCustomThemedSplitContainer.RecalculateLayout;
var
  LAvailable, LDistance, LWidth, LTotal, LButton, LCenter: Integer;
  R1, R2: TRect;
begin
  if not FInitialized or FLayouting or (Parent = nil) or (csDestroying in ComponentState) then Exit;
  FLayouting := True;
  try
    LWidth := ScaleValue(FSplitterWidth);
    LTotal := GetTotalExtent;
    LAvailable := Max(0, LTotal - LWidth);
    LDistance := ClampDistance(ScaleValue(FSplitterDistance));
    if FPanel1Collapsed then LDistance := 0;
    if FPanel2Collapsed then LDistance := LAvailable;
    if FOrientation = tsoVertical then
    begin
      R1 := Rect(0, 0, LDistance, ClientHeight);
      FSplitterRect := Rect(LDistance, 0, LDistance + LWidth, ClientHeight);
      R2 := Rect(LDistance + LWidth, 0, ClientWidth, ClientHeight);
    end
    else
    begin
      R1 := Rect(0, 0, ClientWidth, LDistance);
      FSplitterRect := Rect(0, LDistance, ClientWidth, LDistance + LWidth);
      R2 := Rect(0, LDistance + LWidth, ClientWidth, ClientHeight);
    end;
    if FPanel1 <> nil then
    begin
      FPanel1.Visible := not FPanel1Collapsed;
      FPanel1.SetBounds(R1.Left, R1.Top, Max(0, R1.Width), Max(0, R1.Height));
    end;
    if FPanel2 <> nil then
    begin
      FPanel2.Visible := not FPanel2Collapsed;
      FPanel2.SetBounds(R2.Left, R2.Top, Max(0, R2.Width), Max(0, R2.Height));
    end;
    FFirstButtonRect := Rect(0, 0, 0, 0);
    FSecondButtonRect := Rect(0, 0, 0, 0);
    if FShowCollapseButtons then
    begin
      LButton := ScaleValue(20);
      if FOrientation = tsoVertical then
      begin
        LCenter := ClientHeight div 2;
        FFirstButtonRect := Rect(FSplitterRect.Left, LCenter - LButton - 2, FSplitterRect.Right, LCenter - 2);
        FSecondButtonRect := Rect(FSplitterRect.Left, LCenter + 2, FSplitterRect.Right, LCenter + LButton + 2);
      end
      else
      begin
        LCenter := ClientWidth div 2;
        FFirstButtonRect := Rect(LCenter - LButton - 2, FSplitterRect.Top, LCenter - 2, FSplitterRect.Bottom);
        FSecondButtonRect := Rect(LCenter + 2, FSplitterRect.Top, LCenter + LButton + 2, FSplitterRect.Bottom);
      end;
    end;
    if FFirstButtonTarget <> nil then
    begin
      FFirstButtonTarget.Visible := FShowCollapseButtons and Enabled;
      FFirstButtonTarget.SetBounds(FFirstButtonRect.Left, FFirstButtonRect.Top,
        Max(0, FFirstButtonRect.Width), Max(0, FFirstButtonRect.Height));
      if FFirstButtonTarget.Visible then FFirstButtonTarget.BringToFront;
    end;
    if FSecondButtonTarget <> nil then
    begin
      FSecondButtonTarget.Visible := FShowCollapseButtons and Enabled;
      FSecondButtonTarget.SetBounds(FSecondButtonRect.Left, FSecondButtonRect.Top,
        Max(0, FSecondButtonRect.Width), Max(0, FSecondButtonRect.Height));
      if FSecondButtonTarget.Visible then FSecondButtonTarget.BringToFront;
    end;
    Invalidate;
  finally
    FLayouting := False;
  end;
end;

procedure TCustomThemedSplitContainer.SetOrientation(const AValue: TThemedSplitOrientation);
begin
  if FOrientation = AValue then Exit;
  FOrientation := AValue;
  FLastExtent := GetAvailableExtent;
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.SetFixedPanel(const AValue: TThemedSplitFixedPanel);
begin
  if FFixedPanel = AValue then Exit;
  FFixedPanel := AValue;
end;

procedure TCustomThemedSplitContainer.SetSplitterStyle(const AValue: TThemedSplitterStyle);
begin
  if FSplitterStyle = AValue then Exit;
  FSplitterStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedSplitContainer.SetSplitterDistance(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FSplitterDistance = LValue then Exit;
  FSplitterDistance := LValue;
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.SetSplitterWidth(const AValue: Integer);
begin
  if FSplitterWidth = Max(3, AValue) then Exit;
  FSplitterWidth := Max(3, AValue);
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.SetPanel1MinSize(const AValue: Integer);
begin
  if FPanel1MinSize = Max(0, AValue) then Exit;
  FPanel1MinSize := Max(0, AValue);
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.SetPanel2MinSize(const AValue: Integer);
begin
  if FPanel2MinSize = Max(0, AValue) then Exit;
  FPanel2MinSize := Max(0, AValue);
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.SetPanel1Collapsed(const AValue: Boolean);
begin
  if FPanel1Collapsed = AValue then Exit;
  FPanel1Collapsed := AValue;
  if AValue then FPanel2Collapsed := False;
  RecalculateLayout;
  UpdateCollapseToolTip;
end;

procedure TCustomThemedSplitContainer.SetPanel2Collapsed(const AValue: Boolean);
begin
  if FPanel2Collapsed = AValue then Exit;
  FPanel2Collapsed := AValue;
  if AValue then FPanel1Collapsed := False;
  RecalculateLayout;
  UpdateCollapseToolTip;
end;

procedure TCustomThemedSplitContainer.SetIsSplitterFixed(const AValue: Boolean);
begin
  if FIsSplitterFixed = AValue then Exit;
  FIsSplitterFixed := AValue;
  if AValue then FinishDrag;
  Invalidate;
end;

procedure TCustomThemedSplitContainer.SetShowCollapseButtons(const AValue: Boolean);
begin
  if FShowCollapseButtons = AValue then Exit;
  FShowCollapseButtons := AValue;
  if not AValue then
  begin
    FHotButton := 0;
    UpdateCollapseToolTip;
  end;
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.CollapsePanel(const APanelIndex: Integer);
begin
  case APanelIndex of
    1: Panel1Collapsed := not FPanel1Collapsed;
    2: Panel2Collapsed := not FPanel2Collapsed;
  end;
end;

procedure TCustomThemedSplitContainer.ExpandPanels;
begin
  if not FPanel1Collapsed and not FPanel2Collapsed then Exit;
  FPanel1Collapsed := False;
  FPanel2Collapsed := False;
  RecalculateLayout;
  UpdateCollapseToolTip;
end;

procedure TCustomThemedSplitContainer.Resize;
var
  LNewExtent, LDelta, LOldDistance: Integer;
begin
  inherited Resize;
  if not FInitialized or FLayouting then Exit;
  LNewExtent := GetAvailableExtent;
  LDelta := LNewExtent - FLastExtent;
  if (LNewExtent >= ScaleValue(FPanel1MinSize + FPanel2MinSize + 8)) and
    (LDelta <> 0) and (FLastExtent > 0) and not FPanel1Collapsed and not FPanel2Collapsed then
  begin
    LOldDistance := ScaleValue(FSplitterDistance);
    case FFixedPanel of
      tsfpPanel2: FSplitterDistance := Max(0, MulDiv(LOldDistance + LDelta, 96, Max(1, CurrentPPI)));
      tsfpNone: FSplitterDistance := Max(0, MulDiv(MulDiv(LOldDistance, LNewExtent, FLastExtent), 96, Max(1, CurrentPPI)));
    end;
  end;
  if LNewExtent >= ScaleValue(FPanel1MinSize + FPanel2MinSize + 8) then
    FLastExtent := LNewExtent;
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  if Parent <> nil then FLastExtent := GetAvailableExtent;
  RecalculateLayout;
end;

procedure TCustomThemedSplitContainer.Paint;
var
  LContext: TThemedSplitRenderContext;
begin
  if RenderCanvas = nil then Exit;
  LContext := Default(TThemedSplitRenderContext);
  LContext.Bounds := ClientRect;
  LContext.SplitterRect := FSplitterRect;
  LContext.FirstButtonRect := FFirstButtonRect;
  LContext.SecondButtonRect := FSecondButtonRect;
  LContext.Palette := Palette;
  LContext.Vertical := FOrientation = tsoVertical;
  LContext.Enabled := Enabled;
  LContext.Hovered := FHovered;
  LContext.HotButton := FHotButton;
  LContext.Dragging := FDragging;
  LContext.ShowCollapseButtons := FShowCollapseButtons;
  LContext.SplitterStyle := FSplitterStyle;
  LContext.PPI := CurrentPPI;
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedSplitContainerRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedSplitContainer.UpdateCollapseToolTip;
var
  LFirst, LSecond: string;
begin
  if FCollapseToolTip = nil then Exit;
  if FPanel1Collapsed then LFirst := SSplitExpandFirst else LFirst := SSplitCollapseFirst;
  if FPanel2Collapsed then LSecond := SSplitExpandSecond else LSecond := SSplitCollapseSecond;
  if (FFirstButtonTarget <> nil) and (FCollapseToolTip.GetToolTip(FFirstButtonTarget) <> LFirst) then
    FCollapseToolTip.SetToolTip(FFirstButtonTarget, LFirst);
  if (FSecondButtonTarget <> nil) and (FCollapseToolTip.GetToolTip(FSecondButtonTarget) <> LSecond) then
    FCollapseToolTip.SetToolTip(FSecondButtonTarget, LSecond);
end;

procedure TCustomThemedSplitContainer.CollapseButtonEnter(Sender: TObject);
var
  LButton: Integer;
begin
  if Sender = FFirstButtonTarget then LButton := 1
  else if Sender = FSecondButtonTarget then LButton := 2
  else Exit;
  if FHotButton <> LButton then
  begin
    FHotButton := LButton;
    FHovered := True;
    if HandleAllocated then InvalidateRect(Handle, @FSplitterRect, False);
  end;
end;

procedure TCustomThemedSplitContainer.CollapseButtonLeave(Sender: TObject);
begin
  if ((Sender = FFirstButtonTarget) and (FHotButton = 1)) or
     ((Sender = FSecondButtonTarget) and (FHotButton = 2)) then
  begin
    FHotButton := 0;
    FHovered := False;
    if HandleAllocated then InvalidateRect(Handle, @FSplitterRect, False);
  end;
end;

procedure TCustomThemedSplitContainer.CollapseButtonClick(Sender: TObject);
begin
  if not Enabled then Exit;
  if Sender = FFirstButtonTarget then
  begin
    if FPanel1Collapsed then ExpandPanels else CollapsePanel(1);
  end
  else if Sender = FSecondButtonTarget then
  begin
    if FPanel2Collapsed then ExpandPanels else CollapsePanel(2);
  end;
end;

procedure TCustomThemedSplitContainer.UpdateCursor(const X, Y: Integer);
var
  LHot: Boolean;
  LButton: Integer;
begin
  LButton := 0;
  if FShowCollapseButtons and Enabled then
  begin
    if PtInRect(FFirstButtonRect, Point(X, Y)) then LButton := 1
    else if PtInRect(FSecondButtonRect, Point(X, Y)) then LButton := 2;
  end;
  if FHotButton <> LButton then
  begin
    FHotButton := LButton;
    UpdateCollapseToolTip;
    if HandleAllocated then InvalidateRect(Handle, @FSplitterRect, False);
  end;
  LHot := PtInRect(FSplitterRect, Point(X, Y));
  if FHovered <> LHot then
  begin
    FHovered := LHot;
    if HandleAllocated then InvalidateRect(Handle, @FSplitterRect, False);
  end;
  if LButton <> 0 then Cursor := crHandPoint
  else if LHot and not FIsSplitterFixed then
  begin
    if FOrientation = tsoVertical then Cursor := crHSplit else Cursor := crVSplit;
  end
  else Cursor := crDefault;
end;

procedure TCustomThemedSplitContainer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  if FShowCollapseButtons and PtInRect(FFirstButtonRect, Point(X, Y)) then
  begin
    if FPanel1Collapsed then ExpandPanels else CollapsePanel(1);
    UpdateCollapseToolTip;
    Exit;
  end;
  if FShowCollapseButtons and PtInRect(FSecondButtonRect, Point(X, Y)) then
  begin
    if FPanel2Collapsed then ExpandPanels else CollapsePanel(2);
    UpdateCollapseToolTip;
    Exit;
  end;
  if FIsSplitterFixed or FPanel1Collapsed or FPanel2Collapsed or not PtInRect(FSplitterRect, Point(X, Y)) then Exit;
  if CanFocus then SetFocus;
  FDragging := True;
  if FOrientation = tsoVertical then FDragOffset := X - FSplitterRect.Left else FDragOffset := Y - FSplitterRect.Top;
  MouseCapture := True;
  InvalidateRect(Handle, @FSplitterRect, False);
end;

procedure TCustomThemedSplitContainer.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LPosition: Integer;
  LAllow: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  if not FDragging then
  begin
    UpdateCursor(X, Y);
    Exit;
  end;
  if FOrientation = tsoVertical then LPosition := X - FDragOffset else LPosition := Y - FDragOffset;
  LPosition := ClampDistance(LPosition);
  LAllow := True;
  if Assigned(FOnSplitterMoving) then FOnSplitterMoving(Self, LPosition, LAllow);
  if LAllow then SplitterDistance := MulDiv(ClampDistance(LPosition), 96, Max(1, CurrentPPI));
end;

procedure TCustomThemedSplitContainer.FinishDrag;
begin
  if not FDragging then Exit;
  FDragging := False;
  if MouseCapture then MouseCapture := False;
  if HandleAllocated then InvalidateRect(Handle, @FSplitterRect, False);
  if Assigned(FOnSplitterMoved) then FOnSplitterMoved(Self, FSplitterDistance);
end;

procedure TCustomThemedSplitContainer.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then FinishDrag;
end;

procedure TCustomThemedSplitContainer.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if FDragging then FinishDrag;
end;

procedure TCustomThemedSplitContainer.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FinishDrag;
    FHotButton := 0;
    UpdateCollapseToolTip;
  end;
end;

procedure TCustomThemedSplitContainer.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHovered or (FHotButton <> 0) then
  begin
    FHovered := False;
    FHotButton := 0;
    UpdateCollapseToolTip;
    Cursor := crDefault;
    if HandleAllocated then InvalidateRect(Handle, @FSplitterRect, False);
  end;
end;

procedure TCustomThemedSplitContainer.KeyDown(var Key: Word; Shift: TShiftState);
var
  LDelta, LPosition: Integer;
  LAllow: Boolean;
begin
  inherited KeyDown(Key, Shift);
  if FIsSplitterFixed or not Enabled or FPanel1Collapsed or FPanel2Collapsed then Exit;
  LDelta := 0;
  if FOrientation = tsoVertical then
  begin
    if Key = VK_LEFT then LDelta := -1;
    if Key = VK_RIGHT then LDelta := 1;
  end
  else
  begin
    if Key = VK_UP then LDelta := -1;
    if Key = VK_DOWN then LDelta := 1;
  end;
  if LDelta = 0 then Exit;
  if ssCtrl in Shift then LDelta := LDelta * 10;
  LPosition := ClampDistance(ScaleValue(FSplitterDistance + LDelta));
  LAllow := True;
  if Assigned(FOnSplitterMoving) then FOnSplitterMoving(Self, LPosition, LAllow);
  if LAllow then
  begin
    SplitterDistance := MulDiv(ClampDistance(LPosition), 96, Max(1, CurrentPPI));
    if Assigned(FOnSplitterMoved) then FOnSplitterMoved(Self, FSplitterDistance);
  end;
  Key := 0;
end;

initialization
  RegisterClass(TPanel);

end.

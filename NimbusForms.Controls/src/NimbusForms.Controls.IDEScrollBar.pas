{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.IDEScrollBar;

interface

uses
  System.Classes, System.Types, Vcl.Controls, NimbusForms.Controls.ScrollBarBase,
  NimbusForms.Rendering.ScrollBar, NimbusForms.Rendering.Canvas, NimbusForms.Rendering.IDEScrollBar;

type
  TThemedIDEScrollBarMarker = class(TCollectionItem)
  private
    FFirst: Integer;
    FLast: Integer;
    FShape: TNimbusIDEMarkerShape;
    FLane: TNimbusIDEMarkerLane;
    FTone: TNimbusIDEMarkerTone;
    FTag: NativeInt;
    FHint: string;
    procedure SetFirst(const AValue: Integer);
    procedure SetLast(const AValue: Integer);
    procedure SetShape(const AValue: TNimbusIDEMarkerShape);
    procedure SetLane(const AValue: TNimbusIDEMarkerLane);
    procedure SetTone(const AValue: TNimbusIDEMarkerTone);
  public
    function Geometry: TNimbusIDEMarkerGeometry;
  published
    property First: Integer read FFirst write SetFirst;
    property Last: Integer read FLast write SetLast;
    property Shape: TNimbusIDEMarkerShape read FShape write SetShape default imsBar;
    property Lane: TNimbusIDEMarkerLane read FLane write SetLane default imlLeft;
    property Tone: TNimbusIDEMarkerTone read FTone write SetTone default imtAccent;
    property Tag: NativeInt read FTag write FTag default 0;
    property Hint: string read FHint write FHint;
  end;

  TThemedIDEScrollBarMarkers = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(AIndex: Integer): TThemedIDEScrollBarMarker;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedIDEScrollBarMarker;
    property Items[AIndex: Integer]: TThemedIDEScrollBarMarker read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TIDEMarkerClickEvent = procedure(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer) of object;
  TThemedIDEScrollBar = class(TCustomThemedScrollBar)
  private
    FMarkers: TThemedIDEScrollBarMarkers;
    FMarkerWidth: Integer;
    FOnMarkerClick: TIDEMarkerClickEvent;
    FOnMarkerEnter: TIDEMarkerClickEvent;
    FHotMarker: TThemedIDEScrollBarMarker;
    procedure MarkersChanged(Sender: TObject);
    procedure SetMarkers(const AValue: TThemedIDEScrollBarMarkers);
    procedure SetMarkerWidth(const AValue: Integer);
    function MarkerAt(const X, Y: Integer): TThemedIDEScrollBarMarker;
  protected
    procedure RenderOverlay(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddMarker(AFirst, ALast: Integer; AShape: TNimbusIDEMarkerShape; ALane: TNimbusIDEMarkerLane; ATone: TNimbusIDEMarkerTone): TThemedIDEScrollBarMarker;
    procedure ClearMarkers;
    property HoverMarker: TThemedIDEScrollBarMarker read FHotMarker;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop default False;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property Minimum;
    property Maximum;
    property Value;
    property SmallChange;
    property LargeChange;
    property ButtonSize;
    property MinimumThumbSize;
    property Markers: TThemedIDEScrollBarMarkers read FMarkers write SetMarkers;
    property MarkerWidth: Integer read FMarkerWidth write SetMarkerWidth default 5;
    property OnValueChanged;
    property OnMarkerClick: TIDEMarkerClickEvent read FOnMarkerClick write FOnMarkerClick;
    property OnMarkerEnter: TIDEMarkerClickEvent read FOnMarkerEnter write FOnMarkerEnter;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnKeyDown;
    property OnKeyUp;
  end;

implementation

uses
  System.Math, Winapi.Windows;

procedure TThemedIDEScrollBarMarker.SetFirst(const AValue: Integer);
begin
  if FFirst = AValue then Exit;
  FFirst := AValue;
  Changed(False);
end;

procedure TThemedIDEScrollBarMarker.SetLast(const AValue: Integer);
begin
  if FLast = AValue then Exit;
  FLast := AValue;
  Changed(False);
end;

procedure TThemedIDEScrollBarMarker.SetShape(const AValue: TNimbusIDEMarkerShape);
begin
  if FShape = AValue then Exit;
  FShape := AValue;
  Changed(False);
end;

procedure TThemedIDEScrollBarMarker.SetLane(const AValue: TNimbusIDEMarkerLane);
begin
  if FLane = AValue then Exit;
  FLane := AValue;
  Changed(False);
end;

procedure TThemedIDEScrollBarMarker.SetTone(const AValue: TNimbusIDEMarkerTone);
begin
  if FTone = AValue then Exit;
  FTone := AValue;
  Changed(False);
end;

function TThemedIDEScrollBarMarker.Geometry: TNimbusIDEMarkerGeometry;
begin
  Result.First := FFirst;
  Result.Last := FLast;
  Result.Shape := FShape;
  Result.Lane := FLane;
  Result.Tone := FTone;
end;

constructor TThemedIDEScrollBarMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TThemedIDEScrollBarMarker);
end;

procedure TThemedIDEScrollBarMarkers.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TThemedIDEScrollBarMarkers.GetItem(AIndex: Integer): TThemedIDEScrollBarMarker;
begin
  Result := TThemedIDEScrollBarMarker(inherited Items[AIndex]);
end;

function TThemedIDEScrollBarMarkers.Add: TThemedIDEScrollBarMarker;
begin
  Result := TThemedIDEScrollBarMarker(inherited Add);
end;

constructor TThemedIDEScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitializeOrientation(nsboVertical);
  FMarkers := TThemedIDEScrollBarMarkers.Create(Self);
  FMarkers.OnChange := MarkersChanged;
  FMarkerWidth := 5;
  SetBounds(Left, Top, 20, 160);
end;

destructor TThemedIDEScrollBar.Destroy;
begin
  FMarkers.Free;
  inherited;
end;

procedure TThemedIDEScrollBar.MarkersChanged(Sender: TObject);
begin
  FHotMarker := nil;
  Invalidate;
end;

procedure TThemedIDEScrollBar.SetMarkers(const AValue: TThemedIDEScrollBarMarkers);
begin
  FMarkers.Assign(AValue);
end;

procedure TThemedIDEScrollBar.SetMarkerWidth(const AValue: Integer);
begin
  if FMarkerWidth = Max(2, AValue) then Exit;
  FMarkerWidth := Max(2, AValue);
  Invalidate;
end;

function TThemedIDEScrollBar.AddMarker(AFirst, ALast: Integer; AShape: TNimbusIDEMarkerShape; ALane: TNimbusIDEMarkerLane; ATone: TNimbusIDEMarkerTone): TThemedIDEScrollBarMarker;
begin
  FMarkers.BeginUpdate;
  try
    Result := FMarkers.Add;
    Result.First := AFirst;
    Result.Last := ALast;
    Result.Shape := AShape;
    Result.Lane := ALane;
    Result.Tone := ATone;
  finally
    FMarkers.EndUpdate;
  end;
end;

procedure TThemedIDEScrollBar.ClearMarkers;
begin
  FMarkers.Clear;
end;

function TThemedIDEScrollBar.MarkerAt(const X, Y: Integer): TThemedIDEScrollBarMarker;
var
  I: Integer;
  LContext: TNimbusScrollBarRenderContext;
  LRect: TRect;
begin
  Result := nil;
  LContext := BuildRenderContext;
  for I := FMarkers.Count - 1 downto 0 do
  begin
    LRect := TThemedIDEScrollBarRenderer.MarkerRect(LContext, FMarkers[I].Geometry, ScaleValue(FMarkerWidth));
    InflateRect(LRect, ScaleValue(2), ScaleValue(2));
    if PtInRect(LRect, Point(X, Y)) then Exit(FMarkers[I]);
  end;
end;

procedure TThemedIDEScrollBar.RenderOverlay(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext);
var
  I: Integer;
begin
  for I := 0 to FMarkers.Count - 1 do
    TThemedIDEScrollBarRenderer.DrawMarker(ACanvas, AContext, FMarkers[I].Geometry, ScaleValue(FMarkerWidth));
end;

procedure TThemedIDEScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LMarker: TThemedIDEScrollBarMarker;
begin
  if (Button = mbLeft) and Enabled then
  begin
    LMarker := MarkerAt(X, Y);
    if LMarker <> nil then
    begin
      inherited MouseDown(mbRight, Shift, X, Y);
      if Assigned(FOnMarkerClick) then FOnMarkerClick(Self, LMarker, LMarker.First, LMarker.Last);
      Exit;
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TThemedIDEScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LMarker: TThemedIDEScrollBarMarker;
begin
  inherited MouseMove(Shift, X, Y);
  LMarker := MarkerAt(X, Y);
  if FHotMarker = LMarker then Exit;
  FHotMarker := LMarker;
  if Assigned(FOnMarkerEnter) and (LMarker <> nil) then FOnMarkerEnter(Self, LMarker, LMarker.First, LMarker.Last);
end;

end.

unit NimbusForms.HexEditor.ScrollBar;

interface

uses
  System.Types,
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.RenderSurface;

type
  THexScrollPart = (sspNone, sspThumb, sspTrackBefore, sspTrackAfter);

  THexScrollBar = class
  private
    FVertical: Boolean;
    FBounds: TRect;
    FMax: Integer;
    FPage: Integer;
    FPosition: Integer;
    FHovered: Boolean;
    FDragging: Boolean;
    FDragStart: Integer;
    FDragStartPosition: Integer;
    function TrackLength: Integer;
    function ScrollableMax: Integer;
    function ThumbLength: Integer;
    function ThumbStart: Integer;
  public
    constructor Create(const AVertical: Boolean);
    procedure Configure(const AMax, APage, APosition: Integer);
    procedure SetBounds(const ABounds: TRect);
    function Visible: Boolean;
    function Thickness: Integer;
    function ThumbRect: TRect;
    function HitTest(const AX, AY: Integer): THexScrollPart;
    procedure Paint(const ASurface: IHexRenderSurface; const ATheme: THexTheme);
    procedure SetHovered(const AValue: Boolean);
    procedure BeginDrag(const AX, AY: Integer);
    function DragTo(const AX, AY: Integer): Integer;
    procedure EndDrag;
    function PageStep(const AForward: Boolean): Integer;
    property Vertical: Boolean read FVertical;
    property Position: Integer read FPosition;
    property Dragging: Boolean read FDragging;
    property Hovered: Boolean read FHovered;
    property Bounds: TRect read FBounds;
  end;

implementation

const
  CScrollBarThickness = 14;
  CMinThumbLength = 24;

constructor THexScrollBar.Create(const AVertical: Boolean);
begin
  inherited Create;
  FVertical := AVertical;
end;

procedure THexScrollBar.Configure(const AMax, APage, APosition: Integer);
begin
  FMax := Max(0, AMax);
  FPage := Max(1, APage);
  FPosition := APosition;
  if FPosition < 0 then
    FPosition := 0;
  if FPosition > ScrollableMax then
    FPosition := ScrollableMax;
end;

procedure THexScrollBar.SetBounds(const ABounds: TRect);
begin
  FBounds := ABounds;
end;

function THexScrollBar.Thickness: Integer;
begin
  Result := CScrollBarThickness;
end;

function THexScrollBar.Visible: Boolean;
begin
  Result := FMax > FPage;
end;

function THexScrollBar.ScrollableMax: Integer;
begin
  Result := Max(0, FMax - FPage);
end;

function THexScrollBar.TrackLength: Integer;
begin
  if FVertical then
    Result := FBounds.Bottom - FBounds.Top
  else
    Result := FBounds.Right - FBounds.Left;
end;

function THexScrollBar.ThumbLength: Integer;
var
  LTrack: Integer;
begin
  LTrack := TrackLength;
  if (FMax <= 0) or (LTrack <= 0) then
    Exit(LTrack);
  Result := Round(LTrack * (FPage / FMax));
  if Result < CMinThumbLength then
    Result := CMinThumbLength;
  if Result > LTrack then
    Result := LTrack;
end;

function THexScrollBar.ThumbStart: Integer;
var
  LTravel, LBase: Integer;
begin
  if FVertical then
    LBase := FBounds.Top
  else
    LBase := FBounds.Left;
  LTravel := TrackLength - ThumbLength;
  if (ScrollableMax <= 0) or (LTravel <= 0) then
    Exit(LBase);
  Result := LBase + Round(LTravel * (FPosition / ScrollableMax));
end;

function THexScrollBar.ThumbRect: TRect;
var
  LStart, LLen: Integer;
begin
  LStart := ThumbStart;
  LLen := ThumbLength;
  if FVertical then
    Result := Rect(FBounds.Left + 2, LStart + 1, FBounds.Right - 2, LStart + LLen - 1)
  else
    Result := Rect(LStart + 1, FBounds.Top + 2, LStart + LLen - 1, FBounds.Bottom - 2);
end;

function THexScrollBar.HitTest(const AX, AY: Integer): THexScrollPart;
var
  LThumb: TRect;
  LPos, LThumbStart, LThumbEnd: Integer;
begin
  if not Visible then
    Exit(sspNone);
  if (AX < FBounds.Left) or (AX >= FBounds.Right) or (AY < FBounds.Top) or (AY >= FBounds.Bottom) then
    Exit(sspNone);
  LThumb := ThumbRect;
  if (AX >= LThumb.Left) and (AX < LThumb.Right) and (AY >= LThumb.Top) and (AY < LThumb.Bottom) then
    Exit(sspThumb);
  if FVertical then
  begin
    LPos := AY;
    LThumbStart := LThumb.Top;
    LThumbEnd := LThumb.Bottom;
  end
  else
  begin
    LPos := AX;
    LThumbStart := LThumb.Left;
    LThumbEnd := LThumb.Right;
  end;
  if LPos < LThumbStart then
    Result := sspTrackBefore
  else if LPos >= LThumbEnd then
    Result := sspTrackAfter
  else
    Result := sspNone;
end;

procedure THexScrollBar.Paint(const ASurface: IHexRenderSurface; const ATheme: THexTheme);
var
  LThumbColor: TThemeColor;
begin
  if not Visible then
    Exit;
  ASurface.FillRectangle(ATheme.ScrollBarTrackColor, FBounds);
  if FDragging or FHovered then
    LThumbColor := ATheme.ScrollBarThumbHoverColor
  else
    LThumbColor := ATheme.ScrollBarThumbColor;
  ASurface.FillRoundedRectangle(LThumbColor, ThumbRect, 3);
end;

procedure THexScrollBar.SetHovered(const AValue: Boolean);
begin
  FHovered := AValue;
end;

procedure THexScrollBar.BeginDrag(const AX, AY: Integer);
begin
  FDragging := True;
  if FVertical then
    FDragStart := AY
  else
    FDragStart := AX;
  FDragStartPosition := FPosition;
end;

function THexScrollBar.DragTo(const AX, AY: Integer): Integer;
var
  LDelta, LTravel, LPos: Integer;
begin
  Result := FPosition;
  if not FDragging then
    Exit;
  LTravel := TrackLength - ThumbLength;
  if LTravel <= 0 then
    Exit;
  if FVertical then
    LDelta := AY - FDragStart
  else
    LDelta := AX - FDragStart;
  LPos := FDragStartPosition + Round(LDelta * (ScrollableMax / LTravel));
  if LPos < 0 then
    LPos := 0;
  if LPos > ScrollableMax then
    LPos := ScrollableMax;
  FPosition := LPos;
  Result := LPos;
end;

procedure THexScrollBar.EndDrag;
begin
  FDragging := False;
end;

function THexScrollBar.PageStep(const AForward: Boolean): Integer;
begin
  if AForward then
    Result := FPosition + FPage
  else
    Result := FPosition - FPage;
  if Result < 0 then
    Result := 0;
  if Result > ScrollableMax then
    Result := ScrollableMax;
end;

end.

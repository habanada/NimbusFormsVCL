unit NimbusForms.Grid.ToolTipHost;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ExtCtrls;

type
  TThemedGridToolTipHost = class
  private
    FOwner: TWinControl;
    FHint: THintWindow;
    FTimer: TTimer;
    FVisible: Boolean;
    procedure TimerTick(ASender: TObject);
  public
    constructor Create(const AOwner: TWinControl);
    destructor Destroy; override;
    procedure Show(const AText: string; const AX, AY: Integer);
    procedure Hide;
    property Visible: Boolean read FVisible;
  end;

implementation

const
  ToolTipDurationMs = 5000;

constructor TThemedGridToolTipHost.Create(const AOwner: TWinControl);
begin
  inherited Create;
  FOwner := AOwner;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := ToolTipDurationMs;
  FTimer.OnTimer := TimerTick;
end;

destructor TThemedGridToolTipHost.Destroy;
begin
  FTimer.Free;
  FHint.Free;
  inherited Destroy;
end;

procedure TThemedGridToolTipHost.TimerTick(ASender: TObject);
begin
  Hide;
end;

procedure TThemedGridToolTipHost.Show(const AText: string; const AX, AY: Integer);
var
  LRect: TRect;
  LOrigin: TPoint;
begin
  if (AText = '') or (FOwner = nil) or not FOwner.HandleAllocated then
  begin
    Hide;
    Exit;
  end;
  if FHint = nil then
  begin
    FHint := THintWindow.Create(nil);
    FHint.Color := clInfoBk;
  end;
  LOrigin := FOwner.ClientToScreen(Point(AX, AY));
  LRect := FHint.CalcHintRect(Screen.Width, AText, nil);
  OffsetRect(LRect, LOrigin.X, LOrigin.Y);
  FHint.ActivateHint(LRect, AText);
  FVisible := True;
  FTimer.Enabled := False;
  FTimer.Enabled := True;
end;

procedure TThemedGridToolTipHost.Hide;
begin
  FTimer.Enabled := False;
  if not FVisible then
    Exit;
  FVisible := False;
  if (FHint <> nil) and FHint.HandleAllocated then
    ShowWindow(FHint.Handle, SW_HIDE);
end;

end.

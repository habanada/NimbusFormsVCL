unit NimbusForms.Grid.SearchPanel;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  System.UITypes,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette;

type
  TThemedGridSearchPanel = class(TCustomPanel)
  private
    FEdit: TEdit;
    FPreviousButton: TSpeedButton;
    FNextButton: TSpeedButton;
    FCloseButton: TSpeedButton;
    FResultLabel: TLabel;
    FDebounceTimer: TTimer;
    FUpdating: Boolean;
    FDebounceInterval: Integer;
    FOnSearchTextChanged: TNotifyEvent;
    FOnNextClicked: TNotifyEvent;
    FOnPreviousClicked: TNotifyEvent;
    FOnCloseClicked: TNotifyEvent;
    function GetFindText: string;
    procedure SetFindText(const AValue: string);
    procedure SetDebounceInterval(const AValue: Integer);
    procedure EditChange(ASender: TObject);
    procedure EditKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
    procedure EditKeyPress(ASender: TObject; var AKey: Char);
    procedure DebounceTick(ASender: TObject);
    procedure NextClick(ASender: TObject);
    procedure PreviousClick(ASender: TObject);
    procedure CloseClick(ASender: TObject);
    procedure RaiseSearchTextChanged;
    procedure RaiseCloseClicked;
    procedure ApplyButtonTheme(const AButton: TSpeedButton; const APalette: TThemePalette);
    procedure LayoutChildren;
    function ScaleValue(const AValue: Integer): Integer;
  protected
    procedure CreateWnd; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFindTextSilent(const AValue: string; const ASilent: Boolean);
    procedure CancelPendingSearch;
    procedure FlushPendingSearch;
    procedure FocusTextBox;
    procedure SetResultInfo(const AIndex, ACount: Integer);
    procedure ApplyTheme(const APalette: TThemePalette);
    property FindText: string read GetFindText write SetFindText;
    property DebounceInterval: Integer read FDebounceInterval write SetDebounceInterval default 180;
    property OnSearchTextChanged: TNotifyEvent read FOnSearchTextChanged write FOnSearchTextChanged;
    property OnNextClicked: TNotifyEvent read FOnNextClicked write FOnNextClicked;
    property OnPreviousClicked: TNotifyEvent read FOnPreviousClicked write FOnPreviousClicked;
    property OnCloseClicked: TNotifyEvent read FOnCloseClicked write FOnCloseClicked;
  end;

implementation

uses
  NimbusForms.Grid.SearchStrings;

constructor TThemedGridSearchPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := ThemedGridSearchStrings.PanelName;
  BevelOuter := bvNone;
  ShowCaption := False;
  ParentBackground := False;
  FullRepaint := True;
  Height := 32;
  FDebounceInterval := 180;

  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.Name := ThemedGridSearchStrings.EditName;
  FEdit.BorderStyle := bsSingle;
  FEdit.OnChange := EditChange;
  FEdit.OnKeyDown := EditKeyDown;
  FEdit.OnKeyPress := EditKeyPress;

  FResultLabel := TLabel.Create(Self);
  FResultLabel.AutoSize := False;
  FResultLabel.Parent := Self;
  FResultLabel.Alignment := taCenter;
  FResultLabel.Layout := tlCenter;
  FResultLabel.Caption := ThemedGridSearchStrings.EmptyResultText;

  FPreviousButton := TSpeedButton.Create(Self);
  FPreviousButton.Parent := Self;
  FPreviousButton.Flat := True;
  FPreviousButton.Caption := ThemedGridSearchStrings.PreviousText;
  FPreviousButton.Hint := ThemedGridSearchStrings.PreviousHint;
  FPreviousButton.ShowHint := True;
  FPreviousButton.OnClick := PreviousClick;

  FNextButton := TSpeedButton.Create(Self);
  FNextButton.Parent := Self;
  FNextButton.Flat := True;
  FNextButton.Caption := ThemedGridSearchStrings.NextText;
  FNextButton.Hint := ThemedGridSearchStrings.NextHint;
  FNextButton.ShowHint := True;
  FNextButton.OnClick := NextClick;

  FCloseButton := TSpeedButton.Create(Self);
  FCloseButton.Parent := Self;
  FCloseButton.Flat := True;
  FCloseButton.Caption := ThemedGridSearchStrings.CloseText;
  FCloseButton.Hint := ThemedGridSearchStrings.CloseHint;
  FCloseButton.ShowHint := True;
  FCloseButton.OnClick := CloseClick;

  FDebounceTimer := TTimer.Create(Self);
  FDebounceTimer.Enabled := False;
  FDebounceTimer.Interval := FDebounceInterval;
  FDebounceTimer.OnTimer := DebounceTick;
end;

function TThemedGridSearchPanel.ScaleValue(const AValue: Integer): Integer;
begin
  if HandleAllocated then
    Result := MulDiv(AValue, CurrentPPI, 96)
  else
    Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
end;

procedure TThemedGridSearchPanel.CreateWnd;
begin
  inherited CreateWnd;
  LayoutChildren;
end;

procedure TThemedGridSearchPanel.Resize;
begin
  inherited Resize;
  LayoutChildren;
end;

procedure TThemedGridSearchPanel.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  LayoutChildren;
end;

procedure TThemedGridSearchPanel.LayoutChildren;
var
  LPad, LButtonWidth, LCloseWidth, LLabelWidth, LRight, LHeight, LEditHeight: Integer;
begin
  if (FEdit = nil) or (FCloseButton = nil) or not HandleAllocated then
    Exit;
  LPad := ScaleValue(6);
  LButtonWidth := ScaleValue(32);
  LCloseWidth := ScaleValue(28);
  LLabelWidth := ScaleValue(90);
  LHeight := ClientHeight - 2 * ScaleValue(4);
  if LHeight < 1 then
    LHeight := 1;
  LRight := ClientWidth - LPad;
  FCloseButton.SetBounds(LRight - LCloseWidth, ScaleValue(4), LCloseWidth, LHeight);
  Dec(LRight, LCloseWidth);
  FNextButton.SetBounds(LRight - LButtonWidth, ScaleValue(4), LButtonWidth, LHeight);
  Dec(LRight, LButtonWidth);
  FPreviousButton.SetBounds(LRight - LButtonWidth, ScaleValue(4), LButtonWidth, LHeight);
  Dec(LRight, LButtonWidth);
  FResultLabel.SetBounds(LRight - LLabelWidth, ScaleValue(4), LLabelWidth, LHeight);
  Dec(LRight, LLabelWidth);
  LEditHeight := FEdit.Height;
  if LEditHeight > LHeight then
    LEditHeight := LHeight;
  FEdit.SetBounds(LPad, ScaleValue(4) + (LHeight - LEditHeight) div 2, LRight - LPad, LEditHeight);
end;

function TThemedGridSearchPanel.GetFindText: string;
begin
  Result := FEdit.Text;
end;

procedure TThemedGridSearchPanel.SetFindText(const AValue: string);
begin
  SetFindTextSilent(AValue, True);
end;

procedure TThemedGridSearchPanel.SetDebounceInterval(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then
    LValue := 0;
  if FDebounceInterval = LValue then
    Exit;
  FDebounceInterval := LValue;
  if FDebounceInterval = 0 then
    FDebounceTimer.Interval := 1
  else
    FDebounceTimer.Interval := FDebounceInterval;
end;

procedure TThemedGridSearchPanel.SetFindTextSilent(const AValue: string; const ASilent: Boolean);
var
  LOldUpdating: Boolean;
begin
  if FEdit.Text = AValue then
    Exit;
  LOldUpdating := FUpdating;
  try
    FUpdating := ASilent;
    FDebounceTimer.Enabled := False;
    FEdit.Text := AValue;
  finally
    FUpdating := LOldUpdating;
  end;
end;

procedure TThemedGridSearchPanel.CancelPendingSearch;
begin
  FDebounceTimer.Enabled := False;
end;

procedure TThemedGridSearchPanel.FlushPendingSearch;
begin
  if FUpdating then
    Exit;
  FDebounceTimer.Enabled := False;
  RaiseSearchTextChanged;
end;

procedure TThemedGridSearchPanel.FocusTextBox;
begin
  if FEdit.CanFocus then
  begin
    FEdit.SetFocus;
    FEdit.SelectAll;
  end;
end;

procedure TThemedGridSearchPanel.SetResultInfo(const AIndex, ACount: Integer);
begin
  if ACount <= 0 then
    FResultLabel.Caption := ThemedGridSearchStrings.EmptyResultText
  else
    FResultLabel.Caption := Format(ThemedGridSearchStrings.ResultFormat, [AIndex + 1, ACount]);
end;

procedure TThemedGridSearchPanel.ApplyButtonTheme(const AButton: TSpeedButton; const APalette: TThemePalette);
begin
  AButton.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
end;

procedure TThemedGridSearchPanel.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  Color := ThemeColorToColor(APalette.ControlBackColor);
  Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  FEdit.Color := ThemeColorToColor(APalette.ControlBackColor);
  FEdit.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  FResultLabel.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  ApplyButtonTheme(FPreviousButton, APalette);
  ApplyButtonTheme(FNextButton, APalette);
  ApplyButtonTheme(FCloseButton, APalette);
  Invalidate;
end;

procedure TThemedGridSearchPanel.EditChange(ASender: TObject);
begin
  if FUpdating then
    Exit;
  FDebounceTimer.Enabled := False;
  if FDebounceInterval <= 0 then
  begin
    RaiseSearchTextChanged;
    Exit;
  end;
  FDebounceTimer.Interval := FDebounceInterval;
  FDebounceTimer.Enabled := True;
end;

procedure TThemedGridSearchPanel.EditKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
begin
  if AKey = VK_RETURN then
  begin
    FlushPendingSearch;
    AKey := 0;
    Exit;
  end;
  if AKey = VK_ESCAPE then
  begin
    FDebounceTimer.Enabled := False;
    RaiseCloseClicked;
    AKey := 0;
  end;
end;

procedure TThemedGridSearchPanel.EditKeyPress(ASender: TObject; var AKey: Char);
begin
  if (AKey = #13) or (AKey = #27) then
    AKey := #0;
end;

procedure TThemedGridSearchPanel.DebounceTick(ASender: TObject);
begin
  FDebounceTimer.Enabled := False;
  RaiseSearchTextChanged;
end;

procedure TThemedGridSearchPanel.NextClick(ASender: TObject);
begin
  FlushPendingSearch;
  if Assigned(FOnNextClicked) then
    FOnNextClicked(Self);
end;

procedure TThemedGridSearchPanel.PreviousClick(ASender: TObject);
begin
  FlushPendingSearch;
  if Assigned(FOnPreviousClicked) then
    FOnPreviousClicked(Self);
end;

procedure TThemedGridSearchPanel.CloseClick(ASender: TObject);
begin
  FDebounceTimer.Enabled := False;
  RaiseCloseClicked;
end;

procedure TThemedGridSearchPanel.RaiseSearchTextChanged;
begin
  if Assigned(FOnSearchTextChanged) then
    FOnSearchTextChanged(Self);
end;

procedure TThemedGridSearchPanel.RaiseCloseClicked;
begin
  if Assigned(FOnCloseClicked) then
    FOnCloseClicked(Self);
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.StepIndicator;

interface

uses
  System.Classes, System.Types, Winapi.Messages, Vcl.Controls, NimbusForms.Controls.Base, NimbusForms.Controls.Types, NimbusForms.Rendering.StepIndicator;

type
  TCustomThemedStepIndicator = class;
  TThemedStepChangingEvent = procedure(Sender: TObject; AOldIndex, ANewIndex: Integer; var AAllow: Boolean) of object;
  TThemedStepIndexChangedEvent = procedure(Sender: TObject; AOldIndex, ANewIndex: Integer) of object;
  TThemedStepClickEvent = procedure(Sender: TObject; AIndex: Integer) of object;
  TThemedStepStatusChangedEvent = procedure(Sender: TObject; AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus) of object;
  TThemedStepItem = class(TCollectionItem)
  private
    FCaption: string;
    FStatus: TThemedStepStatus;
    FHint: string;
    procedure SetCaption(const AValue: string);
    procedure SetStatus(const AValue: TThemedStepStatus);
    procedure SetHint(const AValue: string);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Status: TThemedStepStatus read FStatus write SetStatus default tssAutomatic;
    property Hint: string read FHint write SetHint;
  end;
  TThemedStepItems = class(TOwnedCollection)
  protected
    procedure Update(Item: TCollectionItem); override;
  private
    function GetItem(AIndex: Integer): TThemedStepItem;
    procedure SetItem(AIndex: Integer; const AValue: TThemedStepItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedStepItem;
    function OwnerControl: TCustomThemedStepIndicator;
    property Items[AIndex: Integer]: TThemedStepItem read GetItem write SetItem; default;
  end;
  TCustomThemedStepIndicator = class(TCustomNimbusControl)
  private
    FSteps: TThemedStepItems;
    FCurrentStep: Integer;
    FDensity: TThemedStepDensity;
    FCircleSize: Integer;
    FLineThickness: Integer;
    FAllowNavigation: Boolean;
    FShowCaptions: Boolean;
    FOnStepChanged: TNotifyEvent;
    FOnStepChanging: TThemedStepChangingEvent;
    FOnStepIndexChanged: TThemedStepIndexChangedEvent;
    FOnStepClick: TThemedStepClickEvent;
    FOnStepStatusChanged: TThemedStepStatusChangedEvent;
    FReadOnly: Boolean;
    FAllowFutureNavigation: Boolean;
    FHighestReachedStep: Integer;
    procedure SetSteps(const AValue: TThemedStepItems);
    procedure SetCurrentStep(const AValue: Integer);
    procedure SetDensity(const AValue: TThemedStepDensity);
    procedure SetCircleSize(const AValue: Integer);
    procedure SetLineThickness(const AValue: Integer);
    procedure SetAllowNavigation(const AValue: Boolean);
    procedure SetShowCaptions(const AValue: Boolean);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetAllowFutureNavigation(const AValue: Boolean);
    procedure ChangeStep(const AValue: Integer; const AFromUser: Boolean);
    procedure NotifyStatusChanged(AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus);
    procedure NavigateTo(AIndex: Integer);
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    function StepAt(const X, Y: Integer): Integer;
    function EffectiveCircleSize: Integer;
    procedure StepsChanged;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoStepChanged; virtual;
    procedure DoStepChanging(AOldIndex, ANewIndex: Integer; var AAllow: Boolean); virtual;
    procedure DoStepIndexChanged(AOldIndex, ANewIndex: Integer); virtual;
    procedure DoStepClick(AIndex: Integer); virtual;
    procedure DoStepStatusChanged(AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus); virtual;
    property Steps: TThemedStepItems read FSteps write SetSteps;
    property CurrentStep: Integer read FCurrentStep write SetCurrentStep default 0;
    property Density: TThemedStepDensity read FDensity write SetDensity default tsdNormal;
    property CircleSize: Integer read FCircleSize write SetCircleSize default 24;
    property LineThickness: Integer read FLineThickness write SetLineThickness default 2;
    property AllowNavigation: Boolean read FAllowNavigation write SetAllowNavigation default True;
    property ShowCaptions: Boolean read FShowCaptions write SetShowCaptions default True;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property AllowFutureNavigation: Boolean read FAllowFutureNavigation write SetAllowFutureNavigation default True;
    property OnStepChanged: TNotifyEvent read FOnStepChanged write FOnStepChanged;
    property OnStepChanging: TThemedStepChangingEvent read FOnStepChanging write FOnStepChanging;
    property OnStepIndexChanged: TThemedStepIndexChangedEvent read FOnStepIndexChanged write FOnStepIndexChanged;
    property OnStepClick: TThemedStepClickEvent read FOnStepClick write FOnStepClick;
    property OnStepStatusChanged: TThemedStepStatusChangedEvent read FOnStepStatusChanged write FOnStepStatusChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure NextStep;
    procedure PreviousStep;
    procedure SetStepStatus(AIndex: Integer; AStatus: TThemedStepStatus);
  end;
  TThemedStepIndicator = class(TCustomThemedStepIndicator)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property Constraints;
    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Steps;
    property CurrentStep;
    property Density;
    property CircleSize;
    property LineThickness;
    property AllowNavigation;
    property ReadOnly;
    property AllowFutureNavigation;
    property ShowCaptions;
    property OnStepChanged;
    property OnStepChanging;
    property OnStepIndexChanged;
    property OnStepClick;
    property OnStepStatusChanged;
    property OnClick;
    property OnMouseDown;
    property OnKeyDown;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Math;

constructor TThemedStepItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FStatus := tssAutomatic;
end;

procedure TThemedStepItem.Assign(Source: TPersistent);
begin
  if Source is TThemedStepItem then
  begin
    Caption := TThemedStepItem(Source).Caption;
    Status := TThemedStepItem(Source).Status;
    Hint := TThemedStepItem(Source).Hint;
  end
  else inherited Assign(Source);
end;

procedure TThemedStepItem.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then begin FCaption := AValue; Changed(False); end;
end;

procedure TThemedStepItem.SetStatus(const AValue: TThemedStepStatus);
var LOldStatus: TThemedStepStatus;
begin
  if FStatus <> AValue then
  begin
    LOldStatus := FStatus;
    FStatus := AValue;
    Changed(False);
    if (Collection <> nil) and (Collection is TThemedStepItems) and (TThemedStepItems(Collection).OwnerControl <> nil) then
      TThemedStepItems(Collection).OwnerControl.NotifyStatusChanged(Index, LOldStatus, AValue);
  end;
end;

procedure TThemedStepItem.SetHint(const AValue: string);
begin
  if FHint <> AValue then begin FHint := AValue; Changed(False); end;
end;

constructor TThemedStepItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TThemedStepItem);
end;

function TThemedStepItems.OwnerControl: TCustomThemedStepIndicator;
begin
  Result := nil;
  if GetOwner is TCustomThemedStepIndicator then Result := TCustomThemedStepIndicator(GetOwner);
end;

procedure TThemedStepItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if GetOwner is TCustomThemedStepIndicator then TCustomThemedStepIndicator(GetOwner).StepsChanged;
end;

function TThemedStepItems.Add: TThemedStepItem;
begin
  Result := TThemedStepItem(inherited Add);
end;

function TThemedStepItems.GetItem(AIndex: Integer): TThemedStepItem;
begin
  Result := TThemedStepItem(inherited Items[AIndex]);
end;

procedure TThemedStepItems.SetItem(AIndex: Integer; const AValue: TThemedStepItem);
begin
  inherited Items[AIndex] := AValue;
end;

constructor TCustomThemedStepIndicator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSteps := TThemedStepItems.Create(Self);
  FCurrentStep := 0;
  FDensity := tsdNormal;
  FCircleSize := 24;
  FLineThickness := 2;
  FAllowNavigation := True;
  FAllowFutureNavigation := True;
  FHighestReachedStep := 0;
  FShowCaptions := True;
  Width := 390;
  Height := 76;
  TabStop := True;
  FSteps.Add.Caption := 'Start';
  FSteps.Add.Caption := 'Configure';
  FSteps.Add.Caption := 'Finish';
end;

destructor TCustomThemedStepIndicator.Destroy;
begin
  FSteps.Free;
  inherited Destroy;
end;

procedure TCustomThemedStepIndicator.StepsChanged;
begin
  if FSteps.Count = 0 then FCurrentStep := -1
  else if FCurrentStep < 0 then FCurrentStep := 0
  else if FCurrentStep >= FSteps.Count then FCurrentStep := FSteps.Count - 1;
  if FHighestReachedStep >= FSteps.Count then FHighestReachedStep := FSteps.Count - 1;
  if FHighestReachedStep < FCurrentStep then FHighestReachedStep := FCurrentStep;
  Invalidate;
end;

procedure TCustomThemedStepIndicator.SetSteps(const AValue: TThemedStepItems);
begin
  if AValue <> nil then begin FSteps.Assign(AValue); StepsChanged; end;
end;

procedure TCustomThemedStepIndicator.SetCurrentStep(const AValue: Integer);
begin
  ChangeStep(AValue, False);
end;

procedure TCustomThemedStepIndicator.ChangeStep(const AValue: Integer; const AFromUser: Boolean);
var
  LValue, LOld: Integer;
  LAllow: Boolean;
begin
  if FSteps.Count = 0 then LValue := -1
  else LValue := EnsureRange(AValue, 0, FSteps.Count - 1);
  if LValue = FCurrentStep then Exit;
  if AFromUser then
  begin
    if not Enabled or FReadOnly or not FAllowNavigation then Exit;
    if not FAllowFutureNavigation and (LValue > FHighestReachedStep) then Exit;
  end;
  LOld := FCurrentStep;
  LAllow := True;
  DoStepChanging(LOld, LValue, LAllow);
  if not LAllow or (csDestroying in ComponentState) then Exit;
  if FSteps.Count = 0 then LValue := -1
  else if LValue >= FSteps.Count then Exit;
  FCurrentStep := LValue;
  if FCurrentStep > FHighestReachedStep then FHighestReachedStep := FCurrentStep;
  Invalidate;
  DoStepChanged;
  DoStepIndexChanged(LOld, LValue);
end;

procedure TCustomThemedStepIndicator.NavigateTo(AIndex: Integer);
begin
  ChangeStep(AIndex, True);
end;

procedure TCustomThemedStepIndicator.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly <> AValue then begin FReadOnly := AValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.SetAllowFutureNavigation(const AValue: Boolean);
begin
  if FAllowFutureNavigation <> AValue then begin FAllowFutureNavigation := AValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.SetStepStatus(AIndex: Integer; AStatus: TThemedStepStatus);
begin
  if (AIndex < 0) or (AIndex >= FSteps.Count) then raise EArgumentOutOfRangeException.Create('Step index out of range');
  FSteps[AIndex].Status := AStatus;
end;

procedure TCustomThemedStepIndicator.NotifyStatusChanged(AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus);
begin
  DoStepStatusChanged(AIndex, AOldStatus, ANewStatus);
end;

procedure TCustomThemedStepIndicator.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(76, 58);
end;

procedure TCustomThemedStepIndicator.SetDensity(const AValue: TThemedStepDensity);
begin
  if FDensity <> AValue then begin FDensity := AValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.SetCircleSize(const AValue: Integer);
var LValue: Integer;
begin
  LValue := EnsureRange(AValue, 8, 80);
  if FCircleSize <> LValue then begin FCircleSize := LValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.SetLineThickness(const AValue: Integer);
var LValue: Integer;
begin
  LValue := EnsureRange(AValue, 1, 10);
  if FLineThickness <> LValue then begin FLineThickness := LValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.SetAllowNavigation(const AValue: Boolean);
begin
  if FAllowNavigation <> AValue then begin FAllowNavigation := AValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.SetShowCaptions(const AValue: Boolean);
begin
  if FShowCaptions <> AValue then begin FShowCaptions := AValue; Invalidate; end;
end;

procedure TCustomThemedStepIndicator.DoStepChanging(AOldIndex, ANewIndex: Integer; var AAllow: Boolean);
begin
  if Assigned(FOnStepChanging) then FOnStepChanging(Self, AOldIndex, ANewIndex, AAllow);
end;

procedure TCustomThemedStepIndicator.DoStepIndexChanged(AOldIndex, ANewIndex: Integer);
begin
  if Assigned(FOnStepIndexChanged) then FOnStepIndexChanged(Self, AOldIndex, ANewIndex);
end;

procedure TCustomThemedStepIndicator.DoStepClick(AIndex: Integer);
begin
  if Assigned(FOnStepClick) then FOnStepClick(Self, AIndex);
end;

procedure TCustomThemedStepIndicator.DoStepStatusChanged(AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus);
begin
  if Assigned(FOnStepStatusChanged) then FOnStepStatusChanged(Self, AIndex, AOldStatus, ANewStatus);
end;

procedure TCustomThemedStepIndicator.DoStepChanged;
begin
  if Assigned(FOnStepChanged) then FOnStepChanged(Self);
end;

function TCustomThemedStepIndicator.EffectiveCircleSize: Integer;
var LSize: Integer; LDensity: TThemedStepDensity;
begin
  LDensity := FDensity;
  if (StyleMode = stCompact) and (LDensity = tsdNormal) then LDensity := tsdCompact;
  case LDensity of
    tsdCompact: LSize := MulDiv(FCircleSize, 3, 4);
    tsdUltraCompact: LSize := MulDiv(FCircleSize, 1, 2);
  else
    LSize := FCircleSize;
  end;
  Result := Max(6, ScaleValue(LSize));
end;

function TCustomThemedStepIndicator.StepAt(const X, Y: Integer): Integer;
var I, LCount, LPad, LCenterY, LCenterX, LRadius, LDistance, LBest: Integer;
begin
  Result := -1;
  LCount := FSteps.Count;
  if LCount = 0 then Exit;
  LRadius := EffectiveCircleSize div 2;
  LPad := Max(LRadius + 3, ScaleValue(12));
  LCenterY := Max(LRadius + 3, ScaleValue(7) + LRadius);
  LBest := MaxInt;
  for I := 0 to LCount - 1 do
  begin
    if LCount = 1 then LCenterX := Width div 2
    else LCenterX := LPad + MulDiv(Max(0, Width - LPad * 2), I, LCount - 1);
    LDistance := Abs(X - LCenterX) + Abs(Y - LCenterY);
    if (LDistance < LBest) and (Abs(Y - LCenterY) <= Max(LRadius + ScaleValue(10), ScaleValue(18))) then
    begin
      LBest := LDistance;
      Result := I;
    end;
  end;
  if LBest > Max(ScaleValue(25), Width div Max(1, LCount * 2)) then Result := -1;
end;

procedure TCustomThemedStepIndicator.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var LIndex: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  LIndex := StepAt(X, Y);
  if LIndex >= 0 then
  begin
    DoStepClick(LIndex);
    if csDestroying in ComponentState then Exit;
    if FReadOnly or not FAllowNavigation then Exit;
    if CanFocus then SetFocus;
    NavigateTo(LIndex);
  end;
end;

procedure TCustomThemedStepIndicator.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled or FReadOnly or not FAllowNavigation or (FSteps.Count = 0) then Exit;
  case Key of
    VK_LEFT: begin NavigateTo(FCurrentStep - 1); Key := 0; end;
    VK_RIGHT: begin NavigateTo(FCurrentStep + 1); Key := 0; end;
    VK_HOME: begin NavigateTo(0); Key := 0; end;
    VK_END: begin NavigateTo(FSteps.Count - 1); Key := 0; end;
  end;
end;

procedure TCustomThemedStepIndicator.CMDialogKey(var Message: TCMDialogKey);
begin
  if Focused and (Message.CharCode in [VK_LEFT, VK_RIGHT, VK_HOME, VK_END]) and FAllowNavigation and not FReadOnly and Enabled and (FSteps.Count > 0) then
  begin
    case Message.CharCode of
      VK_LEFT: NavigateTo(FCurrentStep - 1);
      VK_RIGHT: NavigateTo(FCurrentStep + 1);
      VK_HOME: NavigateTo(0);
      VK_END: NavigateTo(FSteps.Count - 1);
    end;
    Message.Result := 1;
  end
  else inherited;
end;

procedure TCustomThemedStepIndicator.NextStep;
begin
  ChangeStep(FCurrentStep + 1, False);
end;

procedure TCustomThemedStepIndicator.PreviousStep;
begin
  ChangeStep(FCurrentStep - 1, False);
end;

procedure TCustomThemedStepIndicator.Paint;
var LContext: TThemedStepRenderContext; I: Integer;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Palette := Palette;
    LContext.Font := Font;
    LContext.CurrentStep := FCurrentStep;
    LContext.CircleSize := EffectiveCircleSize;
    LContext.LineThickness := Max(1, ScaleValue(FLineThickness));
    LContext.Density := FDensity;
    if (StyleMode = stCompact) and (FDensity = tsdNormal) then LContext.Density := tsdCompact;
    LContext.Enabled := Enabled;
    LContext.ShowCaptions := FShowCaptions;
    LContext.Focused := Focused;
    SetLength(LContext.Items, FSteps.Count);
    for I := 0 to FSteps.Count - 1 do
    begin
      LContext.Items[I].Caption := FSteps[I].Caption;
      LContext.Items[I].Status := FSteps[I].Status;
    end;
    TThemedStepIndicatorRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

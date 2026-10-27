unit NimbusForms.Controls.FinancialSettings;

interface

uses System.Classes, Vcl.Controls, NimbusForms.Charts.Financial.Business.Types, NimbusForms.Theming.Palette;

function EditNimbusFinancialPanel(Owner: TComponent; Panel: TNimbusFinancialPanel;
  Options: TNimbusFinancialBusinessOptions; Palette: TThemePalette): Boolean;

implementation

uses System.SysUtils, System.Math, System.UITypes, System.Types, Winapi.Windows, NimbusForms.Theming.Types, Vcl.Forms, Vcl.Graphics,
  NimbusForms.Controls.Panel, NimbusForms.Controls.ThemedLabel, NimbusForms.Controls.TextBox,
  NimbusForms.Controls.ComboBox, NimbusForms.Controls.CheckBox, NimbusForms.Controls.Button,
  NimbusForms.Charts.Financial.Indicators, NimbusForms.Theming.Manager, NimbusForms.Rendering.Types,
  NimbusForms.Controls.VScrollBar;

resourcestring
  SSettingsTitle = 'Financial panel settings';
  SPanelTitle = 'Panel title';
  SPanelScale = 'Scale mode';
  SPanelMinimum = 'Minimum';
  SPanelMaximum = 'Maximum';
  SPanelWeight = 'Height weight';
  SIndicator = 'Indicator';
  SEnabled = 'Enabled';
  SSession = 'Reset per session';
  SVolumeAverage = 'Volume SMA';
  SPeriods = 'Periods';
  SFast = 'Fast period';
  SSlow = 'Slow period';
  SSignal = 'Signal / D period';
  SSmooth = 'Smooth K period';
  SDeviation = 'Bollinger deviation';
  SOversold = 'Oversold level';
  SOverbought = 'Overbought level';
  SApply = 'Apply';
  SCancel = 'Cancel';
  SInvalid = 'Check the periods, ranges and numeric values.';

type
  TNimbusFinancialSettingsForm = class(TForm)
  private
    FPanel: TNimbusFinancialPanel;
    FOptions: TNimbusFinancialBusinessOptions;
    FTitle, FMinimum, FMaximum, FWeight, FPeriods, FFast, FSlow, FSignal, FSmooth, FDeviation, FOversold, FOverbought: TThemedTextBox;
    FScale, FKind: TThemedComboBox;
    FEnabled, FExtra: TThemedCheckBox;
    FError: TThemedLabel;
    FViewport, FContent: TThemedPanel;
    FScroll: TThemedVScrollBar;
    FCurrentKind: Integer;
    FBusy: Boolean;
    function StoreIndicator: Boolean;
    procedure LoadIndicator;
    procedure KindChanged(Sender: TObject);
    procedure Accept(Sender: TObject);
    procedure ScrollSettings(Sender: TObject);
  protected
    procedure Resize; override;
    procedure DoShow; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor CreateForPanel(Owner: TComponent; Panel: TNimbusFinancialPanel; Options: TNimbusFinancialBusinessOptions);
    destructor Destroy; override;
  end;

constructor TNimbusFinancialSettingsForm.CreateForPanel(Owner: TComponent; Panel: TNimbusFinancialPanel; Options: TNimbusFinancialBusinessOptions);
var Surface: TThemedPanel; LabelControl: TThemedLabel; Button: TThemedButton; Row: Integer;
  function Field(const Caption: string): TThemedTextBox;
  begin
    LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Surface; LabelControl.SetBounds(14, Row, 180, 26); LabelControl.Caption := Caption;
    Result := TThemedTextBox.Create(Self); Result.Parent := Surface; Result.SetBounds(206, Row, 290, 28); Inc(Row, 34);
  end;
begin
  inherited CreateNew(Owner); PixelsPerInch := 96; Caption := SSettingsTitle; Position := poOwnerFormCenter;
  BorderStyle := bsDialog; ClientWidth := 536; ClientHeight := 650;
  FPanel := TNimbusFinancialPanel.Create(nil); FPanel.Assign(Panel); FOptions := TNimbusFinancialBusinessOptions.Create; FOptions.Assign(Options);
  FScroll := TThemedVScrollBar.Create(Self); FScroll.Parent := Self; FScroll.Align := alRight; FScroll.Width := 18; FScroll.OnValueChanged := ScrollSettings;
  FViewport := TThemedPanel.Create(Self); FViewport.Parent := Self; FViewport.Align := alClient; FViewport.ShowBorder := False;
  Surface := TThemedPanel.Create(Self); Surface.Parent := FViewport; Surface.ShowBorder := False; FContent := Surface;
  Row := 12; FTitle := Field(SPanelTitle); FTitle.Text := FPanel.Title;
  FScale := TThemedComboBox.Create(Self); FScale.Parent := Surface; FScale.SetBounds(206, Row, 290, 28);
  LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Surface; LabelControl.SetBounds(14, Row, 180, 26); LabelControl.Caption := SPanelScale;
  FScale.Items.Add('Auto'); FScale.Items.Add('Manual'); FScale.Items.Add('Fixed'); FScale.Items.Add('Percent'); FScale.Items.Add('Logarithmic'); FScale.Items.Add('Shared price scale');
  FScale.ItemIndex := Ord(FPanel.ScaleMode); Inc(Row, 34);
  FMinimum := Field(SPanelMinimum); FMinimum.Text := FloatToStr(FPanel.ManualMinimumValue);
  FMaximum := Field(SPanelMaximum); FMaximum.Text := FloatToStr(FPanel.ManualMaximumValue);
  if FPanel.ScaleMode = nfsmFixed then begin FMinimum.Text := FloatToStr(FPanel.FixedMinimumValue); FMaximum.Text := FloatToStr(FPanel.FixedMaximumValue) end;
  FWeight := Field(SPanelWeight); FWeight.Text := FloatToStr(FPanel.HeightWeight);
  FKind := TThemedComboBox.Create(Self); FKind.Parent := Surface; FKind.SetBounds(206, Row, 290, 28);
  LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Surface; LabelControl.SetBounds(14, Row, 180, 26); LabelControl.Caption := SIndicator;
  FKind.Items.Add('SMA'); FKind.Items.Add('EMA'); FKind.Items.Add('Bollinger'); FKind.Items.Add('RSI'); FKind.Items.Add('MACD'); FKind.Items.Add('Stochastic'); FKind.Items.Add('ATR'); FKind.Items.Add('VWAP');
  FKind.Items.Add('Volume');
  FCurrentKind := 0;
  if SameText(Panel.Key, 'rsi') then FCurrentKind := 3 else if SameText(Panel.Key, 'macd') then FCurrentKind := 4
  else if SameText(Panel.Key, 'stochastic') then FCurrentKind := 5 else if SameText(Panel.Key, 'atr') then FCurrentKind := 6
  else if SameText(Panel.Key, 'volume') then FCurrentKind := 8;
  FKind.ItemIndex := FCurrentKind; Inc(Row, 34);
  FEnabled := TThemedCheckBox.Create(Self); FEnabled.Parent := Surface; FEnabled.SetBounds(206, Row, 118, 28); FEnabled.Caption := SEnabled;
  FExtra := TThemedCheckBox.Create(Self); FExtra.Parent := Surface; FExtra.SetBounds(330, Row, 166, 28); Inc(Row, 34);
  FPeriods := Field(SPeriods); FFast := Field(SFast); FSlow := Field(SSlow); FSignal := Field(SSignal); FSmooth := Field(SSmooth);
  FDeviation := Field(SDeviation); FOversold := Field(SOversold); FOverbought := Field(SOverbought);
  ClientHeight := Row + 80;
  FError := TThemedLabel.Create(Self); FError.Parent := Surface; FError.SetBounds(14, Row, 480, 26); Inc(Row, 30);
  Button := TThemedButton.Create(Self); Button.Parent := Surface; Button.SetBounds(240, Row, 120, 30); Button.Caption := SApply; Button.Default := True; Button.OnClick := Accept;
  Button := TThemedButton.Create(Self); Button.Parent := Surface; Button.SetBounds(374, Row, 120, 30); Button.Caption := SCancel; Button.Cancel := True; Button.ModalResult := mrCancel;
  Surface.SetBounds(0, 0, 516, Row + 48);
  LoadIndicator; FKind.OnChange := KindChanged; ThemeManager.ApplyCurrent(Self); Resize;
end;

procedure TNimbusFinancialSettingsForm.ScrollSettings(Sender: TObject);
begin if FContent <> nil then FContent.Top := -FScroll.Value end;

procedure TNimbusFinancialSettingsForm.Resize;
begin
  inherited;
  if (FContent = nil) or (FViewport = nil) or (FScroll = nil) then Exit;
  FScroll.Visible := FContent.Height > FViewport.ClientHeight;
  FScroll.Minimum := 0; FScroll.Maximum := Max(0, FContent.Height - 1);
  FScroll.LargeChange := Max(1, FViewport.ClientHeight); FScroll.SmallChange := MulDiv(24, CurrentPPI, 96);
  FContent.Width := FViewport.ClientWidth; ScrollSettings(Self);
end;

procedure TNimbusFinancialSettingsForm.DoShow;
begin
  inherited;
  ClientHeight := Min(ClientHeight, Max(MulDiv(180, CurrentPPI, 96), Screen.WorkAreaRect.Height - MulDiv(100, CurrentPPI, 96)));
  Resize;
end;

function TNimbusFinancialSettingsForm.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := FScroll.Visible;
  if Result then FScroll.Value := FScroll.Value - Round(WheelDelta / 120 * MulDiv(72, CurrentPPI, 96))
  else Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

destructor TNimbusFinancialSettingsForm.Destroy;
begin FOptions.Free; FPanel.Free; inherited end;

procedure TNimbusFinancialSettingsForm.LoadIndicator;
begin
  FBusy := True;
  try
    FPeriods.Enabled := FCurrentKind in [0, 1, 2, 3, 5, 6, 8]; FFast.Enabled := FCurrentKind = 4; FSlow.Enabled := FCurrentKind = 4;
    FExtra.Visible := FCurrentKind in [7, 8];
    if FCurrentKind = 7 then begin FExtra.Caption := SSession; FExtra.Checked := FOptions.VwapResetBySession end
    else begin FExtra.Caption := SVolumeAverage; FExtra.Checked := FOptions.ShowVolumeMovingAverage end;
    FSignal.Enabled := FCurrentKind in [4, 5]; FSmooth.Enabled := FCurrentKind = 5;
    FDeviation.Enabled := FCurrentKind = 2; FOversold.Enabled := FCurrentKind in [3, 5]; FOverbought.Enabled := FOversold.Enabled;
    FFast.Text := IntToStr(FOptions.MacdFastPeriod); FSlow.Text := IntToStr(FOptions.MacdSlowPeriod); FSignal.Text := IntToStr(FOptions.MacdSignalPeriod);
    FSmooth.Text := IntToStr(FOptions.StochasticSmoothKPeriod); FDeviation.Text := FloatToStr(FOptions.BollingerBandStandardDeviation);
    FOversold.Text := FloatToStr(FOptions.RsiOversoldLevel); FOverbought.Text := FloatToStr(FOptions.RsiOverboughtLevel);
    case FCurrentKind of
      0: begin FPeriods.Text := FOptions.SimpleMovingAveragePeriods; FEnabled.Checked := FOptions.ShowSimpleMovingAverage end;
      1: begin FPeriods.Text := FOptions.ExponentialMovingAveragePeriods; FEnabled.Checked := FOptions.ShowExponentialMovingAverage end;
      2: begin FPeriods.Text := FOptions.BollingerBandPeriods; FEnabled.Checked := FOptions.ShowBollingerBands end;
      3: begin FPeriods.Text := FOptions.RsiPeriods; FEnabled.Checked := FOptions.ShowRsi end;
      4: FEnabled.Checked := FOptions.ShowMacd;
      5: begin FPeriods.Text := IntToStr(FOptions.StochasticPeriod); FSignal.Text := IntToStr(FOptions.StochasticDPeriod); FOversold.Text := FloatToStr(FOptions.StochasticOversoldLevel); FOverbought.Text := FloatToStr(FOptions.StochasticOverboughtLevel); FEnabled.Checked := FOptions.ShowStochastic end;
      6: begin FPeriods.Text := FOptions.AtrPeriods; FEnabled.Checked := FOptions.ShowAtr end;
      7: FEnabled.Checked := FOptions.ShowVwap;
      8: begin FPeriods.Text := IntToStr(FOptions.VolumeMovingAveragePeriod); FEnabled.Checked := FOptions.ShowVolume end;
    end;
  finally FBusy := False end;
end;

function TNimbusFinancialSettingsForm.StoreIndicator: Boolean;
var Fast, Slow, Signal, Smooth, Period: Integer; Deviation, Oversold, Overbought: Double;
begin
  Result := False;
  if FPeriods.Enabled and (Length(TNimbusFinancialIndicators.NormalizePeriods(FPeriods.Text)) = 0) then Exit;
  if not TryStrToInt(FFast.Text, Fast) or not TryStrToInt(FSlow.Text, Slow) or not TryStrToInt(FSignal.Text, Signal) or not TryStrToInt(FSmooth.Text, Smooth) then Exit;
  if not TryStrToFloat(FDeviation.Text, Deviation) or not TryStrToFloat(FOversold.Text, Oversold) or not TryStrToFloat(FOverbought.Text, Overbought) then Exit;
  if ((FCurrentKind = 4) and ((Fast < 2) or (Slow <= Fast) or (Signal < 2))) or (Signal < 1) or (Smooth < 1) or (Deviation <= 0) or
    IsNan(Deviation) or IsInfinite(Deviation) or IsNan(Oversold) or IsInfinite(Oversold) or IsNan(Overbought) or IsInfinite(Overbought) or
    (Oversold < 0) or (Overbought > 100) or (Oversold >= Overbought) then Exit;
  case FCurrentKind of
    0: begin FOptions.SimpleMovingAveragePeriods := FPeriods.Text; FOptions.ShowSimpleMovingAverage := FEnabled.Checked end;
    1: begin FOptions.ExponentialMovingAveragePeriods := FPeriods.Text; FOptions.ShowExponentialMovingAverage := FEnabled.Checked end;
    2: begin FOptions.BollingerBandPeriods := FPeriods.Text; FOptions.BollingerBandStandardDeviation := Deviation; FOptions.ShowBollingerBands := FEnabled.Checked end;
    3: begin FOptions.RsiPeriods := FPeriods.Text; FOptions.RsiOversoldLevel := Oversold; FOptions.RsiOverboughtLevel := Overbought; FOptions.ShowRsi := FEnabled.Checked end;
    4: begin FOptions.MacdFastPeriod := Fast; FOptions.MacdSlowPeriod := Slow; FOptions.MacdSignalPeriod := Signal; FOptions.ShowMacd := FEnabled.Checked end;
    5: begin if not TryStrToInt(FPeriods.Text, Period) or (Period < 2) then Exit; FOptions.StochasticPeriod := Period; FOptions.StochasticSmoothKPeriod := Smooth; FOptions.StochasticDPeriod := Signal; FOptions.StochasticOversoldLevel := Oversold; FOptions.StochasticOverboughtLevel := Overbought; FOptions.ShowStochastic := FEnabled.Checked end;
    6: begin FOptions.AtrPeriods := FPeriods.Text; FOptions.ShowAtr := FEnabled.Checked end;
    7: begin FOptions.ShowVwap := FEnabled.Checked; FOptions.VwapResetBySession := FExtra.Checked end;
    8: begin if not TryStrToInt(FPeriods.Text, Period) or (Period < 2) then Exit; FOptions.VolumeMovingAveragePeriod := Period; FOptions.ShowVolume := FEnabled.Checked; FOptions.ShowVolumeMovingAverage := FExtra.Checked end;
  end;
  Result := True;
end;

procedure TNimbusFinancialSettingsForm.KindChanged(Sender: TObject);
begin
  if FBusy then Exit;
  if not StoreIndicator then begin FBusy := True; try FKind.ItemIndex := FCurrentKind finally FBusy := False end; FError.Caption := SInvalid; Exit end;
  FCurrentKind := FKind.ItemIndex; FError.Caption := ''; LoadIndicator;
end;

procedure TNimbusFinancialSettingsForm.Accept(Sender: TObject);
var Minimum, Maximum, Weight: Double;
begin
  if not TryStrToFloat(FMinimum.Text, Minimum) or not TryStrToFloat(FMaximum.Text, Maximum) or not TryStrToFloat(FWeight.Text, Weight) then begin FError.Caption := SInvalid; Exit end;
  if IsNan(Minimum) or IsInfinite(Minimum) or IsNan(Maximum) or IsInfinite(Maximum) or IsNan(Weight) or IsInfinite(Weight) or (Maximum <= Minimum) or (Weight <= 0) or not StoreIndicator then begin FError.Caption := SInvalid; Exit end;
  FPanel.Title := FTitle.Text; FPanel.ScaleMode := TNimbusFinancialScaleMode(FScale.ItemIndex);
  FPanel.ManualMinimumValue := Minimum; FPanel.ManualMaximumValue := Maximum; FPanel.FixedMinimumValue := Minimum;
  FPanel.FixedMaximumValue := Maximum; FPanel.HeightWeight := Weight; ModalResult := mrOk;
end;

function EditNimbusFinancialPanel(Owner: TComponent; Panel: TNimbusFinancialPanel;
  Options: TNimbusFinancialBusinessOptions; Palette: TThemePalette): Boolean;
var Dialog: TNimbusFinancialSettingsForm;
begin
  Dialog := TNimbusFinancialSettingsForm.CreateForPanel(Owner, Panel, Options);
  try
    if Palette <> nil then Dialog.Color := ThemeColorToColor(NimbusControlBackColor(Palette));
    Result := Dialog.ShowModal = mrOk;
    if Result then begin Panel.Assign(Dialog.FPanel); Options.Assign(Dialog.FOptions) end;
  finally Dialog.Free end;
end;

end.

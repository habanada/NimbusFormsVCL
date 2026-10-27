{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Financial.Types;

interface

uses System.Classes, System.SysUtils, System.Math, Vcl.Graphics;

type
  TNimbusFinancialPriceDisplayMode = (nfpCandlestick, nfpOhlc);
  TNimbusFinancialVolumeDisplayMode = (nfvNone, nfvBars, nfvBubbles);
  TNimbusFinancialDataPoint = class(TCollectionItem)
  private
    FXValue: Double;
    FOpen: Double;
    FHigh: Double;
    FLow: Double;
    FClose: Double;
    FVolume: Double;
    FLabel: string;
    FToolTipText: string;
    FEventText: string;
    FEventColor: TColor;
    FEventSize: Double;
    FVisible: Boolean;
    FTag: NativeInt;
    procedure SetXValue(const Value: Double);
    procedure SetOpen(const Value: Double);
    procedure SetHigh(const Value: Double);
    procedure SetLow(const Value: Double);
    procedure SetClose(const Value: Double);
    procedure SetVolume(const Value: Double);
    procedure SetLabel(const Value: string);
    procedure SetToolTipText(const Value: string);
    procedure SetEventText(const Value: string);
    procedure SetEventColor(const Value: TColor);
    procedure SetEventSize(const Value: Double);
    procedure SetVisible(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
    function GetIsValid: Boolean;
    function GetTime: TDateTime;
    procedure SetTime(const Value: TDateTime);
    function GetTypicalPrice: Double;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property IsValid: Boolean read GetIsValid;
    property TypicalPrice: Double read GetTypicalPrice;
  published
    property XValue: Double read FXValue write SetXValue;
    property Time: TDateTime read GetTime write SetTime;
    property Open: Double read FOpen write SetOpen;
    property High: Double read FHigh write SetHigh;
    property Low: Double read FLow write SetLow;
    property Close: Double read FClose write SetClose;
    property Volume: Double read FVolume write SetVolume;
    property &Label: string read FLabel write SetLabel;
    property ToolTipText: string read FToolTipText write SetToolTipText;
    property EventText: string read FEventText write SetEventText;
    property EventColor: TColor read FEventColor write SetEventColor;
    property EventSize: Double read FEventSize write SetEventSize;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusFinancialDataPointCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialDataPoint;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialDataPoint; overload;
    function Add(const XValue, Open, High, Low, Close, Volume: Double): TNimbusFinancialDataPoint; overload;
    property Items[Index: Integer]: TNimbusFinancialDataPoint read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialChartOptions = class(TPersistent)
  private
    FPriceDisplayMode: TNimbusFinancialPriceDisplayMode;
    FVolumeDisplayMode: TNimbusFinancialVolumeDisplayMode;
    FShowVolumePanel: Boolean;
    FShowSimpleMovingAverage: Boolean;
    FShowExponentialMovingAverage: Boolean;
    FShowBollingerBands: Boolean;
    FShowLastPriceLine: Boolean;
    FShowEventMarkers: Boolean;
    FShowPriceChange: Boolean;
    FSimpleMovingAveragePeriod: Integer;
    FExponentialMovingAveragePeriod: Integer;
    FBollingerPeriod: Integer;
    FBollingerDeviation: Double;
    FVolumePanelRatio: Single;
    FRisingColor: TColor;
    FFallingColor: TColor;
    FNeutralColor: TColor;
    FSimpleMovingAverageColor: TColor;
    FExponentialMovingAverageColor: TColor;
    FBollingerBandColor: TColor;
    FShowMacdPanel: Boolean;
    FShowRsiPanel: Boolean;
    FShowStochasticPanel: Boolean;
    FMacdFastPeriod: Integer;
    FMacdSlowPeriod: Integer;
    FMacdSignalPeriod: Integer;
    FRsiPeriod: Integer;
    FStochasticPeriod: Integer;
    FStochasticSignalPeriod: Integer;
    FIndicatorPanelRatio: Single;
    FMacdColor: TColor;
    FMacdSignalColor: TColor;
    FRsiColor: TColor;
    FStochasticKColor: TColor;
    FStochasticDColor: TColor;
    FOnChange: TNotifyEvent;
    procedure SetPriceDisplayMode(const Value: TNimbusFinancialPriceDisplayMode);
    procedure SetVolumeDisplayMode(const Value: TNimbusFinancialVolumeDisplayMode);
    procedure SetShowVolumePanel(const Value: Boolean);
    procedure SetShowSimpleMovingAverage(const Value: Boolean);
    procedure SetShowExponentialMovingAverage(const Value: Boolean);
    procedure SetShowBollingerBands(const Value: Boolean);
    procedure SetShowLastPriceLine(const Value: Boolean);
    procedure SetShowEventMarkers(const Value: Boolean);
    procedure SetShowPriceChange(const Value: Boolean);
    procedure SetSimpleMovingAveragePeriod(const Value: Integer);
    procedure SetExponentialMovingAveragePeriod(const Value: Integer);
    procedure SetBollingerPeriod(const Value: Integer);
    procedure SetBollingerDeviation(const Value: Double);
    procedure SetVolumePanelRatio(const Value: Single);
    procedure SetRisingColor(const Value: TColor);
    procedure SetFallingColor(const Value: TColor);
    procedure SetNeutralColor(const Value: TColor);
    procedure SetSimpleMovingAverageColor(const Value: TColor);
    procedure SetExponentialMovingAverageColor(const Value: TColor);
    procedure SetBollingerBandColor(const Value: TColor);
    procedure SetShowMacdPanel(const Value: Boolean);
    procedure SetShowRsiPanel(const Value: Boolean);
    procedure SetShowStochasticPanel(const Value: Boolean);
    procedure SetMacdFastPeriod(const Value: Integer);
    procedure SetMacdSlowPeriod(const Value: Integer);
    procedure SetMacdSignalPeriod(const Value: Integer);
    procedure SetRsiPeriod(const Value: Integer);
    procedure SetStochasticPeriod(const Value: Integer);
    procedure SetStochasticSignalPeriod(const Value: Integer);
    procedure SetIndicatorPanelRatio(const Value: Single);
    procedure SetMacdColor(const Value: TColor);
    procedure SetMacdSignalColor(const Value: TColor);
    procedure SetRsiColor(const Value: TColor);
    procedure SetStochasticKColor(const Value: TColor);
    procedure SetStochasticDColor(const Value: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property PriceDisplayMode: TNimbusFinancialPriceDisplayMode read FPriceDisplayMode write SetPriceDisplayMode;
    property VolumeDisplayMode: TNimbusFinancialVolumeDisplayMode read FVolumeDisplayMode write SetVolumeDisplayMode;
    property ShowVolumePanel: Boolean read FShowVolumePanel write SetShowVolumePanel;
    property ShowSimpleMovingAverage: Boolean read FShowSimpleMovingAverage write SetShowSimpleMovingAverage;
    property ShowExponentialMovingAverage: Boolean read FShowExponentialMovingAverage write SetShowExponentialMovingAverage;
    property ShowBollingerBands: Boolean read FShowBollingerBands write SetShowBollingerBands;
    property ShowLastPriceLine: Boolean read FShowLastPriceLine write SetShowLastPriceLine;
    property ShowEventMarkers: Boolean read FShowEventMarkers write SetShowEventMarkers;
    property ShowPriceChange: Boolean read FShowPriceChange write SetShowPriceChange;
    property SimpleMovingAveragePeriod: Integer read FSimpleMovingAveragePeriod write SetSimpleMovingAveragePeriod;
    property ExponentialMovingAveragePeriod: Integer read FExponentialMovingAveragePeriod write SetExponentialMovingAveragePeriod;
    property BollingerPeriod: Integer read FBollingerPeriod write SetBollingerPeriod;
    property BollingerDeviation: Double read FBollingerDeviation write SetBollingerDeviation;
    property VolumePanelRatio: Single read FVolumePanelRatio write SetVolumePanelRatio;
    property RisingColor: TColor read FRisingColor write SetRisingColor;
    property FallingColor: TColor read FFallingColor write SetFallingColor;
    property NeutralColor: TColor read FNeutralColor write SetNeutralColor;
    property SimpleMovingAverageColor: TColor read FSimpleMovingAverageColor write SetSimpleMovingAverageColor;
    property ExponentialMovingAverageColor: TColor read FExponentialMovingAverageColor write SetExponentialMovingAverageColor;
    property BollingerBandColor: TColor read FBollingerBandColor write SetBollingerBandColor;
    property ShowMacdPanel: Boolean read FShowMacdPanel write SetShowMacdPanel;
    property ShowRsiPanel: Boolean read FShowRsiPanel write SetShowRsiPanel;
    property ShowStochasticPanel: Boolean read FShowStochasticPanel write SetShowStochasticPanel;
    property MacdFastPeriod: Integer read FMacdFastPeriod write SetMacdFastPeriod;
    property MacdSlowPeriod: Integer read FMacdSlowPeriod write SetMacdSlowPeriod;
    property MacdSignalPeriod: Integer read FMacdSignalPeriod write SetMacdSignalPeriod;
    property RsiPeriod: Integer read FRsiPeriod write SetRsiPeriod;
    property StochasticPeriod: Integer read FStochasticPeriod write SetStochasticPeriod;
    property StochasticSignalPeriod: Integer read FStochasticSignalPeriod write SetStochasticSignalPeriod;
    property IndicatorPanelRatio: Single read FIndicatorPanelRatio write SetIndicatorPanelRatio;
    property MacdColor: TColor read FMacdColor write SetMacdColor;
    property MacdSignalColor: TColor read FMacdSignalColor write SetMacdSignalColor;
    property RsiColor: TColor read FRsiColor write SetRsiColor;
    property StochasticKColor: TColor read FStochasticKColor write SetStochasticKColor;
    property StochasticDColor: TColor read FStochasticDColor write SetStochasticDColor;
  end;

implementation

constructor TNimbusFinancialDataPoint.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FXValue := 0;
  FOpen := 0;
  FHigh := 0;
  FLow := 0;
  FClose := 0;
  FVolume := 0;
  FLabel := '';
  FToolTipText := '';
  FEventText := '';
  FEventColor := clNone;
  FEventSize := 1;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusFinancialDataPoint.Assign(Source: TPersistent);
var S: TNimbusFinancialDataPoint;
begin
  if not (Source is TNimbusFinancialDataPoint) then begin inherited; Exit end; S := TNimbusFinancialDataPoint(Source);
  FXValue := S.FXValue;
  FOpen := S.FOpen;
  FHigh := S.FHigh;
  FLow := S.FLow;
  FClose := S.FClose;
  FVolume := S.FVolume;
  FLabel := S.FLabel;
  FToolTipText := S.FToolTipText;
  FEventText := S.FEventText;
  FEventColor := S.FEventColor;
  FEventSize := S.FEventSize;
  FVisible := S.FVisible;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetXValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FXValue = Value then Exit; FXValue := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetOpen(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FOpen = Value then Exit; FOpen := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetHigh(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FHigh = Value then Exit; FHigh := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetLow(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FLow = Value then Exit; FLow := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetClose(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FClose = Value then Exit; FClose := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetVolume(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FVolume = Value then Exit; FVolume := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetLabel(const Value: string);
begin
  if FLabel = Value then Exit; FLabel := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetToolTipText(const Value: string);
begin
  if FToolTipText = Value then Exit; FToolTipText := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetEventText(const Value: string);
begin
  if FEventText = Value then Exit; FEventText := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetEventColor(const Value: TColor);
begin
  if FEventColor = Value then Exit; FEventColor := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetEventSize(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FEventSize = Value then Exit; FEventSize := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialDataPoint.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

function TNimbusFinancialDataPoint.GetIsValid: Boolean;
begin Result := not (IsNan(FXValue) or IsInfinite(FXValue) or IsNan(FOpen) or IsInfinite(FOpen) or IsNan(FHigh) or IsInfinite(FHigh) or IsNan(FLow) or IsInfinite(FLow) or IsNan(FClose) or IsInfinite(FClose)) and (FHigh >= Max(FOpen, FClose)) and (FLow <= Min(FOpen, FClose)) and (FHigh >= FLow) end;

function TNimbusFinancialDataPoint.GetTime: TDateTime;
begin Result := FXValue end;

procedure TNimbusFinancialDataPoint.SetTime(const Value: TDateTime);
begin SetXValue(Value) end;

function TNimbusFinancialDataPoint.GetTypicalPrice: Double;
begin Result := (FHigh + FLow + FClose) / 3 end;

constructor TNimbusFinancialDataPointCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialDataPoint) end;

function TNimbusFinancialDataPointCollection.GetItem(Index: Integer): TNimbusFinancialDataPoint;
begin Result := TNimbusFinancialDataPoint(inherited Items[Index]) end;

function TNimbusFinancialDataPointCollection.Add: TNimbusFinancialDataPoint;
begin Result := TNimbusFinancialDataPoint(inherited Add) end;

function TNimbusFinancialDataPointCollection.Add(const XValue, Open, High, Low, Close, Volume: Double): TNimbusFinancialDataPoint;
begin BeginUpdate; try Result := Add; Result.XValue := XValue; Result.Open := Open; Result.High := High; Result.Low := Low; Result.Close := Close; Result.Volume := Volume finally EndUpdate end end;

procedure TNimbusFinancialDataPointCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialChartOptions.Create;
begin
  inherited Create;
  FPriceDisplayMode := nfpCandlestick;
  FVolumeDisplayMode := nfvBars;
  FShowVolumePanel := True;
  FShowSimpleMovingAverage := True;
  FShowExponentialMovingAverage := True;
  FShowBollingerBands := True;
  FShowLastPriceLine := True;
  FShowEventMarkers := True;
  FShowPriceChange := True;
  FSimpleMovingAveragePeriod := 10;
  FExponentialMovingAveragePeriod := 20;
  FBollingerPeriod := 20;
  FBollingerDeviation := 2;
  FVolumePanelRatio := 0.22;
  FRisingColor := $009AA626;
  FFallingColor := $005053EF;
  FNeutralColor := $00AEA490;
  FSimpleMovingAverageColor := $0007C1FF;
  FExponentialMovingAverageColor := $00F5A542;
  FBollingerBandColor := $00BC47AB;
  FShowMacdPanel := True;
  FShowRsiPanel := True;
  FShowStochasticPanel := True;
  FMacdFastPeriod := 12;
  FMacdSlowPeriod := 26;
  FMacdSignalPeriod := 9;
  FRsiPeriod := 14;
  FStochasticPeriod := 14;
  FStochasticSignalPeriod := 3;
  FIndicatorPanelRatio := 0.15;
  FMacdColor := $00F5A542;
  FMacdSignalColor := $0007C1FF;
  FRsiColor := $00BC47AB;
  FStochasticKColor := $009AA626;
  FStochasticDColor := $005053EF;
end;

procedure TNimbusFinancialChartOptions.Assign(Source: TPersistent);
var S: TNimbusFinancialChartOptions;
begin
  if not (Source is TNimbusFinancialChartOptions) then begin inherited; Exit end; S := TNimbusFinancialChartOptions(Source);
  FPriceDisplayMode := S.FPriceDisplayMode;
  FVolumeDisplayMode := S.FVolumeDisplayMode;
  FShowVolumePanel := S.FShowVolumePanel;
  FShowSimpleMovingAverage := S.FShowSimpleMovingAverage;
  FShowExponentialMovingAverage := S.FShowExponentialMovingAverage;
  FShowBollingerBands := S.FShowBollingerBands;
  FShowLastPriceLine := S.FShowLastPriceLine;
  FShowEventMarkers := S.FShowEventMarkers;
  FShowPriceChange := S.FShowPriceChange;
  FSimpleMovingAveragePeriod := S.FSimpleMovingAveragePeriod;
  FExponentialMovingAveragePeriod := S.FExponentialMovingAveragePeriod;
  FBollingerPeriod := S.FBollingerPeriod;
  FBollingerDeviation := S.FBollingerDeviation;
  FVolumePanelRatio := S.FVolumePanelRatio;
  FRisingColor := S.FRisingColor;
  FFallingColor := S.FFallingColor;
  FNeutralColor := S.FNeutralColor;
  FSimpleMovingAverageColor := S.FSimpleMovingAverageColor;
  FExponentialMovingAverageColor := S.FExponentialMovingAverageColor;
  FBollingerBandColor := S.FBollingerBandColor;
  FShowMacdPanel := S.FShowMacdPanel;
  FShowRsiPanel := S.FShowRsiPanel;
  FShowStochasticPanel := S.FShowStochasticPanel;
  FMacdFastPeriod := S.FMacdFastPeriod;
  FMacdSlowPeriod := S.FMacdSlowPeriod;
  FMacdSignalPeriod := S.FMacdSignalPeriod;
  FRsiPeriod := S.FRsiPeriod;
  FStochasticPeriod := S.FStochasticPeriod;
  FStochasticSignalPeriod := S.FStochasticSignalPeriod;
  FIndicatorPanelRatio := S.FIndicatorPanelRatio;
  FMacdColor := S.FMacdColor;
  FMacdSignalColor := S.FMacdSignalColor;
  FRsiColor := S.FRsiColor;
  FStochasticKColor := S.FStochasticKColor;
  FStochasticDColor := S.FStochasticDColor;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetPriceDisplayMode(const Value: TNimbusFinancialPriceDisplayMode);
begin
  if FPriceDisplayMode = Value then Exit; FPriceDisplayMode := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetVolumeDisplayMode(const Value: TNimbusFinancialVolumeDisplayMode);
begin
  if FVolumeDisplayMode = Value then Exit; FVolumeDisplayMode := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowVolumePanel(const Value: Boolean);
begin
  if FShowVolumePanel = Value then Exit; FShowVolumePanel := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowSimpleMovingAverage(const Value: Boolean);
begin
  if FShowSimpleMovingAverage = Value then Exit; FShowSimpleMovingAverage := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowExponentialMovingAverage(const Value: Boolean);
begin
  if FShowExponentialMovingAverage = Value then Exit; FShowExponentialMovingAverage := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowBollingerBands(const Value: Boolean);
begin
  if FShowBollingerBands = Value then Exit; FShowBollingerBands := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowLastPriceLine(const Value: Boolean);
begin
  if FShowLastPriceLine = Value then Exit; FShowLastPriceLine := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowEventMarkers(const Value: Boolean);
begin
  if FShowEventMarkers = Value then Exit; FShowEventMarkers := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowPriceChange(const Value: Boolean);
begin
  if FShowPriceChange = Value then Exit; FShowPriceChange := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetSimpleMovingAveragePeriod(const Value: Integer);
begin
  if FSimpleMovingAveragePeriod = EnsureRange(Value, 2, 100000) then Exit; FSimpleMovingAveragePeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetExponentialMovingAveragePeriod(const Value: Integer);
begin
  if FExponentialMovingAveragePeriod = EnsureRange(Value, 2, 100000) then Exit; FExponentialMovingAveragePeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetBollingerPeriod(const Value: Integer);
begin
  if FBollingerPeriod = EnsureRange(Value, 2, 100000) then Exit; FBollingerPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetBollingerDeviation(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FBollingerDeviation = Max(0.01, Value) then Exit; FBollingerDeviation := Max(0.01, Value); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetVolumePanelRatio(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FVolumePanelRatio = EnsureRange(Value, 0.12, 0.4) then Exit; FVolumePanelRatio := EnsureRange(Value, 0.12, 0.4); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetRisingColor(const Value: TColor);
begin
  if FRisingColor = Value then Exit; FRisingColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetFallingColor(const Value: TColor);
begin
  if FFallingColor = Value then Exit; FFallingColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetNeutralColor(const Value: TColor);
begin
  if FNeutralColor = Value then Exit; FNeutralColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetSimpleMovingAverageColor(const Value: TColor);
begin
  if FSimpleMovingAverageColor = Value then Exit; FSimpleMovingAverageColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetExponentialMovingAverageColor(const Value: TColor);
begin
  if FExponentialMovingAverageColor = Value then Exit; FExponentialMovingAverageColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetBollingerBandColor(const Value: TColor);
begin
  if FBollingerBandColor = Value then Exit; FBollingerBandColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowMacdPanel(const Value: Boolean);
begin
  if FShowMacdPanel = Value then Exit; FShowMacdPanel := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowRsiPanel(const Value: Boolean);
begin
  if FShowRsiPanel = Value then Exit; FShowRsiPanel := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetShowStochasticPanel(const Value: Boolean);
begin
  if FShowStochasticPanel = Value then Exit; FShowStochasticPanel := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetMacdFastPeriod(const Value: Integer);
begin
  if FMacdFastPeriod = EnsureRange(Value, 2, 100000) then Exit; FMacdFastPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetMacdSlowPeriod(const Value: Integer);
begin
  if FMacdSlowPeriod = EnsureRange(Value, 2, 100000) then Exit; FMacdSlowPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetMacdSignalPeriod(const Value: Integer);
begin
  if FMacdSignalPeriod = EnsureRange(Value, 2, 100000) then Exit; FMacdSignalPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetRsiPeriod(const Value: Integer);
begin
  if FRsiPeriod = EnsureRange(Value, 2, 100000) then Exit; FRsiPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetStochasticPeriod(const Value: Integer);
begin
  if FStochasticPeriod = EnsureRange(Value, 2, 100000) then Exit; FStochasticPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetStochasticSignalPeriod(const Value: Integer);
begin
  if FStochasticSignalPeriod = EnsureRange(Value, 2, 100000) then Exit; FStochasticSignalPeriod := EnsureRange(Value, 2, 100000); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetIndicatorPanelRatio(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FIndicatorPanelRatio = EnsureRange(Value, 0.1, 0.24) then Exit; FIndicatorPanelRatio := EnsureRange(Value, 0.1, 0.24); if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetMacdColor(const Value: TColor);
begin
  if FMacdColor = Value then Exit; FMacdColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetMacdSignalColor(const Value: TColor);
begin
  if FMacdSignalColor = Value then Exit; FMacdSignalColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetRsiColor(const Value: TColor);
begin
  if FRsiColor = Value then Exit; FRsiColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetStochasticKColor(const Value: TColor);
begin
  if FStochasticKColor = Value then Exit; FStochasticKColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusFinancialChartOptions.SetStochasticDColor(const Value: TColor);
begin
  if FStochasticDColor = Value then Exit; FStochasticDColor := Value; if Assigned(FOnChange) then FOnChange(Self);
end;

end.

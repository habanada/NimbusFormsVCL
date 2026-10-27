unit NimbusForms.Charts.Financial.Viewport;

interface

uses System.Classes, System.SysUtils, System.Math, NimbusForms.Charts.Financial.Indicators,
  NimbusForms.Charts.Financial.Business.Types;

type
  TNimbusFinancialViewport = class(TNimbusFinancialPersistent)
  private
    FDataCount, FFirstVisibleIndex, FVisibleCount, FMinVisibleCandles, FMaxVisibleCandles: Integer;
    procedure SetFirstVisibleIndex(const Value: Integer);
    procedure SetVisibleCount(const Value: Integer);
    procedure SetMinVisibleCandles(const Value: Integer);
    procedure SetMaxVisibleCandles(const Value: Integer);
    function GetLastVisibleIndex: Integer;
    function GetActualVisibleCount: Integer;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetDataCount(const Count: Integer);
    procedure SetVisibleRange(const First, Count: Integer);
    procedure SetVisibleTimeRange(const StartTime, EndTime: TDateTime; const Candles: TNimbusFinancialCandleArray);
    procedure ScrollToStart;
    procedure ScrollToEnd;
    procedure CenterOnIndex(const Index: Integer);
    procedure Pan(const CandleDelta: Integer);
    procedure Zoom(const Factor, AnchorRatio: Double);
    procedure ZoomToFit;
    property DataCount: Integer read FDataCount;
    property LastVisibleIndex: Integer read GetLastVisibleIndex;
    property ActualVisibleCount: Integer read GetActualVisibleCount;
  published
    property FirstVisibleIndex: Integer read FFirstVisibleIndex write SetFirstVisibleIndex;
    property VisibleCount: Integer read FVisibleCount write SetVisibleCount;
    property MinVisibleCandles: Integer read FMinVisibleCandles write SetMinVisibleCandles;
    property MaxVisibleCandles: Integer read FMaxVisibleCandles write SetMaxVisibleCandles;
  end;

implementation

constructor TNimbusFinancialViewport.Create;
begin inherited Create; FVisibleCount := 120; FMinVisibleCandles := 10; FMaxVisibleCandles := 2000 end;

procedure TNimbusFinancialViewport.Assign(Source: TPersistent);
var Other: TNimbusFinancialViewport;
begin
  if not (Source is TNimbusFinancialViewport) then begin inherited; Exit end;
  Other := TNimbusFinancialViewport(Source); FMinVisibleCandles := Other.FMinVisibleCandles;
  FMaxVisibleCandles := Other.FMaxVisibleCandles; SetVisibleRange(Other.FFirstVisibleIndex, Other.FVisibleCount);
end;

function TNimbusFinancialViewport.GetLastVisibleIndex: Integer;
begin if FDataCount = 0 then Result := -1 else Result := Min(FDataCount - 1, FFirstVisibleIndex + FVisibleCount - 1) end;

function TNimbusFinancialViewport.GetActualVisibleCount: Integer;
begin Result := Max(0, GetLastVisibleIndex - FFirstVisibleIndex + 1) end;

procedure TNimbusFinancialViewport.SetDataCount(const Count: Integer);
var AtEnd: Boolean;
begin
  if Count < 0 then raise EArgumentOutOfRangeException.Create('Data count');
  if FDataCount = Count then Exit;
  AtEnd := (FDataCount > 0) and (GetLastVisibleIndex = FDataCount - 1); FDataCount := Count;
  if AtEnd then SetVisibleRange(Max(0, Count - FVisibleCount), FVisibleCount)
  else SetVisibleRange(FFirstVisibleIndex, FVisibleCount);
  Changed;
end;

procedure TNimbusFinancialViewport.SetVisibleRange(const First, Count: Integer);
var NewCount, NewFirst: Integer;
begin
  NewCount := EnsureRange(Count, FMinVisibleCandles, FMaxVisibleCandles);
  if FDataCount > 0 then NewCount := Min(NewCount, Max(FMinVisibleCandles, FDataCount));
  NewFirst := EnsureRange(First, 0, Max(0, FDataCount - NewCount));
  if (FFirstVisibleIndex = NewFirst) and (FVisibleCount = NewCount) then Exit;
  FFirstVisibleIndex := NewFirst; FVisibleCount := NewCount; Changed;
end;

procedure TNimbusFinancialViewport.SetFirstVisibleIndex(const Value: Integer);
begin SetVisibleRange(Value, FVisibleCount) end;

procedure TNimbusFinancialViewport.SetVisibleCount(const Value: Integer);
begin SetVisibleRange(FFirstVisibleIndex, Value) end;

procedure TNimbusFinancialViewport.SetMinVisibleCandles(const Value: Integer);
begin
  FMinVisibleCandles := EnsureRange(Value, 1, 1000000); FMaxVisibleCandles := Max(FMinVisibleCandles, FMaxVisibleCandles);
  SetVisibleRange(FFirstVisibleIndex, FVisibleCount); Changed;
end;

procedure TNimbusFinancialViewport.SetMaxVisibleCandles(const Value: Integer);
begin
  FMaxVisibleCandles := EnsureRange(Value, FMinVisibleCandles, 1000000);
  SetVisibleRange(FFirstVisibleIndex, FVisibleCount); Changed;
end;

procedure TNimbusFinancialViewport.SetVisibleTimeRange(const StartTime, EndTime: TDateTime; const Candles: TNimbusFinancialCandleArray);
var I, First, Last: Integer; Start, Finish: Double;
begin
  Start := Min(StartTime, EndTime); Finish := Max(StartTime, EndTime); First := -1; Last := -1;
  for I := 0 to High(Candles) do if (Candles[I].XValue >= Start) and (Candles[I].XValue <= Finish) then
  begin if First < 0 then First := I; Last := I end;
  if First < 0 then SetVisibleRange(Max(0, Length(Candles) - FMinVisibleCandles), FMinVisibleCandles)
  else SetVisibleRange(First, Last - First + 1);
end;

procedure TNimbusFinancialViewport.ScrollToStart;
begin SetVisibleRange(0, FVisibleCount) end;

procedure TNimbusFinancialViewport.ScrollToEnd;
begin SetVisibleRange(Max(0, FDataCount - FVisibleCount), FVisibleCount) end;

procedure TNimbusFinancialViewport.CenterOnIndex(const Index: Integer);
begin SetVisibleRange(Index - FVisibleCount div 2, FVisibleCount) end;

procedure TNimbusFinancialViewport.Pan(const CandleDelta: Integer);
begin SetVisibleRange(Integer(EnsureRange(Int64(FFirstVisibleIndex) + CandleDelta, Int64(0), Int64(Max(0, FDataCount - 1)))), FVisibleCount) end;

procedure TNimbusFinancialViewport.Zoom(const Factor, AnchorRatio: Double);
var NewCount, First: Integer; Anchor: Double;
begin
  if IsNan(Factor) or IsInfinite(Factor) or (Factor <= 0) then raise EArgumentOutOfRangeException.Create('Zoom factor');
  if IsNan(AnchorRatio) or IsInfinite(AnchorRatio) then raise EArgumentOutOfRangeException.Create('Anchor');
  NewCount := Round(EnsureRange(FVisibleCount / Factor, Double(FMinVisibleCandles), Double(FMaxVisibleCandles)));
  if FDataCount > 0 then NewCount := Min(NewCount, Max(FMinVisibleCandles, FDataCount));
  Anchor := EnsureRange(AnchorRatio, 0.0, 1.0); First := Round(FFirstVisibleIndex + Anchor * (FVisibleCount - NewCount));
  SetVisibleRange(First, NewCount);
end;

procedure TNimbusFinancialViewport.ZoomToFit;
begin SetVisibleRange(0, FDataCount) end;

end.

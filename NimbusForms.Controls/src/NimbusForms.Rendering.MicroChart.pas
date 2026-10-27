{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.MicroChart;

interface

uses System.Types, System.Math, NimbusForms.Rendering.Canvas, NimbusForms.Theming.Types, NimbusForms.Theming.Palette;

type
  TMicroChartKind = (mckBullet, mckDonut, mckHeatstrip, mckHistogram, mckWaterfall, mckCandlestick, mckFunnel, mckStackedBar, mckGauge, mckBoxPlot);
  TMicroChartValues = TArray<Double>;
  TMicroChartRenderContext = record
    Bounds: TRect;
    Kind: TMicroChartKind;
    Values: TMicroChartValues;
    Target: Double;
    PPI: Integer;
    Palette: TThemePalette;
    Enabled: Boolean;
  end;
  TMicroChartRenderer = class
  public
    procedure Render(const Canvas: INimbusRenderCanvas; const C: TMicroChartRenderContext);
  end;

implementation

uses NimbusForms.Rendering.Types;

procedure TMicroChartRenderer.Render(const Canvas: INimbusRenderCanvas; const C: TMicroChartRenderContext);
var
  R, B: TRect; N, I, J, X, Y, H, W, Gap, Pad: Integer;
  LowV, HighV, Total, V, Acc, Base, Peak, First, Last, Q1, Q3, Med, Prev, RangeV: Double;
  Accent, Muted, Negative, Back, Fore, Col: TThemeColor;
  Sorted: TMicroChartValues; Temp: Double;
  function ValueAt(const Index: Integer): Double;
  begin
    if (Index < 0) or (Index >= N) then Exit(0);
    Result := C.Values[Index];
    if IsNan(Result) or IsInfinite(Result) then Result := 0;
  end;
  function MapX(const Value: Double): Integer;
  begin Result := R.Left + Round(EnsureRange(Value, 0.0, 1.0) * R.Width) end;
  function MapY(const Value: Double): Integer;
  begin Result := R.Bottom - Round(EnsureRange(Value, 0.0, 1.0) * R.Height) end;
  procedure Bar(const ARect: TRect; const Color: TThemeColor);
  begin if (ARect.Right > ARect.Left) and (ARect.Bottom > ARect.Top) then Canvas.FillRectangle(Color, ARect) end;
  function Normal(const Value: Double): Double;
  begin Result := (Value - LowV) / Max(0.00001, HighV - LowV) end;
begin
  N := Length(C.Values); if (N = 0) or C.Bounds.IsEmpty then Exit;
  Pad := NimbusScaleValue(3, C.PPI); R := C.Bounds; R.Inflate(-Pad, -Pad);
  if (R.Width < 3) or (R.Height < 3) then Exit;
  Accent := NimbusAccentColor(C.Palette); Back := NimbusControlBackColor(C.Palette);
  Fore := NimbusControlForeColor(C.Palette); Muted := NimbusBlendColor(Accent, Back, 170);
  Negative := TThemeColor($FFE47171);
  if not C.Enabled then begin Accent := Muted; Negative := Muted end;
  LowV := ValueAt(0); HighV := LowV; Total := 0;
  for I := 0 to N - 1 do begin V := ValueAt(I); LowV := Min(LowV, V); HighV := Max(HighV, V); Total := Total + Max(0, V) end;
  case C.Kind of
    mckBullet:
      begin
        Base := Max(1, Max(HighV, C.Target)); Y := R.Top + R.Height div 3; H := Max(2, R.Height div 3);
        Bar(Rect(R.Left, Y, R.Right, Y + H), Muted);
        Bar(Rect(R.Left, Y, MapX(ValueAt(0) / Base), Y + H), Accent);
        X := MapX(C.Target / Base); Canvas.DrawLine(Fore, X, R.Top + 1, X, R.Bottom - 1, Max(1, C.PPI / 96));
      end;
    mckDonut:
      begin
        W := Min(R.Width, R.Height); B := Rect(R.Left + (R.Width-W) div 2, R.Top + (R.Height-W) div 2, R.Left + (R.Width+W) div 2, R.Top + (R.Height+W) div 2);
        Canvas.DrawArc(Muted, B, 0, 360, Max(2, W * 0.18)); Acc := -90;
        if Total > 0 then for I := 0 to N - 1 do begin V := Max(0, ValueAt(I)) / Total * 360; Col := NimbusBlendColor(Accent, Back, Round(175 * I / Max(1, N-1))); Canvas.DrawArc(Col, B, Acc, V, Max(2, W * 0.18)); Acc := Acc + V end;
      end;
    mckHeatstrip:
      begin
        Gap := Max(1, NimbusScaleValue(1, C.PPI));
        for I := 0 to N - 1 do begin X := R.Left + I * R.Width div N; W := R.Left + (I+1) * R.Width div N - Gap; Col := NimbusBlendColor(Accent, Back, Round(230 * (1-Normal(ValueAt(I))))); Bar(Rect(X, R.Top, W, R.Bottom), Col) end;
      end;
    mckHistogram:
      begin
        Gap := Max(1, NimbusScaleValue(1, C.PPI));
        for I := 0 to N - 1 do begin X := R.Left + I*R.Width div N; W := R.Left+(I+1)*R.Width div N-Gap; Y := MapY(Normal(ValueAt(I))); Bar(Rect(X, Y, W, R.Bottom), Accent) end;
      end;
    mckWaterfall:
      begin
        Base := 0; Peak := 0;
        for I := 0 to N - 1 do begin Base := Base + ValueAt(I); Peak := Max(Peak, Base); LowV := Min(LowV, Base) end;
        LowV := Min(0, LowV); HighV := Max(Peak, 0); Base := 0;
        for I := 0 to N - 1 do begin V := ValueAt(I); X := R.Left + I*R.Width div N; W := R.Left+(I+1)*R.Width div N-Max(1, R.Width div (N*5)); Y := MapY(Normal(Max(Base, Base+V))); H := MapY(Normal(Min(Base, Base+V))); if V >= 0 then Col := Accent else Col := Negative; Bar(Rect(X, Y, W, Max(Y+1,H)), Col); Base := Base + V end;
      end;
    mckCandlestick:
      begin
        for I := 0 to N div 4 - 1 do begin J := I*4; LowV := Min(LowV, ValueAt(J+2)); HighV := Max(HighV, ValueAt(J+1)) end;
        for I := 0 to N div 4 - 1 do begin J := I*4; X := R.Left + (2*I+1)*R.Width div Max(1, 2*(N div 4)); W := Max(1, R.Width div Max(3, 3*(N div 4))); First := ValueAt(J); Last := ValueAt(J+3); if Last >= First then Col := Accent else Col := Negative; Canvas.DrawLine(Col, X, MapY(Normal(ValueAt(J+1))), X, MapY(Normal(ValueAt(J+2))), 1); Bar(Rect(X-W, MapY(Normal(Max(First,Last))), X+W+1, Max(MapY(Normal(Max(First,Last)))+1,MapY(Normal(Min(First,Last))))), Col) end;
      end;
    mckFunnel:
      begin
        for I := 0 to N - 1 do begin W := Round(R.Width * Max(0, ValueAt(I)) / Max(0.00001, HighV)); W := Max(1,W); Y := R.Top + I*R.Height div N; H := R.Top+(I+1)*R.Height div N-Max(1,R.Height div (N*8)); Col := NimbusBlendColor(Accent, Back, Round(140*I/Max(1,N-1))); Bar(Rect(R.CenterPoint.X-W div 2,Y,R.CenterPoint.X+(W+1) div 2,H),Col) end;
      end;
    mckStackedBar:
      begin
        Acc := 0; Y := R.Top+R.Height div 3; H := Max(2,R.Height div 3);
        if Total > 0 then for I := 0 to N - 1 do begin X := MapX(Acc / Total); Acc := Acc + Max(0,ValueAt(I)); W := MapX(Acc / Total); Col := NimbusBlendColor(Accent,Back,Round(195*I/Max(1,N-1))); Bar(Rect(X,Y,W,Y+H),Col) end;
      end;
    mckGauge:
      begin
        W := Min(R.Width,R.Height*2); H := Min(R.Height*2,R.Width); B := Rect(R.CenterPoint.X-W div 2,R.Bottom-H div 2,R.CenterPoint.X+(W+1) div 2,R.Bottom+H div 2);
        Canvas.DrawArc(Muted,B,180,180,Max(2,R.Height*0.16)); Canvas.DrawArc(Accent,B,180,180*EnsureRange(ValueAt(0)/Max(1,C.Target),0.0,1.0),Max(2,R.Height*0.16));
      end;
    mckBoxPlot:
      begin
        SetLength(Sorted,N); for I := 0 to N - 1 do Sorted[I] := ValueAt(I);
        for I := 1 to N - 1 do begin Temp := Sorted[I]; J := I-1; while (J >= 0) and (Sorted[J] > Temp) do begin Sorted[J+1] := Sorted[J]; Dec(J) end; Sorted[J+1] := Temp end;
        First := Sorted[0]; Last := Sorted[N-1]; Q1 := Sorted[N div 4]; Med := Sorted[N div 2]; Q3 := Sorted[3*N div 4];
        Base := Max(0.00001,Last-First); Y := R.CenterPoint.Y;
        Canvas.DrawLine(Muted,MapX(0),Y,MapX(1),Y,1);
        B := Rect(MapX((Q1-First)/Base),R.Top+R.Height div 4,MapX((Q3-First)/Base),R.Bottom-R.Height div 4);
        Canvas.FillRectangle(Muted,B); Canvas.DrawRectangle(Accent,B,Max(1,C.PPI/96)); X := MapX((Med-First)/Base); Canvas.DrawLine(Fore,X,B.Top,X,B.Bottom,Max(1,C.PPI/96));
      end;
  end;
end;

end.

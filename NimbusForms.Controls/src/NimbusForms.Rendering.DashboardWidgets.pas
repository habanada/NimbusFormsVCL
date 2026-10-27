{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.DashboardWidgets;

interface

uses System.Types, System.Math, System.SysUtils, Vcl.Graphics, NimbusForms.Rendering.Canvas, NimbusForms.Theming.Types, NimbusForms.Theming.Palette;

type
  TDashboardWidgetKind = (dwKpiTile, dwDeltaTile, dwProgressMeter, dwSegmentMeter, dwStatusMatrix, dwTrendArrow, dwComparisonBars, dwRadialScore, dwActivityDots, dwCapacityBars);
  TDashboardWidgetValues = TArray<Double>;
  TDashboardWidgetContext = record
    Bounds: TRect;
    Kind: TDashboardWidgetKind;
    Values: TDashboardWidgetValues;
    Target: Double;
    Caption: string;
    Detail: string;
    PPI: Integer;
    Palette: TThemePalette;
    Enabled: Boolean;
    Font: TFont;
  end;
  TDashboardWidgetRenderer = class
  public
    procedure Render(const Canvas: INimbusRenderCanvas; const C: TDashboardWidgetContext);
  end;

implementation

uses NimbusForms.Rendering.Types;

procedure TDashboardWidgetRenderer.Render(const Canvas: INimbusRenderCanvas; const C: TDashboardWidgetContext);
var
  R, B: TRect;
  I, N, X, Y, W, H, Gap, Pad, Row, Col: Integer;
  V, Total, MaxV, Base, Last: Double;
  Accent, Back, Fore, Muted, Negative, Shade, Color: TThemeColor;
  F: TFont;
  function ValueAt(const Index: Integer): Double;
  begin
    Result := 0;
    if (Index < 0) or (Index >= N) then Exit;
    Result := C.Values[Index];
    if IsNan(Result) or IsInfinite(Result) then Result := 0;
  end;
  function Fraction(const Value, Limit: Double): Double;
  begin Result := EnsureRange(Value / Max(0.000001, Limit), 0.0, 1.0) end;
  procedure FillBar(const AR: TRect; const AColor: TThemeColor);
  begin if (AR.Right > AR.Left) and (AR.Bottom > AR.Top) then Canvas.FillRoundedRectangle(AColor, AR, Max(1, AR.Height div 3)) end;
  procedure TextAt(const S: string; const AR: TRect; const AColor: TThemeColor; const Size: Integer);
  begin
    if S = '' then Exit;
    F.Size := Size;
    Canvas.DrawText(S, F, AColor, AR, []);
  end;
begin
  R := C.Bounds; if R.IsEmpty then Exit;
  Pad := NimbusScaleValue(8, C.PPI); R.Inflate(-Pad, -Pad);
  if (R.Width < 8) or (R.Height < 8) then Exit;
  N := Length(C.Values);
  Accent := NimbusAccentColor(C.Palette); Back := NimbusControlBackColor(C.Palette);
  Fore := NimbusControlForeColor(C.Palette); Muted := NimbusBlendColor(Accent, Back, 190);
  Negative := TThemeColor($FFE47171); Shade := NimbusBlendColor(Fore, Back, 175);
  if not C.Enabled then begin Accent := Muted; Negative := Muted end;
  F := TFont.Create;
  try
    F.Assign(C.Font);
    Canvas.FillRoundedRectangle(NimbusBlendColor(Back, Fore, 15), C.Bounds, NimbusScaleValue(9, C.PPI));
    TextAt(C.Caption, Rect(R.Left, R.Top, R.Right, R.Top + NimbusScaleValue(20, C.PPI)), Shade, 9);
    R.Top := R.Top + NimbusScaleValue(24, C.PPI);
    if R.Height < 8 then Exit;
    MaxV := Max(1, C.Target); Total := 0;
    for I := 0 to N - 1 do begin MaxV := Max(MaxV, Abs(ValueAt(I))); Total := Total + Max(0, ValueAt(I)) end;
    case C.Kind of
      dwKpiTile:
        begin
          TextAt(FormatFloat('#,##0.##', ValueAt(0)), R, Fore, 23);
          TextAt(C.Detail, Rect(R.Left, R.Bottom - 18, R.Right, R.Bottom), Accent, 9);
        end;
      dwDeltaTile:
        begin
          V := ValueAt(0) - ValueAt(1);
          if V < 0 then Color := Negative else Color := Accent;
          TextAt(FormatFloat('+#,##0.##;-#,##0.##;0', V), R, Color, 22);
          TextAt(C.Detail, Rect(R.Left, R.Bottom - 18, R.Right, R.Bottom), Shade, 9);
        end;
      dwProgressMeter:
        begin
          B := Rect(R.Left, R.CenterPoint.Y, R.Right, R.CenterPoint.Y + 12);
          FillBar(B, Muted); B.Right := B.Left + Round(B.Width * Fraction(ValueAt(0), C.Target)); FillBar(B, Accent);
          TextAt(FormatFloat('0', Fraction(ValueAt(0), C.Target)*100) + '%', Rect(R.Left, R.Top, R.Right, R.CenterPoint.Y), Fore, 15);
        end;
      dwSegmentMeter:
        begin
          Gap := Max(2, NimbusScaleValue(3, C.PPI)); W := Max(1, (R.Width - 9*Gap) div 10);
          for I := 0 to 9 do begin X := R.Left + I*(W+Gap); if I < Round(10 * Fraction(ValueAt(0), C.Target)) then Color := Accent else Color := Muted; FillBar(Rect(X, R.CenterPoint.Y-6, Min(X+W,R.Right), R.CenterPoint.Y+7), Color) end;
          TextAt(C.Detail, Rect(R.Left,R.Bottom-20,R.Right,R.Bottom), Shade, 9);
        end;
      dwStatusMatrix:
        begin
          Gap := Max(2, NimbusScaleValue(3, C.PPI)); W := Max(3, (R.Width - 7*Gap) div 8); H := Max(3, (R.Height - 3*Gap) div 4);
          for I := 0 to 31 do begin Row := I div 8; Col := I mod 8; X := R.Left+Col*(W+Gap); Y := R.Top+Row*(H+Gap); if ValueAt(I) > 0 then Color := Accent else Color := Muted; Canvas.FillRoundedRectangle(Color,Rect(X,Y,Min(R.Right,X+W),Min(R.Bottom,Y+H)),2) end;
        end;
      dwTrendArrow:
        begin
          V := ValueAt(0) - ValueAt(1); if V < 0 then Color := Negative else Color := Accent;
          W := Min(R.Height div 2, R.Width div 4); X := R.Right-W-10; Y := R.CenterPoint.Y;
          if V >= 0 then begin Canvas.DrawLine(Color,X,Y+W div 2,X,Y-W div 2,3); Canvas.DrawLine(Color,X,Y-W div 2,X-W div 3,Y-W div 6,3); Canvas.DrawLine(Color,X,Y-W div 2,X+W div 3,Y-W div 6,3) end
          else begin Canvas.DrawLine(Color,X,Y-W div 2,X,Y+W div 2,3); Canvas.DrawLine(Color,X,Y+W div 2,X-W div 3,Y+W div 6,3); Canvas.DrawLine(Color,X,Y+W div 2,X+W div 3,Y+W div 6,3) end;
          TextAt(FormatFloat('0.0', Abs(V))+'%',Rect(R.Left,R.Top,X-W div 2,R.Bottom),Color,19);
        end;
      dwComparisonBars:
        begin
          for I := 0 to Min(3,N-1) do begin Y := R.Top+I*R.Height div 4; H := Max(4,R.Height div 7); FillBar(Rect(R.Left,Y,R.Right,Y+H),Muted); FillBar(Rect(R.Left,Y,R.Left+Round(R.Width*Fraction(ValueAt(I),MaxV)),Y+H),NimbusBlendColor(Accent,Back,I*36)) end;
        end;
      dwRadialScore:
        begin
          W := Min(R.Height,R.Width); B := Rect(R.CenterPoint.X-W div 2,R.CenterPoint.Y-W div 2,R.CenterPoint.X+(W+1) div 2,R.CenterPoint.Y+(W+1) div 2);
          Canvas.DrawArc(Muted,B,-90,360,Max(3,W*0.11)); Canvas.DrawArc(Accent,B,-90,360*Fraction(ValueAt(0),C.Target),Max(3,W*0.11));
          TextAt(FormatFloat('0',100*Fraction(ValueAt(0),C.Target)),Rect(B.Left+W div 3,B.Top+W div 3,B.Right,B.Bottom),Fore,13);
        end;
      dwActivityDots:
        begin
          Gap := Max(2,NimbusScaleValue(4,C.PPI)); W := Max(4,Min(R.Height div 3,(R.Width-11*Gap) div 12));
          for I := 0 to 11 do begin X := R.Left+I*(W+Gap); Y := R.CenterPoint.Y-W div 2; if ValueAt(I) > 0 then Color := Accent else Color := Muted; Canvas.FillEllipse(Color,Rect(X,Y,X+W,Y+W)) end;
          TextAt(C.Detail,Rect(R.Left,R.Bottom-18,R.Right,R.Bottom),Shade,9);
        end;
      dwCapacityBars:
        begin
          for I := 0 to Min(5,N-1) do begin W := Max(2,R.Width div 8); X := R.Left+I*R.Width div 6; H := Round(R.Height*Fraction(ValueAt(I),C.Target)); Canvas.FillRoundedRectangle(Muted,Rect(X,R.Top,X+W,R.Bottom),2); Canvas.FillRoundedRectangle(Accent,Rect(X,R.Bottom-H,X+W,R.Bottom),2) end;
        end;
    end;
  finally F.Free end;
end;

end.

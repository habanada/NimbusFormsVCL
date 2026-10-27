unit NimbusForms.Grid.SvgPath;

interface

uses
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI;

type
  TThemedSvgPathBuilder = class sealed
  strict private
    type
      TReader = record
        Text: string;
        Pos: Integer;
        function AtEnd: Boolean;
        procedure SkipSeparators;
        function PeekCommand(out ACommand: Char): Boolean;
        function ReadNumber(out AValue: Double): Boolean;
        function ReadFlag(out AValue: Boolean): Boolean;
      end;
    class procedure AddArc(const APath: TGPGraphicsPath; const AX1, AY1: Double; ARx, ARy: Double;
      const ARotation: Double; const ALarge, ASweep: Boolean; const AX2, AY2: Double); static;
    class procedure AddCubic(const APath: TGPGraphicsPath; const AX0, AY0, AX1, AY1, AX2, AY2, AX3, AY3: Double); static;
  public
    class function Build(const AData: string; const AEvenOdd: Boolean): TGPGraphicsPath; static;
    class procedure AddRoundedRectangle(const APath: TGPGraphicsPath; const AX, AY, AWidth, AHeight, ARx, ARy: Double); static;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  NimbusForms.Grid.SvgValues;

function TThemedSvgPathBuilder.TReader.AtEnd: Boolean;
begin
  Result := Pos > Length(Text);
end;

procedure TThemedSvgPathBuilder.TReader.SkipSeparators;
begin
  while (Pos <= Length(Text)) and (CharInSet(Text[Pos], [#0..' ', ','])) do
    Inc(Pos);
end;

function TThemedSvgPathBuilder.TReader.PeekCommand(out ACommand: Char): Boolean;
begin
  SkipSeparators;
  Result := (Pos <= Length(Text)) and CharInSet(Text[Pos], ['M', 'm', 'L', 'l', 'H', 'h', 'V', 'v', 'C', 'c',
    'S', 's', 'Q', 'q', 'T', 't', 'A', 'a', 'Z', 'z']);
  if Result then
    ACommand := Text[Pos]
  else
    ACommand := #0;
end;

function TThemedSvgPathBuilder.TReader.ReadNumber(out AValue: Double): Boolean;
var
  LStart: Integer;
  LHasDot, LHasExp, LHasDigit: Boolean;
begin
  AValue := 0;
  SkipSeparators;
  if Pos > Length(Text) then
    Exit(False);
  LStart := Pos;
  LHasDot := False;
  LHasExp := False;
  LHasDigit := False;
  if CharInSet(Text[Pos], ['+', '-']) then
    Inc(Pos);
  while Pos <= Length(Text) do
  begin
    if CharInSet(Text[Pos], ['0'..'9']) then
    begin
      LHasDigit := True;
      Inc(Pos);
    end
    else if (Text[Pos] = '.') and not LHasDot and not LHasExp then
    begin
      LHasDot := True;
      Inc(Pos);
    end
    else if CharInSet(Text[Pos], ['e', 'E']) and LHasDigit and not LHasExp then
    begin
      LHasExp := True;
      Inc(Pos);
      if (Pos <= Length(Text)) and CharInSet(Text[Pos], ['+', '-']) then
        Inc(Pos);
    end
    else
      Break;
  end;
  if not LHasDigit then
  begin
    Pos := LStart;
    Exit(False);
  end;
  AValue := TThemedSvgValues.ParseNumber(Copy(Text, LStart, Pos - LStart), 0);
  Result := True;
end;

function TThemedSvgPathBuilder.TReader.ReadFlag(out AValue: Boolean): Boolean;
begin
  AValue := False;
  SkipSeparators;
  if (Pos > Length(Text)) or not CharInSet(Text[Pos], ['0', '1']) then
    Exit(False);
  AValue := Text[Pos] = '1';
  Inc(Pos);
  Result := True;
end;

class procedure TThemedSvgPathBuilder.AddCubic(const APath: TGPGraphicsPath; const AX0, AY0, AX1, AY1, AX2, AY2,
  AX3, AY3: Double);
begin
  APath.AddBezier(Single(AX0), Single(AY0), Single(AX1), Single(AY1), Single(AX2), Single(AY2),
    Single(AX3), Single(AY3));
end;

class procedure TThemedSvgPathBuilder.AddArc(const APath: TGPGraphicsPath; const AX1, AY1: Double; ARx, ARy: Double;
  const ARotation: Double; const ALarge, ASweep: Boolean; const AX2, AY2: Double);
var
  LPhi, LCos, LSin, LDx, LDy, LX1p, LY1p, LLambda, LNum, LDen, LCoef, LCxp, LCyp, LCx, LCy: Double;
  LTheta1, LDelta, LT, LA1, LA2, LSegmentDelta: Double;
  LSegments, I: Integer;
  LPrevX, LPrevY, LC1X, LC1Y, LC2X, LC2Y, LEX, LEY: Double;

  procedure Transform(const AUx, AUy: Double; out AX, AY: Double);
  begin
    AX := LCos * ARx * AUx - LSin * ARy * AUy + LCx;
    AY := LSin * ARx * AUx + LCos * ARy * AUy + LCy;
  end;

begin
  if (AX1 = AX2) and (AY1 = AY2) then
    Exit;
  ARx := Abs(ARx);
  ARy := Abs(ARy);
  if (ARx = 0) or (ARy = 0) then
  begin
    APath.AddLine(Single(AX1), Single(AY1), Single(AX2), Single(AY2));
    Exit;
  end;
  LPhi := DegToRad(ARotation);
  LCos := Cos(LPhi);
  LSin := Sin(LPhi);
  LDx := (AX1 - AX2) / 2;
  LDy := (AY1 - AY2) / 2;
  LX1p := LCos * LDx + LSin * LDy;
  LY1p := -LSin * LDx + LCos * LDy;
  LLambda := (LX1p * LX1p) / (ARx * ARx) + (LY1p * LY1p) / (ARy * ARy);
  if LLambda > 1 then
  begin
    ARx := ARx * Sqrt(LLambda);
    ARy := ARy * Sqrt(LLambda);
  end;
  LNum := ARx * ARx * ARy * ARy - ARx * ARx * LY1p * LY1p - ARy * ARy * LX1p * LX1p;
  LDen := ARx * ARx * LY1p * LY1p + ARy * ARy * LX1p * LX1p;
  if (LDen = 0) or (LNum <= 0) then
    LCoef := 0
  else
    LCoef := Sqrt(LNum / LDen);
  if ALarge = ASweep then
    LCoef := -LCoef;
  LCxp := LCoef * ARx * LY1p / ARy;
  LCyp := -LCoef * ARy * LX1p / ARx;
  LCx := LCos * LCxp - LSin * LCyp + (AX1 + AX2) / 2;
  LCy := LSin * LCxp + LCos * LCyp + (AY1 + AY2) / 2;
  LTheta1 := ArcTan2((LY1p - LCyp) / ARy, (LX1p - LCxp) / ARx);
  LDelta := ArcTan2(((LX1p - LCxp) / ARx) * ((-LY1p - LCyp) / ARy) - ((LY1p - LCyp) / ARy) * ((-LX1p - LCxp) / ARx),
    ((LX1p - LCxp) / ARx) * ((-LX1p - LCxp) / ARx) + ((LY1p - LCyp) / ARy) * ((-LY1p - LCyp) / ARy));
  if (not ASweep) and (LDelta > 0) then
    LDelta := LDelta - 2 * Pi
  else if ASweep and (LDelta < 0) then
    LDelta := LDelta + 2 * Pi;
  LSegments := Max(1, Ceil(Abs(LDelta) / (Pi / 2) - 0.000001));
  LSegmentDelta := LDelta / LSegments;
  LT := 4 / 3 * Tan(LSegmentDelta / 4);
  LPrevX := AX1;
  LPrevY := AY1;
  for I := 0 to LSegments - 1 do
  begin
    LA1 := LTheta1 + I * LSegmentDelta;
    LA2 := LA1 + LSegmentDelta;
    Transform(Cos(LA1) - LT * Sin(LA1), Sin(LA1) + LT * Cos(LA1), LC1X, LC1Y);
    Transform(Cos(LA2) + LT * Sin(LA2), Sin(LA2) - LT * Cos(LA2), LC2X, LC2Y);
    if I = LSegments - 1 then
    begin
      LEX := AX2;
      LEY := AY2;
    end
    else
      Transform(Cos(LA2), Sin(LA2), LEX, LEY);
    AddCubic(APath, LPrevX, LPrevY, LC1X, LC1Y, LC2X, LC2Y, LEX, LEY);
    LPrevX := LEX;
    LPrevY := LEY;
  end;
end;

class procedure TThemedSvgPathBuilder.AddRoundedRectangle(const APath: TGPGraphicsPath; const AX, AY, AWidth, AHeight,
  ARx, ARy: Double);
var
  LRx, LRy: Double;
begin
  LRx := Min(ARx, AWidth / 2);
  LRy := Min(ARy, AHeight / 2);
  if (LRx <= 0) or (LRy <= 0) then
  begin
    APath.AddRectangle(MakeRect(Single(AX), Single(AY), Single(AWidth), Single(AHeight)));
    Exit;
  end;
  APath.StartFigure;
  APath.AddArc(Single(AX), Single(AY), Single(LRx * 2), Single(LRy * 2), 180, 90);
  APath.AddLine(Single(AX + LRx), Single(AY), Single(AX + AWidth - LRx), Single(AY));
  APath.AddArc(Single(AX + AWidth - LRx * 2), Single(AY), Single(LRx * 2), Single(LRy * 2), 270, 90);
  APath.AddLine(Single(AX + AWidth), Single(AY + LRy), Single(AX + AWidth), Single(AY + AHeight - LRy));
  APath.AddArc(Single(AX + AWidth - LRx * 2), Single(AY + AHeight - LRy * 2), Single(LRx * 2), Single(LRy * 2), 0, 90);
  APath.AddLine(Single(AX + AWidth - LRx), Single(AY + AHeight), Single(AX + LRx), Single(AY + AHeight));
  APath.AddArc(Single(AX), Single(AY + AHeight - LRy * 2), Single(LRx * 2), Single(LRy * 2), 90, 90);
  APath.CloseFigure;
end;

class function TThemedSvgPathBuilder.Build(const AData: string; const AEvenOdd: Boolean): TGPGraphicsPath;
var
  LReader: TReader;
  LCommand, LNext: Char;
  LUpper: Char;
  LRelative, LFlagLarge, LFlagSweep: Boolean;
  LCx, LCy, LSx, LSy, LX, LY, LX1, LY1, LX2, LY2, LRx, LRy, LRot: Double;
  LLastKind: Integer;
  LLastX, LLastY: Double;
  LQx, LQy: Double;
  LOk: Boolean;
begin
  Result := TGPGraphicsPath.Create;
  if AEvenOdd then
    Result.SetFillMode(FillModeAlternate)
  else
    Result.SetFillMode(FillModeWinding);
  LReader.Text := AData;
  LReader.Pos := 1;
  LCommand := #0;
  LCx := 0;
  LCy := 0;
  LSx := 0;
  LSy := 0;
  LLastKind := 0;
  LLastX := 0;
  LLastY := 0;
  while True do
  begin
    LReader.SkipSeparators;
    if LReader.AtEnd then
      Break;
    if LReader.PeekCommand(LNext) then
    begin
      LCommand := LNext;
      Inc(LReader.Pos);
    end
    else if LCommand = #0 then
      Break
    else if LCommand = 'M' then
      LCommand := 'L'
    else if LCommand = 'm' then
      LCommand := 'l';
    LRelative := CharInSet(LCommand, ['a'..'z']);
    LUpper := UpCase(LCommand);
    LOk := True;
    case LUpper of
      'Z':
        begin
          Result.CloseFigure;
          LCx := LSx;
          LCy := LSy;
          LLastKind := 0;
          LCommand := #0;
        end;
      'M':
        begin
          LOk := LReader.ReadNumber(LX) and LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            Result.StartFigure;
            LCx := LX;
            LCy := LY;
            LSx := LX;
            LSy := LY;
            LLastKind := 0;
          end;
        end;
      'L':
        begin
          LOk := LReader.ReadNumber(LX) and LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            Result.AddLine(Single(LCx), Single(LCy), Single(LX), Single(LY));
            LCx := LX;
            LCy := LY;
            LLastKind := 0;
          end;
        end;
      'H':
        begin
          LOk := LReader.ReadNumber(LX);
          if LOk then
          begin
            if LRelative then
              LX := LX + LCx;
            Result.AddLine(Single(LCx), Single(LCy), Single(LX), Single(LCy));
            LCx := LX;
            LLastKind := 0;
          end;
        end;
      'V':
        begin
          LOk := LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
              LY := LY + LCy;
            Result.AddLine(Single(LCx), Single(LCy), Single(LCx), Single(LY));
            LCy := LY;
            LLastKind := 0;
          end;
        end;
      'C':
        begin
          LOk := LReader.ReadNumber(LX1) and LReader.ReadNumber(LY1) and LReader.ReadNumber(LX2) and
            LReader.ReadNumber(LY2) and LReader.ReadNumber(LX) and LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LX1 := LX1 + LCx;
              LY1 := LY1 + LCy;
              LX2 := LX2 + LCx;
              LY2 := LY2 + LCy;
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            AddCubic(Result, LCx, LCy, LX1, LY1, LX2, LY2, LX, LY);
            LLastKind := 1;
            LLastX := LX2;
            LLastY := LY2;
            LCx := LX;
            LCy := LY;
          end;
        end;
      'S':
        begin
          LOk := LReader.ReadNumber(LX2) and LReader.ReadNumber(LY2) and LReader.ReadNumber(LX) and
            LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LX2 := LX2 + LCx;
              LY2 := LY2 + LCy;
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            if LLastKind = 1 then
            begin
              LX1 := 2 * LCx - LLastX;
              LY1 := 2 * LCy - LLastY;
            end
            else
            begin
              LX1 := LCx;
              LY1 := LCy;
            end;
            AddCubic(Result, LCx, LCy, LX1, LY1, LX2, LY2, LX, LY);
            LLastKind := 1;
            LLastX := LX2;
            LLastY := LY2;
            LCx := LX;
            LCy := LY;
          end;
        end;
      'Q':
        begin
          LOk := LReader.ReadNumber(LQx) and LReader.ReadNumber(LQy) and LReader.ReadNumber(LX) and
            LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LQx := LQx + LCx;
              LQy := LQy + LCy;
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            AddCubic(Result, LCx, LCy, LCx + 2 / 3 * (LQx - LCx), LCy + 2 / 3 * (LQy - LCy),
              LX + 2 / 3 * (LQx - LX), LY + 2 / 3 * (LQy - LY), LX, LY);
            LLastKind := 2;
            LLastX := LQx;
            LLastY := LQy;
            LCx := LX;
            LCy := LY;
          end;
        end;
      'T':
        begin
          LOk := LReader.ReadNumber(LX) and LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            if LLastKind = 2 then
            begin
              LQx := 2 * LCx - LLastX;
              LQy := 2 * LCy - LLastY;
            end
            else
            begin
              LQx := LCx;
              LQy := LCy;
            end;
            AddCubic(Result, LCx, LCy, LCx + 2 / 3 * (LQx - LCx), LCy + 2 / 3 * (LQy - LCy),
              LX + 2 / 3 * (LQx - LX), LY + 2 / 3 * (LQy - LY), LX, LY);
            LLastKind := 2;
            LLastX := LQx;
            LLastY := LQy;
            LCx := LX;
            LCy := LY;
          end;
        end;
      'A':
        begin
          LOk := LReader.ReadNumber(LRx) and LReader.ReadNumber(LRy) and LReader.ReadNumber(LRot) and
            LReader.ReadFlag(LFlagLarge) and LReader.ReadFlag(LFlagSweep) and LReader.ReadNumber(LX) and
            LReader.ReadNumber(LY);
          if LOk then
          begin
            if LRelative then
            begin
              LX := LX + LCx;
              LY := LY + LCy;
            end;
            AddArc(Result, LCx, LCy, LRx, LRy, LRot, LFlagLarge, LFlagSweep, LX, LY);
            LCx := LX;
            LCy := LY;
            LLastKind := 0;
          end;
        end;
    end;
    if not LOk then
      Break;
  end;
end;

end.

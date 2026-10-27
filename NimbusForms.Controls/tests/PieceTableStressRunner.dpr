program PieceTableStressRunner;

{$APPTYPE CONSOLE}
{$R+}
{$Q+}

uses System.SysUtils, NimbusPieceTableStressChecks;

var FirstSeed, Seeds, Steps: Integer;
begin
  try
    ReportMemoryLeaksOnShutdown := True;
    FirstSeed := 1; Seeds := 128; Steps := 1000;
    if ParamCount >= 1 then FirstSeed := StrToInt(ParamStr(1));
    if ParamCount >= 2 then Seeds := StrToInt(ParamStr(2));
    if ParamCount >= 3 then Steps := StrToInt(ParamStr(3));
    Writeln('Piece table stress: first_seed=', FirstSeed, ' seeds=', Seeds, ' steps=', Steps);
    RunPieceTableStressChecks(FirstSeed, Seeds, Steps);
  except on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); ExitCode := 1; end; end;
end.

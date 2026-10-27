program NimbusCodeStructureTests;

{$APPTYPE CONSOLE}
{$R+}
{$Q+}

uses System.SysUtils, NimbusCodeStructureChecks;

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    RunCodeStructureChecks;
    Writeln('Code structure selection checks passed');
  except on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); ExitCode := 1; end; end;
end.

program NimbusHexEditorDUnitXTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses System.SysUtils, System.IOUtils, Vcl.Forms, DUnitX.TestFramework, DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit, NimbusHexEditor.DUnitX.Support,
  NimbusHexEditor.DUnitX.DocumentTests, NimbusHexEditor.DUnitX.PersistenceTests,
  NimbusHexEditor.DUnitX.EditorTests;

resourcestring
  SPressEnter = 'Press Enter to close.';

var Runner: ITestRunner; Results: IRunResults; Logger: ITestLogger; Report: string;
begin
  try
    Application.Initialize;
    TDUnitX.CheckCommandLine;
    Report := ChangeFileExt(TPath.GetFullPath(ParamStr(0)), '.xml');
    CheckHexTestPath(Report);
    Runner := TDUnitX.CreateRunner; Runner.UseRTTI := True; Runner.FailsOnNoAsserts := True;
    Logger := TDUnitXConsoleLogger.Create(True); Runner.AddLogger(Logger);
    Logger := TDUnitXXMLNUnitFileLogger.Create(Report); Runner.AddLogger(Logger);
    Results := Runner.Execute;
    if not Results.AllPassed then ExitCode := 1;
  except
    on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end;
  end;
{$IFNDEF CI}
  Writeln(SPressEnter); Readln;
{$ENDIF}
end.

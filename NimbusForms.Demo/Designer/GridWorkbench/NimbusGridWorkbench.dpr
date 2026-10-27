program NimbusGridWorkbench;

uses
  Vcl.Forms,
  NimbusForms.Demo.GridWorkbench.Main in 'NimbusForms.Demo.GridWorkbench.Main.pas' {GridWorkbenchForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'NimbusForms Grid Workbench';
  Application.CreateForm(TGridWorkbenchForm, GridWorkbenchForm);
  Application.Run;
end.

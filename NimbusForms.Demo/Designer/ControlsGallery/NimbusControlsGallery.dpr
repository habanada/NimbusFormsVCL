program NimbusControlsGallery;

uses
  Vcl.Forms,
  NimbusForms.Demo.ControlsGallery.Main in 'NimbusForms.Demo.ControlsGallery.Main.pas' {ControlsGalleryForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'NimbusForms Controls Gallery';
  Application.CreateForm(TControlsGalleryForm, ControlsGalleryForm);
  Application.Run;
end.

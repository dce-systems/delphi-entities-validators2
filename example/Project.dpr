program Project;

uses
  Vcl.Forms,
  UApp in 'UApp.pas' {AppForm},
  UModel in 'UModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAppForm, AppForm);
  Application.Run;
end.

program Project;

uses
  Vcl.Forms,
  UApp in 'UApp.pas' {AppForm},
  UModel in 'UModel.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := (DebugHook <> 0);
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAppForm, AppForm);
  Application.Run;
end.

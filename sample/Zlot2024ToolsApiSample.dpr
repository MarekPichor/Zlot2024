program Zlot2024ToolsApiSample;

uses
  Vcl.Forms,
  oMain in 'oMain.pas' {fMain},
  uDB in 'uDB.pas',
  uDBHandler in 'uDBHandler.pas',
  Grid in 'Grid.pas',
  PngUtils in 'PngUtils.pas',
  ControlUtils in '..\src\ControlUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

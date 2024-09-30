program Zlot2024ToolsApiSample;

uses
  Vcl.Forms,
  oMain in 'oMain.pas' {fMain},
  uDBHandler in 'uDBHandler.pas',
  Grid in 'Grid.pas',
  PngUtils in 'PngUtils.pas',
  ControlUtils in '..\src\utils\ControlUtils.pas',
  uDB in 'uDB.pas' {TDBDataModule: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

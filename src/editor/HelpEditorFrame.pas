unit HelpEditorFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmHelpEditorFrame = class(TFrame)
    Panel1: TPanel;
    M_Content: TMemo;
  private
    { Private declarations }
  public
    procedure LoadContent(const aFileName : String);
  end;

implementation

{$R *.dfm}

{ TfrmHelpEditorFrame }

procedure TfrmHelpEditorFrame.LoadContent(const aFileName: String);
begin
  if FileExists(aFileName) then
    M_Content.Lines.LoadFromFile(aFileName);
end;

end.

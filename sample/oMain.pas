unit oMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, uDBHandler, Data.DB, Vcl.DBGrids, Grid{, FireDAC.Phys.SQLite};

type
  TfMain = class(TForm)
    PageControl1: TPageControl;
    TS_Visualizers: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fDBHandler : TDBHandler;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.FormCreate(Sender: TObject);
var
  wGrid : TGrid;
begin
  fDBHandler := TDBHandler.Create();
  fDBHandler.Init();
  wGrid := TGrid.Create(Self);
  wGrid.Parent := TS_Visualizers;
  wGrid.Align := alClient;
  wGrid.DataSource := TDataSource.Create(Self);
  wGrid.DataSource.Dataset := fDBHandler.ContactsQuery;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fDBHandler);
end;

end.


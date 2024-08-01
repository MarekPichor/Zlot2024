unit uDBHandler;

interface

uses
  uDB, Data.DB;

type
  TDBHandler = class
  private
    fConnection : TConnection;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Init();
    function ContactsQuery() : TDataSet;
  end;

implementation

uses
  System.SysUtils;

{ TDBHandler }

function TDBHandler.ContactsQuery: TDataSet;
begin
  Result := fConnection.Query('select * from contacts');
end;

constructor TDBHandler.Create;
begin
  fConnection := TConnection.Create();
end;

destructor TDBHandler.Destroy;
begin
  FreeAndNil(fConnection);
  inherited;
end;

procedure TDBHandler.Init;
begin
  fConnection.Connect();
  fConnection.ExecScript('create.sql');
end;

end.

unit uDBHandler;

interface

uses
  uDB, Data.DB;

type
  TDBHandler = class
  private
    fConnection : TConnection;
    procedure UpdateContactImage(aId : Integer);
    procedure UpdateImages();
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
  UpdateImages();
end;

procedure TDBHandler.UpdateContactImage(aId: Integer);
var
  wQ : TDataset;
begin
  wQ := fConnection.Query(Format('select * from contacts where id = %d', [aId]));
  wQ.Edit();
  TBlobField(wQ.FieldByName('photo')).LoadFromFile(Format('images/%d.png', [aId]));
  wQ.Post();
end;

procedure TDBHandler.UpdateImages;
var
  wQ : TDataSet;
begin
  wQ := fConnection.Query('select id from contacts');
  while not wQ.Eof do begin
    UpdatecontactImage(wQ.FieldByName('id').AsInteger);
    wQ.Next();
  end;
end;

end.

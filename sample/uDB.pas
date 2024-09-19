unit uDB;

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.DApt, FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands,
  System.SysUtils, Vcl.Dialogs, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  System.Classes, FireDAC.Phys.SQLite;

type

  TConnection = class
  private
    fConnection : TFDConnection;
    fTrans : TFDTransaction;
    procedure OnError(aSender: TObject; aInitiator: TObject; var aException : Exception);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Connect();
    function ExecSQL(aSQL : String) : Integer;
    function ExecScript(aFileName : String) : Boolean;
    function Query(aSQL : String) : TDataSet;
  end;

implementation

procedure TConnection.Connect;
begin
  fConnection.Connected := True;
end;

constructor TConnection.Create;
var
  wDBFileName : String;
begin
  fConnection := TFDConnection.Create(nil);
  fTrans := TFDTransaction.Create(nil);
  fConnection.Transaction := fTrans;
  fConnection.DriverName := 'SQLite';

  wDBFileName := ExtractFilePath(ParamStr(0)) + 'db.sqlite';
  fConnection.Params.AddPair('Database', wDBFileName);
end;

destructor TConnection.Destroy;
begin
  FreeAndNil(fTrans);
  FreeAndNil(fConnection);
  inherited;
end;

function TConnection.ExecScript(aFileName: String) : Boolean;
var
  wScript : TFDScript;
begin
  wScript := TFDScript.Create(nil);
  try
    wScript.Connection := fConnection;
    wScript.SQLScriptFileName := aFileName;
    wScript.OnError := OnError;
    Result := wScript.ValidateAll();
    if Result then
      Result := wScript.ExecuteAll();
  finally
    wScript.Free;
  end;
end;

function TConnection.ExecSQL(aSQL: String) : Integer;
begin
  Result := fConnection.ExecSQL(aSQL);
end;

procedure TConnection.OnError(aSender: TObject; aInitiator: TObject; var aException : Exception);
begin
  ShowMessage(aException.Message);
end;

function TConnection.Query(aSQL: String): TDataSet;
var
  wQuery : TFDQuery;
  i : Integer;
begin
  wQuery := TFDQuery.Create(fTrans);
  wQuery.Transaction := fTrans;
  wQuery.Connection := fConnection;
  wQuery.Open(aSQL);
  for i := 0 to wQuery.FieldCount - 1 do begin
    if wQuery.Fields[i] is TWideMemoField then
      TWideMemoField(wQuery.Fields[i]).DisplayValue := dvFull;
  end;
  Result := wQuery;
end;

end.

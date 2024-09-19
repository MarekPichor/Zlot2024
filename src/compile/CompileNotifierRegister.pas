unit CompileNotifierRegister;

interface

procedure Register;

implementation

uses
  OTAInterfaces, IDENotifier;

var
  NotifierIndex : Integer;

procedure Register;
begin
  NotifierIndex := Interfaces.Services.AddNotifier(TIDENotifier.Create());
end;

initialization
finalization
  Interfaces.Services.RemoveNotifier(NotifierIndex);

end.

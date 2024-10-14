unit MenuRegister;

interface

  procedure Register;

implementation

uses
  System.SysUtils, Menu;

var
  gMenu : TMenu;

procedure Register;
begin
  gMenu := TMenu.Create();
  gMenu.CreateMenu();
end;

initialization

finalization
  FreeAndNil(gMenu);

end.

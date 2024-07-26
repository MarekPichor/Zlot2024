unit Startup;

interface

uses
  Menu;

type
  TStartup = class
  private
    fMenu : TMenu;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

{ TStartup }

constructor TStartup.Create;
begin
  fMenu := TMenu.Create();
  fMenu.CreateMenu();
end;

destructor TStartup.Destroy;
begin
  FreeAndNil(fMenu);
  inherited;
end;

end.

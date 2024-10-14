unit Menu;

interface

uses
  Vcl.Menus, System.Classes;

type
  TMenu = class
  private const
    MENU_ITEM_NAME = 'MI_Zlot';
    MENU_ITEM_CAPTION = 'Zlot';
  private
    fMenuItem : TMenuItem;
    procedure CreateItem(aCaption : String; aOnClick : TNotifyEvent);
    procedure CreateItems();
  private
    procedure OnShowFileName(Sender : TObject);
  public
    procedure CreateMenu();
    destructor Destroy; override;
  end;

implementation

uses
  ToolsApi, System.SysUtils, Vcl.Dialogs, OTAInterfaces;

{ TMenu }

procedure TMenu.CreateItem(aCaption: String; aOnClick: TNotifyEvent);
var
  wMI : TMenuItem;
begin
  wMI := TMenuItem.Create(fMenuItem);
  wMI.Name := '';
  wMI.Caption := aCaption;
  wMI.OnClick := aOnClick;
  fMenuItem.Add(wMI);
end;

procedure TMenu.CreateItems;
begin
  CreateItem('Show file name', OnShowFileName);
end;

procedure TMenu.CreateMenu;
var
  wNTA : INTAServices;
begin
  wNTA := Interfaces.NTAServices;
  fMenuItem := TMenuItem.Create(nil);
  fMenuItem.Name := MENU_ITEM_NAME;
  fMenuItem.Caption := MENU_ITEM_CAPTION;
  wNTA.MainMenu.Items.Insert(wNTA.MainMenu.Items.Count - 2, fMenuItem);
  CreateItems();
end;

destructor TMenu.Destroy;
begin
  FreeAndNil(fMenuItem);
  inherited;
end;

procedure TMenu.OnShowFileName(Sender: TObject);
begin
  ShowMessage(ExtractFileName(Interfaces.CurrentModule.FileName));
end;

end.

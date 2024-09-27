unit TabManagerToolbar;

interface

uses
  Vcl.ComCtrls, Vcl.ActnList, TabManager, Winapi.Windows, Vcl.Controls, System.Classes;

type
  TTabManagerToolbar = class
  private
    fToolbar : TToolbar;
    fTest : String;
    fMenuAction : TAction;
    fToolButton : TToolButton;
    fTabManager : TTabManager;
    procedure OnMenuActionExecute(Sender : TObject);
    procedure RemoveToolbar();
    function FindToolButton(aName : String) : TToolButton;
    procedure UpdateToolbar();
    procedure OnTabSetLoad(Sender : TObject);
    procedure OnTabCustomize(Sender : TObject);
    procedure OnToolButtonPopup(Sender : TObject);
    procedure LoadDropDownMenu();
  public
    constructor Create();
    destructor Destroy; override;
    procedure Reset();
  end;

  procedure Register;

implementation

uses
  OTAInterfaces, ToolsApi, SysUtils, Vcl.Menus,
  System.Rtti, Vcl.Forms, Vcl.ExtCtrls, TabManagerCustomize;

type

  TToolbarAction = class(TAction)
  public
    destructor Destroy; override;
  end;

  TTabMenuItem = class(TMenuItem)
  private
    fTabSetName: String;
  public
    property TabSetName : String read fTabSetName write fTabSetName;
  end;

const
  TOOLBAR_NAME = 'TabManagerToolbar';
  MENUACTION_NAME = 'TabManagerMenuAction';
  TOOLBUTTON_NAME = 'TabManagerToolButton';

var
  gTabManagerToolbar : TTabManagerToolbar;

procedure Register;
begin
  gTabManagerToolbar := TTabManagerToolbar.Create();
end;

{ TToolbarManagerToolbar }

constructor TTabManagerToolbar.Create;
begin
  fTabManager := TTabManager.Create();
  UpdateToolbar();
end;

destructor TTabManagerToolbar.Destroy;
begin
  RemoveToolbar();
  FreeAndNil(fTabManager);
  inherited;
end;

function TTabManagerToolbar.FindToolButton(aName: String): TToolButton;
var
  i : Integer;
  wButton : TToolButton;
begin
  for i := 0 to fToolbar.ButtonCount - 1 do begin
    wButton := fToolbar.Buttons[i];
    if SameText(wButton.Name, aName) then
      Exit(wButton);
  end;
  Result := nil;
end;

procedure TTabManagerToolbar.LoadDropDownMenu;
var
  wNames : TStringList;
  wItem : TTabMenuItem;
  wName : String;
begin
  wNames := TStringList.Create();
  try
    fTabManager.LoadNames(wNames);
    wNames.Sort();
    fToolButton.DropdownMenu.Items.Clear();
    for wName in wNames do begin
      wItem := TTabMenuItem.Create(fToolButton.DropdownMenu);
      wItem.Caption := wName;
      wItem.TabSetName := wName;
      wItem.OnClick := OnTabSetLoad;
      fToolButton.DropdownMenu.Items.Add(wItem);
    end;

    if fToolButton.DropdownMenu.Items.Count > 0 then begin
      wItem := TTabMenuItem.Create(fToolButton.DropdownMenu);
      wItem.Caption := '-';
      fToolButton.DropdownMenu.Items.Add(wItem);
    end;

    wItem := TTabMenuItem.Create(fToolButton.DropdownMenu);
    wItem.Caption := 'Customize';
    wItem.OnClick := OnTabCustomize;
    fToolButton.DropdownMenu.Items.Add(wItem);

  finally
    wNames.Free;
  end;
end;

procedure TTabManagerToolbar.OnMenuActionExecute(Sender: TObject);
begin
  fTabManager.SaveCurrent();
end;

procedure TTabManagerToolbar.OnTabCustomize(Sender: TObject);
var
  wForm : TfTabManagerCustomize;
begin
  wForm := TfTabManagerCustomize.Create(nil, fTabManager);
  try
    wForm.ShowModal();
  finally
    wForm.Free;
  end;
end;

procedure TTabManagerToolbar.OnTabSetLoad(Sender: TObject);
begin
  if Sender is TTabMenuItem then begin
    fTabManager.Load(TTabMenuItem(Sender).TabSetName);
  end;
end;

procedure TTabManagerToolbar.OnToolButtonPopup(Sender: TObject);
begin
  LoadDropDownMenu();
end;

//based on http://blog.livedoor.jp/locked_empty_shell/archives/21319291.html
procedure TTabManagerToolbar.RemoveToolbar;
var
  ctx: TRttiContext;
  typ: TRttiType;
  fld: TRttiField;
  toolbars: array of TWinControl;
  i, j: Integer;
  btn: TToolButton;

begin
  typ := ctx.FindType('AppMain.TAppBuilder');
  if typ = nil then Exit;
  fld := typ.GetField('FToolbars');
  if fld = nil then Exit;
  fld.GetValue(Application.MainForm).ExtractRawData(@toolbars);
  for i := High(toolbars) downto Low(toolbars) do
    if toolbars[i] = fToolBar then
      Delete(toolbars, i, 1);
  TValue.From(toolbars).ExtractRawData(PByte(Application.MainForm) + fld.Offset);

  for j:= fToolBar.ButtonCount-1 downto 0 do begin
    btn := fToolBar.Buttons[j];
    fToolBar.Perform(CM_CONTROLCHANGE, WPARAM(btn), LPARAM(False));
    btn.Free;
  end;

  fToolBar.Free;

end;

procedure TTabManagerToolbar.Reset;
begin
  UpdateToolbar();
end;

procedure TTabManagerToolbar.UpdateToolbar;
begin
  fToolbar := Interfaces.NTAServices.ToolBar[TOOLBAR_NAME];
  if fToolbar = nil then begin
    fToolbar := Interfaces.NTAServices.NewToolbar(TOOLBAR_NAME, 'Tab manager', sCustomToolBar, True);
  end;

  fTest := fToolbar.Name;

  fMenuAction := TAction(fToolbar.FindComponent(MENUACTION_NAME));
  if fMenuAction = nil then begin
    fMenuAction := TToolbarAction.Create(fToolbar);
    fMenuAction.Name := MENUACTION_NAME;
  end;

  fMenuAction.Hint := 'Save opened tabs';
  fMenuAction.Caption := fMenuAction.Hint;
  fMenuAction.OnExecute := OnMenuActionExecute;
  fMenuAction.Enabled := True;
  Interfaces.NTAServices.AddActionMenu('', fMenuAction, nil);
  fMenuAction.Category := 'Tab manger';
  fMenuAction.ImageIndex := 3;

  fToolButton := FindToolButton(TOOLBUTTON_NAME);
  if fToolButton = nil then begin
    fToolButton := TToolButton(Interfaces.NTAServices.AddToolButton(TOOLBAR_NAME, TOOLBUTTON_NAME, fMenuAction));
  end;

  fToolButton.DropdownMenu := TPopupMenu.Create(fToolButton);
  fToolButton.Style := tbsDropDown;
  fToolButton.Enabled := True;
  fToolButton.Action := fMenuAction;
  fToolButton.DropdownMenu.OnPopup := OnToolButtonPopup;

end;

{ TToolbarAction }

destructor TToolbarAction.Destroy;
begin
  if gTabManagerToolbar <> nil then begin
    gTabManagerToolbar.Reset();
  end;
  inherited;
end;

initialization
finalization
  FreeAndNil(gTabManagerToolbar);

end.

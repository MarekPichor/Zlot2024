unit Wizard;

interface

uses
  ToolsApi, Startup;

type
  TIDEWizard = class(TNotifierObject, IOTAWizard)
  private
    fStartup : TStartup;
  public
    {IOTAWizard}
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
    constructor Create;
    destructor Destroy; override;
  end;

  procedure Register;

implementation

uses
  System.SysUtils;

procedure Register;
begin
  RegisterPackageWizard(TIDEWizard.Create);
end;

{ TIDEWizard }

constructor TIDEWizard.Create;
begin
  fStartup := TStartup.Create()
end;

destructor TIDEWizard.Destroy;
begin
  FreeAndNil(fStartup);
  inherited;
end;

procedure TIDEWizard.Execute;
begin

end;

function TIDEWizard.GetIDString: string;
begin
  Result := 'ZLOT.2024';
end;

function TIDEWizard.GetName: string;
begin
  Result := 'Zlot 2024';
end;

function TIDEWizard.GetState: TWizardState;
begin
  Result := [wsEnabled, wsChecked];
end;

end.

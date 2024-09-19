unit IDENotifier;

interface

uses
  ToolsApi, UsesAnalyzer;

type
  TIDENotifier = class(TInterfacedObject, IOTAIDENotifier)
  private
    fMessageGroup : IOTAMessageGroup;
    function GetProjectSettingsFileName(const Project: IOTAProject) : String;
    function GetProjectSettings(const Project: IOTAProject) : String;
    /// <summary>
    ///   Returns true when everything is OK
    /// </summary>
    function AnalyzeUses(const Project: IOTAProject) : Boolean;
    procedure OnUsesAnalyzerLog(const aContext : TUsesAnalyzerLogContext);
  public
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
  end;

implementation

uses
  System.SysUtils, OTAInterfaces, System.IOUtils, System.Classes;

{ TIDENotifier }

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin

end;

procedure TIDENotifier.AfterSave;
begin

end;

function TIDENotifier.AnalyzeUses(const Project: IOTAProject): Boolean;
var
  wFileList: TStringList;
  wUsesAnalyzer : TUsesAnalyzer;
  wSettings : String;
begin
  wSettings := GetProjectSettings(Project);
  if wSettings.IsEmpty() then
    Exit(True);
    
  wFileList := TStringList.Create();
  try
    Project.GetCompleteFileList(wFileList);
    wUsesAnalyzer := TUsesAnalyzer.Create(wSettings);
    try
      wUsesAnalyzer.OnLog := OnUsesAnalyzerLog;
      wUsesAnalyzer.Run(wFileList);
      Result := wUsesAnalyzer.Status <> uasError;

    finally
      FreeAndNil(wUsesAnalyzer);
    end;
  finally
    wFileList.Free;
  end;
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin
  if fMessageGroup = nil then
    fMessageGroup := Interfaces.MessageServices.AddMessageGroup('Uses analyzer');

  Interfaces.MessageServices.ClearMessageGroup(fMessageGroup);

  Cancel := not AnalyzeUses(Project);
end;

procedure TIDENotifier.BeforeSave;
begin

end;

procedure TIDENotifier.Destroyed;
begin

end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin

end;

function TIDENotifier.GetProjectSettings(const Project: IOTAProject): String;
var
  wFileName : String;
begin
  Result := '';
  wFileName := GetProjectSettingsFileName(Project);
  if not TFile.Exists(wFileName) then
    Exit;
  Result := TFile.ReadAllText(wFileName);
end;

function TIDENotifier.GetProjectSettingsFileName(
  const Project: IOTAProject): String;
begin
  Result := ChangeFileExt(Project.FileName, '.json');
end;

procedure TIDENotifier.Modified;
begin

end;

procedure TIDENotifier.OnUsesAnalyzerLog(const aContext : TUsesAnalyzerLogContext);
var
  wLineRef : Pointer;
  wLineNumber, wColumnNumber : Integer;

  function wIsCompilerMessage() : Boolean;
  begin
    Result := not aContext.FileName.IsEmpty() and (aContext.UsesItem <> nil);
  end;

begin
  if aContext.LogKind = lkError then begin
    if wIsCompilerMessage() then begin
      TUsesAnalyzer.GetLineAndColumnNumber(aContext, wLineNumber, wColumnNumber);
      Interfaces.MessageServices.AddCompilerMessage(aContext.FileName, aContext.LogMessage, TUsesAnalyzer.GetName(), otamkError, wLineNumber, wColumnNumber, nil, wLineRef, '');
    end;
    Interfaces.MessageServices.AddTitleMessage(aContext.LogMessage, fMessageGroup);

  end else
    Interfaces.MessageServices.AddToolMessage('', aContext.LogMessage, '', 0, 0, nil, wLineRef, fMessageGroup);
end;

end.

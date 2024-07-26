unit OTAInterfaces;

interface

uses
  ToolsApi;

type
  TOTAInterfaces = class
  private
    function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
  public
    function ProjectGroup : IOTAProjectGroup;
    function CurrentProject : IOTAProject;
    function CurrentModule : IOTAModule;
    function CurrentFormEditor : IOTAFormEditor;
    function FormEditor(const aModule : IOTAModule) : IOTAFormEditor;
    function Editor(const aModule : IOTAModule; aIndex : Integer) : IOTAEditor; overload;
    function ModuleServices : IOTAModuleServices;
    function NTAServices : INTAServices;
    function ActionServices : IOTAActionServices;
    function EditorViewServices : IOTAEditorViewServices;
    function Editor : IOTAEditor; overload;
    function SourceEditor : IOTASourceEditor;
    function EditView: IOTAEditView;
    function EditActions: IOTAEditActions;
    function EditBuffer: IOTAEditBuffer;
  end;

var
  Interfaces : TOTAInterfaces;

implementation

uses
  System.SysUtils, System.Classes;

{ TOTAInterfaces }

function TOTAInterfaces.ActionServices: IOTAActionServices;
begin
  Result := BorlandIDEServices as IOTAActionServices;
end;

function TOTAInterfaces.CurrentFormEditor: IOTAFormEditor;
var
  wModule: IOTAModule;
begin
  wModule := CurrentModule;
  if Assigned(wModule) then
  begin
    Result := FormEditor(wModule);
    Exit;
  end;
  Result := nil;
end;

function TOTAInterfaces.CurrentModule: IOTAModule;
var
  wModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, wModuleServices);
  if wModuleServices = nil then
    Result := nil
  else
    Result := wModuleServices.CurrentModule;
end;

function TOTAInterfaces.CurrentProject: IOTAProject;
var
  wProjectGroup: IOTAProjectGroup;
begin
  wProjectGroup := ProjectGroup;
  if Assigned(wProjectGroup) then
  begin
      try
        Result := wProjectGroup.ActiveProject;
        Exit;
      except
        ;
      end;
  end;
  Result := nil;
end;

function TOTAInterfaces.EditActions: IOTAEditActions;
begin
  QuerySvcs(EditView, IOTAEditActions, Result);
end;

function TOTAInterfaces.EditBuffer: IOTAEditBuffer;
var
  wEditorServices: IOTAEditorServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAEditorServices, wEditorServices);
  if wEditorServices <> nil then
  begin
    Result := wEditorServices.GetTopBuffer;
    Exit;
  end;
  Result := nil;
end;

function TOTAInterfaces.Editor: IOTAEditor;
var
  wModule : IOTAModule;
begin
  wModule := CurrentModule;
  if wModule = nil then
    Exit(nil);
  Result := wModule.CurrentEditor;
end;

function TOTAInterfaces.EditorViewServices: IOTAEditorViewServices;
begin
  Result := BorlandIDEServices as IOTAEditorViewServices;
end;

function TOTAInterfaces.EditView: IOTAEditView;
var
  wEditBuffer: IOTAEditBuffer;
begin
  wEditBuffer := EditBuffer;
  if wEditBuffer <> nil then
  begin
    Result := wEditBuffer.GetTopView;
    Exit;
  end;
  Result := nil;
end;

function TOTAInterfaces.Editor(const aModule: IOTAModule;
  aIndex: Integer): IOTAEditor;
begin
  Result := nil;
  if not Assigned(aModule) then Exit;
  try
    {$IFDEF BCB5}
    if IsCpp(Module.FileName) and (Module.GetModuleFileCount = 2) and (Index = 1) then
      Index := 2;   qweqwe
    {$ENDIF}
    Result := aModule.GetModuleFileEditor(aIndex);
  except
    Result := nil;
  end;
end;

function TOTAInterfaces.FormEditor(const aModule: IOTAModule): IOTAFormEditor;
var
  i: Integer;
  wEditor: IOTAEditor;
  wFormEditor: IOTAFormEditor;
begin
  if Assigned(aModule) then
  begin
      for i := 0 to aModule.GetModuleFileCount - 1 do
      begin
        wEditor := Editor(aModule, i);
        if Supports(wEditor, IOTAFormEditor, wFormEditor) then
        begin
          Result := wFormEditor;
          Exit;
        end;
      end;
  end;
  Result := nil;
end;

function TOTAInterfaces.ModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, Result);
end;

function TOTAInterfaces.NTAServices: INTAServices;
begin
  Result := BorlandIDEServices as INTAServices;
end;

function TOTAInterfaces.ProjectGroup: IOTAProjectGroup;
var
  wModuleServices: IOTAModuleServices;
  wModule: IOTAModule;
  i: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, wModuleServices);
  if wModuleServices <> nil then begin
    for i := 0 to wModuleServices.ModuleCount - 1 do
    begin
      wModule := wModuleServices.Modules[i];
      if Supports(wModule, IOTAProjectGroup, Result) then
        Exit;
    end;
  end;
  Result := nil;
end;

function TOTAInterfaces.QuerySvcs(const Instance: IInterface;
  const Intf: TGUID; out Inst): Boolean;
begin
  Result := (Instance <> nil) and Supports(Instance, Intf, Inst);
end;

function TOTAInterfaces.SourceEditor: IOTASourceEditor;
var
  wEditor : IOTAEditor;
begin
  wEditor := Editor;
  if wEditor = nil then
    Exit(nil);
  if wEditor.QueryInterface(IOTASourceEditor, Result) <> S_OK then
    Exit(nil);
end;

initialization
  Interfaces := TOTAInterfaces.Create();

finalization
  FreeAndNil(Interfaces);

end.

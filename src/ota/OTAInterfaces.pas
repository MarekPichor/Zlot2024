unit OTAInterfaces;

interface

uses
  ToolsApi;

type
/// <summary>
///   Wystawione interfejsy ToolsApi
/// </summary>
  TOTAInterfaces = class
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
    function DebuggerServices: IOTADebuggerServices;
    function ThemeServices: IOTAIDEThemingServices250;
    function CompileServices : IOTACompileServices;
    function Services: IOTAServices;
    function MessageServices: IOTAMessageServices;
    function EditorServices : IOTAEditorServices;
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

function TOTAInterfaces.CompileServices: IOTACompileServices;
begin
  Result := BorlandIDEServices as IOTACompileServices;
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
begin
  Result := ModuleServices.CurrentModule;
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

function TOTAInterfaces.DebuggerServices: IOTADebuggerServices;
begin
  Result := BorlandIDEServices as IOTADebuggerServices;
end;

function TOTAInterfaces.EditActions: IOTAEditActions;
begin
  Result := EditView as IOTAEditActions;
end;

function TOTAInterfaces.EditBuffer: IOTAEditBuffer;
begin
  Result := EditorServices.GetTopBuffer;
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

function TOTAInterfaces.EditorServices: IOTAEditorServices;
begin
  Result := BorlandIDEServices as IOTAEditorServices;
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
  Result := aModule.GetModuleFileEditor(aIndex)
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

function TOTAInterfaces.MessageServices: IOTAMessageServices;
begin
  Result := BorlandIDEServices as IOTAMessageServices;
end;

function TOTAInterfaces.ModuleServices: IOTAModuleServices;
begin
  Result := BorlandIDEServices as IOTAModuleServices;
end;

function TOTAInterfaces.NTAServices: INTAServices;
begin
  Result := BorlandIDEServices as INTAServices;
end;

function TOTAInterfaces.ProjectGroup: IOTAProjectGroup;
var
  wModule: IOTAModule;
  i: Integer;
begin
  for i := 0 to ModuleServices.ModuleCount - 1 do
  begin
    wModule := ModuleServices.Modules[i];
    if Supports(wModule, IOTAProjectGroup, Result) then
      Exit;
  end;
end;

function TOTAInterfaces.Services: IOTAServices;
begin
  Result := BorlandIDEServices as IOTAServices;
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

function TOTAInterfaces.ThemeServices: IOTAIDEThemingServices250;
begin
  Result := BorlandIDEServices as IOTAIDEThemingServices250;
end;

initialization
  Interfaces := TOTAInterfaces.Create();

finalization
  FreeAndNil(Interfaces);

end.

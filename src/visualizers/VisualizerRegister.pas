unit VisualizerRegister;

interface

procedure Register;

implementation

uses
  OTAInterfaces, ToolsAPI, Generics.Collections, ColorVisualizer,
  System.SysUtils, ImageVisualizer;

var
  Visualizers : TList<IOTADebuggerVisualizer>;

procedure Register;
var
  wDebuggerServices : IOTADebuggerServices;
  wVisualizer : IOTADebuggerVisualizer;
begin
  wDebuggerServices := Interfaces.DebuggerServices;
  if wDebuggerServices <> nil then begin
    Visualizers := TList<IOTADebuggerVisualizer>.Create();
    Visualizers.Add(TColorVisualizer.Create());
    Visualizers.Add(TImageVisualizer.Create());

    for wVisualizer in Visualizers do
      wDebuggerServices.RegisterDebugVisualizer(wVisualizer);
  end;
end;

procedure UnregisterVisualizers;
var
  wDebuggerServices : IOTADebuggerServices;
  wVisualizer : IOTADebuggerVisualizer;
begin
  if Visualizers <> nil then begin
    wDebuggerServices := Interfaces.DebuggerServices;
    if (wDebuggerServices <> nil) then begin
      for wVisualizer in Visualizers do
        wDebuggerServices.UnregisterDebugVisualizer(wVisualizer);
    end;
    FreeAndNil(Visualizers);
  end;
end;

initialization
finalization
  UnregisterVisualizers();

end.

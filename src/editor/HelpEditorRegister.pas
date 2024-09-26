unit HelpEditorRegister;

interface

procedure Register;

implementation

uses
  OTAInterfaces, HelpEditorView;

var
  fHelpEditorViewPointer : Pointer;

procedure Register;
begin
  fHelpEditorViewPointer := Interfaces.EditorViewServices.RegisterEditorSubView(THelpEditorView.Create());
end;

initialization
finalization
  Interfaces.EditorViewServices.UnregisterEditorSubView(fHelpEditorViewPointer);
end.

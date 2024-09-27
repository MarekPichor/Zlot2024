unit MessageUtils;

interface

function Question(aText : String) : Boolean;
function Input(aCaption, aPrompt : String; var aValue : String) : Boolean;

implementation

uses
  Vcl.Forms, Winapi.Windows, Vcl.Dialogs;

function Question(aText : String) : Boolean;
begin
  Result := MessageBox(Screen.ActiveForm.Handle, PChar(aText), 'Question', MB_YESNO + MB_ICONQUESTION) = IDYES;
end;

function Input(aCaption, aPrompt : String; var aValue : String) : Boolean;
begin
  Result := InputQuery(aCaption, aPrompt, aValue);
end;

end.

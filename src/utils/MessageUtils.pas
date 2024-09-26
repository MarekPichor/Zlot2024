unit MessageUtils;

interface

function Question(aText : String) : Boolean;

implementation

uses
  Vcl.Forms, Winapi.Windows;

function Question(aText : String) : Boolean;
begin
  Result := MessageBox(Screen.ActiveForm.Handle, PChar(aText), 'Question', MB_YESNO + MB_ICONQUESTION) = IDYES;
end;

end.

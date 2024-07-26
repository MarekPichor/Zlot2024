unit OTAFunctions;

interface

uses
  ToolsApi;

type
  TOTAFunctions = class
  public
   function Evaluate(Expression: string; aThread : IOTAThreadNotifier; out aCompleted : Boolean;
      out aDeferredResult : String; out aDeferredError : Boolean; out aNotifierIndex : Integer): string; overload;
  end;

var
  Functions : TOTAFunctions;

implementation

uses
  System.SysUtils;

{ TOTAFunctions }

function TOTAFunctions.Evaluate(Expression: string; aThread: IOTAThreadNotifier;
  out aCompleted: Boolean; out aDeferredResult: String;
  out aDeferredError: Boolean; out aNotifierIndex: Integer): string;
begin

end;

initialization
  Functions := TOTAFunctions.Create();

finalization
  FreeAndNil(Functions);

end.

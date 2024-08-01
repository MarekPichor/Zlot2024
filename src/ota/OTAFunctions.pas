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
  System.SysUtils, OTAInterfaces;

{ TOTAFunctions }

function TOTAFunctions.Evaluate(Expression: string; aThread: IOTAThreadNotifier;
  out aCompleted: Boolean; out aDeferredResult: String;
  out aDeferredError: Boolean; out aNotifierIndex: Integer): string;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ResultStr: array[0..4095] of Char;
  CanModify: Boolean;
  Done: Boolean;
  ResultAddr, ResultSize, ResultVal: LongWord;
  EvalRes: TOTAEvaluateResult;
  DebugSvcs: IOTADebuggerServices;
begin
  begin
    Result := '';
    DebugSvcs := Interfaces.DebuggerServices;
    if DebugSvcs <> nil then
      CurProcess := DebugSvcs.CurrentProcess;
    if CurProcess <> nil then begin
      CurThread := CurProcess.CurrentThread;
      if CurThread <> nil then begin
        repeat begin
          Done := True;
          EvalRes := CurThread.Evaluate(Expression, @ResultStr, Length(ResultStr),
            CanModify, eseAll, '', ResultAddr, ResultSize, ResultVal, '', 0);
          case EvalRes of
            erOK: Result := ResultStr;
            erDeferred:
              begin
                aCompleted := False;
                aDeferredResult := '';
                aDeferredError := False;
                aNotifierIndex := CurThread.AddNotifier(aThread);
                while not aCompleted do
                  DebugSvcs.ProcessDebugEvents;
                CurThread.RemoveNotifier(aNotifierIndex);
                aNotifierIndex := -1;
                if not aDeferredError then
                begin
                  if aDeferredResult <> '' then
                    Result := aDeferredResult
                  else
                    Result := ResultStr;
                end;
              end;
            erBusy:
              begin
                DebugSvcs.ProcessDebugEvents;
                Done := False;
              end;
          end;
        end until Done = True;
      end;
    end;
  end;
end;

initialization
  Functions := TOTAFunctions.Create();

finalization
  FreeAndNil(Functions);

end.

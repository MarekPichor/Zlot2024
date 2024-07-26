unit BaseVisualizer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsApi;

type
  TBaseVisualizer = class(TFrame, IOTAThreadNotifier, IOTAThreadNotifier160)
  private
    fCompleted: Boolean;
    fDeferredResult: string;
    fDeferredError: Boolean;
    fNotifierIndex : Integer;
  protected
    function Evaluate(aExpression : String) : String;
    property Completed : Boolean read fCompleted;
    property DeferredResult : String read fDeferredResult;
    property DeferredError : Boolean read fDeferredError;
    property NotifierIndex : Integer read fNotifierIndex;
  public
    { IOTAThreadNotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);
    { IOTAThreadNotifier160 }
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress: TOTAAddress; ResultSize: LongWord; ReturnCode: Integer);
  end;

implementation

uses
  OTAFunctions;

{$R *.dfm}

{ TBaseVisualizer }

procedure TBaseVisualizer.AfterSave;
begin

end;

procedure TBaseVisualizer.BeforeSave;
begin

end;

procedure TBaseVisualizer.Destroyed;
begin

end;

function TBaseVisualizer.Evaluate(aExpression: String): String;
begin
  Result := Functions.Evaluate(aExpression, Self, fCompleted, fDeferredResult, fDeferredError, fNotifierIndex);
end;

procedure TBaseVisualizer.EvaluateComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
  ReturnCode: Integer);
begin
  FCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
end;

procedure TBaseVisualizer.Modified;
begin

end;

procedure TBaseVisualizer.ModifyComplete(const ExprStr, ResultStr: string;
  ReturnCode: Integer);
begin

end;

procedure TBaseVisualizer.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

end.

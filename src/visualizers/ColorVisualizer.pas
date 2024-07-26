unit ColorVisualizer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ToolsApi, BaseVisualizer;

type
  TfmColorVisualizer = class(TBaseVisualizer, IOTADebuggerVisualizerExternalViewerUpdater)
  published
    P_Color: TPanel;
    E_Edit: TEdit;
  private
    procedure UpdateColor(aColor : TColor); overload;
    procedure UpdateColor(aExpression : String); overload;
  public
    procedure CloseVisualizer;
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason);
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string);
    procedure SetClosedCallback(ClosedProc: TOTAVisualizerClosedProcedure);
  end;

implementation

{$R *.dfm}

{ TfmColorVisualizer }

procedure TfmColorVisualizer.CloseVisualizer;
begin

end;

procedure TfmColorVisualizer.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin

end;

procedure TfmColorVisualizer.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin

end;

procedure TfmColorVisualizer.SetClosedCallback(
  ClosedProc: TOTAVisualizerClosedProcedure);
begin

end;

procedure TfmColorVisualizer.UpdateColor(aExpression: String);
var
  wRes : String;
begin
  wRes := Evaluate(aExpression);
  try
    P_Color.ShowCaption := False;
    P_Color.ParentBackground := False;
    UpdateColor(TColor(StrToInt(wRes)))
  except
    P_Color.ShowCaption := True;
    P_Color.Caption := 'Evaluate error!';
    P_Color.ParentBackground := True;
  end;
end;

procedure TfmColorVisualizer.UpdateColor(aColor: TColor);
begin
  P_Color.Color := aColor;
  E_Edit.Text := ColorToString(aColor);
end;

end.

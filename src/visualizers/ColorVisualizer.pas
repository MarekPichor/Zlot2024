unit ColorVisualizer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ToolsApi, BaseVisualizer;

type
  TColorVisualizer = class(TBaseVisualizer)
    function GetMenuText: string; override;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendents: Boolean); override;
    function GetSupportedTypeCount: Integer; override;
    function GetVisualizerDescription: string; override;
    function GetVisualizerIdentifier: string; override;
    function GetVisualizerName: string; override;
    function GetFormClass: TFormVisualizerClass; override;
  end;


  TfmColorVisualizer = class(TfrmBaseVisualizer)
  published
    P_Color: TPanel;
    E_Edit: TEdit;
  private
    procedure UpdateColor(aColor : TColor); overload;
    procedure UpdateColor(aExpression : String); overload;
  public
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason); override;
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string); override;
    constructor Create(AOwner: TComponent); override;

  end;

  TFormColorVisualizer = class(TFormBaseVisualizer)
  public
    function GetCaption: string; override;
    function GetFrameClass: TCustomFrameClass; override;
    function GetIdentifier: string; override;
  end;

implementation

{$R *.dfm}

{ TfmColorVisualizer }

constructor TfmColorVisualizer.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TfmColorVisualizer.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin
  inherited;
  UpdateColor(clNone);
end;

procedure TfmColorVisualizer.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin
  inherited;
  UpdateColor(Expression);
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

{ TFormColorVisualizer }

function TFormColorVisualizer.GetCaption: string;
begin
  Result := '[Zlot 2024] Wizualizacja koloru';
end;

function TFormColorVisualizer.GetFrameClass: TCustomFrameClass;
begin
  Result := TfmColorVisualizer;
end;

function TFormColorVisualizer.GetIdentifier: string;
begin
  Result := 'Zlot2024ColorVisualizer';
end;

{ TColorVisualizer }

function TColorVisualizer.GetFormClass: TFormVisualizerClass;
begin
  Result := TFormColorVisualizer;
end;

function TColorVisualizer.GetMenuText: string;
begin
  Result := 'Poka¿ kolor';
end;

procedure TColorVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendents: Boolean);
begin
  TypeName := 'TColor';
  AllDescendents := True;
end;

function TColorVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := 1;
end;

function TColorVisualizer.GetVisualizerDescription: string;
begin
  Result := 'Wizualizator kolorów stworzony na potrzeby Zlotu Delphi 2024';
end;

function TColorVisualizer.GetVisualizerIdentifier: string;
begin
  Result := 'Zlot2024ColorVisualizer';
end;

function TColorVisualizer.GetVisualizerName: string;
begin
  Result := '[Zlot2024] Color visualizer';
end;

end.

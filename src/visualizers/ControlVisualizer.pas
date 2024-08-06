unit ControlVisualizer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  BaseVisualizer, ToolsApi;

type
  TControlVisualizer = class(TBaseVisualizer)
    function GetMenuText: string; override;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendents: Boolean); override;
    function GetSupportedTypeCount: Integer; override;
    function GetVisualizerDescription: string; override;
    function GetVisualizerIdentifier: string; override;
    function GetVisualizerName: string; override;
    function GetFormClass: TFormVisualizerClass; override;
  end;

  TfmControlVisualizer = class(TfrmBaseVisualizer)
    P_Options: TPanel;
    L_Size: TLabel;
    P_Content: TPanel;
    I_Content: TImage;
    CB_Proportional: TCheckBox;
    CB_Stretch: TCheckBox;
    procedure CB_StretchClick(Sender: TObject);
    procedure CB_ProportionalClick(Sender: TObject);
  private
    procedure UpdateBitmap(aBmp : TBitmap);
    procedure UpdateControl(aExpression : String);
    procedure ShowInfo(aInfo : String);
  public
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason); override;
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string); override;
    constructor Create(AOwner: TComponent); override;
  end;

  TFormControlVisualizer = class(TFormBaseVisualizer)
  public
    function GetFrameClass: TCustomFrameClass; override;
    function GetIdentifier: string; override;
  end;

implementation

uses
  FileUtils;

{$R *.dfm}

{ TfmControlVisualizer }

procedure TfmControlVisualizer.CB_ProportionalClick(Sender: TObject);
begin
  inherited;
  I_Content.Proportional := CB_Proportional.Checked;
end;

procedure TfmControlVisualizer.CB_StretchClick(Sender: TObject);
begin
  inherited;
  I_Content.Stretch := CB_Stretch.Checked;
end;

constructor TfmControlVisualizer.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TfmControlVisualizer.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin
  inherited;
  UpdateBitmap(nil);
end;

procedure TfmControlVisualizer.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin
  inherited;
  UpdateControl(Expression);
end;

procedure TfmControlVisualizer.ShowInfo(aInfo: String);
begin
  I_Content.Visible := False;
  P_Content.ShowCaption := True;
  P_Content.Caption := aInfo;
  L_Size.Visible := False;
end;

procedure TfmControlVisualizer.UpdateBitmap(aBmp: TBitmap);
begin
  if aBmp = nil then begin
    ShowInfo('');
    Exit;
  end;
  I_Content.Visible := True;
  P_Content.ShowCaption := False;
  L_Size.Visible := True;
  L_Size.Caption := Format('%dx%d', [aBmp.Width, aBmp.Height]);
  I_Content.Picture.Assign(aBmp);
end;

procedure TfmControlVisualizer.UpdateControl(aExpression: String);
var
  wFileName : String;
  wBmp : TBitmap;
  wResult : String;
  wControlUtilsExists : Boolean;
begin
  wFileName := TFileUtils.TempDir + '\controlvisualizer';
  if FileExists(wFileName) then
    DeleteFile(wFileName);
  wControlUtilsExists := SameText(Evaluate('ControlUtilsObj.ClassName'), '''TControlUtils''');
  if not wControlUtilsExists then begin
    ShowInfo('ControlUtils not available in this context');
    Exit;
  end;

  wResult := Evaluate(Format('ControlUtilsObj.CanvasToFile(%s, ''%s'')', [aExpression, wFileName]));
  if FileExists(wFileName) then begin
    wBmp := TBitmap.Create();
    try
      wBmp.LoadFromFile(wFileName);
      UpdateBitmap(wBmp);
    finally
      wBmp.Free;
    end;
  end else begin
    ShowInfo(DeferredResult);
  end;
end;

{ TFormControlVisualizer }

function TFormControlVisualizer.GetFrameClass: TCustomFrameClass;
begin
  Result := TfmControlVisualizer;
end;

function TFormControlVisualizer.GetIdentifier: string;
begin
  Result := 'Zlot2024ControlVisualizer';
end;

{ TControlVisualizer }

function TControlVisualizer.GetFormClass: TFormVisualizerClass;
begin
  Result := TFormControlVisualizer;
end;

function TControlVisualizer.GetMenuText: string;
begin
  Result := 'Poka¿ kontrolkê';
end;

procedure TControlVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendents: Boolean);
begin
  inherited;
  TypeName := 'TControl';
  AllDescendents := True;
end;

function TControlVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := 1;
end;

function TControlVisualizer.GetVisualizerDescription: string;
begin
  Result := 'Wizualizator kontrolek stworzony na potrzeby Zlotu Delphi 2024';
end;

function TControlVisualizer.GetVisualizerIdentifier: string;
begin
  Result := 'Zlot2024ControlVisualizer';
end;

function TControlVisualizer.GetVisualizerName: string;
begin
  Result := '[Zlot2024] Control visualizer';
end;

end.

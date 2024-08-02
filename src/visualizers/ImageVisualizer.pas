unit ImageVisualizer;

interface

uses
  BaseVisualizer, Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, ToolsApi,
  System.Classes, Vcl.Controls, Vcl.Forms;

type
  TImageVisualizer = class(TBaseVisualizer)
    function GetMenuText: string; override;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendents: Boolean); override;
    function GetSupportedTypeCount: Integer; override;
    function GetVisualizerDescription: string; override;
    function GetVisualizerIdentifier: string; override;
    function GetVisualizerName: string; override;
    function GetFormClass: TFormVisualizerClass; override;
  end;

  TfmImageVisualizer = class(TfrmBaseVisualizer)
    P_Content: TPanel;
    I_Content: TImage;
    CB_Stretch: TCheckBox;
    CB_Proportional: TCheckBox;
    procedure CB_StretchClick(Sender: TObject);
    procedure CB_ProportionalClick(Sender: TObject);
  published
    P_Options: TPanel;
    L_Size: TLabel;
  private
    procedure UpdateImage(aGraphic : TGraphic); overload;
    procedure UpdateImage(aExpression : String; aTypeName : String); overload;
    procedure ShowInfo(aInfo : String);
  public
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason); override;
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string); override;
    constructor Create(AOwner: TComponent); override;
  end;

  TFormImageVisualizer = class(TFormBaseVisualizer)
  public
    function GetFrameClass: TCustomFrameClass; override;
    function GetIdentifier: string; override;
  end;

implementation

uses
  System.SysUtils, Vcl.Imaging.PngImage, FileUtils, OtaInterfaces;

{$R *.dfm}

{ TfmImageVisualizer }

procedure TfmImageVisualizer.CB_ProportionalClick(Sender: TObject);
begin
  I_Content.Proportional := CB_Proportional.Checked;
end;

procedure TfmImageVisualizer.CB_StretchClick(Sender: TObject);
begin
  I_Content.Stretch := CB_Stretch.Checked;
end;

constructor TfmImageVisualizer.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TfmImageVisualizer.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin
  inherited;
  UpdateImage(nil);
end;

procedure TfmImageVisualizer.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin
  inherited;
  UpdateImage(Expression, TypeName);
end;

procedure TfmImageVisualizer.ShowInfo(aInfo: String);
begin
  I_Content.Visible := False;
  P_Content.ShowCaption := True;
  P_Content.Caption := aInfo;
  L_Size.Visible := False;
end;

procedure TfmImageVisualizer.UpdateImage(aGraphic: TGraphic);
begin
  if aGraphic = nil then begin
    ShowInfo('');
    Exit;
  end;
  I_Content.Visible := True;
  P_Content.ShowCaption := False;
  L_Size.Visible := True;
  L_Size.Caption := Format('%dx%d', [aGraphic.Width, aGraphic.Height]);
  if aGraphic.Width = 0 then
    aGraphic := nil;
  I_Content.Picture.Assign(aGraphic);
end;

procedure TfmImageVisualizer.UpdateImage(aExpression: String; aTypeName : String);
var
  wFileName : String;
  wGraphic : TGraphic;
  wWidth : Integer;
  wGraphicEvaluate : String;
begin
  wGraphicEvaluate := Evaluate(aExpression);
  if SameText(wGraphicEvaluate, 'nil') then begin
    UpdateImage(nil);
    Exit;
  end;

  if SameText(aTypeName, 'TBitmap') then begin
    wGraphic := TBitmap.Create;
  end else begin
    wGraphic := TPngImage.Create;
  end;

  try
    wFileName := TFileUtils.TempDir + '\imagevisualizer';
    DeleteFile(wFileName);

    Evaluate(Format('%s.SaveToFile(''%s'')', [aExpression, wFileName]));

    if FileExists(wFileName) then begin

      wWidth := Evaluate(aExpression + '.Width').ToInteger;
      if wWidth = 0 then begin
        UpdateImage(wGraphic);
        Exit;
      end;

      wGraphic.LoadFromFile(wFileName);
      UpdateImage(wGraphic);
    end else begin
      ShowInfo(Format('B³¹d przetwarzania ¿¹dania (%s)', [DeferredResult]));
    end;
  finally
    FreeAndNil(wGraphic);
  end;
end;

{ TFormImageVisualizer }

function TFormImageVisualizer.GetFrameClass: TCustomFrameClass;
begin
  Result := TfmImageVisualizer;
end;

function TFormImageVisualizer.GetIdentifier: string;
begin
  Result := 'Zlot2024ImageVisualizer';
end;

{ TImageVisualizer }

function TImageVisualizer.GetFormClass: TFormVisualizerClass;
begin
  Result := TFormImageVisualizer;
end;

function TImageVisualizer.GetMenuText: string;
begin
  Result := 'Poka¿ zdjêcie';
end;

procedure TImageVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendents: Boolean);
begin
  inherited;
  AllDescendents := True;
  case Index of
    0: TypeName := 'TBitmap';
    1: TypeName := 'TPngImage';
    else
      raise Exception.Create('Implementation of GetSupportedType and result of GetSupportedTypeCount does not match');
  end;
end;

function TImageVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := 2;
end;

function TImageVisualizer.GetVisualizerDescription: string;
begin
  Result := 'Wizualizator zdjêæ stworzony na potrzeby Zlotu Delphi 2024';
end;

function TImageVisualizer.GetVisualizerIdentifier: string;
begin
  Result := 'Zlot2024ImageVisualizer';
end;

function TImageVisualizer.GetVisualizerName: string;
begin
  Result := '[Zlot2024] Image visualizer';
end;

end.

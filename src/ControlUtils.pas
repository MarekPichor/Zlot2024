unit ControlUtils;

interface

uses
  Vcl.Controls, Winapi.Windows, Vcl.Graphics;

type
  TControlUtils = class
  private
    function GetExistingCanvas(aControl : TControl) : TCanvas;
  public
    procedure CanvasToFile(aControl : TControl; aFileName : String);
  end;

  var ControlUtilsObj : TControlUtils;

implementation

uses
  System.SysUtils;

{ TControlUtils }

type
  TGraphicControlH = class(TGraphicControl);
  TCustomControlH = class(TCustomControl);

procedure TControlUtils.CanvasToFile(aControl: TControl; aFileName: String);
var
  wCanvas : TControlCanvas;
  wExistingCanvas : TCanvas;
  wBmp : TBitmap;
  wRect : TRect;
begin
  if aControl = nil then
    Exit;

  wCanvas := TControlCanvas.Create();
  try
    wCanvas.Control := aControl;
    wBmp := TBitmap.Create();
    try
      wBmp.Width := aControl.Width;
      wBmp.Height := aControl.Height;

      wRect := TRect.Create(0, 0, wBmp.Width, wBmp.Height);
      wBmp.Canvas.CopyRect(wRect, wCanvas, wRect);

      wExistingCanvas := GetExistingCanvas(aControl);
      if wExistingCanvas <> nil then
        wBmp.Canvas.CopyRect(wRect, wExistingCanvas, wRect);

      wBmp.SaveToFile(aFileName);
    finally
      wBmp.Free;
    end;
  finally
      wCanvas.Free;
  end;
end;

function TControlUtils.GetExistingCanvas(aControl: TControl): TCanvas;
begin
  Result := nil;
  if aControl is TCustomControl then
    Result := TCustomControlH(aControl).Canvas;
  if aControl is TGraphicControl then
    Result := TGraphicControlH(aControl).Canvas;
end;

initialization
  ControlUtilsObj := TControlUtils.Create();

finalization
  FreeAndNil(ControlUtilsObj);

end.

unit ControlUtils;

interface

uses
  Vcl.Controls, Winapi.Windows, Vcl.Graphics, System.Classes;

type
  TControlUtils = class
  private
    function GetExistingCanvas(aControl : TControl) : TCanvas;
  public
    procedure CanvasToFile(aControl : TControl; aFileName : String);
    function RecursiveSearchByClassName(aControl : TControl; aControlClassName : String) : TArray<TComponent>;
  end;

  var ControlUtilsObj : TControlUtils;

implementation

uses
  System.SysUtils, Generics.Collections;

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

function TControlUtils.RecursiveSearchByClassName(aControl: TControl;
  aControlClassName: String): TArray<TComponent>;
var
  wList : TList<TComponent>;

  procedure wInternalFind(aComponent : TComponent);
  var
    i : Integer;
  begin
    if aComponent = nil then
      Exit;
    for i := 0 to aComponent.ComponentCount - 1 do begin
      if SameText(aComponent.Components[i].ClassName, aControlClassName) then
        if not wList.Contains(aComponent.Components[i]) then
          wList.Add(aComponent.Components[i]);
      wInternalFind(aComponent.Components[i]);
    end;

    if aComponent is TWinControl then
      for i := 0 to TWinControl(aComponent).ControlCount - 1 do begin
        if SameText(TWinControl(aComponent).Controls[i].ClassName, aControlClassName) then
          if not wList.Contains(TWinControl(aComponent).Controls[i]) then
            wList.Add(TWinControl(aComponent).Controls[i]);
        wInternalFind(TWinControl(aComponent).Controls[i]);
      end;
  end;

begin
  wList := TList<TComponent>.Create;
  try
    wInternalFind(aControl);
    Result := wList.ToArray();
  finally
    wList.Free;
  end;
end;


initialization
  ControlUtilsObj := TControlUtils.Create();

finalization
  FreeAndNil(ControlUtilsObj);

end.

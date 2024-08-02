unit PngUtils;

interface

uses Vcl.Imaging.pngimage;

procedure ScalePngImageAR(aPngImage: TPngImage; aSize: Integer);

implementation

uses
  Winapi.Windows, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.Classes,
  System.SysUtils, Winapi.GDIPUTIL, Winapi.ActiveX;

function CreateScaledPngImageGDIPlus(aPngImage: TPngImage;
  aWidth, aHeight: Integer): TPngImage;
var
  Input: TGPImage;
  Output: TGPBitmap;
  wEncoderClsid: TGUID;
  Graphics: TGPGraphics;
  wMS: TMemoryStream;
  wStream: IStream;
begin
  Result := nil;
  wMS := TMemoryStream.Create;
  aPngImage.SaveToStream(wMS);
  wStream := TStreamAdapter.Create(wMS);
  Input := TGPImage.Create(wStream);
  try
    Output := TGPBitmap.Create(aWidth, aHeight, PixelFormat32bppARGB);
    try
      Graphics := TGPGraphics.Create(Output);
      try
        Graphics.SetCompositingMode(CompositingModeSourceCopy);
        Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
        Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
        Graphics.SetSmoothingMode(SmoothingModeHighQuality);
        Graphics.DrawImage(Input, 0, 0, Output.GetWidth, Output.GetHeight);
      finally
        Graphics.Free;
        FreeAndNil(wMS);
        wStream := nil;
      end;
      wMS := TMemoryStream.Create;
      wStream := TStreamAdapter.Create(wMS);
      try
        if GetEncoderClsid('image/png', wEncoderClsid) <> -1 then
        begin
          Output.Save(wStream, wEncoderClsid);
          wMS.Position := 0;
          Result := TPngImage.Create;
          Result.LoadFromStream(wMS);
        end;
      finally
        FreeAndNil(wMS);
        wStream := nil;
      end;
    finally
      Output.Free;
    end;
  finally
    Input.Free;
    FreeAndNil(wMS);
    wStream := nil;
  end;
end;

function CreateScaledPngImage(aPngImage: TPngImage; aWidth, aHeight: Integer)
  : TPngImage;
begin
  if aPngImage = nil then
    Exit(nil);
  Result := CreateScaledPngImageGDIPlus(aPngImage, aWidth, aHeight);
end;

function CreateScaledPngImageW(aPngImage: TPngImage; aWidth: Integer)
  : TPngImage;
var
  wRatio: Currency;
  wHeight: Integer;
begin
  wRatio := aPngImage.Width / aPngImage.Height;
  wHeight := Trunc(aWidth / wRatio);
  Result := CreateScaledPngImage(aPngImage, aWidth, wHeight);
end;

function CreateScaledPngImageH(aPngImage: TPngImage; aHeight: Integer)
  : TPngImage;
var
  wRatio: Currency;
  wWidth: Integer;
begin
  wRatio := aPngImage.Width / aPngImage.Height;
  wWidth := Trunc(aHeight * wRatio);
  Result := CreateScaledPngImage(aPngImage, wWidth, aHeight);
end;

function CreateScaledPngImageAR(aPngImage: TPngImage; aSize: Integer)
  : TPngImage;
begin
  if aPngImage.Width > aPngImage.Height then
    Result := CreateScaledPngImageW(aPngImage, aSize)
  else
    Result := CreateScaledPngImageH(aPngImage, aSize);
end;

procedure ScalePngImageAR(aPngImage: TPngImage; aSize: Integer);
var
  wPngImage : TPngImage;
begin
  wPngImage := CreateScaledPngImageAR(aPngImage, aSize);
  try
    aPngImage.Assign(wPngImage);
  finally
    wPngImage.Free;
  end;
end;

end.

unit Grid;

interface

uses
  Data.DB, Vcl.DBGrids, Vcl.Graphics, Winapi.Windows, Vcl.Grids,
  System.Classes, Winapi.Messages, Vcl.Controls, Vcl.Imaging.PngImage,
  System.Generics.Collections;

type
  TImageBuffer = TDictionary<Integer, TPngImage>;

  TGrid = class(TDBGrid)
  private
    fImageBuffer : TImageBuffer;
  protected
    procedure DrawCell(ACol: Integer; ARow: Integer; ARect: TRect;
      AState: TGridDrawState); override;
    procedure LayoutChanged; override;
    procedure DrawImage(aRect : TRect; aField : TField);
    function GetBackgroundColor(aState : TGridDrawState) : TColor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, PngUtils;

{ TGrid }

constructor TGrid.Create(AOwner: TComponent);
begin
  inherited;
  Options := Options + [dgRowSelect] - [dgIndicator];
  fImageBuffer := TImageBuffer.Create();
end;

destructor TGrid.Destroy;
begin
  FreeAndNil(fImageBuffer);
  inherited;
end;

procedure TGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  wText : String;
  wOldActiveRecord : Integer;
begin
  Canvas.Brush.Color := GetBackgroundColor(aState);
  Canvas.FillRect(aRect);

  wText := '';

  if gdFixed in aState then begin
    wText := Columns[aCol].Field.FieldName;
  end else begin
    wOldActiveRecord := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := aRow - Ord(dgTitles in Options);
      if Columns[aCol].Field is TBlobField then begin
        DrawImage(aRect, Columns[aCol].Field);
      end else begin
        wText := Columns[aCol].Field.DisplayText;
      end;
    finally
      DataLink.ActiveRecord := wOldActiveRecord;
    end;
  end;

  if not wText.IsEmpty() then
    Canvas.TextRect(ARect, wText, [tfCenter, tfEndEllipsis, tfVerticalCenter, tfSingleLine]);
end;

procedure TGrid.DrawImage(aRect: TRect; aField: TField);
var
  wPngImage : TPngImage;
  wMS : TMemoryStream;
  wId : Integer;
begin
  wId := aField.DataSet.FieldByName('id').AsInteger;
  if fImageBuffer.ContainsKey(wId) then
    wPngImage := fImageBuffer[wId]
  else begin
    wPngImage := TPngImage.Create();
    wMS := TMemoryStream.Create();
    try
      TBlobField(aField).SaveToStream(wMS);
      wMs.Position := 0;
      wPngImage.LoadFromStream(wMS);
      ScalePngImageAR(wPngImage, aRect.Height);
      fImageBuffer.Add(wId, wPngImage);
    finally
      wMS.Free;
    end;
  end;
 Canvas.Draw(aRect.Left + (aRect.Width - wPngImage.Width) div 2, aRect.Top, wPngImage);
end;

function TGrid.GetBackgroundColor(aState: TGridDrawState): TColor;
begin
  if gdFixed in AState then
    Result := $00B2B2FF
  else if gdSelected in AState then
    Result := $00FAD1D1
  else
    Result := clWhite;
end;

procedure TGrid.LayoutChanged;
begin
  inherited;
  DefaultRowHeight := 64;
  DefaultColWidth := 200;
  RowHeights[0] := DefaultRowHeight div 2;
end;

end.

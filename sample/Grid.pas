unit Grid;

interface

uses
  Data.DB, Vcl.DBGrids, Vcl.Graphics, Winapi.Windows, Vcl.Grids,
  System.Classes, Winapi.Messages, Vcl.Controls;

type
  TGrid = class(TDBGrid)
  protected
    procedure DrawCell(ACol: Integer; ARow: Integer; ARect: TRect;
      AState: TGridDrawState); override;

    procedure LayoutChanged; override;
    procedure DrawDataCell(const Rect: TRect; Field: TField;
      State: TGridDrawState); override;

  public
    constructor Create(AOwner: TComponent); override;


  end;

implementation

{ TGrid }

constructor TGrid.Create(AOwner: TComponent);
begin
  inherited;
  Options := Options + [dgRowSelect] - [dgIndicator];
end;

procedure TGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  wText : String;
  wOldActiveRecord : Integer;
begin

  if gdFixed in AState then
    Canvas.Brush.Color := clRed
  else if gdSelected in AState then
    Canvas.Brush.Color := $00FAD1D1
  else
    Canvas.Brush.Color := clWhite;
  Canvas.FillRect(aRect);

  if not (gdFixed in aState) then begin
    wOldActiveRecord := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := aRow - Ord(dgTitles in Options);
      wText := Columns[aCol].Field.DisplayText;
      Canvas.TextRect(ARect, wText, []);
    finally
      DataLink.ActiveRecord := wOldActiveRecord;
    end;
  end;
end;

procedure TGrid.DrawDataCell(const Rect: TRect; Field: TField;
  State: TGridDrawState);
var
  wText : String;
  wRect : TRect;
begin
  inherited;
  wText := Field.AsString;
  wRect := Rect;
  Canvas.TextRect(wRect, wText, []);
end;

procedure TGrid.LayoutChanged;
begin
  inherited;
  DefaultRowHeight := 64;
  DefaultColWidth := 200;
  RowHeights[0] := DefaultRowHeight div 2;
end;

end.

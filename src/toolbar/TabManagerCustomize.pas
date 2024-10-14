unit TabManagerCustomize;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, TabManager,
  Vcl.Menus;

type
  TfTabManagerCustomize = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SG_TabSetContent: TStringGrid;
    SG_TabSets: TStringGrid;
    Splitter1: TSplitter;
    PM_Sets: TPopupMenu;
    Remove1: TMenuItem;
    Rename1: TMenuItem;
    PM_Unit: TPopupMenu;
    MenuItem2: TMenuItem;
    procedure SG_TabSetsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SG_TabSetsDblClick(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
  private
    fTabManager : TTabManager;
    procedure UpdateTabSetsGrid();
    procedure UpdateTabSetContent();
    function GetCurrentSet() : String;
    function GetCurrentUnit() : String;
    procedure ResizeGrids();
  public
    constructor Create(aOwner : TComponent; aTabManager : TTabManager); reintroduce;
  end;

implementation

uses
  System.Math, MessageUtils;

{$R *.dfm}

{ TfTabManagerCustomize }

constructor TfTabManagerCustomize.Create(aOwner: TComponent;
  aTabManager: TTabManager);
begin
  fTabManager := aTabManager;
  inherited Create(aOwner);
end;


procedure TfTabManagerCustomize.FormResize(Sender: TObject);
begin
  ResizeGrids();
end;

procedure TfTabManagerCustomize.FormShow(Sender: TObject);
begin
  UpdateTabSetsGrid();
end;

function TfTabManagerCustomize.GetCurrentSet: String;
begin
  Result := SG_TabSets.Cells[0, SG_TabSets.Row];
end;

function TfTabManagerCustomize.GetCurrentUnit: String;
var
  wName : String;
  wTabSet : TTabset;
  wIndex : Integer;
begin
  wName := GetCurrentSet();
  if wName.IsEmpty() then
    Exit('');

  wTabSet := fTabManager.GetTabSet(wName);
  if wTabSet = nil then
    Exit('');

  wIndex := SG_TabSetContent.Row - SG_TabSetContent.FixedRows;
  if (wIndex < 0) or (wIndex > wTabSet.Tabs.Count - 1) then
    Exit('');

  Result := wTabSet.Tabs[wIndex];
end;

procedure TfTabManagerCustomize.MenuItem2Click(Sender: TObject);
var
  wName : String;
  wTabSet : TTabSet;
  wUnit : String;
begin
  wName := GetCurrentSet();
  if not wName.IsEmpty() then begin
    wTabSet := fTabManager.GetTabSet(wName);
    wUnit := GetCurrentUnit();
    wTabSet.Tabs.Remove(wUnit);
    fTabManager.SaveTabSetList();
    UpdateTabSetContent();
  end;
end;

procedure TfTabManagerCustomize.Remove1Click(Sender: TObject);
var
  wName : String;
begin
  wName := GetCurrentSet();
  if not wName.IsEmpty() then begin
    if fTabManager.RemoveTabSet(wName) then
      UpdateTabSetsGrid();
  end;

end;

procedure TfTabManagerCustomize.Rename1Click(Sender: TObject);
var
  wName : String;
  wTabSet : TTabSet;
begin
  wName := GetCurrentSet();
  if not wName.IsEmpty() then begin
    wTabSet := fTabManager.GetTabSet(wName);
    if wTabSet <> nil then begin
      if Input('Name', 'New name of the tab list', wName) then begin
        wTabSet.Name := wName;
        fTabManager.SaveTabSetList();
        UpdateTabSetsGrid();
      end;
    end;
  end;
end;

procedure TfTabManagerCustomize.ResizeGrids;
begin
  SG_TabSets.ColWidths[0] := SG_TabSets.Width;
  SG_TabSetContent.ColWidths[0] := SG_TabSetContent.Width;
end;

procedure TfTabManagerCustomize.SG_TabSetsClick(Sender: TObject);
begin
  UpdateTabSetContent();
end;

procedure TfTabManagerCustomize.SG_TabSetsDblClick(Sender: TObject);
var
  wName : String;
begin
  wName := GetCurrentSet();
  if not wName.IsEmpty() then begin
    Close();
    fTabManager.Load(GetCurrentSet());
  end;
end;

procedure TfTabManagerCustomize.Splitter1Moved(Sender: TObject);
begin
  ResizeGrids();
end;

procedure TfTabManagerCustomize.UpdateTabSetContent;
var
  wTabSet : TTabSet;
  i : Integer;
  wUnit : String;
begin
  SG_TabSetContent.FixedCols := 0;
  SG_TabSetContent.ColCount := 1;
  SG_TabSetContent.FixedRows := 1;
  SG_TabSetContent.Cells[0, 0] := 'Unit';
  SG_TabSetContent.Cells[0, 1] := '';

  wTabSet := fTabManager.GetTabSet(GetCurrentSet());
  if wTabSet = nil then begin
    SG_TabSetContent.RowCount := 2;
    Exit;
  end;
  SG_TabSetContent.RowCount := SG_TabSetContent.FixedRows + Max(1, wTabSet.Tabs.Count);
  for i := 0 to wTabSet.Tabs.Count - 1 do begin
    wUnit := ExtractFileName(wTabSet.Tabs[i]);
    SG_TabSetContent.Cells[0, i + 1] := wUnit;
  end;
end;

procedure TfTabManagerCustomize.UpdateTabSetsGrid;
var
  wNames : TStringList;
  i : Integer;
begin
  SG_TabSets.FixedCols := 0;
  SG_TabSets.ColCount := 1;
  SG_TabSets.FixedRows := 1;
  SG_TabSets.Cells[0, 0] := 'Tab set name';
  SG_TabSets.Cells[0, 1] := '';

  wNames := TStringList.Create();
  try
    fTabManager.LoadNames(wNames);
    SG_TabSets.RowCount := SG_TabSets.FixedRows + Max(1, wNames.Count);
    for i := 0 to wNames.Count - 1 do begin
      SG_TabSets.Cells[0, i + SG_TabSets.FixedRows] := wNames[i];
    end;
      
  finally
    wNames.Free;
  end;

  UpdateTabSetContent();
end;

end.

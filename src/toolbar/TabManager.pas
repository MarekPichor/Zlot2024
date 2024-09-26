unit TabManager;

interface

uses
  ToolsApi, System.Classes, Generics.Collections;

type
  TTabSet = class
  private
    fName: String;
    fTabs: TList<String>;
  public
    constructor Create;
    destructor Destroy; override;
    property Tabs : TList<String> read fTabs write fTabs;
    property Name : String read fName write fName;
  end;

  TTabSetList = class
  private
    fSets: TObjectList<TTabSet>;
  public
    property Sets: TObjectList<TTabSet> read fSets write fSets;
    constructor Create();
    destructor Destroy; override;

    function ToJson() : String;
    procedure FromJson(aJson : String);
  end;

  TTabManager = class
  private
    fTabSetList : TTabSetList;
    function GetModule(aUnitName : String) : IOTAModule;
    function GetTabsInOrder() : TStringList;
    function GetModulesInOrder() : TArray<IOTAModule>;
    function SaveCurrent(aName : String) : Boolean; overload;
    function Save(aTabSet : TTabSet) : Boolean;
    function GetTabSet(aName : String) : TTabSet;
    function GetFileName() : String;
    procedure LoadTabSetList();
    procedure SaveTabSetList();
    procedure RestoreTabs(aTabSet : TTabSet);
    procedure CloseAllTabs();
  public
    function SaveCurrent() : Boolean; overload;
    procedure Load(aName : String);
    procedure LoadNames(aList : TStrings);
    destructor Destroy; override;
  end;

implementation

uses
  OTAInterfaces, Vcl.Dialogs, System.SysUtils, System.IOUtils,
  ControlUtils, Vcl.Forms, RTTIUtils, MessageUtils, System.JSON;

{ TTabManager }

procedure TTabManager.CloseAllTabs;
var
  wModule : IOTAModule;
begin
  wModule := Interfaces.ModuleServices.CurrentModule;
  while wModule <> nil do begin
    if SameText(ExtractFileExt(wModule.FileName), '.pas') then
      wModule.CloseModule(False)
    else
      Break;
    wModule := Interfaces.ModuleServices.CurrentModule;
  end;
end;

destructor TTabManager.Destroy;
begin
  FreeAndNil(fTabSetList);
  inherited;
end;

function TTabManager.GetFileName: String;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'modulemanager.json';
end;

function TTabManager.GetModule(aUnitName: String): IOTAModule;
var
  i : Integer;
  wModule : IOTAModule;
  wUnitName : String;
begin
  for i := 0 to Interfaces.ModuleServices.ModuleCount - 1 do begin
    wModule := Interfaces.ModuleServices.Modules[i];
    wUnitName := ChangeFileExt(ExtractFileName(wModule.FileName), '');
    if SameText(wUnitName, aUnitName) then
      Exit(wModule);
  end;
  Result := nil;
end;

function TTabManager.GetTabSet(aName: String): TTabSet;
var
  wTabSet : TTabSet;
begin
  Result := nil;
  if fTabSetList = nil then
    Exit;

  for wTabSet in fTabSetList.Sets do
    if SameText(wTabSet.Name, aName) then
      Exit(wTabSet);
end;

function TTabManager.GetModulesInOrder: TArray<IOTAModule>;
var
  wTabs : TStringList;
  i : Integer;
  wModule : IOTAModule;
  wList : TList<IOTAModule>;
begin
  wTabs := GetTabsInOrder();
  if (wTabs = nil) or (wTabs.Count = 0) then
    Exit;

  wList := TList<IOTAModule>.Create();
  try
    for i := 0 to wTabs.Count - 1 do begin
      wModule := GetModule(wTabs[i]);
      if wModule <> nil then
        wList.Add(wModule);
    end;
    Result := wList.ToArray();
  finally
    wList.Free;
  end;
end;

function TTabManager.GetTabsInOrder: TStringList;
var
  wTabComponents : TArray<TComponent>;
  wTabSet : TComponent;
begin
  Result := nil;
  wTabComponents := ControlUtilsObj.RecursiveSearchByClassName(Application.MainForm, 'TIDEGradientTabSet');
  if (Length(wTabComponents) > 0) and (wTabComponents[0] is TComponent) then begin
    wTabSet := TComponent(wTabComponents[0]);
    Result := TStringList(Pointer(Cardinal(RTTI_GetProperty(wTabSet, 'Tabs'))));
  end;
end;

procedure TTabManager.Load(aName: String);
var
  wTabSet : TTabSet;
begin
  LoadTabSetList();
  wTabSet := GetTabSet(aName);
  if wTabSet <> nil then begin
    CloseAllTabs();
    RestoreTabs(wTabSet);
  end;
end;

procedure TTabManager.LoadTabSetList;
var
  wFileName : String;
  wContent : String;
begin
  if fTabSetList = nil then
    fTabSetList := TTabSetList.Create();

  fTabSetList.Sets.Clear();

  wFileName := GetFileName();
  if not FileExists(wFileName) then
    Exit;
  wContent := TFile.ReadAllText(wFileName);
  try
    fTabSetList.FromJson(wContent);
  except
    fTabSetList.Sets.Clear();
  end;
end;

procedure TTabManager.LoadNames(aList: TStrings);
var
  wTabSet : TTabSet;
begin
  LoadTabSetList();
  for wTabSet in fTabSetList.Sets do
    aList.Add(wTabSet.Name);
end;

procedure TTabManager.RestoreTabs(aTabSet: TTabSet);
var
  i : Integer;
begin
  for i := 0 to aTabSet.Tabs.Count - 1 do
    Interfaces.ActionServices.OpenFile(aTabSet.Tabs[i]);
end;

function TTabManager.SaveCurrent(aName: String) : Boolean;
var
  wTabSet : TTabSet;
  wModules : TArray<IOTAModule>;
  i : Integer;
begin
  wModules := GetModulesInOrder();

  if Length(wModules) = 0 then begin
    ShowMessage('There''s nothing to save.');
    Exit(False);
  end;

  wTabSet := TTabSet.Create();
  wTabSet.Name := aName;

  for i := 0 to High(wModules) do
    wTabSet.Tabs.Add(wModules[i].FileName);

  Result := Save(wTabSet);
end;

function TTabManager.Save(aTabSet: TTabSet) : Boolean;
var
  wTabSet : TTabSet;
begin
  Result := False;
  LoadTabSetList();
  wTabSet := GetTabSet(aTabSet.Name);
  if wTabSet <> nil then begin
    if not Question(Format('List named "%s" already exists. Override?', [wTabSet.Name])) then
      Exit;
    fTabSetList.Sets.Remove(wTabSet);
  end;
  fTabSetList.Sets.Add(aTabSet);
  SaveTabSetList();
  Result := True;
end;

function TTabManager.SaveCurrent : Boolean;
var
  wName : String;
begin
  Result := False;
  wName := InputBox('Name', 'Name of the new tab list', '');
  if not wName.IsEmpty() then
    Result := SaveCurrent(wName);
end;

procedure TTabManager.SaveTabSetList;
var
  wFileName : String;
  wContent : String;
begin
  if fTabSetList = nil then
    fTabSetList := TTabSetList.Create();
  try
    wContent := fTabSetList.ToJson();
    wFileName := GetFileName();
    TFile.WriteAllText(wFileName, wContent);
  except
    fTabSetList.Sets.Clear();
  end;
end;

{ TTabSet }

constructor TTabSet.Create;
begin
  fTabs := TList<String>.Create();
end;

destructor TTabSet.Destroy;
begin
  FreeAndNil(fTabs);
  inherited;
end;

{ TTabSetList }

constructor TTabSetList.Create;
begin
  fSets := TObjectList<TTabSet>.Create();
end;

destructor TTabSetList.Destroy;
begin
  FreeAndNil(fSets);
  inherited;
end;

procedure TTabSetList.FromJson(aJson: String);
var
  wJsonObject : TJSONObject;
  wJsonSets : TJSONArray;
  wJsonSetElement : TJSONObject;
  wJsonTabs : TJSONArray;

  i : Integer;
  wSet : TTabSet;
  j: Integer;
begin
  Sets.Clear();

  wJsonObject := TJSONObject.ParseJSONValue(aJson) as TJSONObject;
  try
    wJsonSets := wJsonObject.GetValue('Sets') as TJSONArray;
    for i := 0 to wJsonSets.Count - 1 do begin
      wSet := TTabSet.Create();
      wJsonSetElement := wJsonSets.Items[i] as TJSONObject;
      wSet.Name := (wJsonSetElement.GetValue('Name') as TJSONString).Value;
      wJsonTabs :=  wJsonSetElement.GetValue('Tabs') as TJSONArray;
      for j := 0 to wJsonTabs.Count - 1 do begin
        wSet.Tabs.Add((wJsonTabs.Items[j] as TJSONString).Value);
      end;
      Sets.Add(wSet);
    end;
  finally
     wJsonObject.Free;
  end;
end;

function TTabSetList.ToJson: String;
var
  wJsonObject : TJSONObject;
  wJsonSets : TJSONArray;
  wJsonSetElement : TJSONObject;
  wJsonTabs : TJSONArray;

  wSet : TTabSet;
  wTab : String;
begin
  wJsonObject := TJSONObject.Create();
  try
    wJsonSets := TJSONArray.Create();
    for wSet in Sets do begin
      wJsonSetElement := TJSONObject.Create();
      wJsonSetElement.AddPair('Name', wSet.Name);
      wJsonTabs := TJSONArray.Create();
      for wTab in wSet.Tabs do
        wJsonTabs.Add(wTab);
      wJsonSetElement.AddPair('Tabs', wJsonTabs);
      wJsonSets.Add(wJsonSetElement);
    end;

    wJsonObject.AddPair('Sets', wJsonSets);

    Result := wJsonObject.ToJSON;
  finally
    wJsonObject.Free;
  end;

end;

end.

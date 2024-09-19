unit UsesAnalyzer;

interface

uses
  System.Classes, System.JSON, UsesManager, System.Diagnostics;

type
  TUsesAnalyzerStatus = (uasNotStarted, uasSuccess, uasError);
  TLogKind = (lkNormal, lkError);

  TUsesAnalyzer = class;

  TUsesAnalyzerLogContext = record
    Sender : TUsesAnalyzer;
    LogMessage : String;
    LogKind : TLogKind;
    FileName : String;
    UsesItem : TUsesItem;
  end;

  TOnUsesAnalyzerLog = procedure (const LogContext : TUsesAnalyzerLogContext) of object;

  TUsesAnalyzer = class
  private
    fConfig : String;
    fRestrictedUses : TObject;
    fStatus: TUsesAnalyzerStatus;
    fOnLog: TOnUsesAnalyzerLog;
    fStopwatch : TStopwatch;
    fCurrentFileName : String;
    procedure AnalyzeFile(aFileName : String);
    procedure CreateRestrictedUses();
  protected
    procedure Log(const aLog : String; const aLogKind : TLogKind = lkNormal; const aUsesItem : TUsesItem = nil); virtual;
    procedure Clear(); virtual;
  public
    constructor Create(aConfig : String);
    destructor Destroy; override;
    procedure Run(aList: TStrings);
    property Status : TUsesAnalyzerStatus read fStatus write fStatus;
    property OnLog : TOnUsesAnalyzerLog read fOnLog write fOnLog;
  public
    class function GetUnitName(const aFileName : String) : String;
    class procedure GetLineAndColumnNumber(const aContext : TUsesAnalyzerLogContext; out aLineNumber, aColumnNumber : Integer);
    class function GetName() : String;
  end;

implementation

uses
  Generics.Collections, System.SysUtils;

type
  TRestrictedUsesEntry = class
  private
    fName: String;
    fUsez: TList<String>;
    fAllowedIn: TList<String>;
  public
    property Name : String read fName write fName;
    property Usez : TList<String> read fUsez write fUsez;
    property AllowedIn : TList<String> read fAllowedIn write fAllowedIn;
    constructor Create;
    destructor Destroy; override;
  end;

  TRestrictedUses = class
  private
    fEntries: TObjectList<TRestrictedUsesEntry>;
  public
    property Entries : TObjectList<TRestrictedUsesEntry> read fEntries write fEntries;
    constructor Create;
    destructor Destroy; override;
  end;

{ TUsesAnalyzer }

procedure TUsesAnalyzer.AnalyzeFile(aFileName: String);
var
  wUses : TUsesList;
  wRestrictedUses : TRestrictedUses;
  wEntry : TRestrictedUsesEntry;
  wUnit : String;
  wRestricted : String;
  wUnitInUses : TUsesItem;

  function wCheck(const aRestricted : String; const aUnit : String) : Boolean;
  var
    wFormattedRestricted : String;
  begin
    if aRestricted.EndsWith('*') then begin
      wFormattedRestricted := aRestricted.Substring(0, aRestricted.Length - 1);
      Result := aUnit.ToLower().StartsWith(wFormattedRestricted.ToLower());
    end else begin
      Result := SameText(aRestricted, aUnit);
    end;
  end;

  function wIgnoreUnit() : Boolean;
  var
    wAllowedIn : String;
  begin
    for wAllowedIn in wEntry.fAllowedIn do
      if SameText(wUnit, wAllowedIn) then
        Exit(True);
    Result := False;
  end;

begin
  if not SameText(ExtractFileExt(aFileName), '.pas') then
    Exit;

  fCurrentFileName := aFileName;
  wUnit := GetUnitName(aFileName);

  try
    wUses := gCreateAllUsesList(aFileName);
    try
      wRestrictedUses := TRestrictedUses(fRestrictedUses);
      for wEntry in wRestrictedUses.Entries do begin
        if wIgnoreUnit() then
          Exit;
        for wRestricted in wEntry.Usez do begin
          for wUnitInUses in wUses do begin
            if wCheck(wRestricted, wUnitInUses.Name) then begin
              Log(Format('Uses "%s" cannot be present here due to restriction "%s"', [wUnitInUses.Name, wEntry.Name]), lkError, wUnitInUses);
              Status := uasError;
              Exit;
            end;
          end;
        end;

      end;
    finally
      wUses.Free;
    end;
    
  except on E : Exception do
    Log(E.Message, lkError);
  end;
  Log(Format('Unit "%s" is ok', [wUnit]));
end;

procedure TUsesAnalyzer.Clear;
begin
  FreeAndNil(fRestrictedUses);
end;

constructor TUsesAnalyzer.Create(aConfig: String);
begin
  fConfig := aConfig;
  fStatus := uasNotStarted;
end;

procedure TUsesAnalyzer.CreateRestrictedUses;
var
  wJson, wRestrictedUses : TJSONObject;
  wJsonPair : TJSONPair;
  i, j : Integer;
  wRestrictedUsesEntry : TRestrictedUsesEntry;
  wJsonArray : TJSONArray;
begin
  fRestrictedUses := TRestrictedUses.Create();
  wJson := TJSONObject.ParseJSONValue(fConfig) as TJSONObject;
  if wJson = nil then begin
    Log('Invalid settings json structure.', lkError);
    Exit;
  end;

  wRestrictedUses := wJson.GetValue('restrictedUses') as TJSONObject;
  for i := 0  to wRestrictedUses.Count - 1 do begin
    wJsonPair := wRestrictedUses.Pairs[i];
    wRestrictedUsesEntry := TRestrictedUsesEntry.Create();
    wRestrictedUsesEntry.Name := wJsonPair.JsonString.Value;

    wJson := TJSONObject.ParseJSONValue(wJsonPair.JsonValue.ToJson()) as TJSONObject;

    wJsonArray := wJson.GetValue('uses') as TJSONArray;
    for j := 0 to wJsonArray.Count - 1 do begin
      wRestrictedUsesEntry.Usez.Add(wJsonArray.Items[j].Value);
    end;

    wJsonArray := wJson.GetValue('allowedIn') as TJSONArray;
    for j := 0 to wJsonArray.Count - 1 do begin
      wRestrictedUsesEntry.AllowedIn.Add(wJsonArray.Items[j].Value);
    end;

    TRestrictedUses(fRestrictedUses).Entries.Add(wRestrictedUsesEntry);
  end;
end;

destructor TUsesAnalyzer.Destroy;
begin
  Clear();
  inherited;
end;

class procedure TUsesAnalyzer.GetLineAndColumnNumber(
  const aContext: TUsesAnalyzerLogContext; out aLineNumber,
  aColumnNumber: Integer);
var
  i : Integer;
  wSum : Integer;
  wFileContent : TStringList;
  wBP : Integer;
begin
  aLineNumber := 0;
  aColumnNumber := 0;
  wBP := aContext.UsesItem.BeginPos - 1;
  wFileContent := TStringList.Create();
  try
    wFileContent.LoadFromfile(aContext.FileName);
    wSum := 0;
    for i := 0 to wFileContent.Count - 1 do begin
      wSum := wSum + wFileContent[i].Length + 2;
      if wSum - 1 > wBP then begin
        aColumnNumber := wFileContent[i].Length - (wSum - wBP - 4);
        aLineNumber := i + 1;
        Exit;
      end;
    end;
  finally
    wFileContent.Free;
  end;
end;

class function TUsesAnalyzer.GetName: String;
begin
  Result := 'Uses analyzer';
end;

class function TUsesAnalyzer.GetUnitName(const aFileName: String): String;
begin
  Result := ChangeFileExt(ExtractFileName(aFileName), '')
end;

procedure TUsesAnalyzer.Log(const aLog: String; const aLogKind : TLogKind; const aUsesItem : TUsesItem);
var
  wContext : TUsesAnalyzerLogContext;
begin
  if Assigned(fOnLog) then begin
    wContext.Sender := Self;
    wContext.LogMessage := aLog;
    wContext.LogKind := aLogKind;
    wContext.FileName := fCurrentFileName;
    wContext.UsesItem := aUsesItem;
    fOnLog(wContext);
  end;
end;

function MillisecondsToTTime(Milliseconds: Int64): TTime;
const
  MSecsPerDay = 24 * 60 * 60 * 1000;
  MSecsPerHour = 60 * 60 * 1000;
  MSecsPerMinute = 60 * 1000;
  MSecsPerSecond = 1000;
var
  Hours, Minutes, Seconds, MSecs: Word;
begin
  Hours := Milliseconds div MSecsPerHour;
  Milliseconds := Milliseconds mod MSecsPerHour;
  Minutes := Milliseconds div MSecsPerMinute;
  Milliseconds := Milliseconds mod MSecsPerMinute;
  Seconds := Milliseconds div MSecsPerSecond;
  MSecs := Milliseconds mod MSecsPerSecond;

  Result := EncodeTime(Hours, Minutes, Seconds, MSecs);
end;

procedure TUsesAnalyzer.Run(aList: TStrings);
var
  wFile : String;

  function wFormatTime(aStopwatch : TStopwatch) : String;
  begin
    Result := TimeToStr(MillisecondsToTTime(aStopwatch.ElapsedMilliseconds));
  end;

begin
  Log('Unit analyzer starts at ' + DateTimeToStr(Now), lkNormal);
  fCurrentFileName := '';
  fStopwatch.Reset();
  fStopwatch.Start();
  try
    fStatus := uasNotStarted;
    if fRestrictedUses = nil then
      CreateRestrictedUses();
    for wFile in aList do begin
      AnalyzeFile(wFile);
    end;
    if fStatus = uasNotStarted then
      fStatus := uasSuccess;
  finally
    fStopwatch.Stop();
    Log('Whole process tooks ' + wFormatTime(fStopwatch));
    if fStatus = uasSuccess then
      Log('All units are ok :)', lkNormal)
    else
      Log('There are errors!', lkError);
  end;
end;

{ TRestrictedUsesEntry }

constructor TRestrictedUsesEntry.Create;
begin
  fUsez := TList<String>.Create();
  fAllowedIn := TList<String>.Create();
end;

destructor TRestrictedUsesEntry.Destroy;
begin
  FreeAndNil(fUsez);
  FreeAndNil(fAllowedIn);
  inherited;
end;

{ TRestrictedUses }

constructor TRestrictedUses.Create;
begin
  fEntries := TObjectList<TRestrictedUsesEntry>.Create();
end;

destructor TRestrictedUses.Destroy;
begin
  FreeAndNil(fEntries);
  inherited;
end;

end.

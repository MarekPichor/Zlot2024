unit UsesManager;

interface

uses
  System.Classes, Contnrs, mPasLex;

type

  TUsesItem = class(TObject)
  public
    Name: string;
    BeginPos: Longint;
    EndPos: Longint; // Position at the end of the unit name
    CommaBeforePos: Longint; // Position of ',' before unit name
    CommaAfterPos: Longint;  // Position of ',' after unit name
    SpaceAfter: Boolean;
  end;

  TUsesList = class(TObjectList)
  private
    function GetItem(AIndex: Integer): TUsesItem;
    procedure SetItem(AIndex: Integer; const Value: TUsesItem);
  public
    function Add: TUsesItem;
    function IndexOf(const AUnitName: string): Integer;
    property Items[AIndex: Integer]: TUsesItem read GetItem write SetItem;
  end;

  TUsesStatus = (usNonExisting, usInterface, usImplementation, usInsideUnit);

  TstUsesManager = class
  private
    fFileName : String;
    fMemStream : TMemoryStream;
    fInterfUses : TUsesList;
    fImplemUses : TUsesList;
    FParser : TmwPasLex;
    FImplPosition: Integer;  // Position of the last char of the "implementation" keyword
    FIntfPosition: Integer;  // Position of the last char of the "interface" keyword
    FBegOfIntfUses: Integer; // Position of first char of interface "uses" keyword
    FEndOfIntfUses: Integer; // Position of the semicolon which ends interface uses clause
    FBegOfImplUses: Integer; // Position of first char of implementation "uses" keyword
    FEndOfImplUses: Integer; // Position of the semicolon which ends implementation uses clause
  private
    function LineFromPos(aSL : TStringList; aPos : Integer) : Integer;
  protected
    procedure BuildUsesList; virtual;
    function InternalAddToUsesSection(const AUnitName: string; ToInterface: Boolean): Boolean; virtual;
    procedure InternalRemoveFromUses(InInterface: Boolean; const AUnitName: string); virtual;
    function ExtractPureFileName(aFileName : String) : String; virtual;
    function UsesLineWouldBeTooLong(InsertPos, InsertLength: Integer): Boolean; virtual;
    function DeleteTextFromPos(aStartPos : Integer; aCount : Integer) : Boolean; virtual;
    function InsertTextFromPos(aText : String; aPosition : Integer) : Boolean; virtual;

    function Occurrences(const Substring, Text: string): Integer; virtual;
  public
    procedure RemoveFromImplUses(const AUnitName: string);
    procedure RemoveImplementationUses;
    procedure RemoveFromIntfUses(const AUnitName: string);
    procedure RemoveInterfaceUses;

    function AddToImpSection(const AUnitName: string): Boolean;
    function AddToIntSection(const AUnitName: string): Boolean;

    function GetCurrentUnitName : String;
    function GetUsesStatus(const AUnitName: string): TUsesStatus;
    property InterfUses : TUsesList read fInterfUses;
    property ImplemUses : TUsesList read fImplemUses;
    constructor Create(const aFileName: string);
    destructor Destroy; override;

  end;

    function gRemoveFromImplUses(const aFileName, aUses: string) : Boolean;
    function gRemoveFromIntfUses(const aFileName, aUses: string) : Boolean;
    function gAddToImpSection(const aFileName, aUses: string): Boolean;
    function gAddToIntSection(const aFileName, aUses: string): Boolean;
    function gCreateAllUsesList(const aFileName : String): TUsesList;

implementation

uses
  System.SysUtils, System.StrUtils;

function gRemoveFromImplUses(const aFileName, aUses: string): Boolean;
begin
  with TstUsesManager.Create(aFileName) do
  try
    Result := GetUsesStatus(aUses) = usImplementation;
    if Result then
      RemoveFromImplUses(aUses);
  finally
    Free;
  end;
end;

function gRemoveFromIntfUses(const aFileName, aUses: string): Boolean;
begin
  with TstUsesManager.Create(aFileName) do
  try
    Result := GetUsesStatus(aUses) = usInterface;
    if Result then
      RemoveFromIntfUses(aUses);
  finally
    Free;
  end;
end;

function gAddToImpSection(const aFileName, aUses: string): Boolean;
begin
  with TstUsesManager.Create(aFileName) do
  try
    Result := AddToImpSection(aUses);
  finally
    Free;
  end;
end;

function gAddToIntSection(const aFileName, aUses: string): Boolean;
begin
  with TstUsesManager.Create(aFileName) do
  try
    Result := AddToIntSection(aUses);
  finally
    Free;
  end;
end;

function gCreateAllUsesList(const aFileName : String): TUsesList;

  procedure wAdd(aUsesItem : TUsesItem); overload;
  var
    wUsesItem : TUsesItem;
  begin
    wUsesItem := Result.Add;
    wUsesitem.Name := aUsesItem.Name;
    wUsesItem.BeginPos := aUsesItem.BeginPos;
    wUsesItem.EndPos := aUsesItem.EndPos;
    wUsesItem.CommaBeforePos := aUsesItem.CommaBeforePos;
    wUsesItem.CommaAfterPos := aUsesItem.CommaAfterPos;
    wUsesItem.SpaceAfter := aUsesItem.SpaceAfter;
  end;

  procedure wAdd(aUsesList : TUsesList); overload;
  var
    i : Integer;
  begin
    for i := 0 to aUsesList.Count - 1 do
      wAdd(aUsesList.Items[i]);
  end;

begin
  Result := TUsesList.Create();
  with TstUsesManager.Create(aFileName) do try
    wAdd(InterfUses);
    wAdd(ImplemUses);
  finally
    Free;
  end;
end;

{ TstUsesManager }

function TstUsesManager.AddToImpSection(const AUnitName: string): Boolean;
begin
  Result := InternalAddToUsesSection(AUnitName, False);
end;

function TstUsesManager.AddToIntSection(const AUnitName: string): Boolean;
begin
  Result := InternalAddToUsesSection(AUnitName, True);
end;

procedure TstUsesManager.BuildUsesList;
var
  Section: (sImplementation, sInterface);
  InUses: Boolean;
  UsesItem: TUsesItem;
  LastCommaPos: Integer;
begin
  fMemStream.LoadFromFile(fFileName);
  FParser.Origin := fMemStream.Memory;

  Section := sInterface;
  InUses := False;
  FParser.RunPos := 0;
  FBegOfImplUses := 0;
  FImplPosition := 0;
  FIntfPosition := 0;
  FEndOfIntfUses := 0;
  FBegOfIntfUses := 0;

  UsesItem := nil;
  LastCommaPos := 0;

  FParser.NextNoJunk;
  while FParser.TokenID <> tkNull do
  begin
    case FParser.TokenID of
      tkInterface:
        begin
          Section := sInterface;
          FIntfPosition := FParser.RunPos;
          InUses := False;
          LastCommaPos := 0;
        end;
      tkImplementation:
        begin
          Section := sImplementation;
          FImplPosition := FParser.RunPos;
          InUses := False;
          LastCommaPos := 0;
        end;
      tkUses:
        begin
          InUses := True;
          if Section = sImplementation then
            FBegOfImplUses := FParser.RunPos - Length('uses');
          if Section = sInterface then
            FBegOfIntfUses := FParser.RunPos - Length('uses');
          LastCommaPos := 0;
        end;
    else
      // If it is after the unit identifier
      if InUses and not (FParser.TokenID in [tkCompDirect, tkIn, tkString]) then
      begin
        if FParser.TokenID = tkIdentifier then
        begin
          if Section = sInterface then
            UsesItem := FInterfUses.Add
          else // Section = sImplementation
            UsesItem := FImplemUses.Add;
          {$IFOPT D+} Assert(UsesItem <> nil); {$ENDIF}

          UsesItem.Name := FParser.GetDottedIdentifierAtPos(True);
          UsesItem.EndPos := FParser.RunPos;
          UsesItem.BeginPos := UsesItem.EndPos - Length(UsesItem.Name);

          if LastCommaPos <> 0 then
            UsesItem.CommaBeforePos := LastCommaPos - 1;

          UsesItem.CommaAfterPos := 0;
        end // tkIdentifier
        else if FParser.TokenID = tkComma then
        begin
          LastCommaPos := FParser.RunPos;
          if UsesItem <> nil then
          begin
            UsesItem.CommaAfterPos := LastCommaPos - 1;
            if FParser.NextChar = ' ' then
              UsesItem.SpaceAfter := True;
          end;
        end
        else // FParser.TokenID <> tkComma
        begin
          InUses := False;
          if Section = sImplementation then
          begin
            FEndOfImplUses := FParser.RunPos;
            Break; // End of parsing
          end;
          if Section = sInterface then
            FEndOfIntfUses := FParser.RunPos;
        end; // Not comma
      end; // UsesFlag
    end;
    FParser.NextNoJunk;
  end;
end;

constructor TstUsesManager.Create(const aFileName: string);
begin
  fMemStream := TMemoryStream.Create;
  FInterfUses := TUsesList.Create;
  FImplemUses := TUsesList.Create;

  FParser := TmwPasLex.Create;
  fFileName := aFileName;
  BuildUsesList;
end;

function TstUsesManager.DeleteTextFromPos(aStartPos, aCount: Integer): Boolean;
var
  wSL : TStringList;
  wTemp : String;
begin
  wSL := TStringList.Create;
  try
    wSL.LoadFromFile(fFileName);
    wTemp := wSL.Text;
    wTemp := Copy(wTemp, 0, aStartPos) + Copy(wTemp, aStartPos + aCount + 1);
    wSL.Text := wTemp;
    wSL.SaveToFile(fFileName);
  finally
    wSL.Free;
  end;
  Result := True;
end;

destructor TstUsesManager.Destroy;
begin
  FreeAndNil(fMemStream);
  inherited;
end;

function TstUsesManager.ExtractPureFileName(aFileName: String): String;
begin
  Result := ExtractFileName(aFileName);
  if Result = '' then
    Exit;
  Result := ChangeFileExt(Result, '');
end;

function TstUsesManager.GetCurrentUnitName: String;
begin
  Result := Trim(ExtractPureFileName(FFileName));
end;

function TstUsesManager.GetUsesStatus(const AUnitName: string): TUsesStatus;
begin
  if SameFileName(GetCurrentUnitName, Trim(AUnitName)) then
    Result := usInsideUnit
  else if FImplemUses.IndexOf(AUnitName) > -1 then
    Result := usImplementation
  else if FInterfUses.IndexOf(AUnitName) > -1 then
    Result := usInterface
  else
    Result := usNonExisting;
end;

function TstUsesManager.InsertTextFromPos(aText: String;
  aPosition: Integer): Boolean;
var
  wSL : TStringList;
  wTemp : String;
begin
  wSL := TStringList.Create;
  try
    wSL.LoadFromFile(fFileName);
    wTemp := wSL.Text;
    wTemp := Copy(wTemp, 0, aPosition) + aText + Copy(wTemp, aPosition + 1);
    wSL.Text := wTemp;
    wSL.SaveToFile(fFileName);
  finally
    wSL.Free;
  end;
  Result := True;
end;

function TstUsesManager.InternalAddToUsesSection(const AUnitName: string;
  ToInterface: Boolean): Boolean;
var
  InsertPosition: Integer;
  LastUses: TUsesItem;
  InsertString: string;
  Status: TUsesStatus;
  UsesItems: TUsesList;
  UsesPos: Integer;
begin
  Result := False;
  Status := GetUsesStatus(AUnitName);
  if Status = usInsideUnit then
    Exit;

  if ToInterface then
  begin
    if Status = usImplementation then
      RemoveFromImplUses(AUnitName)
    else if Status = usInterface then
      Exit;
    UsesPos := FIntfPosition;
    UsesItems := FInterfUses;
  end
  else begin // Add to implementation
    if Status in [usInterface, usImplementation] then
      Exit;
    UsesPos := FImplPosition;
    UsesItems := FImplemUses;
  end;
  if UsesPos = 0 then
    Exit;

  // If a uses item exists
  if UsesItems.Count > 0 then
  begin
    // Retrieve the position after the last uses item
    LastUses := UsesItems.Items[UsesItems.Count - 1];
    InsertPosition := LastUses.EndPos;
    InsertString := ', ' + AUnitName;
    if UsesLineWouldBeTooLong(InsertPosition, Length(InsertString)) then
      InsertString := ',' + sLineBreak + '  ' + AUnitName;
    // Insert the new unit name into the uses clause
    InsertTextFromPos(InsertString, InsertPosition);
  end
  else // The uses clause does not exist
  begin
    InsertString := sLineBreak + sLineBreak +'uses'+ sLineBreak +'  '+ AUnitName +';';
    InsertTextFromPos(InsertString, UsesPos);
  end;

  // This needs to be done last since it changes the implementation offsets
  if not ToInterface then
  begin
    if Status = usInterface then
      RemoveFromIntfUses(AUnitName);
  end;

  Result := True;
  BuildUsesList;
end;

procedure TstUsesManager.InternalRemoveFromUses(InInterface: Boolean;
  const AUnitName: string);
var
  DeletedUnit: TUsesItem;
  UnitIndex: Integer;
  BegPos, EndPos: Integer;
  UsesList: TUsesList;
begin
  if InInterface then
    UsesList := FInterfUses
  else
    UsesList := FImplemUses;

  UnitIndex := UsesList.IndexOf(AUnitName);
  if UnitIndex > -1 then
  begin
    // If this is the only uses unit, we delete the whole clause
    if UsesList.Count = 1 then
    begin
      if InInterface then
        RemoveInterfaceUses
      else
        RemoveImplementationUses;
    end
    else
    begin
      DeletedUnit := UsesList.Items[UnitIndex];
      if UnitIndex = 0 then // First in the uses clause
      begin
        if DeletedUnit.CommaAfterPos <> 0 then
          EndPos := DeletedUnit.CommaAfterPos + 1
        else
          EndPos := DeletedUnit.EndPos;
        BegPos := DeletedUnit.BeginPos;
      end
      else if UnitIndex = UsesList.Count-1 then // Last in the uses clause
      begin
        EndPos := DeletedUnit.EndPos;
        if DeletedUnit.CommaBeforePos <> 0 then
          BegPos := DeletedUnit.CommaBeforePos
        else
          BegPos := DeletedUnit.BeginPos;
      end
      else // In the middle of the uses clause
      begin
        if DeletedUnit.CommaAfterPos = DeletedUnit.EndPos then
        begin // Comma directly after unit
          BegPos := DeletedUnit.BeginPos;
          EndPos := DeletedUnit.CommaAfterPos + 1;
        end
        else // Comma before unit
        begin
          if DeletedUnit.CommaBeforePos <> 0 then
            BegPos := DeletedUnit.CommaBeforePos
          else
            BegPos := DeletedUnit.BeginPos;
          EndPos := DeletedUnit.EndPos;
        end;
      end;
      if DeletedUnit.SpaceAfter then
        Inc(EndPos);

      DeleteTextFromPos(BegPos, EndPos - BegPos);
    end;
  end;
end;

function TstUsesManager.LineFromPos(aSL: TStringList; aPos: Integer): Integer;
var
  wPos : Integer;
  i : Integer;
  wL : Integer;
begin
  Result := -1;
  if aSL = nil then
    Exit;
  wPos := 0;
  for i := 0 to aSL.Count - 1 do begin
    wL := Length(aSL[i] + aSL.LineBreak);
    if wPos + wL >= aPos then
      Exit(i);
    Inc(wPos, wL);
  end;
end;

function TstUsesManager.Occurrences(const Substring, Text: string): Integer;
var
  offset: integer;
begin
  result := 0;
  offset := PosEx(Substring, Text, 1);
  while offset <> 0 do
  begin
    inc(result);
    offset := PosEx(Substring, Text, offset + length(Substring));
  end;
end;

procedure TstUsesManager.RemoveFromImplUses(const AUnitName: string);
begin
  InternalRemoveFromUses(False, AUnitName);
end;

procedure TstUsesManager.RemoveFromIntfUses(const AUnitName: string);
begin
  InternalRemoveFromUses(True, AUnitName);
end;

procedure TstUsesManager.RemoveImplementationUses;
var
  BegIndex, Count: Integer;
begin
  if (FBegOfImplUses = 0) or (FEndOfImplUses = 0) then
    raise Exception.Create('RemoveImplementationUses: Begin or End of uses clause is not available!');

  BegIndex := FBegOfImplUses;
  Count := FEndOfImplUses - BegIndex;
  DeleteTextFromPos(BegIndex, Count);
end;

procedure TstUsesManager.RemoveInterfaceUses;
var
  BegIndex, Count: Integer;
begin
  if (FBegOfIntfUses = 0) or (FEndOfIntfUses = 0) then
    raise Exception.Create('RemoveInterfaceUses: Begin or End of uses clause is not available!');

  BegIndex := FBegOfIntfUses;
  Count := FEndOfIntfUses - BegIndex;
  DeleteTextFromPos(BegIndex, Count);
end;

function TstUsesManager.UsesLineWouldBeTooLong(InsertPos,
  InsertLength: Integer): Boolean;
var
  wSL : TStringList;
  wLine : Integer;
begin
  wSL := TStringList.Create;
  try
    wSL.LoadFromFile(fFileName);
    wLine := LineFromPos(wSL, InsertPos);
    if wLine = -1 then
      Exit(False);
    Result := Length(wSL[wLine]) + InsertLength > 80;
  finally
    wSL.Free;
  end;
end;

{ TUsesList }

function TUsesList.Add: TUsesItem;
begin
  Result := TUsesItem.Create;

  inherited Add(Result);
end;

function TUsesList.GetItem(AIndex: Integer): TUsesItem;
begin
  Result := TUsesItem(Get(AIndex));
end;

function TUsesList.IndexOf(const AUnitName: string): Integer;
begin
  Result := Count - 1;
  while Result >= 0 do
  begin
    if SameText(Items[Result].Name, AUnitName) then
      Break;
    Dec(Result);
  end;
end;

procedure TUsesList.SetItem(AIndex: Integer; const Value: TUsesItem);
begin
  Put(AIndex, Value);
end;

end.

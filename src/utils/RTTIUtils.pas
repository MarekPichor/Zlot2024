unit RTTIUtils;

interface

function RTTI_GetProperty(aObj:TObject; aPropertyName: String): Variant;

implementation

uses
  System.RTTI;

function internalTValueToVariant(Val: TValue):Variant;
begin
   case Val.Kind of
    tkClass, tkMethod, tkArray, tkRecord, tkInterface, tkDynArray,
    tkClassRef, tkPointer, tkProcedure:
      Result := Variant(TValueData(Val).FAsSLong);
     else Result := Val.AsVariant;
   end;

end;

function RTTI_GetProperty(aObj:TObject; aPropertyName: String): Variant;
var
    LContext: TRttiContext;
    LType: TRttiType;
    lProperty: TRttiProperty;
begin
   result := '';
   LContext := TRttiContext.Create;
   try
     LType := LContext.GetType(aObj.ClassInfo);
     if LType = nil then
      LType := LContext.FindType(aObj.unitname +'.'+ aObj.Classname);

     if Ltype = nil then
      exit(false);

     lProperty := LType.GetProperty(aPropertyName);
      if lProperty <> nil then
       begin
         try
           Result := internalTValueToVariant(lProperty.GetValue(aObj));
         except;
         end;
       end;
   finally
    LContext.Free;
   end;
end;

end.

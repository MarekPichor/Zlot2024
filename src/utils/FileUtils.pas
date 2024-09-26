unit FileUtils;

interface

type
  TFileUtils = class
  private
    class function SystemTempDir : String;
    class function MakeFileName(aPart1, aPart2 : String) : String;
  public
    class function TempDir() : String;
    class procedure ClearTempDir();
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, System.IOUtils;

{ TFileUtils }

class procedure TFileUtils.ClearTempDir;
begin
  TDirectory.Delete(TempDir, True);
end;

class function TFileUtils.MakeFileName(aPart1, aPart2: String): String;
begin
  Result := (aPart1 + '\' + aPart2).Replace('\\', '\');
end;

class function TFileUtils.SystemTempDir: String;
var
  TMP : Array[0..MAX_PATH + 1] of char;
begin
  GetTempPath(MAX_PATH, TMP);
  result := StrPas(TMP);
end;

class function TFileUtils.TempDir: String;
begin
  Result := MakeFileName(SystemTempDir, 'Zlot');
  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;

end.

unit HelpEditorView;

interface

uses
  ToolsApi, DesignIntf, Vcl.Forms, HelpEditorFrame;

type
  THelpEditorView = class(TInterfacedObject, INTACustomEditorSubView)
  private
    fFrame : TfrmHelpEditorFrame;
    function GetHelpFileNameIfExists(const AContext : IInterface) : String;
  public
    function GetCanCloneView: Boolean;
    function GetCaption: string;
    function GetPriority: Integer;
    function GetViewIdentifier: string;
    procedure Display(const AContext: IInterface; AViewObject: TObject);
    function EditAction(const AContext: IInterface; Action: TEditAction; AViewObject: TObject): Boolean;
    function GetEditState(const AContext: IInterface; AViewObject: TObject): TEditState;
    function Handles(const AContext: IInterface): Boolean;
    procedure Hide(const AContext: IInterface; AViewObject: TObject);
    procedure ViewClosed(const AContext: IInterface; AViewObject: TObject);
    function GetFrameClass: TCustomFrameClass;
    procedure FrameCreated(AFrame: TCustomFrame);

    property CanCloneView: Boolean read GetCanCloneView;
    property Caption: string read GetCaption;
    property FrameClass: TCustomFrameClass read GetFrameClass;
    property Priority: Integer read GetPriority;
    property ViewIdentifier: string read GetViewIdentifier;
  end;

implementation

uses
  OtaInterfaces, SysUtils;

{ THelpEditorView }

procedure THelpEditorView.Display(const AContext: IInterface;
  AViewObject: TObject);
begin
  fFrame.LoadContent(GetHelpFileNameIfExists(aContext));
end;

function THelpEditorView.EditAction(const AContext: IInterface; Action: TEditAction; AViewObject: TObject): Boolean;
begin
  Result := False;
end;

procedure THelpEditorView.FrameCreated(AFrame: TCustomFrame);
begin
  fFrame := TfrmHelpEditorFrame(aFrame);
end;

function THelpEditorView.GetCanCloneView: Boolean;
begin
  Result := False;
end;

function THelpEditorView.GetCaption: string;
begin
  Result := 'Help';
end;

function THelpEditorView.GetEditState(const AContext: IInterface; AViewObject: TObject): TEditState;
begin
  Result := [];
end;

function THelpEditorView.GetFrameClass: TCustomFrameClass;
begin
  Result := TfrmHelpEditorFrame;
end;

function THelpEditorView.GetHelpFileNameIfExists(
  const AContext: IInterface): String;
var
  wFileName : String;
begin
  if Interfaces.EditorViewServices.ContextToFilename(aContext, wFileName) then
    if SameText(ExtractFileExt(wFileName), '.pas') then begin
      Result := ChangeFileExt(wFileName, '.help');
      if not FileExists(Result) then
        Result := '';
    end;
end;

function THelpEditorView.GetPriority: Integer;
begin
  Result := 3;
end;

function THelpEditorView.GetViewIdentifier: string;
begin
  Result := '[Zlot 2024] Help editor';
end;

function THelpEditorView.Handles(const AContext: IInterface): Boolean;
begin
  Result := not GetHelpFileNameIfExists(aContext).IsEmpty();
end;

procedure THelpEditorView.Hide(const AContext: IInterface;
  AViewObject: TObject);
begin

end;

procedure THelpEditorView.ViewClosed(const AContext: IInterface;
  AViewObject: TObject);
begin

end;

end.

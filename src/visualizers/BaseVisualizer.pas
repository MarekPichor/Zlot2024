unit BaseVisualizer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsApi, Vcl.ActnList,
  System.IniFiles, Vcl.ComCtrls, Vcl.ImgList, Vcl.Menus, DesignIntf;

type
  TfrmBaseVisualizer = class(TFrame, IOTADebuggerVisualizerExternalViewerUpdater, IOTAThreadNotifier, IOTAThreadNotifier160)
  private
    fCompleted: Boolean;
    fDeferredResult: string;
    fDeferredError: Boolean;
    fNotifierIndex : Integer;
    fForm : TCustomForm;
    fClosedProc : TOTAVisualizerClosedProcedure;
    fPixelsPerInch: Integer;
    fOldCreateOrder: Boolean;
    fTextHeight: Integer;
  protected
    function Evaluate(aExpression : String) : String;
    procedure Loaded; override;
    property Completed : Boolean read fCompleted;
    property DeferredResult : String read fDeferredResult;
    property DeferredError : Boolean read fDeferredError;
    property NotifierIndex : Integer read fNotifierIndex;
    procedure SetParent(AParent: TWinControl); override;
  public
    { IOTAThreadNotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);
    { IOTAThreadNotifier160 }
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress: TOTAAddress; ResultSize: LongWord; ReturnCode: Integer);
    { IOTADebuggerVisualizerExternalViewerUpdater }
    procedure CloseVisualizer;
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason); virtual;
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string); virtual;
    procedure SetClosedCallback(ClosedProc: TOTAVisualizerClosedProcedure);

  published
    property ClientHeight;
    property ClientWidth;
    property OldCreateOrder : Boolean read fOldCreateOrder write fOldCreateOrder;
    property PixelsPerInch : Integer read fPixelsPerInch write fPixelsPerInch;
    property TextHeight : Integer read fTextHeight write fTextHeight;

  end;

  TFormVisualizerClass = class of TFormBaseVisualizer;

  TBaseVisualizer = class(TInterfacedObject, IOTADebuggerVisualizer,
                             IOTADebuggerVisualizerExternalViewer)
  public
    function GetMenuText: string; virtual; abstract;
    function Show(const Expression, TypeName, EvalResult: string;
      SuggestedLeft, SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendents: Boolean); virtual; abstract;
    function GetSupportedTypeCount: Integer; virtual; abstract;
    function GetVisualizerDescription: string; virtual; abstract;
    function GetVisualizerIdentifier: string; virtual; abstract;
    function GetVisualizerName: string; virtual; abstract;
    function GetFormClass: TFormVisualizerClass; virtual; abstract;
  end;

  IFrameFormHelper = interface
  ['{0FD4A98F-CE6B-422A-BF13-14E49727F3B3}']
    function GetForm: TCustomForm;
    function GetFrame: TCustomFrame;
    procedure SetForm(Form: TCustomForm);
    procedure SetFrame(Form: TCustomFrame);
  end;

  TFormBaseVisualizer = class(TInterfacedObject, INTACustomDockableForm, IFrameFormHelper)
  private
    fFrame: TfrmBaseVisualizer;
    fForm: TCustomForm;
    fExpression: string;
  public
    constructor Create(const Expression: string);
    { INTACustomDockableForm }
    function GetCaption: string; virtual;
    function GetFrameClass: TCustomFrameClass; virtual; abstract;
    function GetIdentifier: string; virtual; abstract;
    procedure FrameCreated(AFrame: TCustomFrame);
    function GetMenuActionList: TCustomActionList;
    function GetMenuImageList: TCustomImageList;
    procedure CustomizePopupMenu(PopupMenu: TPopupMenu);
    function GetToolbarActionList: TCustomActionList;
    function GetToolbarImageList: TCustomImageList;
    procedure CustomizeToolBar(ToolBar: TToolBar);
    procedure LoadWindowState(Desktop: TCustomIniFile; const Section: string);
    procedure SaveWindowState(Desktop: TCustomIniFile; const Section: string; IsProject: Boolean);
    function GetEditState: TEditState;
    function EditAction(Action: TEditAction): Boolean;
    { IFrameFormHelper }
    function GetForm: TCustomForm;
    function GetFrame: TCustomFrame;
    procedure SetForm(Form: TCustomForm);
    procedure SetFrame(Frame: TCustomFrame);
  end;

implementation

{$R *.dfm}

uses
  OTAFunctions, OTAInterfaces;

{ TBaseVisualizer }

procedure TfrmBaseVisualizer.AfterSave;
begin
  //
end;

procedure TfrmBaseVisualizer.BeforeSave;
begin
   //
end;

procedure TfrmBaseVisualizer.CloseVisualizer;
begin
  if fForm <> nil then
    fForm.Close;
end;

procedure TfrmBaseVisualizer.Destroyed;
begin
  //
end;

function TfrmBaseVisualizer.Evaluate(aExpression: String): String;
begin
  Result := Functions.Evaluate(aExpression, Self, fCompleted, fDeferredResult, fDeferredError, fNotifierIndex);
end;

procedure TfrmBaseVisualizer.EvaluateComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
  ReturnCode: Integer);
begin
  FCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
end;

procedure TfrmBaseVisualizer.EvaluteComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
begin
  EvaluateComplete(ExprStr, ResultStr, CanModify, TOTAAddress(ResultAddress), ResultSize, ReturnCode);
end;

procedure TfrmBaseVisualizer.Loaded;
begin
  inherited;
  Height := 350;
  Width := 400;
end;

procedure TfrmBaseVisualizer.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin
  //
end;

procedure TfrmBaseVisualizer.Modified;
begin
  //
end;

procedure TfrmBaseVisualizer.ModifyComplete(const ExprStr, ResultStr: string;
  ReturnCode: Integer);
begin
  //
end;

procedure TfrmBaseVisualizer.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin
  //
end;

procedure TfrmBaseVisualizer.SetClosedCallback(
  ClosedProc: TOTAVisualizerClosedProcedure);
begin
  fClosedProc := ClosedProc;
end;

procedure TfrmBaseVisualizer.SetParent(AParent: TWinControl);
begin
  if AParent = nil then begin
    //ResetValue?
    if Assigned(FClosedProc) then
      FClosedProc;
  end;
  inherited;
end;

procedure TfrmBaseVisualizer.ThreadNotify(Reason: TOTANotifyReason);
begin
  //
end;

{ TBaseVisualizer }

function TBaseVisualizer.Show(const Expression, TypeName, EvalResult: string;
  SuggestedLeft,
  SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
var
  wForm: TCustomForm;
  wFrame: TfrmBaseVisualizer;
  wVisDockForm: INTACustomDockableForm;
begin
  wVisDockForm := GetFormClass().Create(Expression) as INTACustomDockableForm;
  wForm := (BorlandIDEServices as INTAServices).CreateDockableForm(wVisDockForm);
  wForm.Name := '';
  wForm.Left := SuggestedLeft;
  wForm.Top := SuggestedTop;
  (wVisDockForm as IFrameFormHelper).SetForm(wForm);
  wFrame := (wVisDockForm as IFrameFormHelper).GetFrame as TfrmBaseVisualizer;
  wFrame.RefreshVisualizer(Expression, TypeName, EvalResult);
  Result := wFrame as IOTADebuggerVisualizerExternalViewerUpdater;
end;

{ TFormBaseVisualizer }

constructor TFormBaseVisualizer.Create(const Expression: string);
begin
  inherited Create;
  fExpression := Expression;
end;

procedure TFormBaseVisualizer.CustomizePopupMenu(PopupMenu: TPopupMenu);
begin
 //
end;

procedure TFormBaseVisualizer.CustomizeToolBar(ToolBar: TToolBar);
begin
 //
end;

function TFormBaseVisualizer.EditAction(Action: TEditAction): Boolean;
begin
  Result := False;
end;

procedure TFormBaseVisualizer.FrameCreated(AFrame: TCustomFrame);
begin
  fFrame := TfrmBaseVisualizer(AFrame);
end;

function TFormBaseVisualizer.GetCaption: string;
begin
  Result := fExpression;
end;

function TFormBaseVisualizer.GetEditState: TEditState;
begin
  Result := [];
end;

function TFormBaseVisualizer.GetForm: TCustomForm;
begin
  Result := fForm;
end;

function TFormBaseVisualizer.GetFrame: TCustomFrame;
begin
  Result := fFrame;
end;

function TFormBaseVisualizer.GetMenuActionList: TCustomActionList;
begin
  Result := nil;
end;

function TFormBaseVisualizer.GetMenuImageList: TCustomImageList;
begin
  Result := nil;
end;

function TFormBaseVisualizer.GetToolbarActionList: TCustomActionList;
begin
  Result := nil;
end;

function TFormBaseVisualizer.GetToolbarImageList: TCustomImageList;
begin
  Result := nil;
end;

procedure TFormBaseVisualizer.LoadWindowState(Desktop: TCustomIniFile;
  const Section: string);
begin
  //
end;

procedure TFormBaseVisualizer.SaveWindowState(Desktop: TCustomIniFile;
  const Section: string; IsProject: Boolean);
begin
  //
end;

procedure TFormBaseVisualizer.SetForm(Form: TCustomForm);
begin
  fForm := Form;
  if fFrame <> nil then
    TfrmBaseVisualizer(fFrame).fForm := Form;
  Interfaces.ThemeServices.RegisterFormClass(TCustomFormClass(fForm.ClassType));

end;

procedure TFormBaseVisualizer.SetFrame(Frame: TCustomFrame);
begin
  fFrame := TfrmBaseVisualizer(Frame);
end;

end.

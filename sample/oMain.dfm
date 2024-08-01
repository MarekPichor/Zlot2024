object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'Zlot 2024'
  ClientHeight = 411
  ClientWidth = 1150
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1150
    Height = 411
    ActivePage = TS_Visualizers
    Align = alClient
    TabOrder = 0
    object TS_Visualizers: TTabSheet
      Caption = 'Visualizers'
    end
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 932
    Top = 336
  end
end

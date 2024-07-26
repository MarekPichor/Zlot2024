object fmColorVisualizer: TfmColorVisualizer
  Left = 0
  Top = 0
  ClientHeight = 202
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object P_Color: TPanel
    Left = 8
    Top = 35
    Width = 295
    Height = 160
    BevelOuter = bvLowered
    Caption = 'P_Color'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
  end
  object E_Edit: TEdit
    Left = 8
    Top = 8
    Width = 295
    Height = 21
    ReadOnly = True
    TabOrder = 1
  end
end

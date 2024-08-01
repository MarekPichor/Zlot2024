object fmColorVisualizer: TfmColorVisualizer
  Left = 0
  Top = 0
  ClientHeight = 115
  ClientWidth = 264
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    264
    115)
  PixelsPerInch = 96
  TextHeight = 13
  object P_Color: TPanel
    Left = 8
    Top = 35
    Width = 287
    Height = 152
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'P_Color'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
  end
  object E_Edit: TEdit
    Left = 8
    Top = 8
    Width = 287
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 1
  end
end

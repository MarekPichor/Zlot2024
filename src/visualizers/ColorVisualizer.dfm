object fmColorVisualizer: TfmColorVisualizer
  Left = 0
  Top = 0
  ClientHeight = 181
  ClientWidth = 314
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
    AlignWithMargins = True
    Left = 10
    Top = 41
    Width = 294
    Height = 130
    Margins.Left = 10
    Margins.Top = 0
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alClient
    BevelOuter = bvLowered
    Caption = 'P_Color'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
  end
  object E_Edit: TEdit
    AlignWithMargins = True
    Left = 10
    Top = 10
    Width = 294
    Height = 21
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alTop
    ReadOnly = True
    TabOrder = 1
  end
end

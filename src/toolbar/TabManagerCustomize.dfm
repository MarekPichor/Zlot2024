object fTabManagerCustomize: TfTabManagerCustomize
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Customize tab manager'
  ClientHeight = 360
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    AlignWithMargins = True
    Left = 267
    Top = 10
    Height = 340
    Margins.Left = 0
    Margins.Top = 10
    Margins.Right = 0
    Margins.Bottom = 10
    OnMoved = Splitter1Moved
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 10
    Top = 10
    Width = 247
    Height = 340
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object SG_TabSets: TStringGrid
      Left = 0
      Top = 0
      Width = 247
      Height = 340
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      PopupMenu = PM_Sets
      TabOrder = 0
      OnClick = SG_TabSetsClick
      OnDblClick = SG_TabSetsDblClick
    end
  end
  object Panel2: TPanel
    AlignWithMargins = True
    Left = 280
    Top = 10
    Width = 282
    Height = 340
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object SG_TabSetContent: TStringGrid
      Left = 0
      Top = 0
      Width = 282
      Height = 340
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      PopupMenu = PM_Unit
      TabOrder = 0
    end
  end
  object PM_Sets: TPopupMenu
    Left = 186
    Top = 218
    object Rename1: TMenuItem
      Caption = 'Rename'
      OnClick = Rename1Click
    end
    object Remove1: TMenuItem
      Caption = 'Remove'
      ShortCut = 46
      OnClick = Remove1Click
    end
  end
  object PM_Unit: TPopupMenu
    Left = 386
    Top = 234
    object MenuItem2: TMenuItem
      Caption = 'Remove'
      ShortCut = 46
      OnClick = MenuItem2Click
    end
  end
end

object AppForm: TAppForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 
    'Created by DCE-Systems (11.09.2017)  ---> More stuff on: https:/' +
    '/github.com/dce-systems'
  ClientHeight = 193
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LabelFirstname: TLabel
    Left = 48
    Top = 85
    Width = 47
    Height = 13
    Caption = 'Firstname'
  end
  object LabelLastname: TLabel
    Left = 280
    Top = 85
    Width = 46
    Height = 13
    Caption = 'Lastname'
  end
  object LabelEmail: TLabel
    Left = 48
    Top = 141
    Width = 24
    Height = 13
    Caption = 'Email'
  end
  object LabelPwd: TLabel
    Left = 281
    Top = 141
    Width = 20
    Height = 13
    Caption = 'Pwd'
  end
  object ButtonSimple: TButton
    Left = 48
    Top = 8
    Width = 202
    Height = 25
    Caption = 'Simple validation'
    TabOrder = 0
    OnClick = ButtonSimpleClick
  end
  object ButtonAttributes: TButton
    Left = 280
    Top = 8
    Width = 202
    Height = 25
    Caption = 'Attributes Validation'
    TabOrder = 1
    OnClick = ButtonAttributesClick
  end
  object EditFirstname: TEdit
    Left = 48
    Top = 104
    Width = 201
    Height = 21
    ParentShowHint = False
    ShowHint = False
    TabOrder = 2
    Text = 'John'
  end
  object EditLastname: TEdit
    Left = 280
    Top = 104
    Width = 201
    Height = 21
    TabOrder = 3
    Text = 'Kowalski'
  end
  object EditEmail: TEdit
    Left = 48
    Top = 160
    Width = 201
    Height = 21
    TabOrder = 4
    Text = 'mail@gmail.com'
  end
  object EditPwd: TEdit
    Left = 281
    Top = 160
    Width = 201
    Height = 21
    TabOrder = 5
    Text = 'password'
  end
end

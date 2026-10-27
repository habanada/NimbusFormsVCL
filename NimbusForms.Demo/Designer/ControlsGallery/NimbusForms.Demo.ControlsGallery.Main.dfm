object ControlsGalleryForm: TControlsGalleryForm
  Left = 0
  Top = 0
  Caption = 'NimbusForms Controls Gallery'
  ClientHeight = 720
  ClientWidth = 1120
  Constraints.MinHeight = 600
  Constraints.MinWidth = 900
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  object pnlHeader: TThemedPanel
    Left = 0
    Top = 0
    Width = 1120
    Height = 65
    Align = alTop
    ShowBorder = False
    TabOrder = 0
    object lblTitle: TThemedLabel
      Left = 20
      Top = 22
      Caption = 'NimbusForms | Designer-first control gallery'
    end
    object cmbTheme: TThemedComboBox
      Left = 832
      Top = 18
      Width = 264
      Height = 28
      Anchors = [akTop, akRight]
      TabOrder = 0
      OnChange = ThemeChanged
    end
  end
  object pnlFooter: TThemedPanel
    Left = 0
    Top = 686
    Width = 1120
    Height = 34
    Align = alBottom
    ShowBorder = False
    TabOrder = 2
    object lblEvents: TThemedLabel
      Left = 18
      Top = 9
      Width = 1080
      Height = 17
      AutoSize = False
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Ready'
    end
  end
  object Pages: TThemedTabControl
    Left = 0
    Top = 65
    Width = 1120
    Height = 621
    CloseButtonMode = tcbmNone
    CloseOnMiddleClick = False
    AllowTabReorder = False
    ActivePage = tabButtons
    Align = alClient
    TabOrder = 1
    object tabButtons: TTabSheet
      Caption = 'Buttons & States'
      object grpButtonStates: TThemedGroupBox
        Left = 22
        Top = 20
        Width = 830
        Height = 285
        Caption = 'Interaction and state'
        TabOrder = 0
        object btnPrimary: TThemedButton
          Left = 20
          Top = 35
          Width = 155
          Height = 34
          Caption = 'Primary action'
          TabOrder = 0
          OnButtonClicked = ButtonClicked
        end
        object btnToggleEnabled: TThemedButton
          Left = 185
          Top = 35
          Width = 175
          Height = 34
          Caption = 'Toggle checkbox'
          TabOrder = 1
          OnButtonClicked = ButtonClicked
        end
        object btnCheckable: TThemedButton
          Left = 370
          Top = 35
          Width = 152
          Height = 34
          Caption = 'Checkable'
          TabOrder = 2
          OnButtonClicked = ButtonClicked
          Checkable = True
          AutoCheck = True
        end
        object btnReset: TThemedButton
          Left = 532
          Top = 35
          Width = 166
          Height = 34
          Caption = 'Reset all demos'
          TabOrder = 3
          OnButtonClicked = ButtonClicked
        end
        object chkEnabled: TThemedCheckBox
          Left = 20
          Top = 113
          Width = 250
          Height = 28
          Caption = 'Notifications enabled'
          Checked = True
          TabOrder = 4
          OnCheckedChanged = ValueChanged
        end
        object toggleActive: TThemedToggleBox
          Left = 20
          Top = 164
          Width = 270
          Height = 34
          Caption = 'Active mode'
          TabOrder = 5
          OnCheckedChanged = ValueChanged
        end
      end
    end
    object tabInputs: TTabSheet
      Caption = 'Inputs & Validation'
      object grpText: TThemedGroupBox
        Left = 22
        Top = 20
        Width = 830
        Height = 245
        Caption = 'Text, dropdown and numbers'
        TabOrder = 0
        object lblName: TThemedLabel
          Left = 20
          Top = 34
          Caption = 'Customer name'
        end
        object lblDepartment: TThemedLabel
          Left = 20
          Top = 104
          Caption = 'Department'
        end
        object lblQuantity: TThemedLabel
          Left = 20
          Top = 175
          Caption = 'Quantity'
        end
        object txtName: TThemedTextBox
          Left = 190
          Top = 28
          Width = 410
          Height = 32
          Text = 'Nimbus User'
          PlaceholderText = 'Enter a customer name'
          TabOrder = 0
          OnChange = ValueChanged
        end
        object cmbDepartment: TThemedComboBox
          Left = 190
          Top = 98
          Width = 410
          Height = 30
          TabOrder = 1
          OnChange = ValueChanged
        end
        object numQuantity: TThemedNumericUpDown
          Left = 190
          Top = 165
          Width = 190
          Height = 32
          Minimum = 0
          Maximum = 1000
          Value = 25
          TabOrder = 2
          OnValueChanged = ValueChanged
        end
      end
      object grpDates: TThemedGroupBox
        Left = 22
        Top = 282
        Width = 830
        Height = 133
        Caption = 'Dates'
        TabOrder = 1
        object lblDeadline: TThemedLabel
          Left = 20
          Top = 41
          Caption = 'Deadline'
        end
        object dateDeadline: TThemedDatePicker
          Left = 190
          Top = 34
          Width = 266
          Height = 34
          TabOrder = 0
          OnValueChanged = ValueChanged
        end
      end
    end
    object tabFeedback: TTabSheet
      Caption = 'Rating & Progress'
      object grpRating: TThemedGroupBox
        Left = 22
        Top = 20
        Width = 830
        Height = 170
        Caption = 'Interactive rating'
        TabOrder = 0
        object lblRating: TThemedLabel
          Left = 20
          Top = 31
          Caption = 'Select a rating (half-star increments)'
        end
        object rating: TThemedRatingControl
          Left = 20
          Top = 69
          Width = 320
          Height = 48
          Maximum = 5
          RatingValue = 3.5
          Precision = rpHalf
          TabOrder = 0
          OnValueChanged = ValueChanged
        end
      end
      object grpProgress: TThemedGroupBox
        Left = 22
        Top = 206
        Width = 830
        Height = 210
        Caption = 'Progress feedback'
        TabOrder = 1
        object lblProgress: TThemedLabel
          Left = 20
          Top = 31
          Caption = 'Use the buttons to advance the progress indicator.'
        end
        object progress: TThemedProgressBar
          Left = 20
          Top = 69
          Width = 740
          Height = 26
          Position = 45
          ShowPercentage = True
        end
        object btnProgress: TThemedButton
          Left = 20
          Top = 125
          Width = 155
          Height = 34
          Caption = 'Advance +10%'
          TabOrder = 0
          OnButtonClicked = ButtonClicked
        end
        object btnClearProgress: TThemedButton
          Left = 190
          Top = 125
          Width = 155
          Height = 34
          Caption = 'Reset'
          TabOrder = 1
          OnButtonClicked = ButtonClicked
        end
      end
    end
  end
end

object GridWorkbenchForm: TGridWorkbenchForm
  Left = 0
  Top = 0
  Caption = 'NimbusForms Grid Workbench'
  ClientHeight = 810
  ClientWidth = 1320
  Constraints.MinHeight = 650
  Constraints.MinWidth = 1060
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  object pnlHeader: TThemedPanel
    Left = 0
    Top = 0
    Width = 1320
    Height = 70
    Align = alTop
    ShowBorder = False
    TabOrder = 0
    object lblTitle: TThemedLabel
      Left = 16
      Top = 23
      Width = 780
      Height = 22
      Caption = 'NimbusForms | Grid Workbench - five feature labs | 200K showcase'
      Font.Style = [fsBold]
    end
    object cmbTheme: TThemedComboBox
      Left = 1030
      Top = 18
      Width = 270
      Height = 28
      Anchors = [akTop, akRight]
      TabOrder = 0
      OnChange = ThemeChanged
    end
  end
  object pnlFooter: TThemedPanel
    Left = 0
    Top = 779
    Width = 1320
    Height = 31
    Align = alBottom
    ShowBorder = False
    TabOrder = 2
    object lblStatus: TThemedLabel
      Left = 16
      Top = 7
      Width = 1240
      Height = 17
      Caption = 'Ready'
      AutoSize = False
      Anchors = [akLeft, akTop, akRight]
    end
  end
  object Pages: TThemedTabControl
    Left = 0
    Top = 70
    Width = 1320
    Height = 709
    CloseButtonMode = tcbmNone
    CloseOnMiddleClick = False
    AllowTabReorder = False
    ActivePage = tabEditing
    Align = alClient
    TabOrder = 1
    OnChange = PageChanged
    object tabEditing: TTabSheet
      Caption = 'Data & Editing'
      ImageIndex = 0
      object pnlEditing: TThemedPanel
        Left = 0
        Top = 0
        Width = 1312
        Height = 63
        Align = alTop
        ShowBorder = False
        TabOrder = 0
        object btnUndo: TThemedButton
          Left = 16
          Top = 14
          Width = 96
          Height = 32
          Caption = 'Undo'
          TabOrder = 0
          OnButtonClicked = Command
        end
        object btnRedo: TThemedButton
          Left = 118
          Top = 14
          Width = 96
          Height = 32
          Caption = 'Redo'
          TabOrder = 1
          OnButtonClicked = Command
        end
        object btnReadOnly: TThemedButton
          Left = 220
          Top = 14
          Width = 150
          Height = 32
          Caption = 'Toggle read-only'
          TabOrder = 2
          OnButtonClicked = Command
        end
        object btnCopySelection: TThemedButton
          Left = 376
          Top = 14
          Width = 154
          Height = 32
          Caption = 'Copy selection'
          TabOrder = 3
          OnButtonClicked = Command
        end
        object btnPaste: TThemedButton
          Left = 536
          Top = 14
          Width = 130
          Height = 32
          Caption = 'Paste cells'
          TabOrder = 4
          OnButtonClicked = Command
        end
      end
      object gridEditing: TThemedGridView
        Left = 0
        Top = 63
        Width = 1312
        Height = 612
        Align = alClient
        TabOrder = 1
        TabStop = True
      end
    end
    object tabQueries: TTabSheet
      Caption = 'Grouping & Filters'
      ImageIndex = 1
      object pnlQueries: TThemedPanel
        Left = 0
        Top = 0
        Width = 1312
        Height = 96
        Align = alTop
        ShowBorder = False
        TabOrder = 0
        object txtSearch: TThemedTextBox
          Left = 16
          Top = 10
          Width = 490
          Height = 30
          PlaceholderText = 'Search visible grid data'
          TabOrder = 0
          OnChange = SearchChanged
        end
        object btnGroupStatus: TThemedButton
          Left = 16
          Top = 52
          Width = 150
          Height = 32
          Caption = 'Group by status'
          TabOrder = 1
          OnButtonClicked = Command
        end
        object btnGroupApproved: TThemedButton
          Left = 172
          Top = 52
          Width = 166
          Height = 32
          Caption = 'Group by approved'
          TabOrder = 2
          OnButtonClicked = Command
        end
        object btnUngroup: TThemedButton
          Left = 344
          Top = 52
          Width = 145
          Height = 32
          Caption = 'Clear grouping'
          TabOrder = 3
          OnButtonClicked = Command
        end
        object btnFilterApproved: TThemedButton
          Left = 495
          Top = 52
          Width = 136
          Height = 32
          Caption = 'Approved only'
          TabOrder = 4
          OnButtonClicked = Command
        end
        object btnClearFilters: TThemedButton
          Left = 637
          Top = 52
          Width = 145
          Height = 32
          Caption = 'Clear filters'
          TabOrder = 5
          OnButtonClicked = Command
        end
      end
      object gridQueries: TThemedGridView
        Left = 0
        Top = 96
        Width = 1312
        Height = 579
        Align = alClient
        TabOrder = 1
        TabStop = True
      end
    end
    object tabPresentation: TTabSheet
      Caption = 'Layout & Formatting'
      ImageIndex = 2
      object pnlPresentation: TThemedPanel
        Left = 0
        Top = 0
        Width = 1312
        Height = 63
        Align = alTop
        ShowBorder = False
        TabOrder = 0
        object btnFreeze: TThemedButton
          Left = 16
          Top = 14
          Width = 152
          Height = 32
          Caption = 'Freeze first two'
          TabOrder = 0
          OnButtonClicked = Command
        end
        object btnUnfreeze: TThemedButton
          Left = 174
          Top = 14
          Width = 125
          Height = 32
          Caption = 'Unfreeze'
          TabOrder = 1
          OnButtonClicked = Command
        end
        object btnBands: TThemedButton
          Left = 305
          Top = 14
          Width = 134
          Height = 32
          Caption = 'Toggle bands'
          TabOrder = 2
          OnButtonClicked = Command
        end
        object btnFormats: TThemedButton
          Left = 445
          Top = 14
          Width = 150
          Height = 32
          Caption = 'Toggle highlights'
          TabOrder = 3
          OnButtonClicked = Command
        end
        object btnHideAmount: TThemedButton
          Left = 601
          Top = 14
          Width = 136
          Height = 32
          Caption = 'Hide amount'
          TabOrder = 4
          OnButtonClicked = Command
        end
        object btnShowAll: TThemedButton
          Left = 743
          Top = 14
          Width = 160
          Height = 32
          Caption = 'Show all columns'
          TabOrder = 5
          OnButtonClicked = Command
        end
      end
      object gridPresentation: TThemedGridView
        Left = 0
        Top = 63
        Width = 1312
        Height = 612
        Align = alClient
        TabOrder = 1
        TabStop = True
      end
    end
    object tabExport: TTabSheet
      Caption = 'Export & Clipboard'
      ImageIndex = 3
      object pnlExport: TThemedPanel
        Left = 0
        Top = 0
        Width = 1312
        Height = 63
        Align = alTop
        ShowBorder = False
        TabOrder = 0
        object btnCsv: TThemedButton
          Left = 16
          Top = 14
          Width = 132
          Height = 32
          Caption = 'Export CSV'
          TabOrder = 0
          OnButtonClicked = Command
        end
        object btnJson: TThemedButton
          Left = 154
          Top = 14
          Width = 138
          Height = 32
          Caption = 'Export JSON'
          TabOrder = 1
          OnButtonClicked = Command
        end
        object btnHtml: TThemedButton
          Left = 298
          Top = 14
          Width = 144
          Height = 32
          Caption = 'Export HTML'
          TabOrder = 2
          OnButtonClicked = Command
        end
        object btnClipboard: TThemedButton
          Left = 448
          Top = 14
          Width = 176
          Height = 32
          Caption = 'Copy grid as table'
          TabOrder = 3
          OnButtonClicked = Command
        end
        object btnFind: TThemedButton
          Left = 630
          Top = 14
          Width = 130
          Height = 32
          Caption = 'Find panel'
          TabOrder = 4
          OnButtonClicked = Command
        end
      end
      object gridExport: TThemedGridView
        Left = 0
        Top = 63
        Width = 1312
        Height = 612
        Align = alClient
        TabOrder = 1
        TabStop = True
      end
    end
    object tabShowcase: TTabSheet
      Caption = '200K / Visual Showcase'
      ImageIndex = 4
      object pnlShowcaseHero: TThemedPanel
        Left = 0
        Top = 0
        Width = 1312
        Height = 121
        Align = alTop
        CornerRadius = 12
        ShowBorder = False
        TabOrder = 0
        object lblShowcaseTitle: TThemedLabel
          Left = 20
          Top = 12
          Width = 860
          Height = 30
          Caption = 'NIMBUS GRID  |  THE 200K EXPERIENCE'
          Font.Height = -23
          Font.Style = [fsBold]
        end
        object lblShowcaseSubtitle: TThemedLabel
          Left = 20
          Top = 49
          Width = 950
          Height = 22
          Caption = '200,000 synthetic records | master-detail | SVG avatars | progress | color-coded badges'
          Font.Height = -13
        end
        object badgeVolume: TThemedBadgeLabel
          Left = 20
          Top = 86
          Width = 148
          Height = 24
          AutoSize = False
          Text = '200K DATA ROWS'
          BadgeKind = tbkInfo
          BadgeShape = tbsPill
        end
        object badgeDetails: TThemedBadgeLabel
          Left = 182
          Top = 86
          Width = 170
          Height = 24
          AutoSize = False
          Text = 'NESTED DETAIL GRIDS'
          BadgeKind = tbkSuccess
          BadgeShape = tbsPill
        end
        object badgeVisuals: TThemedBadgeLabel
          Left = 366
          Top = 86
          Width = 152
          Height = 24
          AutoSize = False
          Text = 'SVG + COLOR + STARS'
          BadgeKind = tbkWarning
          BadgeShape = tbsPill
        end
        object lblShowcaseHealth: TThemedLabel
          Left = 1030
          Top = 84
          Width = 245
          Height = 20
          Anchors = [akTop, akRight]
          Caption = 'SYNTHETIC KPI PULSE'
          Font.Style = [fsBold]
        end
        object progressShowcase: TThemedProgressBar
          Left = 1010
          Top = 31
          Width = 270
          Height = 22
          Anchors = [akTop, akRight]
          Maximum = 100
          Position = 0
          CornerRadius = 9
          ShowPercentage = True
        end
      end
      object pnlShowcaseTools: TThemedPanel
        Left = 0
        Top = 121
        Width = 1312
        Height = 59
        Align = alTop
        ShowBorder = False
        TabOrder = 1
        object btnShowcaseReload: TThemedButton
          Left = 15
          Top = 12
          Width = 167
          Height = 33
          Caption = 'Reload 200K rows'
          TabOrder = 0
          OnButtonClicked = ShowcaseCommand
        end
        object btnShowcaseExpand: TThemedButton
          Left = 189
          Top = 12
          Width = 175
          Height = 33
          Caption = 'Expand master-detail'
          TabOrder = 1
          OnButtonClicked = ShowcaseCommand
        end
        object btnShowcaseCollapse: TThemedButton
          Left = 371
          Top = 12
          Width = 155
          Height = 33
          Caption = 'Collapse detail'
          TabOrder = 2
          OnButtonClicked = ShowcaseCommand
        end
        object btnShowcaseFreeze: TThemedButton
          Left = 533
          Top = 12
          Width = 145
          Height = 33
          Caption = 'Freeze identity'
          TabOrder = 3
          OnButtonClicked = ShowcaseCommand
        end
        object btnShowcaseHighlights: TThemedButton
          Left = 685
          Top = 12
          Width = 161
          Height = 33
          Caption = 'Toggle vivid colors'
          TabOrder = 4
          OnButtonClicked = ShowcaseCommand
        end
        object btnShowcaseVisuals: TThemedButton
          Left = 853
          Top = 12
          Width = 156
          Height = 33
          Caption = 'Toggle SVG images'
          TabOrder = 5
          OnButtonClicked = ShowcaseCommand
        end
      end
      object gridShowcase: TThemedGridView
        Left = 0
        Top = 180
        Width = 1312
        Height = 495
        Align = alClient
        TabOrder = 2
        TabStop = True
      end
    end
  end
end

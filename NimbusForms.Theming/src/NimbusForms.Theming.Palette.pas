{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Palette;

interface

uses
  System.Classes,
  NimbusForms.Theming.Types;

type
  TThemePalette = class(TPersistent)
  private
    FIsDark: Boolean;
    FBackColor: TThemeColor;
    FForeColor: TThemeColor;
    FControlBackColor: TThemeColor;
    FControlForeColor: TThemeColor;
    FControlBorderColor: TThemeColor;
    FAccentColor: TThemeColor;
    FMutedForeColor: TThemeColor;
    FDisabledForeColor: TThemeColor;
    FDisabledBackColor: TThemeColor;
    FHoverBackColor: TThemeColor;
    FPressedBackColor: TThemeColor;
    FSelectedBackColor: TThemeColor;
    FSelectedForeColor: TThemeColor;
    FFocusBorderColor: TThemeColor;
    FInputBackColor: TThemeColor;
    FInputForeColor: TThemeColor;
    FInputBorderColor: TThemeColor;
    FMenuBackColor: TThemeColor;
    FMenuForeColor: TThemeColor;
    FMenuBorderColor: TThemeColor;
    FMenuSelectedBackColor: TThemeColor;
    FPanelBackColor: TThemeColor;
    FGroupBoxBorderColor: TThemeColor;
    FTabBackColor: TThemeColor;
    FTabForeColor: TThemeColor;
    FActiveTabBackColor: TThemeColor;
    FActiveTabForeColor: TThemeColor;
    FProgressBackColor: TThemeColor;
    FProgressFillColor: TThemeColor;
    FStatusBackColor: TThemeColor;
    FStatusForeColor: TThemeColor;
    FSeparatorColor: TThemeColor;
    FDockHostBackColor: TThemeColor;
    FDockPaneBackColor: TThemeColor;
    FDockPaneBorderColor: TThemeColor;
    FDockHeaderBackColor: TThemeColor;
    FDockHeaderForeColor: TThemeColor;
    FDockTabBackColor: TThemeColor;
    FDockTabHoverBackColor: TThemeColor;
    FDockTabActiveBackColor: TThemeColor;
    FDockTabBorderColor: TThemeColor;
    FDockTabActiveBorderColor: TThemeColor;
    FDockTabForeColor: TThemeColor;
    FDockTabActiveForeColor: TThemeColor;
    FDockTabMutedForeColor: TThemeColor;
    FDockSplitterBackColor: TThemeColor;
    FDockSplitterHoverBackColor: TThemeColor;
    FDockDropTargetBackColor: TThemeColor;
    FDockDropTargetBorderColor: TThemeColor;
    FDockDropTargetHoverBackColor: TThemeColor;
    FDockDropTargetHoverBorderColor: TThemeColor;
    FDockDropPreviewBackColor: TThemeColor;
    FDockDropPreviewBorderColor: TThemeColor;
  public
    procedure Assign(Source: TPersistent); override;
    function Clone: TThemePalette;
    property IsDark: Boolean read FIsDark write FIsDark;
    property BackColor: TThemeColor read FBackColor write FBackColor;
    property ForeColor: TThemeColor read FForeColor write FForeColor;
    property ControlBackColor: TThemeColor read FControlBackColor write FControlBackColor;
    property ControlForeColor: TThemeColor read FControlForeColor write FControlForeColor;
    property ControlBorderColor: TThemeColor read FControlBorderColor write FControlBorderColor;
    property AccentColor: TThemeColor read FAccentColor write FAccentColor;
    property MutedForeColor: TThemeColor read FMutedForeColor write FMutedForeColor;
    property DisabledForeColor: TThemeColor read FDisabledForeColor write FDisabledForeColor;
    property DisabledBackColor: TThemeColor read FDisabledBackColor write FDisabledBackColor;
    property HoverBackColor: TThemeColor read FHoverBackColor write FHoverBackColor;
    property PressedBackColor: TThemeColor read FPressedBackColor write FPressedBackColor;
    property SelectedBackColor: TThemeColor read FSelectedBackColor write FSelectedBackColor;
    property SelectedForeColor: TThemeColor read FSelectedForeColor write FSelectedForeColor;
    property FocusBorderColor: TThemeColor read FFocusBorderColor write FFocusBorderColor;
    property InputBackColor: TThemeColor read FInputBackColor write FInputBackColor;
    property InputForeColor: TThemeColor read FInputForeColor write FInputForeColor;
    property InputBorderColor: TThemeColor read FInputBorderColor write FInputBorderColor;
    property MenuBackColor: TThemeColor read FMenuBackColor write FMenuBackColor;
    property MenuForeColor: TThemeColor read FMenuForeColor write FMenuForeColor;
    property MenuBorderColor: TThemeColor read FMenuBorderColor write FMenuBorderColor;
    property MenuSelectedBackColor: TThemeColor read FMenuSelectedBackColor write FMenuSelectedBackColor;
    property PanelBackColor: TThemeColor read FPanelBackColor write FPanelBackColor;
    property GroupBoxBorderColor: TThemeColor read FGroupBoxBorderColor write FGroupBoxBorderColor;
    property TabBackColor: TThemeColor read FTabBackColor write FTabBackColor;
    property TabForeColor: TThemeColor read FTabForeColor write FTabForeColor;
    property ActiveTabBackColor: TThemeColor read FActiveTabBackColor write FActiveTabBackColor;
    property ActiveTabForeColor: TThemeColor read FActiveTabForeColor write FActiveTabForeColor;
    property ProgressBackColor: TThemeColor read FProgressBackColor write FProgressBackColor;
    property ProgressFillColor: TThemeColor read FProgressFillColor write FProgressFillColor;
    property StatusBackColor: TThemeColor read FStatusBackColor write FStatusBackColor;
    property StatusForeColor: TThemeColor read FStatusForeColor write FStatusForeColor;
    property SeparatorColor: TThemeColor read FSeparatorColor write FSeparatorColor;
    property DockHostBackColor: TThemeColor read FDockHostBackColor write FDockHostBackColor;
    property DockPaneBackColor: TThemeColor read FDockPaneBackColor write FDockPaneBackColor;
    property DockPaneBorderColor: TThemeColor read FDockPaneBorderColor write FDockPaneBorderColor;
    property DockHeaderBackColor: TThemeColor read FDockHeaderBackColor write FDockHeaderBackColor;
    property DockHeaderForeColor: TThemeColor read FDockHeaderForeColor write FDockHeaderForeColor;
    property DockTabBackColor: TThemeColor read FDockTabBackColor write FDockTabBackColor;
    property DockTabHoverBackColor: TThemeColor read FDockTabHoverBackColor write FDockTabHoverBackColor;
    property DockTabActiveBackColor: TThemeColor read FDockTabActiveBackColor write FDockTabActiveBackColor;
    property DockTabBorderColor: TThemeColor read FDockTabBorderColor write FDockTabBorderColor;
    property DockTabActiveBorderColor: TThemeColor read FDockTabActiveBorderColor write FDockTabActiveBorderColor;
    property DockTabForeColor: TThemeColor read FDockTabForeColor write FDockTabForeColor;
    property DockTabActiveForeColor: TThemeColor read FDockTabActiveForeColor write FDockTabActiveForeColor;
    property DockTabMutedForeColor: TThemeColor read FDockTabMutedForeColor write FDockTabMutedForeColor;
    property DockSplitterBackColor: TThemeColor read FDockSplitterBackColor write FDockSplitterBackColor;
    property DockSplitterHoverBackColor: TThemeColor read FDockSplitterHoverBackColor write FDockSplitterHoverBackColor;
    property DockDropTargetBackColor: TThemeColor read FDockDropTargetBackColor write FDockDropTargetBackColor;
    property DockDropTargetBorderColor: TThemeColor read FDockDropTargetBorderColor write FDockDropTargetBorderColor;
    property DockDropTargetHoverBackColor: TThemeColor read FDockDropTargetHoverBackColor write FDockDropTargetHoverBackColor;
    property DockDropTargetHoverBorderColor: TThemeColor read FDockDropTargetHoverBorderColor write FDockDropTargetHoverBorderColor;
    property DockDropPreviewBackColor: TThemeColor read FDockDropPreviewBackColor write FDockDropPreviewBackColor;
    property DockDropPreviewBorderColor: TThemeColor read FDockDropPreviewBorderColor write FDockDropPreviewBorderColor;
  end;

  IThemeAware = interface
    ['{4D1C9E20-3C7E-4B51-9E2F-9A1C0B7E52A1}']
    procedure ApplyTheme(const APalette: TThemePalette);
  end;

implementation

procedure TThemePalette.Assign(Source: TPersistent);
var
  LSource: TThemePalette;
begin
  if Source is TThemePalette then
  begin
    LSource := TThemePalette(Source);
    FIsDark := LSource.FIsDark;
    FBackColor := LSource.FBackColor;
    FForeColor := LSource.FForeColor;
    FControlBackColor := LSource.FControlBackColor;
    FControlForeColor := LSource.FControlForeColor;
    FControlBorderColor := LSource.FControlBorderColor;
    FAccentColor := LSource.FAccentColor;
    FMutedForeColor := LSource.FMutedForeColor;
    FDisabledForeColor := LSource.FDisabledForeColor;
    FDisabledBackColor := LSource.FDisabledBackColor;
    FHoverBackColor := LSource.FHoverBackColor;
    FPressedBackColor := LSource.FPressedBackColor;
    FSelectedBackColor := LSource.FSelectedBackColor;
    FSelectedForeColor := LSource.FSelectedForeColor;
    FFocusBorderColor := LSource.FFocusBorderColor;
    FInputBackColor := LSource.FInputBackColor;
    FInputForeColor := LSource.FInputForeColor;
    FInputBorderColor := LSource.FInputBorderColor;
    FMenuBackColor := LSource.FMenuBackColor;
    FMenuForeColor := LSource.FMenuForeColor;
    FMenuBorderColor := LSource.FMenuBorderColor;
    FMenuSelectedBackColor := LSource.FMenuSelectedBackColor;
    FPanelBackColor := LSource.FPanelBackColor;
    FGroupBoxBorderColor := LSource.FGroupBoxBorderColor;
    FTabBackColor := LSource.FTabBackColor;
    FTabForeColor := LSource.FTabForeColor;
    FActiveTabBackColor := LSource.FActiveTabBackColor;
    FActiveTabForeColor := LSource.FActiveTabForeColor;
    FProgressBackColor := LSource.FProgressBackColor;
    FProgressFillColor := LSource.FProgressFillColor;
    FStatusBackColor := LSource.FStatusBackColor;
    FStatusForeColor := LSource.FStatusForeColor;
    FSeparatorColor := LSource.FSeparatorColor;
    FDockHostBackColor := LSource.FDockHostBackColor;
    FDockPaneBackColor := LSource.FDockPaneBackColor;
    FDockPaneBorderColor := LSource.FDockPaneBorderColor;
    FDockHeaderBackColor := LSource.FDockHeaderBackColor;
    FDockHeaderForeColor := LSource.FDockHeaderForeColor;
    FDockTabBackColor := LSource.FDockTabBackColor;
    FDockTabHoverBackColor := LSource.FDockTabHoverBackColor;
    FDockTabActiveBackColor := LSource.FDockTabActiveBackColor;
    FDockTabBorderColor := LSource.FDockTabBorderColor;
    FDockTabActiveBorderColor := LSource.FDockTabActiveBorderColor;
    FDockTabForeColor := LSource.FDockTabForeColor;
    FDockTabActiveForeColor := LSource.FDockTabActiveForeColor;
    FDockTabMutedForeColor := LSource.FDockTabMutedForeColor;
    FDockSplitterBackColor := LSource.FDockSplitterBackColor;
    FDockSplitterHoverBackColor := LSource.FDockSplitterHoverBackColor;
    FDockDropTargetBackColor := LSource.FDockDropTargetBackColor;
    FDockDropTargetBorderColor := LSource.FDockDropTargetBorderColor;
    FDockDropTargetHoverBackColor := LSource.FDockDropTargetHoverBackColor;
    FDockDropTargetHoverBorderColor := LSource.FDockDropTargetHoverBorderColor;
    FDockDropPreviewBackColor := LSource.FDockDropPreviewBackColor;
    FDockDropPreviewBorderColor := LSource.FDockDropPreviewBorderColor;
  end
  else
    inherited Assign(Source);
end;

function TThemePalette.Clone: TThemePalette;
begin
  Result := TThemePalette.Create;
  Result.Assign(Self);
end;

end.

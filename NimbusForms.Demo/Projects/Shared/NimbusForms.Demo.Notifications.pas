{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Notifications;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  System.TypInfo,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  System.Types,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Imaging.jpeg,
  System.UITypes,
  System.Actions,
  NimbusForms.Controls.NotificationBar.Types,
  NimbusForms.Controls.NotificationBar,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.RichEdit,
  NimbusForms.Controls.TabControl,
  NimbusForms.Demo.Strings;

type
  TNotificationBarDemo = class(TThemedPanel)
  private
    FBar: TThemedIdeNotificationBar;
    FStatus: TThemedLabel;
    FEventLog: TThemedRichEdit;
    FRetry: TAction;
    FBuilding: Boolean;
    procedure Build;
    procedure Populate;
    procedure Command(Sender: TObject);
    procedure Retry(Sender: TObject);
    procedure Dismissed(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
    procedure ActionClicked(Sender: TObject; AMessage: TThemedIdeNotificationMessage; AAction: TThemedIdeNotificationAction);
    procedure LinkClicked(Sender: TObject; const AID, AURL: string);
    procedure Navigation(Sender: TObject; const AID: string; const AIndex, ACount: Integer);
    procedure Closing(Sender: TObject; AMessage: TThemedIdeNotificationMessage;
      const AReason: TNimbusNotificationDismissReason; var AAllow: Boolean);
    procedure Expired(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
    procedure LogEvent(const AText: string);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;



implementation

constructor TNotificationBarDemo.Create(AOwner: TComponent);
begin
  inherited;
  Align := alClient;
end;

procedure TNotificationBarDemo.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent = nil) or FBuilding or (FBar <> nil) or (csDestroying in ComponentState) then Exit;
  FBuilding := True;
  try Build; finally FBuilding := False; end;
end;

procedure TNotificationBarDemo.Build;
const Captions: array[0..10] of string = ('Info', 'Success', 'Warning', 'Error', 'Markdown',
  'Timed message', 'Stack / Carousel', 'Compact', 'Clear', 'Refill', 'Enable / Disable retry');
var
  Header, Body: TThemedPanel;
  LabelControl: TThemedLabel;
  Button: TThemedButton;
  I: Integer;
begin
  Header := TThemedPanel.Create(Self);
  Header.Parent := Self;
  Header.Align := alTop;
  Header.Height := 124;
  LabelControl := TThemedLabel.Create(Self);
  LabelControl.Parent := Header;
  LabelControl.SetBounds(16, 10, 800, 24);
  LabelControl.Caption := 'Visual Studio style notifications: plain text, Markdown, links and actions';
  for I := 0 to High(Captions) do
  begin
    Button := TThemedButton.Create(Self);
    Button.Parent := Header;
    Button.SetBounds(16 + (I mod 6) * 156, 42 + (I div 6) * 36, 148, 30);
    Button.Caption := Captions[I];
    Button.Tag := I;
    Button.OnClick := Command;
  end;
  FStatus := TThemedLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.Align := alBottom;
  FStatus.AutoSize := False;
  FStatus.Height := 36;
  FStatus.Caption := 'Use Tab to focus the bar, arrows to select actions, Enter to activate and Escape to dismiss.';
  FEventLog := TThemedRichEdit.Create(Self);
  FEventLog.Parent := Self;
  FEventLog.Align := alBottom;
  FEventLog.Height := 156;
  FEventLog.ReadOnly := True;
  FEventLog.PlainText := True;
  FEventLog.WordWrap := True;
  Body := TThemedPanel.Create(Self);
  Body.Parent := Self;
  Body.Align := alClient;
  FBar := TThemedIdeNotificationBar.Create(Self);
  FBar.Parent := Body;
  FBar.Align := alTop;
  FBar.MaxStackItems := 8;
  FBar.OnDismissed := Dismissed;
  FBar.OnAction := ActionClicked;
  FBar.OnLinkClicked := LinkClicked;
  FBar.OnNavigation := Navigation;
  FBar.OnClosing := Closing;
  FBar.OnExpired := Expired;
  LabelControl := TThemedLabel.Create(Self);
  LabelControl.Parent := Body;
  LabelControl.Align := alClient;
  LabelControl.AutoSize := False;
  LabelControl.WordWrap := True;
  LabelControl.Layout := tlCenter;
  LabelControl.Alignment := taCenter;
  LabelControl.Caption := 'Your editor or application content stays below the notification area.' + sLineBreak +
    'The bar adjusts its height as messages wrap or disappear. Markdown links raise OnLinkClicked.';
  FRetry := TAction.Create(Self);
  FRetry.Caption := 'Retry build';
  FRetry.OnExecute := Retry;
  Populate;
end;

procedure TNotificationBarDemo.Populate;
var M: TThemedIdeNotificationMessage; A: TThemedIdeNotificationAction;
begin
  FBar.Messages.BeginUpdate;
  try
    FBar.Messages.Clear;
    M := FBar.ShowNotification('A new SDK is available. Review the update before installing.', nnsInfo);
    A := M.Actions.Add;
    A.Text := 'Review update';
    A.OnClick := Retry;
    M := FBar.ShowNotification('Build completed successfully. 42 projects are up to date.', nnsSuccess);
    M := FBar.ShowNotification('Some packages could not be restored. The workspace remains available.', nnsWarning);
    A := M.Actions.Add;
    A.Action := FRetry;
    A.Style := nnasCompactButton;
    A.ClosesNotification := True;
    M := FBar.ShowNotification('Connection failed. Check your proxy configuration and try again.', nnsError);
    A := M.Actions.Add;
    A.Text := 'Open settings';
    A.OnClick := Retry;
    M := FBar.ShowNotification('**Markdown works here:** use *emphasis*, inline `code`, and ' +
      '[documentation](https://learn.microsoft.com/visualstudio/).' + sLineBreak +
      '- Links report their target through an event.' + sLineBreak +
      '- Plain text such as <b>literal tags</b> stays plain when Markdown is off.', nnsInfo, True);
    M.Sticky := True;
  finally FBar.Messages.EndUpdate; end;
  LogEvent('Five notifications loaded. Switch to carousel or resize the window to test wrapping.');
end;

procedure TNotificationBarDemo.Command(Sender: TObject);
var M: TThemedIdeNotificationMessage;
begin
  case TComponent(Sender).Tag of
    0: FBar.ShowNotification('Information: the workspace has been refreshed.', nnsInfo);
    1: FBar.ShowNotification('Success: all files were saved.', nnsSuccess);
    2: FBar.ShowNotification('Warning: an optional component is missing.', nnsWarning);
    3: FBar.ShowNotification('Error: build failed. Open the output window for details.', nnsError);
    4: FBar.ShowNotification('**Tip:** press `Ctrl+S` to save. [Read more](https://learn.microsoft.com/visualstudio/).', nnsInfo, True);
    5: begin M := FBar.ShowNotification('This notification expires after eight seconds.', nnsSuccess, False, 8000); M.Priority := 10; end;
    6: if FBar.DisplayMode = nndStack then FBar.DisplayMode := nndCarousel else FBar.DisplayMode := nndStack;
    7: FBar.CompactMode := not FBar.CompactMode;
    8: FBar.DismissAll;
    9: Populate;
    10: begin FRetry.Enabled := not FRetry.Enabled; FBar.RefreshNotifications; end;
  end;
  LogEvent(Format('Demo command: %s; messages: %d', [TThemedButton(Sender).Caption, FBar.Messages.Count]));
end;

procedure TNotificationBarDemo.Retry(Sender: TObject);
begin
  LogEvent('Action OnClick / TAction.OnExecute: command executed');
end;

procedure TNotificationBarDemo.Dismissed(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
begin
  LogEvent(Format('OnDismissed: %s; reason: %d; remaining: %d', [Copy(AID, 1, 9), Ord(AReason), FBar.Messages.Count]));
end;

procedure TNotificationBarDemo.ActionClicked(Sender: TObject; AMessage: TThemedIdeNotificationMessage; AAction: TThemedIdeNotificationAction);
begin
  LogEvent('OnAction: ' + AAction.DisplayText + '; notification: ' + Copy(AMessage.Text, 1, 80));
end;

procedure TNotificationBarDemo.LinkClicked(Sender: TObject; const AID, AURL: string);
begin
  LogEvent('OnLinkClicked: ' + AURL);
end;

procedure TNotificationBarDemo.LogEvent(const AText: string);
begin
  FStatus.Caption := AText;
  if FEventLog = nil then Exit;
  while FEventLog.Lines.Count >= 300 do FEventLog.Lines.Delete(0);
  FEventLog.Lines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + '  ' + AText);
  FEventLog.Editor.SelStart := Length(FEventLog.Text);
  FEventLog.Editor.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TNotificationBarDemo.Navigation(Sender: TObject; const AID: string; const AIndex, ACount: Integer);
begin
  LogEvent(Format('OnNavigation: notification %d / %d; id: %s', [AIndex + 1, ACount, Copy(AID, 1, 9)]));
end;

procedure TNotificationBarDemo.Closing(Sender: TObject; AMessage: TThemedIdeNotificationMessage;
  const AReason: TNimbusNotificationDismissReason; var AAllow: Boolean);
begin
  LogEvent(Format('OnClosing: reason %d; allowed: %s', [Ord(AReason), BoolToStr(AAllow, True)]));
end;

procedure TNotificationBarDemo.Expired(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
begin
  LogEvent('OnExpired: ' + Copy(AID, 1, 9));
end;

procedure AddNotificationBarDemo(const ATabs: TPageControl);
var Page: TTabSheet; Demo: TNotificationBarDemo;
begin
  Page := TTabSheet.Create(ATabs);
  Page.PageControl := ATabs;
  Page.Caption := 'NotificationBar';
  Demo := TNotificationBarDemo.Create(Page);
  Demo.Parent := Page;
  if ATabs is TThemedTabControl then TThemedTabControl(ATabs).SetTabClosable(Page, False);
end;


end.

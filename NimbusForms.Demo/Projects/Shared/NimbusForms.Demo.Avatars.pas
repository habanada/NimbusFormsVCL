{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Avatars;

interface

uses System.Classes, System.Types, Vcl.Controls, Vcl.ComCtrls, Vcl.Menus,
  NimbusForms.Controls.Panel, NimbusForms.Controls.Avatar, NimbusForms.Controls.Avatar.Badges,
  NimbusForms.Rendering.Avatar, NimbusForms.Controls.TabControl, NimbusForms.Controls.TextBox,
  NimbusForms.Controls.ComboBox, NimbusForms.Controls.NumericUpDown, NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.LogViewer, NimbusForms.Menus.PopupMenu;

type
  TAvatarDemo = class(TThemedPanel)
  private
    FAvatar: TThemedAvatar;
    FPresence, FKind, FTone, FAnchor: TThemedComboBox;
    FCount, FCustomCount: TThemedNumericUpDown;
    FKey, FText: TThemedTextBox;
    FZero, FBlock, FVisible, FEnabled: TThemedCheckBox;
    FLog: TThemedLogViewer;
    FMenu: TThemedPopupMenu;
    FContextHit: TThemedAvatarHitInfo;
    FContextAvatar: TThemedAvatar;
    FReady, FBuilt, FBuilding: Boolean;
    procedure EnsureControls;
    procedure BuildControls;
    procedure Command(Sender: TObject);
    procedure PresenceChanged(Sender: TObject);
    procedure CountChanged(Sender: TObject);
    procedure StatusClick(Sender: TObject);
    procedure CounterClick(Sender: TObject);
    procedure StarClick(Sender: TObject);
    procedure AvatarClick(Sender: TObject);
    procedure BadgeClick(Sender: TObject; const Hit: TThemedAvatarHitInfo);
    procedure BadgeDoubleClick(Sender: TObject; const Hit: TThemedAvatarHitInfo);
    procedure BadgeEnter(Sender: TObject; const Hit: TThemedAvatarHitInfo);
    procedure BadgeActivating(Sender: TObject; const Hit: TThemedAvatarHitInfo; var Allow: Boolean);
    procedure BadgeContext(Sender: TObject; const Hit: TThemedAvatarHitInfo; const MousePos: TPoint; var Handled: Boolean);
    procedure ContextCommand(Sender: TObject);
  protected
    procedure CreateWnd; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure AddNimbusAvatarDemo(Tabs: TThemedTabControl);

implementation

uses Winapi.Windows, System.SysUtils, System.Math, System.UITypes, Vcl.StdCtrls, NimbusForms.Controls.Button,
  NimbusForms.Controls.ThemedLabel, NimbusForms.Demo.AvatarChecks;

resourcestring
  SPage = 'Avatar badges';
  SIntro = 'Independent status, unread counter, favorite and custom badges. Click, double-click, right-click or use the keyboard.';
  SName = 'Alex Morgan';
  SStates = 'Hidden'#13#10'Online'#13#10'Away'#13#10'Busy'#13#10'Offline'#13#10'Connecting'#13#10'Do not disturb'#13#10'Invisible';
  SColors = 'Accent'#13#10'Green'#13#10'Yellow'#13#10'Red'#13#10'Blue'#13#10'Neutral';
  SKinds = 'Dot'#13#10'Counter'#13#10'Text'#13#10'Star';
  SAnchors = 'Top left'#13#10'Top right'#13#10'Bottom left'#13#10'Bottom right';
  SLegend = 'Presence / unread messages';
  SZero = 'Show zero';
  SBlock = 'Block badge activation';
  SAdd = '+1 message';
  SMany = 'Set 125';
  SClear = 'Mark read';
  SStar = 'Toggle favorite';
  SSize = 'Change size';
  SCustom = 'Custom badge: key / text / kind / color / corner / count';
  SKey = 'priority';
  SText = 'NEW';
  SRole = 'VIP';
  SRoleHint = 'Premium contact. Custom text badge with an independent key.';
  SCustomHint = 'Custom badge: %s';
  SVisible = 'Visible';
  SEnabled = 'Enabled';
  SApply = 'Apply badge';
  SRemove = 'Remove badge';
  SClearBadges = 'Clear custom badges';
  SReset = 'Reset this counter';
  SToggle = 'Toggle this badge enabled';
  SReady = 'Information Ready. Tab focuses the avatar. Arrow keys choose a badge; Space or Enter activates it. Escape cancels a pending press.';
  SBody = 'Information Avatar body clicked; badge clicks do not trigger this event.';
  SClicked = 'Information Badge click: %s, value %d, tag %d';
  SDouble = 'Information Badge double-click: %s';
  SHover = 'Debug Badge entered: %s';
  SBlocked = 'Warning Activation blocked: %s';
  SApplied = 'Information Applied badge: %s';
  SFailed = 'Error %s';
  SGreen = 'Green / success';
  SYellow = 'Yellow / warning';
  SRed = 'Red / error';
  SBlue = 'Blue / information';
  SChecks = 'Run checks';

constructor TAvatarDemo.Create(AOwner: TComponent);
begin inherited; FReady := True; EnsureControls; end;

procedure TAvatarDemo.CreateWnd;
begin inherited; EnsureControls; end;

procedure TAvatarDemo.EnsureControls;
var ExistingCount: Integer;
begin
  if not FReady or FBuilt or FBuilding or not HandleAllocated or (csDestroying in ComponentState) then Exit;
  FBuilding := True; ExistingCount := ComponentCount; DisableAlign;
  try
    try BuildControls; FBuilt := True;
    except
      FAvatar := nil; FPresence := nil; FKind := nil; FTone := nil; FAnchor := nil;
      FCount := nil; FCustomCount := nil; FKey := nil; FText := nil;
      FZero := nil; FBlock := nil; FVisible := nil; FEnabled := nil;
      FLog := nil; FMenu := nil; FContextAvatar := nil;
      while ComponentCount > ExistingCount do Components[ComponentCount - 1].Free;
      raise;
    end;
  finally
    try EnableAlign; finally FBuilding := False; end;
  end;
end;

procedure TAvatarDemo.BuildControls;
var Avatar: TThemedAvatar; Badge: TThemedAvatarBadge; I: Integer; Item: TMenuItem; AvatarFiles: TArray<string>;
  function FindAvatarImages: TArray<string>;
  var Candidates: TArray<string>; Directory, Extension, ExeDirectory: string;
    Files: TStringList; Search: TSearchRec;
  begin
    Result := nil; ExeDirectory := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
    Candidates := TArray<string>.Create(ExeDirectory + '\avatars',
      ExtractFileDir(ExeDirectory) + '\NimbusForms.Demo\avatars',
      IncludeTrailingPathDelimiter(GetCurrentDir) + 'avatars',
      IncludeTrailingPathDelimiter(GetCurrentDir) + 'NimbusForms.Demo\avatars');
    Files := TStringList.Create;
    try
      for Directory in Candidates do
      begin
        if not DirectoryExists(Directory) then Continue;
        if FindFirst(IncludeTrailingPathDelimiter(Directory) + '*', faAnyFile, Search) = 0 then
        try
          repeat
            if (Search.Attr and faDirectory) <> 0 then Continue;
            Extension := ExtractFileExt(Search.Name);
            if SameText(Extension, '.png') or SameText(Extension, '.jpg') or SameText(Extension, '.jpeg') then
              Files.Add(IncludeTrailingPathDelimiter(Directory) + Search.Name);
          until FindNext(Search) <> 0;
        finally FindClose(Search); end;
        if Files.Count > 0 then Break;
      end;
      Files.Sort; Result := Files.ToStringArray;
    finally Files.Free; end;
  end;
  procedure LoadAvatarImage(Control: TThemedAvatar; Index: Integer);
  begin
    if Length(AvatarFiles) > 0 then Control.Picture.LoadFromFile(AvatarFiles[Index mod Length(AvatarFiles)]);
  end;
  function P(Value: Integer): Integer;
  begin Result := MulDiv(Value, CurrentPPI, 96); end;
  procedure LabelAt(const Text: string; X, Y, W: Integer);
  var LabelControl: TThemedLabel;
  begin
    LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Self; LabelControl.SetBounds(P(X), P(Y), P(W), P(24));
    LabelControl.AutoSize := False; LabelControl.Caption := Text;
  end;
  function ComboAt(const Text: string; X, Y, W, Selected: Integer): TThemedComboBox;
  begin
    Result := TThemedComboBox.Create(Self); Result.Parent := Self; Result.SetBounds(P(X), P(Y), P(W), P(30));
    Result.Style := csDropDownList; Result.Items.Text := Text; Result.ItemIndex := Selected;
  end;
  function CheckAt(const Text: string; X, Y, W: Integer; Checked: Boolean): TThemedCheckBox;
  begin
    Result := TThemedCheckBox.Create(Self); Result.Parent := Self; Result.SetBounds(P(X), P(Y), P(W), P(28)); Result.Caption := Text; Result.Checked := Checked;
  end;
  procedure ButtonAt(const Text: string; X, Y, W, Tag: Integer);
  var Button: TThemedButton;
  begin
    Button := TThemedButton.Create(Self); Button.Parent := Self; Button.SetBounds(P(X), P(Y), P(W), P(30)); Button.Caption := Text; Button.Tag := Tag; Button.OnClick := Command;
  end;
begin
  AvatarFiles := FindAvatarImages;
  FLog := TThemedLogViewer.Create(Self); FLog.Parent := Self; FLog.Align := alBottom; FLog.Height := P(150);
  LabelAt(SIntro, 22, 8, 910);
  FAvatar := TThemedAvatar.Create(Self); FAvatar.Parent := Self; FAvatar.SetBounds(P(26), P(42), P(112), P(112));
  FAvatar.Text := SName; LoadAvatarImage(FAvatar, 0); FAvatar.SetPresence(tavsOnline); FAvatar.SetUnreadCount(8); FAvatar.ShowStar := True;
  Badge := FAvatar.SetBadgeText('role', SRole, tabtInfo, tabaTopLeft); Badge.Hint := SRoleHint; Badge.Tag := 1001;
  FAvatar.OnClick := AvatarClick; FAvatar.OnStatusClick := StatusClick; FAvatar.OnCounterClick := CounterClick; FAvatar.OnStarClick := StarClick;
  FAvatar.OnBadgeClickEx := BadgeClick; FAvatar.OnBadgeDblClick := BadgeDoubleClick; FAvatar.OnBadgeMouseEnter := BadgeEnter;
  FAvatar.OnBadgeActivating := BadgeActivating; FAvatar.OnBadgeContextPopup := BadgeContext;
  for I := 0 to 3 do
  begin
    Avatar := TThemedAvatar.Create(Self); Avatar.Parent := Self; Avatar.SetBounds(P(246 + I * 158), P(54), P(64), P(64)); Avatar.Text := SName;
    LoadAvatarImage(Avatar, I + 1);
    Avatar.SetBadgeDot('presence', TThemedAvatarBadgeTone(Ord(tabtSuccess) + I), tabaBottomLeft);
    Avatar.SetBadgeCounter('messages', 5 + I * 49, TThemedAvatarBadgeTone(Ord(tabtSuccess) + I), tabaTopRight);
    Avatar.OnBadgeClickEx := BadgeClick; Avatar.OnBadgeContextPopup := BadgeContext; Avatar.OnBadgeDblClick := BadgeDoubleClick;
    case I of
      0: LabelAt(SGreen, 224 + I * 158, 126, 142);
      1: LabelAt(SYellow, 224 + I * 158, 126, 142);
      2: LabelAt(SRed, 224 + I * 158, 126, 142);
      3: LabelAt(SBlue, 224 + I * 158, 126, 142);
    end;
  end;
  LabelAt(SLegend, 22, 162, 380);
  FPresence := ComboAt(SStates, 22, 188, 230, Ord(tavsOnline)); FPresence.OnChange := PresenceChanged;
  FCount := TThemedNumericUpDown.Create(Self); FCount.Parent := Self; FCount.SetBounds(P(266), P(188), P(128), P(30));
  FCount.Maximum := 10000; FCount.Value := 8; FCount.OnValueChanged := CountChanged;
  FZero := CheckAt(SZero, 410, 188, 140, False); FZero.OnCheckedChanged := CountChanged;
  FBlock := CheckAt(SBlock, 570, 188, 270, False);
  ButtonAt(SAdd, 22, 226, 145, 0); ButtonAt(SMany, 180, 226, 145, 1); ButtonAt(SClear, 338, 226, 145, 2);
  ButtonAt(SStar, 496, 226, 145, 3); ButtonAt(SSize, 654, 226, 145, 4);
  LabelAt(SCustom, 22, 268, 860);
  FKey := TThemedTextBox.Create(Self); FKey.Parent := Self; FKey.SetBounds(P(22), P(296), P(130), P(30)); FKey.Text := SKey;
  FText := TThemedTextBox.Create(Self); FText.Parent := Self; FText.SetBounds(P(164), P(296), P(110), P(30)); FText.Text := SText;
  FKind := ComboAt(SKinds, 286, 296, 120, Ord(tabkText)); FTone := ComboAt(SColors, 418, 296, 110, Ord(tabtInfo));
  FAnchor := ComboAt(SAnchors, 540, 296, 140, Ord(tabaTopLeft));
  FCustomCount := TThemedNumericUpDown.Create(Self); FCustomCount.Parent := Self; FCustomCount.SetBounds(P(692), P(296), P(108), P(30)); FCustomCount.Maximum := 10000; FCustomCount.Value := 3;
  FVisible := CheckAt(SVisible, 22, 338, 100, True); FEnabled := CheckAt(SEnabled, 130, 338, 100, True);
  ButtonAt(SApply, 246, 338, 145, 5); ButtonAt(SRemove, 404, 338, 145, 6); ButtonAt(SClearBadges, 562, 338, 237, 7);
  ButtonAt(SChecks, 812, 338, 104, 8);
  FMenu := TThemedPopupMenu.Create(Self);
  for I := 0 to 2 do
  begin
    Item := TMenuItem.Create(FMenu); Item.Tag := I; Item.OnClick := ContextCommand;
    case I of 0: Item.Caption := SReset; 1: Item.Caption := SToggle; 2: Item.Caption := SRemove; end;
    FMenu.Items.Add(Item);
  end;
  FLog.AppendLog(SReady);
end;

procedure TAvatarDemo.Command(Sender: TObject);
var Badge: TThemedAvatarBadge;
begin
  case TComponent(Sender).Tag of
    0: begin FAvatar.IncrementCounter; FCount.Value := FAvatar.Counter; end;
    1: begin FAvatar.SetUnreadCount(125); FCount.Value := 125; end;
    2: begin FAvatar.ClearCounter; FCount.Value := 0; end;
    3: FAvatar.ToggleStar;
    4: if FAvatar.Width = MulDiv(112, CurrentPPI, 96) then FAvatar.SetBounds(FAvatar.Left, FAvatar.Top, MulDiv(72, CurrentPPI, 96), MulDiv(72, CurrentPPI, 96))
      else FAvatar.SetBounds(FAvatar.Left, FAvatar.Top, MulDiv(112, CurrentPPI, 96), MulDiv(112, CurrentPPI, 96));
    5:
      try
        FAvatar.Badges.BeginUpdate;
        try
          Badge := FAvatar.Badges.Ensure(FKey.Text); Badge.Kind := TThemedAvatarBadgeKind(FKind.ItemIndex);
          Badge.Tone := TThemedAvatarBadgeTone(FTone.ItemIndex); Badge.Anchor := TThemedAvatarBadgeAnchor(FAnchor.ItemIndex);
          Badge.Text := FText.Text; Badge.Count := Round(FCustomCount.Value); Badge.Visible := FVisible.Checked; Badge.Enabled := FEnabled.Checked;
          Badge.Hint := Format(SCustomHint, [Badge.Key]);
        finally FAvatar.Badges.EndUpdate; end;
        FLog.AppendLog(Format(SApplied, [FKey.Text]));
      except on E: Exception do FLog.AppendLog(Format(SFailed, [E.Message])); end;
    6: FAvatar.RemoveBadge(FKey.Text);
    7: FAvatar.Badges.Clear;
    8: try FLog.AppendLog(RunAvatarChecks(TComponentClass(ClassType))); except on E: Exception do FLog.AppendLog(Format(SFailed, [E.Message])); end;
  end;
end;
procedure TAvatarDemo.PresenceChanged(Sender: TObject);
begin FAvatar.SetPresence(TThemedAvatarStatus(FPresence.ItemIndex)); end;
procedure TAvatarDemo.CountChanged(Sender: TObject);
begin FAvatar.SetUnreadCount(Round(FCount.Value)); FAvatar.ShowZeroCounter := FZero.Checked; end;
procedure TAvatarDemo.StatusClick(Sender: TObject);
begin FPresence.ItemIndex := (FPresence.ItemIndex + 1) mod FPresence.Items.Count; PresenceChanged(FPresence); end;
procedure TAvatarDemo.CounterClick(Sender: TObject);
begin FAvatar.ClearCounter; FCount.Value := 0; end;
procedure TAvatarDemo.StarClick(Sender: TObject);
begin FLog.AppendLog(SRoleHint); end;
procedure TAvatarDemo.AvatarClick(Sender: TObject);
begin FLog.AppendLog(SBody); end;
procedure TAvatarDemo.BadgeClick(Sender: TObject; const Hit: TThemedAvatarHitInfo);
begin FLog.AppendLog(Format(SClicked, [Hit.Key, Hit.Count, Hit.Tag])); end;
procedure TAvatarDemo.BadgeDoubleClick(Sender: TObject; const Hit: TThemedAvatarHitInfo);
begin FLog.AppendLog(Format(SDouble, [Hit.Key])); end;
procedure TAvatarDemo.BadgeEnter(Sender: TObject; const Hit: TThemedAvatarHitInfo);
begin FLog.AppendLog(Format(SHover, [Hit.Key])); end;
procedure TAvatarDemo.BadgeActivating(Sender: TObject; const Hit: TThemedAvatarHitInfo; var Allow: Boolean);
begin Allow := not FBlock.Checked; if not Allow then FLog.AppendLog(Format(SBlocked, [Hit.Key])); end;
procedure TAvatarDemo.BadgeContext(Sender: TObject; const Hit: TThemedAvatarHitInfo; const MousePos: TPoint; var Handled: Boolean);
var Badge: TThemedAvatarBadge; P: TPoint; Avatar: TThemedAvatar;
begin
  Avatar := TThemedAvatar(Sender); FContextHit := Hit;
  if FContextAvatar <> nil then FContextAvatar.RemoveFreeNotification(Self);
  FContextAvatar := Avatar; FContextAvatar.FreeNotification(Self);
  Badge := Avatar.Badges.Find(Hit.Key); FMenu.Items[0].Enabled := (Hit.Part = tapCounter) or ((Badge <> nil) and (Badge.Kind = tabkCounter));
  FMenu.Items[2].Enabled := Hit.Part = tapBadge;
  if MousePos.X = -1 then P := Point(Hit.Bounds.Left, Hit.Bounds.Bottom) else P := MousePos;
  P := Avatar.ClientToScreen(P); Handled := True; FMenu.Popup(P.X, P.Y);
end;
procedure TAvatarDemo.ContextCommand(Sender: TObject);
var Avatar: TThemedAvatar; Badge: TThemedAvatarBadge;
begin
  Avatar := FContextAvatar; if Avatar = nil then Exit;
  Badge := Avatar.Badges.Find(FContextHit.Key);
  if (FContextHit.Part = tapBadge) and ((Badge = nil) or (Badge.ID <> FContextHit.BadgeID)) then Exit;
  case TComponent(Sender).Tag of
    0: if Badge <> nil then Badge.Count := 0 else begin Avatar.ClearCounter; if Avatar = FAvatar then FCount.Value := 0; end;
    1: if Badge <> nil then Badge.Enabled := not Badge.Enabled else
      case FContextHit.Part of tapStatus: Avatar.StatusEnabled := not Avatar.StatusEnabled;
        tapCounter: Avatar.CounterEnabled := not Avatar.CounterEnabled; tapStar: Avatar.StarEnabled := not Avatar.StarEnabled; end;
    2: if Badge <> nil then Badge.Free;
  end;
end;

procedure TAvatarDemo.Notification(AComponent: TComponent; Operation: TOperation);
begin inherited; if (Operation = opRemove) and (AComponent = FContextAvatar) then FContextAvatar := nil; end;

procedure AddNimbusAvatarDemo(Tabs: TThemedTabControl);
var Tab: TTabSheet; Demo: TAvatarDemo;
begin
  Tab := TTabSheet.Create(Tabs); Tab.PageControl := Tabs; Tab.Caption := SPage;
  Demo := TAvatarDemo.Create(Tab); Demo.Parent := Tab; Demo.Align := alClient;
end;

end.

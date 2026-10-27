program ModernFormTest;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  NimbusForms.Theming.Types in '..\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Palette in '..\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.Strings in '..\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.WinVersion in '..\src\NimbusForms.Theming.WinVersion.pas',
  NimbusForms.Theming.Win32 in '..\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.PresetFactory in '..\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Serializer in '..\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Presets in '..\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Manager in '..\src\NimbusForms.Theming.Manager.pas',
  NimbusForms.Theming.Form.Strings in '..\src\NimbusForms.Theming.Form.Strings.pas',
  NimbusForms.Theming.Form.Types in '..\src\NimbusForms.Theming.Form.Types.pas',
  NimbusForms.Theming.Form.Native in '..\src\NimbusForms.Theming.Form.Native.pas',
  NimbusForms.Theming.Form.Accessibility in '..\src\NimbusForms.Theming.Form.Accessibility.pas',
  NimbusForms.Theming.Form in '..\src\NimbusForms.Theming.Form.pas';

type
  ModernFormTestTexts = class
  public
  const
    FormCaption = 'NimbusForms Modern Form Test';
    LeftHostLabel = 'Left host';
    RightHostButton = 'Right';
    SearchHint = 'Center host';
    StateDebug = 'Debug';
    StateError = 'Error';
    StateWarn = 'Warn';
    StateOk = 'OK';
    StateNormal = 'Normal';
    StateCustom = 'Custom';
    TitleBarNormal = 'TitleBar: Normal';
    TitleBarCompact = 'TitleBar: Compact';
    TitleBarSpacious = 'TitleBar: Spacious';
    CornerRound = 'Corner: Round';
    CornerSmall = 'Corner: RoundSmall';
    CornerSquare = 'Corner: Square';
    ToggleClip = 'Toggle clip to corners';
    ToggleSnap = 'Toggle native snap layout';
    ToggleIcon = 'Toggle icon';
    ToggleMax = 'Toggle maximize button';
    NextTheme = 'Next theme';
    ThemeLabel = 'Theme: %s';
    DpiLabel = 'DPI: %d';
    StatusFormat = 'State=%s Dpi=%d';
    Client = 'Client area';
  end;

  TDemoForm = class(TThemedModernForm)
  private
    FBody: TFlowPanel;
    FInfo: TLabel;
    FLeftLabel: TLabel;
    FRightButton: TButton;
    FSearch: TEdit;
    FThemeIndex: Integer;
    function AddButton(const ACaption: string; const AHandler: TNotifyEvent; const ATag: Integer = 0): TButton;
    procedure StateClick(Sender: TObject);
    procedure TitleBarClick(Sender: TObject);
    procedure CornerClick(Sender: TObject);
    procedure ClipClick(Sender: TObject);
    procedure SnapClick(Sender: TObject);
    procedure IconClick(Sender: TObject);
    procedure MaxClick(Sender: TObject);
    procedure ThemeClick(Sender: TObject);
    procedure DpiChanged(Sender: TObject);
    procedure UpdateInfo;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

function TDemoForm.AddButton(const ACaption: string; const AHandler: TNotifyEvent; const ATag: Integer): TButton;
begin
  Result := TButton.Create(Self);
  Result.Caption := ACaption;
  Result.Tag := ATag;
  Result.Width := 150;
  Result.Height := 28;
  Result.OnClick := AHandler;
  Result.Parent := FBody;
end;

constructor TDemoForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := ModernFormTestTexts.FormCaption;
  Width := 760;
  Height := 460;
  OnChromeDpiChanged := DpiChanged;

  FLeftLabel := TLabel.Create(Self);
  FLeftLabel.Caption := ModernFormTestTexts.LeftHostLabel;
  FLeftLabel.AutoSize := False;
  FLeftLabel.Width := 70;
  FLeftLabel.Height := 24;
  FLeftLabel.Layout := tlCenter;
  FLeftLabel.Parent := TitleBarLeftHost;

  FSearch := TEdit.Create(Self);
  FSearch.TextHint := ModernFormTestTexts.SearchHint;
  FSearch.SetBounds(0, 0, 180, 24);
  FSearch.Parent := TitleBarCenterHost;

  FRightButton := TButton.Create(Self);
  FRightButton.Caption := ModernFormTestTexts.RightHostButton;
  FRightButton.SetBounds(0, 0, 70, 24);
  FRightButton.Parent := TitleBarRightHost;

  FBody := TFlowPanel.Create(Self);
  FBody.BevelOuter := bvNone;
  FBody.Align := alTop;
  FBody.Height := 220;
  FBody.Padding.SetBounds(8, 8, 8, 8);
  FBody.ParentBackground := False;
  FBody.Parent := Self;

  AddButton(ModernFormTestTexts.StateDebug, StateClick, Ord(TThemedModernFormChromeState.Debug));
  AddButton(ModernFormTestTexts.StateError, StateClick, Ord(TThemedModernFormChromeState.Error));
  AddButton(ModernFormTestTexts.StateWarn, StateClick, Ord(TThemedModernFormChromeState.Warning));
  AddButton(ModernFormTestTexts.StateOk, StateClick, Ord(TThemedModernFormChromeState.Success));
  AddButton(ModernFormTestTexts.StateNormal, StateClick, Ord(TThemedModernFormChromeState.Normal));
  AddButton(ModernFormTestTexts.StateCustom, StateClick, Ord(TThemedModernFormChromeState.Custom));
  AddButton(ModernFormTestTexts.TitleBarNormal, TitleBarClick, Ord(TThemedModernFormTitleBarMode.Normal));
  AddButton(ModernFormTestTexts.TitleBarCompact, TitleBarClick, Ord(TThemedModernFormTitleBarMode.Compact));
  AddButton(ModernFormTestTexts.TitleBarSpacious, TitleBarClick, Ord(TThemedModernFormTitleBarMode.Spacious));
  AddButton(ModernFormTestTexts.CornerRound, CornerClick, Ord(TThemedModernFormCornerMode.Round));
  AddButton(ModernFormTestTexts.CornerSmall, CornerClick, Ord(TThemedModernFormCornerMode.RoundSmall));
  AddButton(ModernFormTestTexts.CornerSquare, CornerClick, Ord(TThemedModernFormCornerMode.Square));
  AddButton(ModernFormTestTexts.ToggleClip, ClipClick);
  AddButton(ModernFormTestTexts.ToggleSnap, SnapClick);
  AddButton(ModernFormTestTexts.ToggleIcon, IconClick);
  AddButton(ModernFormTestTexts.ToggleMax, MaxClick);
  AddButton(ModernFormTestTexts.NextTheme, ThemeClick);

  FInfo := TLabel.Create(Self);
  FInfo.Align := alClient;
  FInfo.AutoSize := False;
  FInfo.Alignment := taCenter;
  FInfo.Layout := tlCenter;
  FInfo.Caption := ModernFormTestTexts.Client;
  FInfo.Parent := Self;
  UpdateInfo;
end;

procedure TDemoForm.UpdateInfo;
begin
  FInfo.Caption := Format(ModernFormTestTexts.StatusFormat, [GetEnumName(TypeInfo(TThemedModernFormChromeState),
    Ord(ChromeState)), CurrentDpi]);
end;

procedure TDemoForm.StateClick(Sender: TObject);
var
  LState: TThemedModernFormChromeState;
begin
  LState := TThemedModernFormChromeState(TButton(Sender).Tag);
  if LState = TThemedModernFormChromeState.Custom then
    CustomChromeStatusColor := ThemeColor(255, 0, 188, 212)
  else
    ChromeState := LState;
  UpdateInfo;
end;

procedure TDemoForm.TitleBarClick(Sender: TObject);
begin
  TitleBarMode := TThemedModernFormTitleBarMode(TButton(Sender).Tag);
end;

procedure TDemoForm.CornerClick(Sender: TObject);
begin
  CornerMode := TThemedModernFormCornerMode(TButton(Sender).Tag);
end;

procedure TDemoForm.ClipClick(Sender: TObject);
begin
  ClipWindowToChromeCorners := not ClipWindowToChromeCorners;
end;

procedure TDemoForm.SnapClick(Sender: TObject);
begin
  UseNativeSnapLayout := not UseNativeSnapLayout;
end;

procedure TDemoForm.IconClick(Sender: TObject);
begin
  ShowChromeIcon := not ShowChromeIcon;
end;

procedure TDemoForm.MaxClick(Sender: TObject);
begin
  ShowMaximizeButton := not ShowMaximizeButton;
end;

procedure TDemoForm.ThemeClick(Sender: TObject);
var
  LNames: TArray<string>;
begin
  LNames := TThemePresets.GetNames;
  if Length(LNames) = 0 then
    Exit;
  FThemeIndex := (FThemeIndex + 1) mod Length(LNames);
  ThemeManager.SetThemeByName(LNames[FThemeIndex]);
  Caption := Format(ModernFormTestTexts.ThemeLabel, [LNames[FThemeIndex]]);
end;

procedure TDemoForm.DpiChanged(Sender: TObject);
begin
  UpdateInfo;
end;

var
  LForm: TDemoForm;
begin
  Application.Initialize;
  Application.Title := ModernFormTestTexts.FormCaption;
  LForm := TDemoForm.CreateNew(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end.

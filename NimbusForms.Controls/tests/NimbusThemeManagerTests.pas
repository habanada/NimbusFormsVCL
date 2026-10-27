{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusThemeManagerTests;

interface

function RunNimbusThemeManagerChecks(const Directory: string): Integer;

implementation

uses System.Classes, System.SysUtils, System.IOUtils, System.JSON, Vcl.Controls, Vcl.Forms,
  NimbusForms.Controls.Button, NimbusForms.Controls.Panel, NimbusForms.Theming.Presets,
  NimbusForms.Controls.ThemeManager, NimbusForms.Theming.Manager, NimbusForms.Theming.Palette,
  NimbusForms.Theming.Serializer;

type
  TThemeComponentAccess = class(TThemedThemeManager)
  public
    procedure FinishLoading;
    procedure UseDesigner;
    procedure RefreshPreview;
  end;

  TThemeButtonProbe = class(TThemedButton)
  private
    FConstructed: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    function Matches(const APalette: TThemePalette): Boolean;
  end;

  TThemeErrorProbe = class
  public
    Errors: Integer;
    procedure Failed(Sender: TObject; const Operation, FileName, ErrorMessage: string);
  end;

resourcestring
  SCheckFailed = 'Theme component check failed: %s';

procedure TThemeComponentAccess.FinishLoading;
begin Loaded; end;

procedure TThemeComponentAccess.UseDesigner;
begin SetDesigning(True); end;

procedure TThemeComponentAccess.RefreshPreview;
var Done: Boolean;
begin Done := True; PreviewIdle(Self, Done); end;

constructor TThemeButtonProbe.Create(AOwner: TComponent);
begin inherited; FConstructed := True; end;

procedure TThemeButtonProbe.ApplyTheme(const APalette: TThemePalette);
begin
  if not FConstructed then raise EInvalidOperation.CreateFmt(SCheckFailed, ['theme applied during construction']);
  inherited;
end;

function TThemeButtonProbe.Matches(const APalette: TThemePalette): Boolean;
begin Result := (Palette <> nil) and (TThemePaletteSerializer.ToJson('', Palette) = TThemePaletteSerializer.ToJson('', APalette)); end;

procedure TThemeErrorProbe.Failed(Sender: TObject; const Operation, FileName, ErrorMessage: string);
begin Inc(Errors); end;

function RunNimbusThemeManagerChecks(const Directory: string): Integer;
var Component, Other: TThemeComponentAccess; Clone, Source: TThemedThemeManager; Probe: TThemeErrorProbe;
  Original: TThemePalette; Files: TStringList; Stream: TMemoryStream;
  ID: TGUID; Prefix, Path, Fingerprint, FileName: string; I: Integer; Rejected: Boolean;
  procedure Check(Condition: Boolean; const Name: string);
  begin if not Condition then raise EInvalidOperation.CreateFmt(SCheckFailed, [Name]); Inc(Result); end;
  function NewFile(const Suffix: string): string;
  begin Result := TPath.Combine(Directory, Prefix + Suffix); Files.Add(Result); end;
  function StoredName(const Path: string): string;
  var Value: TJSONValue;
  begin
    Value := TJSONObject.ParseJSONValue(TFile.ReadAllText(Path, TEncoding.UTF8));
    try
      Check(Value is TJSONObject, 'saved JSON object');
      Result := TJSONObject(Value).GetValue<string>('theme');
    finally Value.Free; end;
  end;
  procedure CheckInsertedControls;
  var Form: TForm; Manager: TThemeComponentAccess; Panel: TThemedPanel;
    Button, Outside, DisabledPreview: TThemeButtonProbe; Nord, Dracula, Light: TThemePalette;
  begin
    Form := TForm.CreateNew(nil);
    Nord := TThemePresets.GetByName('Nord'); Dracula := TThemePresets.GetByName('Dracula'); Light := TThemePresets.GetByName('Light');
    try
      Manager := TThemeComponentAccess.Create(Form); Manager.UseDesigner; Manager.ThemeName := 'Nord'; Manager.FinishLoading;
      Panel := TThemedPanel.Create(Form); Panel.Parent := Form;
      Button := TThemeButtonProbe.Create(Form); Button.Parent := Panel;
      Check(not Form.HandleAllocated and not Button.HandleAllocated, 'insertion does not force handles');
      Manager.RefreshPreview;
      Check(Button.Matches(Nord), 'later inserted nested button inherits designer theme');
      Check(not Form.HandleAllocated and not Button.HandleAllocated, 'preview does not force handles');
      Check(Fingerprint = TThemePaletteSerializer.ToJson('', ThemeManager.CurrentTheme), 'inserted controls leave global theme unchanged');
      Manager.Target := Panel; Manager.ThemeName := 'Dracula';
      Outside := TThemeButtonProbe.Create(Form); Outside.Parent := Form; Outside.ApplyTheme(Light);
      Button := TThemeButtonProbe.Create(Form); Button.Parent := Panel;
      Manager.RefreshPreview;
      Check(Button.Matches(Dracula) and Outside.Matches(Light), 'insert refresh respects Target');
      Manager.DesignPreview := False;
      DisabledPreview := TThemeButtonProbe.Create(Form); DisabledPreview.Parent := Panel; DisabledPreview.ApplyTheme(Light);
      Manager.RefreshPreview;
      Check(DisabledPreview.Matches(Light), 'disabled preview leaves new control unchanged');
    finally Form.Free; Light.Free; Dracula.Free; Nord.Free; end;
  end;
begin
  Result := 0;
  if not DirectoryExists(Directory) then raise EArgumentException.Create(Directory);
  Original := nil;
  if ThemeManager.CurrentTheme <> nil then Original := ThemeManager.CurrentTheme.Clone;
  Files := TStringList.Create; Stream := TMemoryStream.Create; Probe := TThemeErrorProbe.Create;
  CreateGUID(ID); Prefix := 'nimbus-theme-check-' + GUIDToString(ID);
  try
    Path := NewFile('-disabled.json');
    Component := TThemeComponentAccess.Create(nil);
    try
      Check(not Component.SaveToFile and Component.DesignPreview, 'property defaults');
      Component.FileName := Path; Component.ThemeName := 'Dark';
      Check(Component.Apply, 'explicit apply');
    finally Component.Free; end;
    Check(not TFile.Exists(Path), 'SaveToFile=False performs no write');
    Fingerprint := TThemePaletteSerializer.ToJson('', ThemeManager.CurrentTheme);
    Path := NewFile('-designer.json');
    Component := TThemeComponentAccess.Create(nil);
    try
      Component.UseDesigner; Component.FileName := Path; Component.SaveToFile := True;
      Component.ThemeName := 'Nord'; Component.FinishLoading;
      Check(not Component.SaveSettings, 'designer cannot save');
      Check(Fingerprint = TThemePaletteSerializer.ToJson('', ThemeManager.CurrentTheme), 'designer leaves global palette unchanged');
    finally Component.Free; end;
    Check(not TFile.Exists(Path), 'designer creates no file');
    CheckInsertedControls;
    Path := NewFile('-selection.json'); TFile.WriteAllText(Path, '{"theme":"Dark"}', TEncoding.UTF8);
    Component := TThemeComponentAccess.Create(nil);
    try
      Component.FileName := Path; Component.ThemeName := 'Nord'; Component.SaveToFile := True;
      Check(Component.LoadSettings and (Component.CurrentThemeName = 'Dark') and (Component.ThemeName = 'Nord'), 'persisted selection and property fallback');
      Other := TThemeComponentAccess.Create(nil);
      try
        Other.FinishLoading;
        Check(Other.CurrentThemeName = 'Dark', 'another form component preserves active theme');
        Other.FileName := Path; Rejected := False;
        try Other.SaveToFile := True; except on E: EInvalidOperation do Rejected := True; end;
        Check(Rejected and not Other.SaveToFile, 'duplicate writer rejected without changing property');
      finally Other.Free; end;
      ThemeManager.SetThemeByName('Dracula');
    finally Component.Free; end;
    Check(StoredName(Path) = 'Dracula', 'destruction saves later external theme selection');
    for I := 0 to 3 do
    begin
      Path := NewFile('-fallback-' + IntToStr(I) + '.json');
      case I of
        1: TFile.WriteAllText(Path, '{"theme":"Unregistered theme"}', TEncoding.UTF8);
        2: TFile.WriteAllText(Path, '{broken', TEncoding.UTF8);
        3: TFile.WriteAllText(Path, '{"theme":42}', TEncoding.UTF8);
      end;
      Component := TThemeComponentAccess.Create(nil);
      try
        Component.FileName := Path; Component.ThemeName := 'Nord'; Component.SaveToFile := True;
        Component.OnPersistenceError := Probe.Failed;
        Check(Component.LoadSettings and (Component.CurrentThemeName = 'Nord'), 'missing, unknown or malformed selection falls back');
      finally Component.Free; end;
    end;
    RegisterClass(TThemedThemeManager);
    Source := TThemedThemeManager.Create(nil);
    try
      Source.ThemeName := 'Nord'; Source.DesignPreview := False;
      Clone := TThemedThemeManager.Create(nil);
      try
        Stream.WriteComponent(Source); Stream.Position := 0;
        Stream.ReadComponent(Clone);
        Check((Clone.ThemeName = 'Nord') and not Clone.SaveToFile and not Clone.DesignPreview, 'DFM property round trip');
      finally Clone.Free; end;
    finally Source.Free; end;
    Path := NewFile('-blocker'); TFile.WriteAllText(Path, 'occupied', TEncoding.UTF8);
    Component := TThemeComponentAccess.Create(nil);
    try
      Component.FileName := TPath.Combine(Path, 'theme.json'); Component.SaveToFile := True;
      Component.OnPersistenceError := Probe.Failed; I := Probe.Errors;
      Check(not Component.SaveSettings and (Component.LastError <> '') and (Probe.Errors = I + 1), 'write error reported without escaping');
      Component.SaveToFile := False;
    finally Component.Free; end;
  finally
    if Original <> nil then
    try ThemeManager.ApplyGlobal(Original); finally Original.Free; end;
    for FileName in Files do if TFile.Exists(FileName) then TFile.Delete(FileName);
    Probe.Free; Stream.Free; Files.Free;
  end;
end;

end.

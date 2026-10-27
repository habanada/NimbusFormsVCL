{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ThemeManager;

interface

uses System.Classes, System.Generics.Collections, Vcl.Controls, Vcl.AppEvnts, NimbusForms.Theming.Palette,
  NimbusForms.Theming.Manager;

type
  TThemePersistenceErrorEvent = procedure(Sender: TObject; const Operation, FileName, ErrorMessage: string) of object;

  TThemedThemeManager = class(TComponent, IThemeAware)
  private
    class var FFileOwners: TList<TThemedThemeManager>;
    class var FShuttingDown: Boolean;
  private
    FThemeName, FFileName, FClaimedFileName, FAppliedName, FLastError: string;
    FSaveToFile, FDesignPreview, FReady, FRegistered, FApplying, FInitialized: Boolean;
    FTarget: TControl;
    FPreviewEvents: TApplicationEvents;
    FPreviewPending: Boolean;
    FOnThemeChanged: TThemeChangedEvent;
    FOnPersistenceError: TThemePersistenceErrorEvent;
    procedure SetThemeName(const Value: string);
    procedure SetFileName(const Value: string);
    procedure SetSaveToFile(Value: Boolean);
    procedure SetDesignPreview(Value: Boolean);
    procedure SetTarget(Value: TControl);
    function ResolveTarget: TControl;
    function ResolveFileName(const Value: string): string;
    function GetSettingsFileName: string;
    function GetCurrentThemeName: string;
    procedure ClaimFile(const Path: string);
    procedure ReleaseFile;
    procedure Observe;
    procedure ObservePreview;
    procedure ReportError(const Operation, MessageText: string);
    function TryApplyName(const Value: string): Boolean;
  protected
    procedure PreviewIdle(Sender: TObject; var Done: Boolean);
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    class constructor Initialize;
    class destructor Finalize;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    function Apply: Boolean;
    function LoadSettings: Boolean;
    function SaveSettings: Boolean;
    property CurrentThemeName: string read GetCurrentThemeName;
    property SettingsFileName: string read GetSettingsFileName;
    property LastError: string read FLastError;
  published
    property ThemeName: string read FThemeName write SetThemeName;
    property Target: TControl read FTarget write SetTarget;
    property DesignPreview: Boolean read FDesignPreview write SetDesignPreview default True;
    property SaveToFile: Boolean read FSaveToFile write SetSaveToFile default False;
    property FileName: string read FFileName write SetFileName;
    property OnThemeChanged: TThemeChangedEvent read FOnThemeChanged write FOnThemeChanged;
    property OnPersistenceError: TThemePersistenceErrorEvent read FOnPersistenceError write FOnPersistenceError;
  end;

implementation

uses Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON,
  NimbusForms.Theming.Presets, NimbusForms.Theming.Serializer;

resourcestring
  SDuplicateFile = 'Another NimbusForms theme component already manages "%s". Enable SaveToFile on only one component for this file.';
  SInvalidSettings = 'The theme settings must contain a nonempty string named "theme".';
  SUnknownTheme = 'The selected theme "%s" is not registered.';
  SUnnamedTheme = 'The active palette does not match a registered theme and cannot be saved by name.';
  SPersistenceError = 'NimbusForms theme %s failed for "%s": %s';

class constructor TThemedThemeManager.Initialize;
begin FFileOwners := TList<TThemedThemeManager>.Create; end;

class destructor TThemedThemeManager.Finalize;
var Component: TThemedThemeManager;
begin
  FShuttingDown := True;
  try
    for Component in FFileOwners do
      if Component.FInitialized and Component.FSaveToFile and not (csDesigning in Component.ComponentState) then
        Component.SaveSettings;
  finally FreeAndNil(FFileOwners); end;
end;

constructor TThemedThemeManager.Create(AOwner: TComponent);
begin
  inherited;
  FThemeName := TThemePresets.DefaultThemeName; FDesignPreview := True;
end;

destructor TThemedThemeManager.Destroy;
begin
  FreeAndNil(FPreviewEvents);
  try
    if not FShuttingDown then
    begin
      if FRegistered then
      begin ThemeManager.UnregisterAware(Self); FRegistered := False; end;
      if FInitialized and FSaveToFile and not (csDesigning in ComponentState) then SaveSettings;
    end;
  finally
    ReleaseFile;
    inherited;
  end;
end;

function TThemedThemeManager.ResolveTarget: TControl;
var Component: TComponent;
begin
  Result := FTarget;
  if Result <> nil then Exit;
  Component := Owner;
  while Component <> nil do
  begin
    if Component is TControl then Exit(TControl(Component));
    Component := Component.Owner;
  end;
end;

function TThemedThemeManager.ResolveFileName(const Value: string): string;
begin
  if Trim(Value) = '' then Result := ChangeFileExt(ParamStr(0), '.theme.json')
  else if TPath.IsPathRooted(Value) then Result := Value
  else Result := TPath.Combine(ExtractFilePath(ParamStr(0)), Value);
  Result := TPath.GetFullPath(Result);
end;

function TThemedThemeManager.GetSettingsFileName: string;
begin Result := ResolveFileName(FFileName); end;

procedure TThemedThemeManager.ClaimFile(const Path: string);
var Component: TThemedThemeManager;
begin
  if FFileOwners = nil then Exit;
  for Component in FFileOwners do
    if (Component <> Self) and SameFileName(Component.FClaimedFileName, Path) then
      raise EInvalidOperation.CreateFmt(SDuplicateFile, [Path]);
  if not FFileOwners.Contains(Self) then FFileOwners.Add(Self);
  FClaimedFileName := Path;
end;

procedure TThemedThemeManager.ReleaseFile;
begin
  if FFileOwners <> nil then FFileOwners.Remove(Self);
  FClaimedFileName := '';
end;

procedure TThemedThemeManager.Observe;
begin
  if FRegistered or FShuttingDown or (csDesigning in ComponentState) then Exit;
  FRegistered := True;
  try ThemeManager.RegisterAware(Self);
  except ThemeManager.UnregisterAware(Self); FRegistered := False; raise; end;
end;

procedure TThemedThemeManager.ObservePreview;
begin
  if (FPreviewEvents <> nil) or not (csDesigning in ComponentState) or not FDesignPreview then Exit;
  FPreviewEvents := TApplicationEvents.Create(nil);
  FPreviewEvents.OnIdle := PreviewIdle;
end;

procedure TThemedThemeManager.PreviewIdle(Sender: TObject; var Done: Boolean);
begin
  if not FPreviewPending or FShuttingDown or (csDestroying in ComponentState) then Exit;
  if (csLoading in ComponentState) or (csReading in ComponentState) then Exit;
  if (Owner <> nil) and ((csLoading in Owner.ComponentState) or (csReading in Owner.ComponentState) or
    (csDestroying in Owner.ComponentState)) then Exit;
  FPreviewPending := False;
  if (csDesigning in ComponentState) and FDesignPreview then Apply;
end;

procedure TThemedThemeManager.ApplyTheme(const APalette: TThemePalette);
begin
  if FApplying or FShuttingDown or (csDestroying in ComponentState) or (csDesigning in ComponentState) then Exit;
  if Assigned(FOnThemeChanged) then FOnThemeChanged(Self, APalette);
end;

function TThemedThemeManager.TryApplyName(const Value: string): Boolean;
var Palette: TThemePalette; Control: TControl;
begin
  Result := False;
  if FApplying or FShuttingDown or (csDestroying in ComponentState) then Exit;
  if (csDesigning in ComponentState) and not FDesignPreview then Exit;
  Palette := TThemePresets.GetByName(Value);
  if Palette = nil then Exit;
  FApplying := True;
  try
    try
      Control := ResolveTarget;
      if csDesigning in ComponentState then
      begin
        ObservePreview; FPreviewPending := False;
        if Control <> nil then ThemeManager.Apply(Control, Palette);
      end
      else
      begin
        Observe; ThemeManager.ApplyGlobal(Palette);
        if Control <> nil then ThemeManager.ApplyCurrent(Control);
      end;
      FAppliedName := Value; FInitialized := True; Result := True;
    finally Palette.Free; end;
  finally FApplying := False; end;
  if not (csDesigning in ComponentState) and Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self, ThemeManager.CurrentTheme);
end;

function TThemedThemeManager.Apply: Boolean;
begin
  Result := TryApplyName(FThemeName);
  if not Result and not (csDesigning in ComponentState) and not FApplying then
    ReportError('apply', Format(SUnknownTheme, [FThemeName]));
end;

procedure TThemedThemeManager.Loaded;
var Control: TControl;
begin
  inherited; FReady := True;
  if csDesigning in ComponentState then
  begin if FDesignPreview then Apply; Exit; end;
  if FSaveToFile then LoadSettings
  else if ThemeManager.CurrentTheme = nil then Apply
  else
  begin
    Control := ResolveTarget;
    if Control <> nil then ThemeManager.ApplyCurrent(Control);
    FInitialized := True; Observe;
  end;
end;

procedure TThemedThemeManager.SetThemeName(const Value: string);
begin
  if FThemeName = Value then Exit;
  FThemeName := Value;
  if not (csLoading in ComponentState) then Apply;
end;

procedure TThemedThemeManager.SetTarget(Value: TControl);
begin
  if FTarget = Value then Exit;
  if FTarget <> nil then FTarget.RemoveFreeNotification(Self);
  FTarget := Value;
  if FTarget <> nil then FTarget.FreeNotification(Self);
  if FReady and not (csLoading in ComponentState) then
    if csDesigning in ComponentState then Apply
    else if ResolveTarget <> nil then ThemeManager.ApplyCurrent(ResolveTarget);
end;

procedure TThemedThemeManager.SetDesignPreview(Value: Boolean);
begin
  if FDesignPreview = Value then Exit;
  FDesignPreview := Value;
  if not Value then begin FPreviewPending := False; FreeAndNil(FPreviewEvents); end;
  if Value and (csDesigning in ComponentState) and not (csLoading in ComponentState) then Apply;
end;

procedure TThemedThemeManager.SetFileName(const Value: string);
begin
  if FFileName = Value then Exit;
  if FSaveToFile and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    ClaimFile(ResolveFileName(Value));
  FFileName := Value;
end;

procedure TThemedThemeManager.SetSaveToFile(Value: Boolean);
begin
  if FSaveToFile = Value then Exit;
  if Value and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then ClaimFile(SettingsFileName);
  FSaveToFile := Value;
  if not Value then ReleaseFile
  else if FReady and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then LoadSettings;
end;

procedure TThemedThemeManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FTarget) then FTarget := nil;
  if (Operation = opInsert) and (AComponent is TControl) and (csDesigning in ComponentState) and
    FDesignPreview and not (csDestroying in ComponentState) then FPreviewPending := True;
end;

procedure TThemedThemeManager.ReportError(const Operation, MessageText: string);
begin
  FLastError := MessageText;
  if Assigned(FOnPersistenceError) and not FShuttingDown and not (csDestroying in ComponentState) and
    ((Owner = nil) or not (csDestroying in Owner.ComponentState)) then
    FOnPersistenceError(Self, Operation, SettingsFileName, MessageText)
  else OutputDebugString(PChar(Format(SPersistenceError, [Operation, FFileName, MessageText])));
end;

function TThemedThemeManager.GetCurrentThemeName: string;
var Palette, Candidate: TThemePalette; Entry: TThemePresetEntry; Fingerprint: string;
  function Matches(const Name: string): Boolean;
  begin
    Candidate := TThemePresets.GetByName(Name);
    try Result := (Candidate <> nil) and (TThemePaletteSerializer.ToJson('', Candidate) = Fingerprint);
    finally Candidate.Free; end;
  end;
begin
  if csDesigning in ComponentState then Exit(FAppliedName);
  Result := ''; Palette := ThemeManager.CurrentTheme;
  if Palette = nil then Exit;
  Fingerprint := TThemePaletteSerializer.ToJson('', Palette);
  if (FAppliedName <> '') and Matches(FAppliedName) then Exit(FAppliedName);
  if (FThemeName <> '') and Matches(FThemeName) then Exit(FThemeName);
  for Entry in TThemePresets.GetAll do
    if Matches(Entry.Name) then Exit(Entry.Name);
end;

function TThemedThemeManager.LoadSettings: Boolean;
var Value, Stored: TJSONValue; Name: string;
begin
  Result := False;
  if csDesigning in ComponentState then Exit;
  FLastError := '';
  if FSaveToFile then
  begin
    ClaimFile(SettingsFileName);
    try
      if TFile.Exists(SettingsFileName) then
      begin
        Value := TJSONObject.ParseJSONValue(TFile.ReadAllText(SettingsFileName, TEncoding.UTF8));
        try
          if not (Value is TJSONObject) then raise EConvertError.Create(SInvalidSettings);
          Stored := TJSONObject(Value).GetValue('theme');
          if not (Stored is TJSONString) or (Trim(Stored.Value) = '') then raise EConvertError.Create(SInvalidSettings);
          Name := Stored.Value;
        finally Value.Free; end;
      end
      else Name := '';
    except
      on E: Exception do begin ReportError('load', E.Message); Name := ''; end;
    end;
    if Name <> '' then Result := TryApplyName(Name);
  end;
  if not Result then Result := Apply;
end;

function TThemedThemeManager.SaveSettings: Boolean;
var Value: TJSONObject; Name, Path, Temporary, Directory: string; ID: TGUID;
begin
  Result := False;
  if not FSaveToFile or (csDesigning in ComponentState) then Exit;
  FLastError := ''; Temporary := '';
  ClaimFile(SettingsFileName);
  try
    try
      Name := CurrentThemeName;
      if Name = '' then raise EInvalidOperation.Create(SUnnamedTheme);
      Path := SettingsFileName; Directory := ExtractFilePath(Path);
      if (Directory <> '') and not DirectoryExists(Directory) then TDirectory.CreateDirectory(Directory);
      CreateGUID(ID); Temporary := Path + '.' + GUIDToString(ID) + '.tmp';
      Value := TJSONObject.Create;
      try
        Value.AddPair('theme', Name);
        TFile.WriteAllBytes(Temporary, TEncoding.UTF8.GetBytes(Value.ToJSON));
      finally Value.Free; end;
      if not MoveFileEx(PChar(Temporary), PChar(Path), MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
      Temporary := ''; Result := True;
    finally
      if (Temporary <> '') and TFile.Exists(Temporary) then TFile.Delete(Temporary);
    end;
  except on E: Exception do ReportError('save', E.Message); end;
end;

end.

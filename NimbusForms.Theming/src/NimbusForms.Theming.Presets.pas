{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Presets;

interface

uses
  System.Classes,
  System.Generics.Collections,
  NimbusForms.Theming.Palette;

type
  TThemePaletteFactory = function: TThemePalette;

  TThemePresetEntry = class
  private
    FName: string;
    FFactory: TThemePaletteFactory;
    FIsBuiltIn: Boolean;
    FOrder: Integer;
    FFilePath: string;
  public
    function Produce: TThemePalette;
    property Name: string read FName write FName;
    property Factory: TThemePaletteFactory read FFactory write FFactory;
    property IsBuiltIn: Boolean read FIsBuiltIn write FIsBuiltIn;
    property Order: Integer read FOrder write FOrder;
    property FilePath: string read FFilePath write FFilePath;
  end;

  TThemePresets = class
  strict private
    class var FItems: TObjectList<TThemePresetEntry>;
    class var FDefaultThemeName: string;
    class function Find(const AName: string): TThemePresetEntry; static;
    class procedure RegisterBuiltIn(const AName: string; const AOrder: Integer;
      const AFactory: TThemePaletteFactory); static;
    class procedure RegisterFile(const AName, AFilePath: string;
      const AOrder: Integer); static;
    class procedure RegisterBuiltInThemes; static;
  public
    class constructor Create;
    class destructor Destroy;
    class function GetAll: TArray<TThemePresetEntry>; static;
    class function GetBuiltIn: TArray<TThemePresetEntry>; static;
    class function GetCustom: TArray<TThemePresetEntry>; static;
    class function GetNames: TArray<string>; static;
    class function Contains(const AName: string): Boolean; static;
    class function GetByName(const AName: string): TThemePalette; static;
    class procedure Register(const AName: string; const AOrder: Integer;
      const AIsBuiltIn: Boolean; const AFactory: TThemePaletteFactory); overload; static;
    class procedure Register(const AName: string;
      const AFactory: TThemePaletteFactory); overload; static;
    class function Remove(const AName: string): Boolean; static;
    class function GetNextName(const ACurrentName: string): string; static;
    class function GetPreviousName(const ACurrentName: string): string; static;
    class procedure LoadFromDirectory(const ADirectoryPath: string); static;
    class function SaveCustomTheme(const ADirectoryPath, AName: string;
      const APalette: TThemePalette): Boolean; static;
    class function ExportTheme(const AFilePath, AName: string;
      const APalette: TThemePalette): Boolean; static;
    class function ImportTheme(const AFilePath: string;
      const ARegisterTheme: Boolean): TThemePalette; static;
    class property DefaultThemeName: string read FDefaultThemeName write FDefaultThemeName;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.Generics.Defaults,
  NimbusForms.Theming.Strings,
  NimbusForms.Theming.Serializer,
  NimbusForms.Theming.PresetFactory;

function SameName(const A, B: string): Boolean;
begin
  Result := SameText(A, B);
end;

{ TThemePresetEntry }

function TThemePresetEntry.Produce: TThemePalette;
begin
  if Assigned(FFactory) then
    Result := FFactory()
  else if FFilePath <> '' then
    Result := TThemePaletteSerializer.LoadFromFile(FFilePath)
  else
    Result := nil;
end;

{ TThemePresets }

class constructor TThemePresets.Create;
begin
  FItems := TObjectList<TThemePresetEntry>.Create(True);
  FDefaultThemeName := ThemeStrings.DefaultThemeName;
  RegisterBuiltInThemes;
end;

class destructor TThemePresets.Destroy;
begin
  FItems.Free;
end;

class function TThemePresets.Find(const AName: string): TThemePresetEntry;
var
  LItem: TThemePresetEntry;
begin
  Result := nil;
  if Trim(AName) = '' then
    Exit;
  for LItem in FItems do
    if SameName(LItem.Name, AName) then
      Exit(LItem);
end;

class procedure TThemePresets.RegisterBuiltIn(const AName: string;
  const AOrder: Integer; const AFactory: TThemePaletteFactory);
begin
  Register(AName, AOrder, True, AFactory);
end;

class procedure TThemePresets.RegisterFile(const AName, AFilePath: string;
  const AOrder: Integer);
var
  LEntry: TThemePresetEntry;
begin
  if Trim(AName) = '' then
    raise EArgumentException.Create(ThemeStrings.ErrEmptyName);
  LEntry := Find(AName);
  if LEntry = nil then
  begin
    LEntry := TThemePresetEntry.Create;
    LEntry.Name := AName;
    FItems.Add(LEntry);
  end;
  LEntry.Factory := nil;
  LEntry.Order := AOrder;
  LEntry.IsBuiltIn := False;
  LEntry.FilePath := AFilePath;
end;

class procedure TThemePresets.RegisterBuiltInThemes;
begin
  RegisterBuiltIn('Light', 100, TThemePresetFactory.Light);
  RegisterBuiltIn('Dark', 200, TThemePresetFactory.Dark);
  RegisterBuiltIn('Nord', 300, TThemePresetFactory.Nord);
  RegisterBuiltIn('Office Blue', 400, TThemePresetFactory.OfficeBlue);
  RegisterBuiltIn('Dracula', 500, TThemePresetFactory.Dracula);
  RegisterBuiltIn('Dark Visual Studio', 600, TThemePresetFactory.DarkVisualStudio);
  RegisterBuiltIn('Midnight Blue', 700, TThemePresetFactory.MidnightBlue);
  RegisterBuiltIn('Hacker', 800, TThemePresetFactory.Hacker);
  RegisterBuiltIn('Solarized Dark', 900, TThemePresetFactory.SolarizedDark);
  RegisterBuiltIn('Light Visual Studio', 1000, TThemePresetFactory.LightVisualStudio);
  RegisterBuiltIn('Paper Light', 1010, TThemePresetFactory.PaperLight);
  RegisterBuiltIn('Nord Light', 1020, TThemePresetFactory.NordLight);
  RegisterBuiltIn('Forest Light', 1030, TThemePresetFactory.ForestLight);
  RegisterBuiltIn('Rose Blush', 1040, TThemePresetFactory.RoseBlush);
  RegisterBuiltIn('Lavender', 1050, TThemePresetFactory.Lavender);
  RegisterBuiltIn('High Contrast Light', 1060, TThemePresetFactory.HighContrastLight);
  RegisterBuiltIn('Catppuccin Mocha', 1070, TThemePresetFactory.CatppuccinMocha);
  RegisterBuiltIn('One Dark', 1080, TThemePresetFactory.OneDark);
  RegisterBuiltIn('Monokai', 1090, TThemePresetFactory.Monokai);
  RegisterBuiltIn('Gruvbox Dark', 1100, TThemePresetFactory.GruvboxDark);
  RegisterBuiltIn('GitHub Dark', 1110, TThemePresetFactory.GitHubDark);
  RegisterBuiltIn('GitHub Light', 1120, TThemePresetFactory.GitHubLight);
  RegisterBuiltIn('Tokyo Night', 1130, TThemePresetFactory.TokyoNight);
  RegisterBuiltIn('Catppuccin Latte', 1140, TThemePresetFactory.CatppuccinLatte);
  RegisterBuiltIn('Everforest Dark', 1150, TThemePresetFactory.EverforestDark);
  RegisterBuiltIn('Ayu Dark', 1160, TThemePresetFactory.AyuDark);
  RegisterBuiltIn('Rose Pine', 1170, TThemePresetFactory.RosePine);
  RegisterBuiltIn('Ayu Light', 1180, TThemePresetFactory.AyuLight);
  RegisterBuiltIn('Windows 95', 1190, TThemePresetFactory.Windows95);
  RegisterBuiltIn('Windows 2000', 1200, TThemePresetFactory.Windows2000);
  RegisterBuiltIn('Windows XP Luna Blue', 1210, TThemePresetFactory.WindowsXpLunaBlue);
  RegisterBuiltIn('CRT Green', 1220, TThemePresetFactory.CrtGreen);
  RegisterBuiltIn('Amber Terminal', 1230, TThemePresetFactory.AmberTerminal);
  RegisterBuiltIn('Classic Slate', 1240, TThemePresetFactory.ClassicSlate);
  RegisterBuiltIn('DOS Navy', 1250, TThemePresetFactory.DosNavy);
end;

class procedure TThemePresets.Register(const AName: string; const AOrder: Integer;
  const AIsBuiltIn: Boolean; const AFactory: TThemePaletteFactory);
var
  LEntry: TThemePresetEntry;
begin
  if Trim(AName) = '' then
    raise EArgumentException.Create(ThemeStrings.ErrEmptyName);
  if not Assigned(AFactory) then
    raise EArgumentNilException.Create(ThemeStrings.ErrNilFactory);
  LEntry := Find(AName);
  if LEntry <> nil then
  begin
    LEntry.Factory := AFactory;
    LEntry.Order := AOrder;
    LEntry.IsBuiltIn := AIsBuiltIn;
    Exit;
  end;
  LEntry := TThemePresetEntry.Create;
  LEntry.Name := AName;
  LEntry.Factory := AFactory;
  LEntry.Order := AOrder;
  LEntry.IsBuiltIn := AIsBuiltIn;
  FItems.Add(LEntry);
end;

class procedure TThemePresets.Register(const AName: string;
  const AFactory: TThemePaletteFactory);
begin
  Register(AName, 10000, False, AFactory);
end;

class function TThemePresets.GetAll: TArray<TThemePresetEntry>;
begin
  Result := FItems.ToArray;
  TArray.Sort<TThemePresetEntry>(Result, TComparer<TThemePresetEntry>.Construct(
    function(const L, R: TThemePresetEntry): Integer
    begin
      Result := L.Order - R.Order;
      if Result = 0 then
        Result := CompareText(L.Name, R.Name);
    end));
end;

class function TThemePresets.GetBuiltIn: TArray<TThemePresetEntry>;
var
  LAll: TArray<TThemePresetEntry>;
  LItem: TThemePresetEntry;
  LList: TList<TThemePresetEntry>;
begin
  LAll := GetAll;
  LList := TList<TThemePresetEntry>.Create;
  try
    for LItem in LAll do
      if LItem.IsBuiltIn then
        LList.Add(LItem);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

class function TThemePresets.GetCustom: TArray<TThemePresetEntry>;
var
  LAll: TArray<TThemePresetEntry>;
  LItem: TThemePresetEntry;
  LList: TList<TThemePresetEntry>;
begin
  LAll := GetAll;
  LList := TList<TThemePresetEntry>.Create;
  try
    for LItem in LAll do
      if not LItem.IsBuiltIn then
        LList.Add(LItem);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

class function TThemePresets.GetNames: TArray<string>;
var
  LAll: TArray<TThemePresetEntry>;
  I: Integer;
begin
  LAll := GetAll;
  SetLength(Result, Length(LAll));
  for I := 0 to High(LAll) do
    Result[I] := LAll[I].Name;
end;

class function TThemePresets.Contains(const AName: string): Boolean;
begin
  Result := Find(AName) <> nil;
end;

class function TThemePresets.GetByName(const AName: string): TThemePalette;
var
  LEntry: TThemePresetEntry;
begin
  LEntry := Find(AName);
  if LEntry <> nil then
    Result := LEntry.Produce
  else
    Result := nil;
end;

class function TThemePresets.Remove(const AName: string): Boolean;
var
  LEntry: TThemePresetEntry;
  LAll: TArray<TThemePresetEntry>;
begin
  LEntry := Find(AName);
  if LEntry = nil then
    Exit(False);
  if LEntry.IsBuiltIn then
    Exit(False);
  if SameName(FDefaultThemeName, LEntry.Name) then
  begin
    FItems.Remove(LEntry);
    LAll := GetAll;
    if Length(LAll) > 0 then
      FDefaultThemeName := LAll[0].Name
    else
      FDefaultThemeName := '';
  end
  else
    FItems.Remove(LEntry);
  Result := True;
end;

class function TThemePresets.GetNextName(const ACurrentName: string): string;
var
  LAll: TArray<TThemePresetEntry>;
  I, LIndex: Integer;
begin
  LAll := GetAll;
  if Length(LAll) = 0 then
    Exit('');
  if Trim(ACurrentName) = '' then
    Exit(LAll[0].Name);
  LIndex := -1;
  for I := 0 to High(LAll) do
    if SameName(LAll[I].Name, ACurrentName) then
    begin
      LIndex := I;
      Break;
    end;
  if LIndex < 0 then
    Exit(LAll[0].Name);
  Inc(LIndex);
  if LIndex >= Length(LAll) then
    LIndex := 0;
  Result := LAll[LIndex].Name;
end;

class function TThemePresets.GetPreviousName(const ACurrentName: string): string;
var
  LAll: TArray<TThemePresetEntry>;
  I, LIndex: Integer;
begin
  LAll := GetAll;
  if Length(LAll) = 0 then
    Exit('');
  if Trim(ACurrentName) = '' then
    Exit(LAll[0].Name);
  LIndex := -1;
  for I := 0 to High(LAll) do
    if SameName(LAll[I].Name, ACurrentName) then
    begin
      LIndex := I;
      Break;
    end;
  if LIndex < 0 then
    Exit(LAll[0].Name);
  Dec(LIndex);
  if LIndex < 0 then
    LIndex := High(LAll);
  Result := LAll[LIndex].Name;
end;

class procedure TThemePresets.LoadFromDirectory(const ADirectoryPath: string);
var
  LFiles: TArray<string>;
  LFilePath, LName: string;
begin
  if Trim(ADirectoryPath) = '' then
    Exit;
  if not TDirectory.Exists(ADirectoryPath) then
    Exit;
  LFiles := TDirectory.GetFiles(ADirectoryPath, ThemeStrings.ThemeFilePattern);
  for LFilePath in LFiles do
  begin
    if not TThemePaletteSerializer.LoadName(LFilePath, LName) then
      Continue;
    if Trim(LName) = '' then
      Continue;
    LName := Trim(LName);
    RegisterFile(LName, LFilePath, 10000);
  end;
end;

class function TThemePresets.SaveCustomTheme(const ADirectoryPath, AName: string;
  const APalette: TThemePalette): Boolean;
var
  LSafeName, LFilePath: string;
  LChar: Char;
  LInvalid: TArray<Char>;
  LBuilder: TStringBuilder;
  LFound: Boolean;
  LInvChar: Char;
begin
  if Trim(ADirectoryPath) = '' then
    Exit(False);
  if Trim(AName) = '' then
    Exit(False);
  if APalette = nil then
    Exit(False);
  if not TDirectory.Exists(ADirectoryPath) then
    TDirectory.CreateDirectory(ADirectoryPath);
  LInvalid := TPath.GetInvalidFileNameChars;
  LBuilder := TStringBuilder.Create;
  try
    for LChar in Trim(AName) do
    begin
      LFound := False;
      for LInvChar in LInvalid do
        if LInvChar = LChar then
        begin
          LFound := True;
          Break;
        end;
      if LFound then
        LBuilder.Append('_')
      else
        LBuilder.Append(LChar);
    end;
    LSafeName := Trim(LBuilder.ToString);
  finally
    LBuilder.Free;
  end;
  if Trim(LSafeName) = '' then
    LSafeName := ThemeStrings.FallbackThemeFileName;
  LFilePath := TPath.Combine(ADirectoryPath, LSafeName + '.json');
  TThemePaletteSerializer.SaveToFile(LFilePath, AName, APalette);
  RegisterFile(AName, LFilePath, 10000);
  Result := True;
end;

class function TThemePresets.ExportTheme(const AFilePath, AName: string;
  const APalette: TThemePalette): Boolean;
var
  LDirectory: string;
begin
  if Trim(AFilePath) = '' then
    Exit(False);
  if Trim(AName) = '' then
    Exit(False);
  if APalette = nil then
    Exit(False);
  LDirectory := TPath.GetDirectoryName(AFilePath);
  if (Trim(LDirectory) <> '') and (not TDirectory.Exists(LDirectory)) then
    TDirectory.CreateDirectory(LDirectory);
  TThemePaletteSerializer.SaveToFile(AFilePath, AName, APalette);
  Result := True;
end;

class function TThemePresets.ImportTheme(const AFilePath: string;
  const ARegisterTheme: Boolean): TThemePalette;
var
  LName: string;
begin
  Result := nil;
  if Trim(AFilePath) = '' then
    Exit;
  if not TFile.Exists(AFilePath) then
    Exit;
  Result := TThemePaletteSerializer.LoadFromFile(AFilePath);
  if Result = nil then
    Exit;
  if ARegisterTheme and TThemePaletteSerializer.LoadName(AFilePath, LName)
    and (Trim(LName) <> '') then
  begin
    LName := Trim(LName);
    RegisterFile(LName, AFilePath, 10000);
  end;
end;

end.

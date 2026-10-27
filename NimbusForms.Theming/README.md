# NimbusForms.Theming (Delphi/VCL)

Theme palettes, JSON persistence, and custom window chrome for Delphi 12 / VCL / Win64.

## Setup and usage

Add `src/` to the Delphi IDE search path and include the required units in the application or package. No dedicated `.dpk` or `.dproj` is described for this component set.

```pascal
uses
  NimbusForms.Theming.Manager, NimbusForms.Theming.Presets;

ThemeManager.SetThemeByName('Dark');
ThemeManager.Apply(Self, ThemeManager.CurrentTheme);
```

Theme-aware controls register with `ThemeManager.RegisterAware(Self)` during construction and unregister with `ThemeManager.UnregisterAware(Self)` during destruction. Stock VCL controls receive a recursive fallback theme application.

## Theming units (`src/`)

| Unit | Purpose |
| --- | --- |
| `NimbusForms.Theming.Types.pas` | `TThemeColor` (`Cardinal`, `$AARRGGBB`), `TThemeScope`, ARGB / `TColor` / COLORREF conversion |
| `NimbusForms.Theming.Palette.pas` | `TThemePalette` (`TPersistent`, 54 colors, `IsDark`, `Assign`, `Clone`) and `IThemeAware` |
| `NimbusForms.Theming.PresetFactory.pas` | 35 built-in theme palettes |
| `NimbusForms.Theming.Presets.pas` | `TThemePresets`: lookup, registration, navigation, directory loading, import/export |
| `NimbusForms.Theming.Serializer.pas` | JSON serialization via `System.JSON`, `#AARRGGBB` color strings, no BOM |
| `NimbusForms.Theming.Manager.pas` | `ThemeManager` singleton, theme-aware registry, recursive application, dark window mode |
| `NimbusForms.Theming.Win32.pas` | DWM immersive dark mode (Windows 10 version 1809+) |
| `NimbusForms.Theming.WinVersion.pas` | Windows build detection using `RtlGetVersion` |
| `NimbusForms.Theming.Strings.pas` | Shared string and JSON key constants |

## Modern form (`TThemedModernForm`)

`TThemedModernForm` is a custom-drawn `TForm` implementing `IThemeAware`.

| Unit in `src/` | Purpose |
| --- | --- |
| `Form.Strings` | Shared strings |
| `Form.Types` | Enums, metrics, palettes, hit-test interfaces |
| `Form.Native` | DWM and DPI integration with delayed imports |
| `Form.Accessibility` | MSAA `IAccessible` implementation |
| `Form` | `TThemedModernForm` |

| Feature | Behavior |
| --- | --- |
| Window frame | `BorderStyle = bsNone`; `WS_THICKFRAME` and `WS_SYSMENU` supplied by `CreateParams` |
| `ChromeState` | Normal, Success, Warning, Error, Debug, Custom; custom color via `CustomChromeStatusColor`, inactive border via `BorderInactiveColor` |
| Caption buttons | Custom GDI+ minimize, maximize, and close glyphs |
| Snap layout | Native `HTMAXBUTTON` support via `UseNativeSnapLayout` |
| Layout | `TitleBarMode` (Normal, Compact, Spacious), `CornerMode`, optional `ClipWindowToChromeCorners` |
| DWM | Windows 11 border, caption, and text colors |
| Title bar content | `TitleBarLeftHost`, `TitleBarCenterHost`, `TitleBarRightHost`; set a child control's `Parent` to the target host |
| Hit testing | `SetTitleBarHitTestMode`, `IThemedModernFormTitleBarHitTest`, and auto-provider interface; labels default to caption, other controls to client area |
| Theming | `ApplyTheme` respects `AutoApplyCurrentTheme`; `ApplyThemePalette` always applies the supplied palette |
| DPI | `OnChromeDpiChanged` and metric updates on `WM_DPICHANGED` |

### Behavior and constraints

| Area | Difference or constraint |
| --- | --- |
| Theme tracking | Theme-aware controls register and unregister with `ThemeManager`; no idle polling |
| Alpha | `TThemeColor` retains ARGB alpha; `ThemeColorToColor` produces opaque GDI `TColor` |
| Child layout | Child state and mouse changes use `WindowProc` hooks; `Margin` changes do not trigger layout |
| Accessibility | Only windowed `TWinControl` children appear in the accessibility tree |
| Stock controls | `TButton` supports color and font color only; `TToolBar` item colors are not customized |
| Minimum size | Form minimum size is managed using VCL `Constraints` |

## Tests

| Test project | Coverage |
| --- | --- |
| `test/ThemingTest.dpr` | Preset selection/navigation; recursive apply to Panel, Label, Edit, Memo and ListBox; immersive dark mode; JSON roundtrip of built-in presets; save/load and custom palette registration |
| `test/ModernFormTest.dpr` | Chrome states, title bar modes, corners, clipping, snap behavior, icon, theme switching, and left/center/right title bar hosts |

The theming test creates its GUI programmatically using `CreateNew` (no DFM). Its file persistence test writes to `%TEMP%\NimbusThemeTest`.

Open a test `.dpr` in the IDE or compile from `test/` with the Delphi Win64 compiler:

```text
dcc64 -B ThemingTest.dpr
```

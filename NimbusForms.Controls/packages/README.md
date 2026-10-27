# NimbusForms Packages

Delphi 12 VCL component packages.

| File | Purpose |
| --- | --- |
| `NimbusFormsRuntime.dpk` | Runtime library |
| `NimbusFormsDesign.dpk` | IDE registration for 68 components |
| `registered-components.json` | Component list |
| `NimbusForms.Design.Register.pas` | Component registration |

## Build and Install

1. Build `NimbusFormsRuntime.dpk` for Win32, then `NimbusFormsDesign.dpk` for Win32.
2. In Delphi 12, open **Component > Install Packages > Add** and select `NimbusFormsDesign.bpl`.
3. Ensure the runtime BPL is on `PATH` and the required DCU/DCP or source paths are configured.

Optional build script:

```powershell
.\NimbusForms.Demo\Projects\build.ps1 -Packages -Project NimbusStandardControls -Platform Win32
```

| Detail | Location or note |
| --- | --- |
| Package output | `bin\packages\Win32` |
| DCU output | `bin\obj\Win32` |
| Win64 | Runtime package only |
| Theme manager | `TThemedThemeManager`; see the [theming guide](../../NimbusForms.Theming/README.md) |
| Financial business chart | `TThemedFinancialBusinessChart` on NimbusForms Charts; see [FINANCIAL.md](../FINANCIAL.md) |

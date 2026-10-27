# NimbusForms demos

Open `NimbusFormsDemos.groupproj` in RAD Studio / Delphi 12. Each demo has its own project and shares code from `Shared`.

| Project | Contents |
| --- | --- |
| NimbusStandardControls | Controls, inputs, lists, menus and interactive examples |
| NimbusCodeEditorBasic | Editing, search, diagnostics and renderer selection |
| NimbusCodeEditorStudio | Multiple documents, navigation, search and resizable panels |
| NimbusHexEditorWorkspace | Hex editor workspace |
| NimbusGridStudio | Editing, validation, grouping, filtering and export |
| NimbusLogViewer | Interactive log viewer |
| NimbusNotifications | Notification examples |
| NimbusPropertyGrid | Editable object properties |
| NimbusCharts | Charts, financial workspace, mini charts and dashboards |

From the repository root, with a Delphi license that supports command-line compilation:

```powershell
.\NimbusForms.Demo\Projects\build.ps1 -List
.\NimbusForms.Demo\Projects\build.ps1 -Project NimbusCharts -Platform Win32
.\NimbusForms.Demo\Projects\build.ps1 -Project All -Configuration Release
```

The script locates the checkout relative to itself and expects RAD Studio 23.0 at its standard installation path. Executables go to `bin`, compiler output to `bin/obj/<platform>/<project>` and logs to `bin/build-logs`. Building another platform replaces executables with the same names. Demo assets and locally supplied Skia DLLs of the matching architecture are copied beside the executables.

Component installation is optional for the demos; see the [package guide](../../NimbusForms.Controls/packages/README.md).

# NimbusForms - Pre-Alpha

**Pre-Alpha software.** Intended for development, testing and evaluation.
APIs and behavior may change, features may be incomplete, and bugs are expected.
Not intended for production use.

NimbusForms is a Windows component library for Delphi 12 / VCL, developed from
the NimbusForms C# reference. It includes themed controls, editors, charts,
renderers and programmatic demos. Implementation and validation status varies
by component.

## Repository layout

| Directory | Purpose |
| --- | --- |
| `NimbusForms.Controls/src` | VCL controls, chart models and renderers |
| `NimbusForms.Controls/packages` | Runtime and design-time packages |
| `NimbusForms.Controls/tests` | Regression sources and source checks |
| `NimbusForms.Controls/renderers/skia` | Optional Skia CodeEditor renderer library |
| `NimbusForms.Theming` | Shared theme, palette and form support |
| `NimbusForms.Grid` | Grid subsystem |
| `NimbusForms.HexEditor` | Hex editor subsystem |
| `NativePattern/src` | NativePattern search library |
| `NimbusForms.Demo/Projects` | Separate demo projects and shared demo units |
| `NimbusForms.Demo/NimbusFormsDemo.dpr` | Combined demo |
| `NimbusFormsC#` | Local C# functional reference (excluded from Git) |
| `LICENSES` | Third-party license texts |

## Getting started

Use RAD Studio / Delphi 12 on Windows. Open
[`NimbusForms.groupproj`](NimbusForms.groupproj) in the repository root and use
**Build All** with the Win32 target to compile packages, demos and the existing
Grid/theming test applications. The optional Skia renderer requires `System.Skia`
in your Delphi installation; its runtime DLL must be supplied separately.

For demos only, open `NimbusForms.Demo/Projects/NimbusFormsDemos.groupproj`.
See the [demo guide](NimbusForms.Demo/Projects/README.md) for
project descriptions, search paths and output locations.

For component palette installation, follow the
[package guide](NimbusForms.Controls/packages/README.md).
The demos can also compile the library sources directly.

For split-container child controls and DFM compatibility, see the
[split-container guide](NimbusForms.Controls/SPLIT-CONTAINER.md).

Build and source-check scripts locate the checkout relative to themselves; no
fixed drive or checkout folder is required. CodeEditor and LogViewer regression
executables locate fixtures relative to the checkout and must run inside it.

In the CodeEditor, double-click a word to select it. Double-click inside an
existing selection to expand it to the nearest enclosing code structure;
repeat to select its parent. Delphi and C# selection includes loop headers,
method signatures, class declarations and array initializers. Shift+double-click
selects only the clicked logical line. Strings and comments do not define code
boundaries. See the [selection guide](NimbusForms.Controls/tests/CODE_STRUCTURE.md)
for supported syntax and regression commands, and the
[piece table stress tests](NimbusForms.Controls/tests/PIECE_TABLE_STRESS.md)
for the separate document-storage regression runner.

For chart appearance presets, independent custom palettes, mathematical
functions and their demos, see the [chart guide](NimbusForms.Controls/CHARTS.md).
It also covers independent country/state colors and GitHub, red and thermal heatmap palettes.
The dedicated [financial business chart](NimbusForms.Controls/FINANCIAL.md) adds
the C# financial palettes, technical indicator workspace, per-panel/global row events and interactive panel demo.

NimbusForms does not distribute Skia binaries. To use the optional CodeEditor
Skia backend, build `NimbusCodeEditorSkia.dll` yourself and obtain a matching
`sk4d.dll` separately. Both must have the same target architecture. See the
[renderer guide](NimbusForms.Controls/renderers/skia/README.md) and
[third-party notices](THIRD-PARTY-NOTICES.md). Other consumers do not need to
link `System.Skia` merely to use the renderer DLL interface.

Official `sk4d.dll` runtime directories:

- [Win32 (32-bit)](https://github.com/skia4delphi/skia4delphi/tree/main/Binary/Shared/Win32)
- [Win64 (64-bit)](https://github.com/skia4delphi/skia4delphi/tree/main/Binary/Shared/Win64)

Choose the architecture of your application and select the Skia4Delphi release
matching your `System.Skia`; the `main` branch may change.

Generated binaries, compiler output, IDE caches and local settings are ignored.
A source checkout therefore requires building the selected demos/packages and
obtaining any optional runtime dependencies separately.
The local C# reference directory and root maintenance `tools` directory are also
excluded from Git; neither is required to open the existing Delphi projects.

## Verification

Source checks are documented beside the demos and tests. They do not replace
Delphi compilation or GUI tests. Use RAD Studio for build and runtime verification;
command-line builds require a Delphi edition and license that support them.

## License

Copyright (c) 2026 Selahattin Erkoc. NimbusForms code is released under the
[MIT License](LICENSE). Third-party software and assets retain their own terms;
see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

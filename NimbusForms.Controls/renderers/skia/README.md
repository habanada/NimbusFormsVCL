# Nimbus CodeEditor Skia renderer DLL

NimbusForms renderer code is MIT licensed, copyright 2026 Selahattin Erkoc.
Skia4Delphi is MIT licensed; Skia is BSD-3-Clause licensed and has additional
third-party dependencies. See the repository-root [LICENSE](../../../LICENSE),
[THIRD-PARTY-NOTICES.md](../../../THIRD-PARTY-NOTICES.md) and
[LICENSES](../../../LICENSES). NimbusForms does not distribute Skia binaries.
Build this optional renderer yourself and obtain a matching `sk4d.dll` separately
from Skia4Delphi or your corresponding RAD Studio installation. If you distribute
your own application with Skia, include the applicable license/notice bundle
supplied with your selected runtime.

Obtain `sk4d.dll` for your application's architecture from the official directories:

- [Win32 (32-bit)](https://github.com/skia4delphi/skia4delphi/tree/main/Binary/Shared/Win32)
- [Win64 (64-bit)](https://github.com/skia4delphi/skia4delphi/tree/main/Binary/Shared/Win64)

Select the release matching your `System.Skia`; `main` is a moving branch.
Place the runtime beside your built `NimbusCodeEditorSkia.dll`.

`NimbusCodeEditorSkia.dpr` builds the existing version 1 `NimbusCodeRendererGetAPI` contract. Only this DLL links `System.Skia`; NimbusForms and its consumer projects retain their existing DLL backend and do not require Skia4Delphi units or runtime packages.

The renderer uses Delphi 12 `System.Skia` interfaces. Skia paragraph shaping, system font fallback and `Segoe UI Emoji` support colored emoji glyphs. Actual color appearance depends on the installed font and matching Skia runtime. The frame is rendered into a reusable top-down BGRA DIB and copied to the host HDC. Paint operations use antialiasing, nested clip state is isolated per frame, and text paragraphs use a bounded cache. Drawing uses pixel coordinates supplied by the NimbusForms renderer; the host already handles DPI scaling. The bridge preloads `sk4d.dll` by its absolute path beside the renderer, without changing global DLL search paths. A conflicting already loaded Skia runtime is rejected.

Build from this directory with `./build.ps1 -Platform Win32` or `./build.ps1 -Platform Win64`. All compiler outputs and temporary files go to `NimbusForms.Controls/build/skia-renderer/<platform>`. Add `-SkiaRuntimePath <path-to-sk4d.dll>` to deploy an explicitly selected matching runtime beside the bridge. Both DLLs must match the application's architecture and the Skia version used to compile the bridge.

For an IDE build, open the library DPR, add `NimbusForms.Controls/src` to the unit search path and set both the executable output directory and unit output directory to `NimbusForms.Controls/build/skia-renderer/Win32` or `Win64` before compiling. Place the matching `sk4d.dll` beside the bridge. In the CodeEditor demo choose **Renderer > Load renderer DLL (Skia / custom)** and select `NimbusCodeEditorSkia.dll`, then choose **Unicode / color emoji sample**. The existing **Nimbus GDI+** action switches back.

The ABI is declared in `NimbusForms.Rendering.CodeEditor.DLL.Types.pas`; the host unit exposes aliases for its public type names. Exceptions inside drawing callbacks become nonzero status codes rather than crossing the DLL boundary. Instances, Skia objects, strings and caches remain owned by the DLL. No Delphi string, object or interface crosses the ABI.

Reference: [official Skia4Delphi source](https://github.com/skia4delphi/skia4delphi/tree/main/Source), particularly `System.Skia` paragraph and raster-surface APIs.

`../../tests/NimbusSkiaBridgeTests.pas` checks version/size negotiation, raster presentation, text measurement, nested clip behavior and actual non-gray pixels from a rainbow emoji. The build script compiles and executes it when a matching `sk4d.dll` is deployed.

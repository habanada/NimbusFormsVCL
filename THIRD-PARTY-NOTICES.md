# Third-party notices

NimbusForms code by Selahattin Erkoc is licensed under the [MIT License](LICENSE).
Third-party software and assets retain their own copyrights and licenses.
Using a library does not make its authors copyright holders of every NimbusForms unit.

## Skia4Delphi

- Project: https://github.com/skia4delphi/skia4delphi
- License: MIT; [upstream license copy](LICENSES/Skia4Delphi-MIT.txt).
- Copyright (c) 2021-2026 Skia4Delphi.
- Used through Delphi's `System.Skia` by
  `NimbusForms.Controls/src/NimbusForms.Rendering.CodeEditor.SkiaBridge.pas`.
  The renderer library is `NimbusCodeEditorSkia.dll`; its runtime is `sk4d.dll`.

## Skia

- Project: https://github.com/google/skia
- License: BSD-3-Clause; [upstream license copy](LICENSES/Skia-BSD-3-Clause.txt).
- Upstream notice: Copyright (c) 2011 Google Inc. All rights reserved.
- Graphics engine used by Skia4Delphi and its native runtime.
- Skia includes third-party dependencies with additional license requirements.
  The two license copies above are not a complete notice bundle for a particular
  `sk4d.dll` build.

## User-supplied optional Skia dependencies

NimbusForms does not distribute Skia binaries, including `sk4d.dll`. The optional
NimbusForms Skia renderer is provided as source; users build the renderer and
provide the matching runtime themselves. Obtain the runtime from the official
Skia4Delphi distribution or the corresponding RAD Studio installation. Match its
architecture and version to the `System.Skia` used to build the renderer.

Official runtime sources:

- [Win32 `sk4d.dll` (32-bit)](https://github.com/skia4delphi/skia4delphi/tree/main/Binary/Shared/Win32)
- [Win64 `sk4d.dll` (64-bit)](https://github.com/skia4delphi/skia4delphi/tree/main/Binary/Shared/Win64)

Choose the architecture matching your application and the release matching your
bindings rather than assuming the current `main` binary matches every Delphi version.

The license copies in this repository document the optional dependency; they
are not a complete notice bundle for every possible user-supplied runtime build.
Users who redistribute their own application with Skia must use the applicable
licenses and third-party notices supplied with their selected runtime.

DLL files are ignored by `.gitignore`. Locally present runtime files are development
dependencies and are excluded from NimbusForms source archives and release assets.

## Delphi, Windows and fonts

Delphi RTL/VCL, `System.Skia` as shipped with RAD Studio, Windows APIs and installed
system fonts remain subject to their suppliers' terms. They are dependencies,
not covered by NimbusForms' MIT license. NimbusForms does not grant permission
to redistribute proprietary SDKs or fonts such as Segoe UI Emoji.

## Demo avatars and icons

The demo avatars and icons are original assets by Selahattin Erkoc,
copyright (c) 2026, released under the [MIT License](LICENSE).
See the [avatar license notice](NimbusForms.Demo/avatars/README.md) and
[icon license notice](NimbusForms.Demo/ico/README.md).

## Geographic data

The embedded data in `NimbusForms.Controls/src/NimbusForms.Charts.Maps.Data.pas`
is derived from [Natural Earth](https://www.naturalearthdata.com/), ported through
the C# reference. The snapshot uses simplified and rounded geometry and a subset
of the populated places.

| Data | Natural Earth layer |
| --- | --- |
| World countries | 1:110m Admin 0 - Countries |
| Country subdivisions | 1:10m Admin 1 - States, Provinces |
| Cities and populations | 1:10m Populated Places |

Natural Earth data is in the public domain under its
[terms of use](https://www.naturalearthdata.com/about/terms-of-use/), including
commercial use and redistribution. It is separate from the MIT-licensed
NimbusForms code. Made with Natural Earth; contributors include Tom Patterson,
Nathaniel Vaughn Kelso and the Natural Earth community. The original upstream
revision of this embedded snapshot is not recorded.

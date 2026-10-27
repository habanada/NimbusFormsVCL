{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.

  Optional graphics dependencies (licensed separately):
  Skia4Delphi: Copyright (c) 2021-2026 Skia4Delphi.
  License: MIT. See LICENSES/Skia4Delphi-MIT.txt.
  https://github.com/skia4delphi/skia4delphi
  Skia: Copyright (c) 2011 Google Inc. All rights reserved.
  License: BSD-3-Clause. See LICENSES/Skia-BSD-3-Clause.txt.
  https://github.com/google/skia
  NimbusForms does not distribute Skia binaries.
}

library NimbusCodeEditorSkia;

uses
  NimbusForms.Rendering.CodeEditor.SkiaBridge in '..\..\src\NimbusForms.Rendering.CodeEditor.SkiaBridge.pas',
  NimbusForms.Rendering.CodeEditor.DLL.Types in '..\..\src\NimbusForms.Rendering.CodeEditor.DLL.Types.pas';

exports
  NimbusCodeRendererGetAPI name 'NimbusCodeRendererGetAPI';

begin
end.

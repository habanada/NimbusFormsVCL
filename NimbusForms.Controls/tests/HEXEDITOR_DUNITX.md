# HexEditor: DUnitX Regression Tests

The suite tests the Delphi HexEditor directly. Test files are located under `NimbusForms.Controls/tests`; build products, reports and temporary files remain under `NimbusForms.Controls/build/hexeditor-dunitx`.

## Directly in RAD Studio / Community Edition

1. **File > Open Project**: Select `NimbusHexEditorDUnitXTests.dproj` in this directory. The actual program entry is `NimbusHexEditorDUnitXTests.dpr`.
2. Select **Debug / Win32** and start with **F9**. **Win64** and **Release** are also configured. Tests run within a console application; the console remains open until Enter is pressed.
3. View the NUnit report beside the test EXE. EXE and report are under `NimbusForms.Controls/build/hexeditor-dunitx/<platform>`; DCUs under `obj/<configuration>`.

A command-line compiler and PowerShell script are not required. The project file contains relative search paths for HexEditor, Controls, Theming and NativePattern plus all fixture/helper units in the project manager. Runtime packages are not required.

DUnitX must be installed or available as a source library. The project uses standard RAD Studio source paths plus `vendor/DUnitX/Source` within this test directory. If installed elsewhere, add the source directory under **Project > Options > Delphi Compiler > Search Path**. It must contain `DUnitX.TestFramework.pas`.

## Included Tests

**Piece Table / THexDocument**

- Initial state, empty documents, insert/delete at start, end and internal boundaries.
- Overwrite and replace across original and memory pieces, different replacement lengths, EOF and invalid ranges.
- Full reads, partial ranges, bounded target buffers and unchanged buffer residue.
- After each verified change: byte comparison with independent byte array, positive piece lengths, valid source ranges, length sum and additional reconstruction from exported pieces.
- Unchanged original source, dirty return after restoration of original bytes, independent full and partial snapshots, atomic rejection of invalid restore data.
- Synthetic source with more than 2 GB and changes above the 32-bit offset boundary, without allocating a corresponding file or large byte array.
- Four fixed random seeds with 4000 changes each; a failed byte comparison includes seed, step and operation.

**Files**

- Load, mixed changes, SaveAs and reopen: 0, 1, 256, 81919, 81920, 81921 and 262177 input bytes.
- Save over still-open original file, repeated backups, disabled backups, empty output files and rebasing after save.
- Failed SaveAs preserves original file, file path and edited document state.

**Editor / Undo / Redo**

- Real public methods `InsertBytes`, `OverwriteBytes`, `DeleteBytes`, `ReplaceSelection`, `Undo` and `Redo`.
- Mixed history completely undone and redone; new edit branch discards redo; empty and rejected changes create no history.
- ReadOnly, load with history reset and undo/redo across saved state.
- Session file with simultaneously filled undo and redo stacks, independent restoration, invalid session JSON and project file round-trip.
- Three fixed random seeds with 2000 edit/undo/redo steps each against independent byte array snapshots; then complete undo and redo of remaining history.

Editor tests use an invisible VCL host form. They do not test mouse interaction, rendering, DPI or clipboard. Synthetic large source tests 64-bit offsets; it does not replace real multi-gigabyte file testing.

## Optional: Automated CLI Run

Prerequisites: Delphi 12 with working command-line license and DUnitX for the same compiler. The script checks standard RAD Studio DUnitX source paths and optionally release DCUs. A framework source installation within the workspace can be explicitly specified:

```powershell
.\NimbusForms.Controls\tests\build_hexeditor_dunitx.ps1 -Platform Win32 -DUnitXPath 'E:\Projects\NimbusForms\NimbusForms.Controls\tests\vendor\DUnitX\Source'
```

The example assumes an existing DUnitX installation at this path; the suite does not automatically load or install dependencies. The source directory must contain `DUnitX.TestFramework.pas`. If DUnitX is in a supported RAD Studio standard path, `-DUnitXPath` can be omitted. For Win64 use `-Platform Win64`. `-BuildOnly` skips execution after a successful build.

The program entry is `NimbusHexEditorDUnitXTests.dpr`; the same-name `.pas` file remains for earlier CLI calls. The CLI script also uses the DPR and defines `CI` so automated runs do not wait for Enter.

Output per platform:

- `NimbusHexEditorDUnitXTests.exe`, `compile.log`, `tests.log`
- `NimbusHexEditorDUnitXTests.xml`: NUnit report with actual executed cases
- `obj/`: freshly compiled units; `temp/`: compiler TEMP/TMP

File tests each receive their own GUID directory under `fixtures/`. They remove only their own files; junctions and symlinks are rejected. The build uses range and overflow checks. Errors, a locked CLI license, stale EXEs, missing reports or zero executed test cases do not count as success.

Reproducible static verification also works without Delphi/DUnitX:

```powershell
node NimbusForms.Controls/tests/check_hexeditor_dunitx.js
```

It checks method bodies, fixture registration, test case count, local dependencies, IDE project entry, output target and CRLF. It does not execute Pascal code and does not confirm piece table correctness. The DUnitX run must complete successfully for that.

DUnitX API reference: [official runner template](https://github.com/VSoftTechnologies/DUnitX/blob/master/Expert/DUnitX.Expert.CodeGen.Templates.pas), [official fixture examples](https://github.com/VSoftTechnologies/DUnitX/blob/master/Tests/DUnitX.Tests.Example.pas).

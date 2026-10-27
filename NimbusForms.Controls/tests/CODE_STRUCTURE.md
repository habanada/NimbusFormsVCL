# CodeEditor structural selection

Double-click inside an existing selection to expand it to the smallest complete
containing structure. Repeat to select its parent. A plain double-click without
a selection selects a word; Shift+double-click selects the clicked logical line.

| Syntax | Selection includes |
| --- | --- |
| C# `for`, `foreach`, `while`, `do` | Header, body and trailing `while` condition where applicable |
| Delphi `for`, `while`, `repeat`, `with` | Header, body, closing `end` or `until` condition |
| Conditional and exception statements | `if`/`else`, `case`/`switch`, `try`/handler/finally structure |
| Methods and routines | Declaration/signature, local declarations and body |
| Classes and types | Type declaration and contiguous body |
| Arrays and initializers | Bracket literals, C# `new[] { ... }`, nested initializers and Delphi parenthesized typed constants |

Loops with a single statement are included even without braces or `begin/end`.
The same statement grammar handles selecting a loop keyword and selecting text
inside its body. Array initializers form a selection level inside their containing
declaration, method or loop. A Delphi class declaration does not include method
implementations located elsewhere in the file.

The shared `CodeEditor.Structure` unit uses current-source syntax highlighting to
retain tokens and offsets while ignoring comments and treating strings as opaque
tokens. Separate Pascal and brace statement grammars identify complete constructs;
the editor's mouse code contains no individual loop or array cases. This is a
bounded structural parser, not a complete compiler syntax tree. Delphi and C#
have explicit regression fixtures; other language-specific grammars are not
guaranteed. Preprocessor branches are not evaluated.

Scanning is disabled in large-file mode and stops after a 100 ms budget, checked
between lines and during tokenization/parsing, or after 256 nested parser calls.
Missing, incomplete or aborted results preserve the existing selection.

## Regression checks

`NimbusCodeStructureChecks.pas` covers nested loops, headers, single-statement
bodies, multiline headers, routines, classes, exception/conditional branches,
array initializers, strings/comments and malformed delimiters for Delphi and C#.
The same checks run in the full CodeEditor runner and a standalone console program.

```powershell
.\NimbusForms.Controls\tests\build_codeeditor.ps1 -Suite Structure -Platform Win32
.\NimbusForms.Controls\tests\build_codeeditor.ps1 -Suite Structure -Platform Win64
```

For RAD Studio builds, `NimbusCodeStructureTests.pas` is the standalone console
program source. Add `..\src` to the search path when saving the project in this
tests directory, and enable range and overflow checking. The full
`NimbusCodeEditorTests.pas` runner also exercises native mouse-message behavior,
first-click selection preservation, read-only selection and Shift line selection.

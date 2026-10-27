# Piece table stress tests

`NimbusPieceTableStress.pas` exercises the actual Delphi piece table and chunked
append buffer.
The oracle uses a flat UTF-16 string and scans line starts independently.

```powershell
.\NimbusForms.Controls\tests\build_piece_table_stress.ps1
.\NimbusForms.Controls\tests\build_piece_table_stress.ps1 -Platform Win32
```

The default requests 256,000 randomized steps: 128 deterministic seeds, 1,000
steps per seed, in both LF and CRLF modes. Each step checks text, tree invariants,
line metadata, slices, characters and position conversions. Up to four retained
snapshots are checked after every step. An assertion is not a separate scenario.
Additional exhaustive cases enumerate every string of zero to four code units
over `x`, CR, LF and NUL. Each normalized insertion position is tested with five
deletion counts and four insertion payloads, including out-of-range positions.
This adds 45,045 edit cases across both newline modes (19,962 LF and 25,083 CRLF).

| Coverage | Cases |
| --- | --- |
| Editing | Insert, prepend, append, delete, reset, empty operations, clamped offsets/counts including Integer extremes |
| Text | Mixed CR/LF/CRLF, NUL, tabs, combining marks, surrogate pairs, unpaired surrogates, Unicode separators |
| Tree | Red-black invariants and metadata after random edits; fragmented insertion/deletion; deep successor deletion |
| Boundaries | 8 KiB pieces, 64 KiB chunks, nearby sizes, 120 KiB original, 1 MiB original and append |
| Queries | Independent line scans; all lines after each step; exhaustive offsets periodically; canonical CRLF positions |
| Snapshots | Multiple generations, mutation rejection, source reset, source destruction, snapshot of snapshot |
| Buffer | Chunk sizes 1, 2, 3, 7 and 64; raw/normalized append, LF search, clear, retained snapshots, Integer-extreme ranges |

Buffer LF queries return zero matches (`CountLineFeeds`) or `-1`
(`FindLineFeed`) for nonpositive counts and ranges starting at or beyond the
buffer end. Negative offsets clip the requested range to the buffer start.

Outputs stay in `NimbusForms.Controls/build/piece-table-stress/<platform>`.
Each invocation writes a JSON status with source hashes, parameters and timestamps,
a build log, and stdout/stderr logs when execution starts. Build failure never
runs an older executable. Compilation enables range and overflow checks and
rebuilds dependencies. A configurable process timeout detects hangs.

Failures include mode, seed, step and the last 32 operations. Payloads are Base64
of raw UTF-16LE code units, preserving malformed surrogates. Replay the complete
seed; the recent-operation log is diagnostic context rather than a standalone replay.

```powershell
.\NimbusForms.Controls\tests\build_piece_table_stress.ps1 -FirstSeed 42 -Seeds 1 -Steps 1000
.\NimbusForms.Controls\tests\build_piece_table_stress.ps1 -Seeds 512 -Steps 2000 -TimeoutSeconds 3600
```

For an IDE-built executable, the same arguments are positional:
`NimbusPieceTableStress.exe 42 1 1000`. The test entry point is
`RunPieceTableStressChecks(FirstSeed, SeedCount, Steps)` in the checks unit.
The command line runner requires a Delphi installation licensed for command line
compilation. Runtime coverage does not include allocation failure injection,
concurrent access, Integer-capacity allocations or editor GUI behavior.

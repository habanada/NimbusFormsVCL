# NimbusForms.HexEditor - Renderer Layer (Delphi/VCL)

Renderer-first hex editor control built on NimbusForms.Theming.

## Architecture

Renderers paint exclusively through `IHexRenderSurface` - an abstract drawing surface. Currently GDI (`TGdiHexRenderSurface` on `TCanvas`). Brush/Pen management is an implementation detail of the surface; renderers only pass `TThemeColor`. `HexTheme` is derived from the active `TThemePalette` through `THexTheme.FromPalette` (blend formula identical to the C# original); `FromPalette(nil)` yields the original's light defaults. The control implements `IThemeAware` and registers with the `ThemeManager` so `ApplyTheme` re-derives `HexTheme` from the palette and redraws; it unregisters in its destructor.

## Units (src/)

- `NimbusForms.HexEditor.Types.pas` - Enums (THexOffsetFormat, THexHitArea, THexTextFlags), THexSelection, THexHitInfo.
- `NimbusForms.HexEditor.Strings.pas` - Text and special character constants.
- `NimbusForms.HexEditor.DataSource.pas` - `IHexDataSource` + `TBytesHexDataSource` (in-memory).
- `NimbusForms.HexEditor.FileDataSource.pas` - read-only file data source (`TFileHexDataSource`, TFileStream).
- `NimbusForms.HexEditor.Bookmarks.pas` - THexBookmark + THexBookmarkManager.
- `NimbusForms.HexEditor.Search.pas` - THexSearchMatch.
- `NimbusForms.HexEditor.Options.pas` - THexEditorOptions (all display options, defaults as in the original).
- `NimbusForms.HexEditor.Theme.pas` - `THexTheme.FromPalette`.
- `NimbusForms.HexEditor.RenderSurface.pas` - `IHexRenderSurface` + GDI implementation (clip stack via SaveDC/RestoreDC).
- `NimbusForms.HexEditor.RenderContext.pas` - THexRenderContext + THexRenderMetrics.
- `NimbusForms.HexEditor.Renderers.pas` - THexCaretRenderer, THexCellRenderer, THexGutterRenderer, THexHeaderRenderer and the orchestrating THexRenderer (Measure/Render/RenderRows/RenderRow, including color and line-break logic).
- `NimbusForms.HexEditor.Control.pas` - `TCustomThemedHexEditor` / `TThemedHexEditor` (TCustomControl).
- `NimbusForms.HexEditor.Undo.pas` - TUndoManager, TEditCommand (byte-level undo/redo).
- `NimbusForms.HexEditor.SearchService.pas` - hex, masked and text search via NativePattern.
- `NimbusForms.HexEditor.Pattern.pas` - pattern token/node model (`THexSearchPattern`) with recursive NFA matcher (backtracking over gaps and alternatives, Hamming distance for fuzzy matching).
- `NimbusForms.HexEditor.PatternParser.pas` - DSL parser (`THexPatternParser`).
- `NimbusForms.HexEditor.PatternSearch.pas` - buffered pattern scanner over a data source (`THexPatternSearch.SearchRich`), with overlap and anchor support.
- `NimbusForms.HexEditor.RuleEngine.pas` - multi-pattern AND/OR rule engine (`THexSearchRule`, `THexSearchRuleEngine`).
- `NimbusForms.HexEditor.Inspector.pas` - `THexDataInspector` (UI-free value interpretation).
- `NimbusForms.HexEditor.InspectorControl.pas` - `TThemedHexInspector` (themed inspector panel).
- `NimbusForms.HexEditor.Tooltip.pas` - `TThemedHexTooltip` (themed popup tooltip).
- `NimbusForms.HexEditor.BookmarkList.pas` - `TThemedHexBookmarkList` (themed bookmark list control).
- `NimbusForms.HexEditor.ScrollBar.pas` - `THexScrollBar` (themed vertical/horizontal scrollbar).
- `NimbusForms.HexEditor.Export.pas` - `THexExporter` (data export formats).
- `NimbusForms.HexEditor.Patch.pas` - `THexPatchFile`/`THexPatchOperation`/`THexPatchSerializer`.
- `NimbusForms.HexEditor.Pieces.pas` - `THexPieceInfo`, `THexEditOperation` (piece-table primitives).
- `NimbusForms.HexEditor.Document.pas` - `THexDocument` (piece-table `IHexDataSource` implementation for large files).
- `Session`, `SessionSerializer`, `ProjectSerializer` - session/project persistence.
- `FindReplaceTypes`, `FindReplaceDialog`, `FindReplaceAdapter` - find/replace dialog and host adapter.
- `NimbusForms.HexEditor.Reg.pas` - component registration.

## The Control (TThemedHexEditor)

`TCustomThemedHexEditor` / `TThemedHexEditor` render through the layer above (Paint builds a context and calls `THexRenderer.Render`).

- Vertical scrolling (mouse wheel, themed scrollbar), line-based.
- Mouse: click sets cursor/active area (Hex/ASCII), drag selects, hover highlight.
- Keyboard: arrows, PgUp/PgDn, Home/End (Ctrl = start/end of data), Tab switches Hex/ASCII.
- Loading: `LoadBytes(TBytes)`, `LoadFromDataSource(IHexDataSource)`, or `LoadDocument` for a `THexDocument`.

### Byte editing

- Hex nibble input (high/low) and ASCII input, depending on the active area; Tab switches between them.
- Overwrite (default) and Insert mode (Insert key); typing in Insert mode adds new bytes.
- Delete/Backspace delete the selection, or a single byte in Insert mode.
- Modified-byte tracking (highlighted, as in the original), shifted correctly on Insert/Delete.
- Undo/Redo (Ctrl+Z / Ctrl+Y) via a command stack.
- ReadOnly protection: editing is only possible when `DataSource.CanWrite` and not `Options.ReadOnly`; a file-backed source (`TFileHexDataSource`) always stays read-only.

### Clipboard and scrolling

- Clipboard (Vcl.Clipbrd): Ctrl+C copies the selection as a hex string (`48 8B 01`), Ctrl+X cuts, Ctrl+V pastes - a hex string is parsed, otherwise the text is pasted as ANSI bytes; respects Insert/Overwrite mode and ReadOnly.
- Horizontal scrolling: content width is computed via `MeasureContentWidth`; HitTest and Measure account for the current horizontal offset.
- Native Windows scrollbars are not used; vertical and horizontal scrollbars are drawn by the control itself via `THexScrollBar` and follow the active palette (flat design, rounded thumb, hover/drag state). `ContentRect` shrinks by the visible scrollbar strips; `UpdateScrollbars` resolves the mutual width/height dependency between the two bars in two passes.

### Data inspector

`THexDataInspector.Inspect(ds, offset, bigEndian)` interprets the bytes at a given offset as Int8/UInt8, Int16/UInt16, Int32/UInt32, Int64/UInt64, Float32/Float64, Char and Binary, in little- or big-endian order. Floats are formatted via `FloatToStrF` for clean display. The control fires `OnCursorChange` and exposes `CursorPosition` on navigation, click, drag and edits. `TThemedHexInspector` is the themed panel that renders this live (header with a clickable LE/BE toggle, row striping, hover highlight, name/value columns).

### Tooltips

Byte tooltips appear after a short hover delay and show offset, byte value (hex/decimal), character and bits. `TThemedHexTooltip` is a themed popup (no activation, drop shadow, monitor clamping) hooked in through the virtual methods `BuildTooltipText`, `DoShowTooltip`, `DoHideTooltip`; it is reusable standalone. `OnByteTooltip` lets a host change or suppress the tooltip text.

### Bookmarks

`THexBookmarkManager` tracks bookmarks; `TThemedHexBookmarkList` is the themed list control (color marker, offset, name, selection/hover, per-row remove button, keyboard navigation) and works with a bookmark manager independently of the editor control, binding to it only through events (`OnBookmarkActivated`, `OnBookmarkRemoveRequested`, `OnBookmarkSelected`). Control API: `ToggleBookmark`.

### Search

`NimbusForms.HexEditor.SearchService.pas` uses NativePattern for three search modes:

- Hex byte search (`48 8B 01` or `488B01`) via `TPatternSearch.FindAll`.
- Masked signatures (`48 8B ?? ?? 89`) via `TBytePattern.Parse`, auto-detected by the presence of `?`.
- Plain text search (ANSI).

Matches feed into the highlight pipeline as `THexSearchMatch` (`AdvancedSearchMatches`, with the active match highlighted separately). Control API: `Search(text, kind)`, `FindNext`, `FindPrevious`, `ClearSearch`, `SearchMatchCount`; the active match scrolls into view and is selected.

### Search DSL and rule engine

A small pattern DSL extends plain hex/masked search:

- `48` exact byte, `??`/`?` wildcard, `A?` high nibble, `?A` low nibble, `AB&CD` bitmask (value & mask).
- `[min-max]` / `[min..max]` / `[n]` gap (a variable-length byte gap).
- `(seq1 | seq2)` alternative.
- Example: `48 [0-4] (8B|8D) ?5` matches `48`, then 0 to 4 arbitrary bytes, then `8B` or `8D`, then a byte whose low nibble is `5`.

`THexPatternSearch.SearchRich` scans a parsed pattern over a data source with buffering and overlap. `THexSearchRuleEngine` combines several named patterns with AND/OR logic and optional negative patterns and relative offset constraints between them, then deduplicates and sorts the combined matches. The search service auto-detects DSL input by its metacharacters; the control exposes `SearchRule(rule)` to feed rule matches into the same highlight pipeline as plain search.

### Export

`THexExporter` converts the current data to a C# array, a C# read-only array, a classic hexdump text layout, an HTML table, a JSON array, Base64 (no line wrap), SQL `VARBINARY` literal syntax, plain hex or ASCII. These are pure, UI-free functions.

### Patch persistence

`THexPatchFile`/`THexPatchOperation` describe a set of edits; `THexPatchSerializer` (de)serializes them as JSON with Base64-encoded byte data. On the control, `CreatePatch` builds a patch file from the current undo stack, `SavePatch` writes it, and `ApplyPatch` replays its operations against the active data source.

### Session and project persistence

`SessionSerializer` (JSON) and `ProjectSerializer` (binary, magic `0x4E485850`) persist: original file path, piece list, add-buffer, cursor, selection and bookmarks. They do not persist undo/redo history (the control's undo is byte-based; sessions expect piece-level operations) or modified-byte highlighting. Session/project persistence requires an open `THexDocument` (a loaded file); it is not available when only an in-memory byte array is loaded. Control API: `SaveProjectToFile`/`LoadProjectFromFile`, `SaveSessionToFile`/`LoadSessionFromFile`.

### Find/Replace

`FindReplaceDialog` is a modeless dialog with separate find and replace modes; `FindReplaceAdapter` hosts it against the control. Keys: Ctrl+F (find), Ctrl+H (replace), F3 / Shift+F3 (next/previous match). Input accepts plain text (UTF-8) or hex (`hex:` prefix, `0x`, or space/comma/minus-separated bytes); whole-word and regular-expression matching are not supported. Replace is implemented as delete + insert (two undo steps); Replace All stops after 100000 matches; scope is document or current selection. Control API: `ShowFindDialog`, `ShowReplaceDialog`, `FindReplaceNext`, `FindReplacePrevious`, `FindReplace`, plus the supporting `DataLength`, `HasSelection`, `SelectionStart`, `SelectionLength`, `ReadBytes`, `InsertBytes`, `DeleteBytes`.

## Piece-table document model (THexDocument)

`THexDocument` (implementing `IHexDataSource`) is the storage model for large files: a read-only original file, a `MemoryStream` add-buffer, and a piece list. Edits change only the piece list - O(pieces), no file data is copied - so Insert/Delete/Overwrite on a 1 GB file costs the same as on a 1 KB file.

- **Read** walks the pieces, reading each one from the original file or the add-buffer.
- **ReplaceRange** is the core operation: splits at the start and end offsets, removes the pieces in between, inserts new ones, merges adjacent pieces of the same source, and updates the dirty state.
- **Dirty tracking**: `IsPristineState` detects an unmodified document; `IsOffsetModified` compares a given offset byte-for-byte against the original. Events: `OnLengthChanged`, `OnDirtyStateChanged`.
- **CreatePatch** derives Insert/Delete operations from the piece list relative to the original.
- **SaveAs** writes the result via a piece walk to a temporary file, optionally keeps a `.bak`, replaces the original atomically, reopens the new file as the original, and resets to a single original piece.
- `ExportPieces`/`ExportMemoryBuffer`/`GetPiecesSnapshot` support session persistence and piece-level undo.

Opening a file loads a `THexDocument` rather than the plain read-only file source, so large files are fully editable. The control's byte-based undo/redo runs unchanged on top of it; the piece-table only makes the underlying edits efficient.

## Event model

`OnSelectionChange`, `OnModifiedChange`, `OnUndoRedoStateChange`, `OnEditModeChange`, `OnSearchChange`, `OnBookmarksChange`, `OnDataSourceChange` (all `TNotifyEvent`) and `OnByteTooltip` (`var Text`, `var Cancel`) fire at every edit, selection, mode, search and load point. Additional control API: `GotoOffset`, `SelectRange`, `ReadAllBytes`, `GetModifiedCount`, `CursorPosition`, `InsertMode`, `ActiveEditArea`.

## Known limitations

- No horizontal-only custom scrollbar skinning beyond the themed `THexScrollBar` already in place.
- `TThemedHexInspector` and `TThemedHexBookmarkList` are UI controls only; they hold no independent business logic beyond what `THexDataInspector` and `THexBookmarkManager` already provide.

## Component registration (package/)

- `NimbusForms.HexEditor.Reg.pas` - `Register` calls `RegisterComponents('NimbusForms', [TThemedHexEditor])`; `TThemedHexInspector` and `TThemedHexBookmarkList` are registered in the same group.
- `NimbusFormsHexEditor.dpk` - design package source containing all Theming, NativePattern, HexEditor and registration units; requires rtl/vcl.

**Installation:** In RAD Studio, `File > Open` the `NimbusFormsHexEditor.dpk`, then `Build` and `Install`. The IDE generates the matching `.dproj` for your Delphi version. `TThemedHexEditor` then appears in the "NimbusForms" palette group. A hand-written `.dproj` is intentionally not provided, since a template-based package `.dproj` can corrupt the IDE's project options; opening the `.dpk` through the IDE is the reliable path.

## Tests

### test/HexRenderTest.dpr

GUI test: a paint-based `TCustomControl` renders 512 bytes of sample data (including CR/LF, Tab, Space, Null, control bytes), with selection, bookmark, cursor and hover. A dropdown switches all theming presets live, exercising the full pipeline: Measure -> Header -> Rows (gutter/cells/caret/bookmark glyph/ASCII) -> border, and the palette-to-HexTheme derivation.

Compile via IDE (open the `.dpr`) or:

```
cd test
dcc64 -B HexRenderTest.dpr
```

Theming units are referenced relatively from `..\..\NimbusForms.Theming\src`; both directories must be adjacent.

### test/HexEditorTest.dpr

Full integration test: `TThemedHexEditor` client-aligned, 4096 sample bytes, an "Open File..." button for real files, and a preset dropdown that themes the form and editor together via the `ThemeManager`. Exercises scrolling, clicking, selecting, keyboard input, search (plain, masked, DSL), clipboard, the data inspector, bookmarks, tooltips, find/replace, and export/patch/session round trips interactively.

# Financial business chart

`TThemedFinancialBusinessChart` in `src/NimbusForms.Controls.FinancialBusinessChart.pas`
provides a dedicated financial workspace alongside the existing `TThemedFinancialChart`.
The implementation follows the local C# financial chart's models, indicator calculations,
palette presets and panel behavior. Both chart demos include the `Financial business` tab.

```pascal
Chart := TThemedFinancialBusinessChart.Create(Self);
Chart.Parent := Self;
Chart.Align := alClient;
Chart.Symbol := 'NIMBUS';
Chart.ThemePreset := nftpTradingBlue;
Chart.ShowDashboardPanels := True;
Imported := Chart.LoadCsv('prices.csv');
try
  Caption := IntToStr(Imported.ImportedRows);
finally
  Imported.Free;
end;
```

Import `NimbusForms.Charts.Financial.Palette` for the preset enum and
`NimbusForms.Charts.Financial.Data` for `TNimbusFinancialDataImportResult`.

| Surface | Behavior |
| --- | --- |
| `Candles`, `ReplaceCandles` | Owned OHLCV collection, `Time` as `TDateTime`; replacement validates every candle before assignment |
| `PriceMode` | Candlestick, OHLC, line or area |
| `Panels` | Price, volume, RSI, MACD, stochastic and ATR; collapse, close, pin, reorder, resize, settings and scale configuration |
| `Indicators` | Additional configured indicators or custom full-history value arrays; built-in period lists remain available directly on the control |
| `SidePanels` | Details, watchlist, alerts, top volumes and transaction metrics; custom items and miniature charts; stacked or column layout; Nimbus scrollbars |
| `Viewport`, `RangeSelector` | Index-based pan/zoom, anchored wheel zoom, date ranges and configurable range buttons |
| `Markers`, `Annotations` | Event markers and horizontal/vertical lines, trends, rectangles, ranges, labels, arrows and channels; unlocked annotations can be dragged |
| `ThemeMode`, `ThemePreset`, `FinancialPalette` | Application theme, light/dark, or independent custom colors; nine C# preset palettes |
| `DataSource`, `CsvImportOptions` | VCL dataset binding or CSV import with quoting, configurable columns/delimiter/decimal separator, duplicate policy and error reporting |
| `SavePanelLayout`, `SavePanelUserProfile` | Versioned Delphi JSON layout/profile strings; invalid input is parsed in a temporary workspace before assignment |
| `ExportPng`, `ExportSvg`, `CopyImageToClipboard` | Shared financial renderer; custom financial colors are retained |
| `SaveVisibleDataCsv`, `SaveIndicatorsCsv` | Invariant CSV for the current viewport; indicator warmup values remain empty |
| `AccessibilityOptions` | Keyboard candle selection, accessible descriptions, native name-change notification and optional system high-contrast palette |

`ThemePreset` selects Custom mode. Edit `FinancialPalette` in Custom mode to retain
independent financial colors across application theme changes. Presets are Nimbus Dark,
Nimbus Light, Trading Dark, Trading Blue, Terminal Black, Office Blue, Nord, Dracula and
High Contrast. The older general chart appearance presets are separate.

SMA, EMA, Bollinger, RSI, MACD, stochastic, ATR and VWAP use the complete ordered candle
history. Zooming changes the viewport without reseeding indicators. EMA starts with an
SMA seed; RSI and ATR use Wilder smoothing. Bollinger uses population deviation,
stochastic applies separate K/D smoothing, and VWAP optionally resets by calendar date.
Warmup samples are NaN and are excluded from drawing.

CSV requires Date/Open/High/Low/Close; Volume is optional and defaults to zero. Date input
accepts ISO, compact numeric, German dotted and US slash formats. Dataset import requires
an active bidirectional dataset and restores its bookmark. Import result objects belong
to the caller; `OnDataLoaded` receives a borrowed result. Collections and settings returned
by control properties belong to the control. Transaction side-panel items are calculated
display metrics and do not submit orders.

Wheel zooms around the pointer, Shift+wheel pans, dragging pans, and Ctrl+drag selects a
candle range. Panel headers support drag reorder and a context menu. The settings dialog
uses Nimbus editors and commits its temporary values only on Apply. Layout presets retain
custom panels. Profile files use Delphi JSON rather than the C# storage format; automatic
profile persistence is disabled by default.

Drag the separators between expanded chart panels to resize them. Starting a drag
captures the current panel heights. Growing the upper panel consumes space from the
following resizable panels in order, respecting their minimum heights; shrinking it
gives space to the first eligible panel below. Collapsed panels and panels with
`AllowResize = False` are excluded. Insufficient space at the configured minimum heights limits further resizing.
Side panels have width splitters and, in stacked mode, separators for their heights.
Resize cursors identify these boundaries. Pinned chart panels cannot be closed.

Header buttons use their full layout rectangles for hit testing. Normal mouse-button
release retains the pending action until it is dispatched; losing capture to another
window cancels it. Hover updates retain existing scrollbar visibility and scroll position
when the content still overflows. Indicator warmup values occupy stable rows in Details.
Scrolling clips rows to the content area below the caption; partially visible text keeps
its original position and is cut at the viewport edge. On-screen painting excludes child
scrollbar windows. Wheel and thumb scrolling update only the affected panel content.
The shared canvas provides `INimbusRenderClipExclusion` as an optional capability;
the existing `INimbusRenderCanvas` interface is unchanged.

Numerical, import, profile, viewport and export regression sources are in
`tests/NimbusFinancialChecks.pas`, included by `tests/NimbusChartsTests.pas`.

## Panel and row events

Every side panel (Details, Alerts, Transactions, Watchlist, Top volumes or a custom
panel) exposes its own row handlers. Equivalent global handlers are published on
the chart. `Sender` is the chart in both cases.

| Global chart event | Per-side-panel event | Trigger |
| --- | --- | --- |
| `OnRowClicked` | `OnRowClicked` | Left click, keyboard activation or `ActivateSidePanelItem` |
| `OnRowDoubleClicked` | `OnRowDoubleClicked` | Mouse double click, with normal Windows click sequencing |
| `OnRowHovered` | `OnRowHovered` | Once when entering a different visible row |
| `OnRowContextMenu` | `OnRowContextMenu` | Right click, Shift+F10 or the menu key |
| `OnPanelAction` | `OnAction` | Header click, collapse/expand, pin/unpin, resize or scroll |

Main chart panels also expose `OnAction`; their notifications include close,
move and settings requests. `TNimbusFinancialPanelActionInfo` supplies the action,
panel key/index/title, tag, pin state and relevant dimensions/scroll offset.
`IsSidePanel` distinguishes side panels from the central chart panels. These are
control action notifications, not notifications for every raw property assignment.
Existing main-panel event handlers remain available.

`TNimbusFinancialRowEventInfo` contains panel key/title/index/kind, row key/kind,
text/value/secondary value, numeric value, change, tag and copied mini-chart values.
`RowIndex` is the zero-based collection index, including hidden rows and separators;
`VisibleRowIndex` counts only visible non-separator rows. The snapshot also includes
mouse button/modifiers/client location, input origin, symbol/exchange and optional
candle index/time/OHLCV from the ordered visible candle history. Check `HasCandle` before using candle values. Custom rows
can set `CandleIndex`; the default is -1. Non-mouse activation uses location (-1,-1).

```pascal
Chart.OnRowClicked := AnyRowClicked;
Chart.SidePanels.FindByKey('watchlist').OnRowClicked := WatchlistRowClicked;
Chart.Panels.FindByKey('rsi').OnAction := RsiAction;
Chart.ActivateSidePanelItem('transactions', 'buy');
```

Row handlers have signature
`procedure(Sender: TObject; const Info: TNimbusFinancialRowEventInfo) of object`.
Panel action handlers use `TNimbusFinancialPanelActionInfo` instead. Activation is
an event notification; it does not submit transactions or perform application actions.
Use stable, unique panel and row keys when connecting handlers or saving profiles.
Existing panel handlers are retained by key during profile reload; callbacks themselves
are not serialized to JSON.

Row data is copied before callbacks: a local handler may rebuild the collection and
the global handler still receives the original row snapshot. Dispatch order is local
row handler, global row handler, then the compatible legacy `OnSidePanelItemClicked`
for clicks. The legacy hit indices can become stale after a callback rebuilds rows;
prefer the new snapshot events. Existing main-panel handlers run before their new
local/global action handlers.

Clicking a row establishes row focus. Up/Down and Home/End navigate visible rows,
Enter/Space activate the focused row, and keyboard navigation scrolls it into view.
Clicking outside the rows returns keyboard navigation to the chart. Separators and
hidden rows do not activate. The Financial business demo displays row/action details
and counts clicks through a separate Watchlist handler.

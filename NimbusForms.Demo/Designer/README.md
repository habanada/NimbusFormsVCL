# NimbusForms designer-first demos

Two text-DFM demonstration projects complement the programmatic NimbusForms demos. The forms use NimbusForms visual controls. Their only native VCL visual infrastructure is `TForm` and the mandatory `TTabSheet` page class used by `TThemedTabControl`. The CSV/JSON/HTML save dialog is a standard operating-system dialog created on demand, not a design-time form component.

## Open the projects in Delphi 12

Open `GridWorkbench/NimbusGridWorkbench.dproj` or `ControlsGallery/NimbusControlsGallery.dproj` from the `NimbusForms.Demo/Designer` directory. The `.pas` and `.dfm` with matching stems must remain in the same directory. `TThemedTabControl`, `TThemedPanel`, `TThemedGroupBox`, `TThemedLabel`, buttons, inputs and the grid are the registered NimbusForms components found in `NimbusForms.Controls/packages/NimbusForms.Design.Register.pas`.

**The NimbusForms design-time package must be built and installed in the Delphi IDE first.** The `NimbusForms.Controls/packages/README.md` describes installation. An older or differently built package can lead to unavailable components or properties even if the text DFM is structurally correct.

## What the demo forms contain

| Project | Tabs and designer-visible controls |
| --- | --- |
| GridWorkbench | Five `TTabSheet` pages beneath `TThemedTabControl`, each containing its own `TThemedGridView`. Four focused labs cover editing, grouping, layout and export. The fifth tab is a 200,000-row visual showcase with embedded master/detail grids, SVG avatars, sparkline icons, native progress-bar cells, colored workflow badges, ratings, color swatches, conditional formatting and column bands. |
| ControlsGallery | Three `TTabSheet` pages beneath `TThemedTabControl`, containing `TThemedGroupBox`, `TThemedLabel`, `TThemedButton`, `TThemedCheckBox`, `TThemedToggleBox`, `TThemedTextBox`, `TThemedComboBox`, `TThemedNumericUpDown`, `TThemedDatePicker`, `TThemedRatingControl` and `TThemedProgressBar`. |

The page containers, child controls, sizes, alignment and events are all present in the text DFMs. Grid rows and columns are initialized at runtime because they are runtime grid model objects rather than streamed controls. Pages are **not** created dynamically or reparented. Tabs cannot be closed or reordered, preventing loss of demo pages at runtime.

## DFM and designer rules

`TThemedTabControl` derives from `TPageControl`, so its children must be ordinary Delphi `TTabSheet` objects. No `TThemedTabSheet` exists in this project. Store pages directly within the `TThemedTabControl` DFM object and place components inside the pages. Do **not** store `PageControl = ...` in a `TTabSheet`: it is not a published streamable property. `ActivePage` references the first page in each DFM. For borderless NimbusForms panels use `ShowBorder = False`, not the VCL-only `BevelOuter` property.

### Grid Workbench: 200K / Visual Showcase

Select the `200K / Visual Showcase` tab to generate exactly 200,000 synthetic in-memory master records using compact row objects. The grid uses its real `SetRows` list adapter and actual NimbusForms renderers for progress, badge, rating, currency and color-swatch cells. The avatar and compact trend icons use eight reusable SVG variants through `OnCellVisualNeeded`. The first parent row is expanded automatically; use its row-header expander or the `Expand master-detail`/`Collapse detail` buttons. Each expanded record loads four order-line objects on demand via `OnMasterDetailDataNeeded` and displays them in the Grid control's built-in embedded child grid. Detail data is retained for the form lifetime, so neither visible child grids nor cached controllers hold dangling source objects. Column-bands, optional frozen identity columns and vivid conditional color rules complete the showcase.

The 200K dataset is initialized only on first activation of its tab to keep initial demo startup fast. The toolbar permits reloading, expanding/collapsing, freezing, highlighting and toggling SVG artwork. The hero progress indicator is a simulated dashboard KPI, not an import-progress or real-time measurement.

**Performance note:** 200,000 rows are materialized in memory. Initial grid row-view construction and expanding detail may have a noticeable pause depending on machine performance. It is a functional large-dataset stress showcase, not a benchmark result.

Run `python NimbusForms.Demo/Designer/verify_designer_demos.py` from the project root. It checks the component registry, classes, parent nesting, DFM/Pascal field compatibility, page settings, project references and event names. This static check does not replace Delphi compilation, IDE designer checks or runtime testing.

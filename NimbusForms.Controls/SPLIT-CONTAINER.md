# Split container DFM support

`TThemedSplitContainer` owns two `TPanel` hosts exposed as `Panel1` and `Panel2`.
Place application controls inside these hosts. Their size is controlled by
`Orientation`, `SplitterDistance`, `SplitterWidth`, and the panel minimum sizes.

The hosts and their child controls are streamed as nested component objects.
Older designer output can also contain dotted properties such as `Panel1.Left`.
These properties remain readable; new output does not write them a second time.
When both formats are present, the explicit child hosts supply the panel contents.

After updating this unit, rebuild the NimbusForms runtime and design-time packages
and rebuild applications that link the sources directly. An already loaded IDE
package keeps its previous component RTTI until the updated package is loaded.

`tests/NimbusSplitContainerStreamingChecks.pas` is called by
`tests/NimbusSplitterTests.pas`. It covers legacy properties, owned hosts, mixed
input, nested controls, duplicate-host cleanup, and write/read round trips.

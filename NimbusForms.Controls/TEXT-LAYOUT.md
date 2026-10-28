# Text layout

`TThemedLabel.AutoSize` uses the same GDI+ font metrics as its renderer. Caption,
font, accelerator and word-wrap changes use the VCL label sizing lifecycle.
For wrapped labels, set the intended width before enabling `AutoSize`.
Constraints and parent layout can still limit the available text area.

`INimbusRenderCanvas.MeasureText` measures without ellipsis, even when
`ntfEndEllipsis` is supplied. The width limit and wrapping flags still apply.
`DrawText` applies ellipsis when requested by the caller. This contract is shared
by controls, menus, tooltips and chart renderers using the GDI+ canvas.

Popup menus reserve bold caption width for default items and separate shortcut
space in both text directions. Before opening, the themed background is assigned
to the current native menu handle and its existing submenus, including the first
opening. Tag input measures text with its renderer and reserves the same
close-button space used for painting and hit testing.

Run the text layout regression executable from a Delphi 12 command-line setup:

```powershell
./NimbusForms.Controls/tests/build_text_layout.ps1
./NimbusForms.Controls/tests/build_text_layout.ps1 -Platform Win64
```

The regression source is `tests/NimbusTextLayoutTests.pas`. It checks measured
text against rendered pixels, constrained ellipsis, label resizing, wrapped
captions and default-menu font metrics at 96, 120, 144 and 192 PPI.

`tests/build_popup_menu.ps1` builds and runs `tests/NimbusPopupMenuTests.pas`.
It checks that the first and repeated openings have a valid themed background,
that submenus inherit it and that temporary drawing hooks are restored after
cancellation. The test cancels in `OnPopup` before displaying a native menu.

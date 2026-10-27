# Chart appearance

For the dedicated OHLCV workspace, C# financial palettes, technical indicators,
panel profiles and financial demo, see [Financial business chart](FINANCIAL.md).

## Maps and heatmap palettes

World maps match point labels against country codes or names. Country maps use
the region codes or names returned by `NimbusCountryMapShapes` (including German
states). Explicit point colors remain exact in Theme, Custom and Adaptive custom
modes. Regions without visible data points use a pale theme fill; set
`Model.Options.MapEmptyColor` to override it.

```pascal
Chart.ChartType := nctChoroplethMap;
Chart.Model.Options.MapColorMode := ncmCategorical;
Series := Chart.Model.AddSeries('Highlighted countries');
Series.Points.Add(0, 12, 'DEU').Color := clRed;
Series.Points.Add(1, 24, 'USA').Color := clBlue;
```

`ncmCategorical` assigns uncolored data points successive colors from
`Model.Palette.Colors`, independently of application theme blending. The default
`ncmValueGradient` retains the theme-based value scale. Explicit point colors take
priority in both modes. To highlight only selected regions, add data points only
for those regions; hover/keyboard selection remains a separate interaction.

Raster and business-calendar heatmaps share `Model.HeatmapColorPreset`:

| Preset | Colors |
| --- | --- |
| `nhcpTheme` | Existing theme-based behavior (default) |
| `nhcpCustom` | Exact `HeatmapLowColor` to `HeatmapHighColor` gradient |
| `nhcpGitHubGreen` | Five discrete light GitHub activity colors |
| `nhcpGitHubDark` | Five discrete dark GitHub activity colors |
| `nhcpReds` | Near-white through orange-red to dark red |
| `nhcpThermal` | Blue through cyan/yellow/orange to red |

Fixed presets retain their colors across application themes. `HeatmapEmptyColor`
overrides the no-data fill; explicit point colors override a populated cell.
Calendar legend swatches follow the selected preset. Raster values use the existing
automatic or manual heatmap range; calendar activity is normalized against its
maximum. Palette selectors are available in the Charts and Remaining charts demos.

`TThemedChart` keeps the existing `ColorMode` choices:

| Mode | Behavior |
| --- | --- |
| `nccTheme` (default) | Uses the application theme. |
| `nccCustom` | Uses `Model.Palette` without blending or replacing its colors. |
| `nccAdaptiveCustom` | Blends a temporary copy toward the application theme using `ThemeInfluence` (default 12 percent). |

Use `ApplyAppearance` to start a complete custom look:

| Appearance | Palette and effects |
| --- | --- |
| `ncaVsIdeLight` | Original C# light chart palette, without glow. |
| `ncaVsIdeDark` | Original C# dark chart palette with VS IDE series colors, without glow. |
| `ncaGlowing` | Additional navy palette with cyan, violet and mint series colors and glow. Inspired by the C# renderer effects. |

```pascal
Chart.ApplyAppearance(ncaVsIdeDark);
Chart.Model.Palette.BackColor := RGB(24, 24, 28);
Chart.Model.Palette.PlotBackColor := RGB(30, 30, 36);
Chart.Model.Palette.Colors := [clAqua, clFuchsia, clLime];
Chart.ShowGlow := True;
```

The example requires `Winapi.Windows`, `Vcl.Graphics`, `NimbusForms.Charts.Types`
and `NimbusForms.Controls.Chart`. `ApplyAppearance` selects `nccCustom` and sets
`ShowGlow`; it preserves data, chart type, options and interaction settings.
Later application theme changes leave the custom palette intact. To follow the
application theme again, set `ColorMode := nccTheme` and, if desired,
`ShowGlow := False`. The custom palette remains available when returning to
`nccCustom`.

`ShowGlow` defaults to `False`. Glow contours for data shapes use the same
primitive pipeline in on-screen drawing, bitmap/PNG export and SVG export.
They do not enlarge hit areas or change selection. KPI and business highlight
contrast uses the chart background, including when it differs from the app theme.

Both the combined demo and `NimbusForms.Demo/Projects/NimbusCharts.dpr` include
the `C# chart looks` tab. It compares the three appearances using the same line,
column and radial-goal data. In the existing `Charts` tab, the appearance list
initializes a custom palette; the color mode, series palette, individual series
colors, chart background, plot background and glow remain editable. Selecting a
new appearance resets its palette and glow settings. Switching chart types or
updating data preserves the chosen custom look.

The comparison gallery uses NimbusForms horizontal and vertical scrollbars.
Mouse wheel scrolls vertically; Shift+wheel scrolls horizontally. Chart zoom is
disabled in this comparison so the wheel remains available for scrolling.

Mini/micro charts and dashboard widgets retain their existing appearance APIs.
These presets belong to `TThemedChart` and its descendants.

Appearance regressions are in `tests/NimbusChartsTests.pas`: app-theme changes,
custom backgrounds, SVG glow, DPI hit geometry and construction without an HWND.

## Mathematical functions

Add `NimbusForms.Charts.Functions` to `uses` to enable the model helper:

```pascal
Options := TNimbusChartFunctionOptions.Create;
try
  Options.MinimumX := -2 * Pi;
  Options.MaximumX := 2 * Pi;
  Options.DetectRoots := True;
  Options.AddRootAnnotations := True;
  Options.AddDerivativeSeries := True;
  Options.AddIntegralSeries := True;
  PlotResult := Chart.Model.AddFunctionSeries('sin(x)',
    TNimbusChartFunctions.Sine(1, 1, 0, 0), Options);
  try
    RootCount := Length(PlotResult.Roots);
  finally
    PlotResult.Free;
  end;
finally
  Options.Free;
end;
```

Declare `Options: TNimbusChartFunctionOptions`,
`PlotResult: TNimbusChartFunctionResult`, and `RootCount: Integer`.
The plotter adds ordinary line series to the existing model; it does not clear
data, change chart type, alter axis ranges or select a theme. Use a Cartesian
chart such as `nctLine`. PNG/SVG export, selection, zoom and downsampling use
the existing chart implementation.

| Factory | Parameters, in order |
| --- | --- |
| `Sine`, `Cosine`, `Tangent` | Amplitude, angular frequency, phase, vertical offset |
| `Exponential` | Amplitude, rate, vertical offset |
| `Logarithm` | Logarithmic base, horizontal offset, vertical offset |
| `Power` | Coefficient, exponent, vertical offset |
| `SquareRoot` | Coefficient, horizontal offset, vertical offset |
| `Polynomial` | Coefficient array, constant term first; evaluated by Horner's method |
| `Gaussian` | Amplitude, mean, standard deviation, vertical offset |
| `DampedOscillation` | Amplitude, damping, angular frequency, phase, vertical offset |

Custom callbacks use `TNimbusChartFunction`, an anonymous function from Double
to Double. `AddParametricSeries` takes separate x(t) and y(t) callbacks and
`TNimbusChartParametricOptions`; point order follows t, including loops and
reversals. Both APIs also exist as static methods on
`TNimbusChartFunctionPlotter` if another class helper is active.

Defaults match the C# function layer: x in [-10, 10], 512 initial samples,
adaptive sampling, relative midpoint tolerance 0.0025, depth 12, maximum absolute
coordinate 1000000, discontinuity threshold 40 and reference axes at zero.
Parametric sampling defaults to 1024 uniform samples over [0, 2*pi].
`AngleUnit = ncauDegrees` converts callback input to radians while retaining x
coordinates in degrees. It applies to the entire callback, as in C#.

NaN, infinity, out-of-limit coordinates and configured discontinuities split
the output into independent series. Set appropriate limits for functions with
poles; the tangent demo uses `MaximumAbsoluteY = 20` and
`DiscontinuityThreshold = 6`. Mathematical domain/overflow exceptions become
gaps; other callback exceptions propagate. Sampling is limited to 1048576 points
per call and raises an exception if that limit is exceeded.

Roots use sampled sign changes with linear interpolation and include sampled
zero endpoints. Extrema use sampled slope reversals. These are numerical
estimates, not symbolic solvers or a guarantee of finding every root/extremum.
Adaptive midpoint sampling can miss features between initial samples; increase
`SampleCount` for oscillatory functions.

Derivatives use centered neighboring samples by default. A positive
`DerivativeStep` instead evaluates x +/- step; degree-mode derivatives are with
respect to degrees. Integration uses the trapezoidal rule and
`IntegralInitialValue`. Neither analysis connects across gaps; after a gap the
integral retains the accumulated value without integrating the missing interval.
This also prevents root/extrema analysis from crossing a configured break.

Free options and results yourself. The model owns the created series and
annotations. Result arrays are snapshots; their series references remain valid
only while those model series exist. `Series` contains the base function's
segments; `DerivativeSeries` and `IntegralSeries` identify the first generated
analysis segment. All analysis segments are stored in the model.

Both demos include the `Mathematical functions` tab with six C# examples:
trigonometric analysis, tangent, technical functions, a cubic polynomial, growth
functions and a 3:2 Lissajous curve. Controls select sampling, analysis overlays
and appearance. Numerical regressions are in
`tests/NimbusChartFunctionChecks.pas`, called by `NimbusChartsTests.pas`.

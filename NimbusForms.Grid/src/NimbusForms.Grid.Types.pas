unit NimbusForms.Grid.Types;

{$SCOPEDENUMS ON}

interface

type
  TThemedGridAutoSizeMode = (None, Header, VisibleCells, DisplayedCells, AllCells, Fill, ContentAndHeader);

  TThemedGridRowHeightMode = (Fixed, AutoVisibleCells, AutoAllCells, Custom);

  TThemedGridSelectionMode = (None, Cell, CellRange, Row, RowRange, Column, ColumnRange, Mixed);

  TThemedGridCellRenderKind = (Auto, Text, Number, Currency, Percent, Date, Time, DateTime,
    BooleanText, CheckBox, Toggle, Image, Icon, Badge, ProgressBar, Slider, Rating, Link, Button,
    ColorSwatch, ComboText, MultiLineText, Command, Custom);

  TThemedGridEditorKind = (None, TextBox, Numeric, Slider, ComboBox, DatePicker, TimePicker,
    CheckBox, ToggleSwitch, ColorPicker, ImagePicker, Memo, Button, Rating, Lookup, Custom);

  TThemedGridNullDisplayMode = (Empty, NullText, Dash, Placeholder, Custom);

  TThemedGridColumnFixedStyle = (None, Left, Right);

  TThemedGridSummaryType = (None, Count, Sum, Min, Max, Average, Custom);

  TThemedGridFormatConditionOperator = (Equals, NotEquals, Contains, NotContains, StartsWith,
    EndsWith, GreaterThan, GreaterOrEqual, LessThan, LessOrEqual, Between, IsNull, IsNotNull,
    IsEmpty, IsNotEmpty, &In, NotIn, Expression, Custom);

  TThemedGridHitArea = (None, Cell, ColumnHeader, SummaryFooter, RowHeader, GridLine, ResizeGrip,
    FilterButton, SortGlyph, SearchPanel, GroupRow, DetailRow, TreeGlyph, PinnedRow, MergedCell,
    Editor, VerticalScrollBar, HorizontalScrollBar, ScrollCorner, DetailExpander);

  TThemedGridSortDirection = (None, Ascending, Descending);

  TThemedGridSearchPanelMode = (Hidden, InlineTop, InlineBottom, Overlay, ExternalBound);

  TThemedGridSearchMode = (Contains, StartsWith, Exact, TokenContains, Fuzzy, Custom);

  TThemedGridCellStateFlag = (Current, Selected, Hovered, Focused, ReadOnly, Editing, Error,
    SearchMatch, Pressed);
  TThemedGridCellState = set of TThemedGridCellStateFlag;

  TThemedGridFilterMode = (Auto, Text, Number, Date, Boolean, Enum, DistinctValues, Custom);

  TThemedGridFilterOperator = (None, Equals, NotEquals, Contains, NotContains, StartsWith, EndsWith,
    GreaterThan, GreaterOrEqual, LessThan, LessOrEqual, Between, IsNull, IsNotNull, IsEmpty, IsNotEmpty,
    &In, NotIn, Today, Yesterday, ThisWeek, ThisMonth, ThisYear, Custom);

  TThemedGridViewRowKind = (Data, GroupHeader, GroupFooter, Detail, TreeNode);

  TThemedGridDetailExpandTrigger = (RowHeaderButton, DoubleClick, Keyboard);
  TThemedGridDetailExpandTriggers = set of TThemedGridDetailExpandTrigger;

  TThemedGridDetailDoubleClickPriority = (Detail, Editor);

  TThemedGridEmbeddedDetailGridRetentionMode = (ParkOnCollapse, DisposeOnCollapse);

  TThemedGridContentAlignment = (TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter,
    MiddleRight, BottomLeft, BottomCenter, BottomRight);

const
  ThemedGridDefaultDetailExpandTriggers: TThemedGridDetailExpandTriggers =
    [TThemedGridDetailExpandTrigger.RowHeaderButton, TThemedGridDetailExpandTrigger.DoubleClick,
     TThemedGridDetailExpandTrigger.Keyboard];

implementation

end.

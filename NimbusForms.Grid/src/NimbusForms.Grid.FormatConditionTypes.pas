unit NimbusForms.Grid.FormatConditionTypes;

{$SCOPEDENUMS ON}

interface

type
  TThemedGridFormatConditionValueType = (Auto, &String, &Decimal, Integer, Boolean, DateTime, TimeSpan, Guid, Color, Enum);

  TThemedGridFormatConditionScope = (Cell, Row, TargetColumn);

implementation

end.
